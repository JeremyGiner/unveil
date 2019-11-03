package unveil;
import sweet.functor.IFunction;
import unveil.tool.VPathAccessor;

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

	public function new() {
		
	}
	
	public function compile( s :String ) {
		
		var lStack = new List<BlockHeader>();
		lStack.push( { template: new CompositeTemplate(), end_tokken: null} );
		var oCurrentTemplate = this;
		
		// Parse
		var a = s.split('::');
		for ( i in 0...a.length ) {
			
			var s = a[i];
			
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
				cast( lStack.first(), IfTemplate).setElseBlock();
			}
			
			// Compile instruction
			var oBlockHeader = compileInstruction( s );
			
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
			throw 'parsing failed';
		
		return lStack.first().template;
	}
	
	public function compileInstruction( s :String) :BlockHeader {
		
		s = s.replace( ' ', '');
		
		if ( s.startsWith('if(') && s.endsWith(')')  ) {
			var s = s.substring(3, s.length - 1);
			return {
				end_tokken: _ENDIF,
				template: new IfTemplate( 
					cast compileExpression( s )
				),
			};
		}
		
		if ( s.startsWith('for(') && s.endsWith(')')  ) {
			var s = s.substring(4, s.length - 1);
			var a = s.split('in');
			// TODO  validate a
			return {
				end_tokken: _ENDFOR,
				template: new ForTemplate( 
					cast compileExpression( a[1] ),
					a[0]
				),
			};
		}
		
		
		return null;
		// TODO : handle else
		
		//https://github.com/HaxeFoundation/haxe/blob/development/std/haxe/Template.hx
		
		// parse exp operator arthmetic
		// re-arange sequence into arbo
			
		
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
		
		return new VPathAccessor(s);
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