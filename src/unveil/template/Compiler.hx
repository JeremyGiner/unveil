package unveil.template;
import sweet.functor.IFunction;
import unveil.View;
import unveil.tool.VPathAccessor;
import unveil.template.ITemplate;

using StringTools;

typedef BlockHeader = {
	var template :CompositeTemplate;
	var end_tokken :Null<String>;
}

/**
 * ...
 * @author 
 */
class Compiler {
	
	static var _ELSE = 'else';
	static var _ENDIF = 'endif';
	static var _ENDFOR = 'endfor';
	
	static var _REGEXP_INTEGER = ~/^\d+$/;
	static var _REGEXP_FLOAT = ~/^[\d.]+$/;
	
	static var _aUnaryOperator = [
        new UnaryOperator('!',function(a :Bool){ return !a;}),
        new UnaryOperator('-',function(a :Dynamic){ return -a;}),
    ];
	static var _aOperator = [
        new Operator('%',function(a :Dynamic,b :Dynamic){ return a%b;}),
        new Operator('*',function(a :Dynamic,b :Dynamic){ return a*b;}),
        new Operator('/',function(a :Dynamic,b :Dynamic){ return a/b;}),
        new Operator('+',function(a :Dynamic,b :Dynamic){ return a+b;}),
        new Operator('-',function(a :Dynamic,b :Dynamic){ return a-b;}),
        new Operator('==',function(a :Dynamic,b :Dynamic){ return a==b;}),
        new Operator('!=',function(a :Dynamic,b :Dynamic){ return a!=b;}),
        new Operator('<',function(a :Dynamic,b :Dynamic){ return a<b;}),
        new Operator('<=',function(a :Dynamic,b :Dynamic){ return a<=b;}),
        new Operator('>',function(a :Dynamic,b :Dynamic){ return a>b;}),
        new Operator('>=',function(a :Dynamic,b :Dynamic){ return a>=b;}),
        new Operator('...',function(a :Dynamic,b :Dynamic){ return a...b;}),
        new Operator('&&',function(a :Bool,b :Bool){ return a&&b;}),
        new Operator('||',function(a :Bool,b :Bool){ return a||b;}),
    ];

	var _oView :View;
	
	public function new( oView :View = null ) {
		_oView = oView;
	}
	
	public function compile( s :String ) {
		
		var lStack = new List<BlockHeader>();
		lStack.push( { template: new CompositeTemplate(), end_tokken: null} );
		var oCurrentTemplate = this;
		
		// Parse
		var a = s.split('::');
		for ( i in 0...a.length ) {
			
			var s = a[i].trim();
			
			// Filter empty string
			if ( s == '' )
				continue;
			
			// Case : pur string
			if ( i % 2 == 0 ) {
				lStack.first().template.addPart( new TemplateString( s ) );
				continue;
			}
			
			// Case : end block tokken
			if ( s!= null && s == lStack.first().end_tokken ) {
				lStack.pop();
				continue;
			}
			
			// Case : else tokken
			if ( s == 'else' ) {
				try {
				cast( lStack.first().template, IfTemplate).setElseBlock();
				continue;
				} catch ( e :Dynamic  ) {
					throw 'else tokken must follow if (following ' + Type.getClassName(Type.getClass(lStack.first().template)) + ')';
				}
			}
			
			// Compile instruction
			var oBlockHeader = compileInstruction( s );
			
			
			if ( s.startsWith('render(') && s.endsWith(')')  ) {
				var s = s.substring(7, s.length - 1);
				lStack.first().template.addPart( compileSubRender(s) );
				continue;
			}
			
			// Case : simple print var
			if ( oBlockHeader == null ) {
				lStack.first().template.addPart( compilePrintVar( s ) );
				continue;
			}
			
			// Link new template to parent
			lStack.first().template.addPart( oBlockHeader.template );
			
			// Case : block
			if ( oBlockHeader.end_tokken != null ) {
				lStack.push(oBlockHeader);
				continue;
			}
		}
		
		// TODO : explain
		if ( lStack.length != 1 )
			throw 'parsing failed, missing closing token '+lStack.first().end_tokken;
		
		return lStack.first().template;
	}
	
	public function compileInstruction( s :String) :BlockHeader {
		
		//s = s.replace( ' ', '');
		
		if ( s.startsWith('if ') ||  s.startsWith('if(')  ) {
			var s = s.substring(2 );
			return {
				end_tokken: _ENDIF,
				template: new IfTemplate( 
					cast compileExpression( s ) // TODO : compile bool expression only
				),
			};
		}
		
		if ( s.startsWith('for ') || s.startsWith('for(') ) {
			var s = s.substring( 3 ).trim();
			if ( s.startsWith('(') && s.endsWith(')') )
				s = s.substring( 1, s.length - 1 ).trim();
			var a = s.split(' in ');
			// TODO  validate a
			return {
				end_tokken: _ENDFOR,
				template: new ForTemplate( 
					cast compileExpression( a[1].trim() ),
					a[0].trim()
				),
			};
		}
		
		return null;
		// TODO : handle else
		
		//https://github.com/HaxeFoundation/haxe/blob/development/std/haxe/Template.hx
		
		// parse exp operator arthmetic
		// re-arange sequence into arbo
			
		
	}
	
	public function compileSubRender( s :String ) :ITemplate {
		var oTemplate = _oView.getTemplate(s.trim());
		if ( oTemplate == null )
			throw 'Missing template "' + s + '" for render instruction';
		return new SubRendererTemplate( oTemplate );
	}
	
	public function compilePrintVar( s :String ) :ITemplate {
		return new PrintVarTemplate( new VPathAccessor( s ) );
	}
	/*
	public function getOperatorPriority( s :String ) {
		
		switch( ) {
			
		}
		return 
	}
	*/	
	public function compileExpression( s :String ) :IFunction<Dynamic,Dynamic> {
		s = s.trim();
		// Case : const
		switch( s ) {
			case 'null' : return new Const( null ); //TODO : re-use same instance
		}
		
		if ( _REGEXP_INTEGER.match( s ) ) 
			return new Const( Std.parseInt(s) );
		if ( _REGEXP_FLOAT.match( s ) ) 
			return new Const( Std.parseFloat(s) );
		
		
		// 
		for ( oOperator in _aOperator ) {
			var a = s.split( oOperator.getTokken() );
			if ( a.length > 2 )
				throw 'not implemented yet';
			if ( a.length == 1 )
				continue;
			var aChild = a.map(function( s ) { return compileExpression(s); });
			return oOperator.createItem( aChild );
		}
		return new VPathAccessor(s);
	}
	
	
}

class Const implements IFunction<Dynamic,Dynamic> {
    
	var _o :Dynamic;
	
    public function new( o :Dynamic ) {
        _o = o;
    }
    
    public function apply( o :Dynamic ) {
        return _o;
    }
}


class TemplateString implements ITemplate {
	var _s :String;
	public function new( s :String ) {
		_s = s;
	}
	public function render( oContext :Dynamic, oBuffer :StringBuf = null  ) {
		oBuffer = oBuffer == null ? new StringBuf() : oBuffer;
		oBuffer.add( _s );
		return oBuffer;
	}
}
/*
class VPathAccessorProxy extends IFunction<Dynamic,Dynamic> {
	
	public function apply( oContext :Dynamic ) {
		return 
	}
}*/


interface IOperator {
    
    public function getTokken() :String;
	public function createItem( aChildren :Array<IFunction<Dynamic,Dynamic>> ) :IFunction<Dynamic,Dynamic>;
}

class UnaryOperator implements IOperator {
	var _s :String;
	var _fn :Dynamic->Dynamic;
	
    public function new( s :String, fn :Dynamic->Dynamic ) {
        _s = s;
    }
	public function getTokken() { return _s; };
	
	public function getCallback() {
		return _fn;
	}
	
	public function createItem( aChildren :Array<IFunction<Dynamic,Dynamic>> ) {
		return new UnaryOperatorItem( this, aChildren ); 
	};
}
class Operator implements IOperator {
	var _s :String;
	var _fn :Dynamic->Dynamic->Dynamic;
    public function new( s :String, fn :Dynamic->Dynamic->Dynamic ) {
        _s = s;
		_fn = fn;
    }
	public function getTokken() { return _s; };
	
	public function getCallback() {
		return _fn;
	}
	
	public function createItem( aChildren :Array<IFunction<Dynamic,Dynamic>> ) {
		return new OperatorItem( this, aChildren ); 
	};
}

class UnaryOperatorItem implements IFunction<Dynamic,Dynamic> {
	var _oOperator :UnaryOperator;
	var _aChildren :Array<IFunction<Dynamic,Dynamic>>;
	
	public function new( 
		oOperator :UnaryOperator, 
		aChildren :Array<IFunction<Dynamic,Dynamic>>
	) {
		_oOperator = oOperator;
		_aChildren = aChildren;// TODO : assert length
	}
	
	public function apply( o :Dynamic ) {
		var fn = _oOperator.getCallback();
		return fn( _aChildren[0].apply( o ) ); 
	};
}

class OperatorItem implements IFunction<Dynamic,Dynamic> {
	var _oOperator :Operator;
	var _aChildren :Array<IFunction<Dynamic,Dynamic>>;
	
	public function new( 
		oOperator :Operator, 
		aChildren :Array<IFunction<Dynamic,Dynamic>>
	) {
		_oOperator = oOperator;
		_aChildren = aChildren;// TODO : assert length
	}
	
	public function apply( o :Dynamic ) {
		var fn = _oOperator.getCallback();
		return fn( _aChildren[0].apply( o ), _aChildren[1].apply( o ) ); 
	};
}

//class Test {
//
   //
    //static function main() {
        //var s = 'text *( toto + titi )/ tutu';
        //s = s.replace(' ','');
        //s = s.replace('()','');
        //var mFirst = _aOperator.map(function(o :Operator) { return o.toString()[0];});
        //var sRegexp = _aOperator.map(function(o :Operator) { return o.toString();});
        //var ergexp = new RegExp('('+sRegexp.join('|')+')');
        //ergexp.
        //trace(s);
    //}
//}