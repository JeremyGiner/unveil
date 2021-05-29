package unveil.compiler;
import haxe.ds.StringMap;
import sweet.functor.IBiFunction;
import sweet.functor.builder.BuilderDefault;
import unveil.compiler.ExpressionCompiler.IExpression;

import sweet.functor.builder.FactoryDefault;
import unveil.compiler.ExpressionCompiler;
import unveil.template.Compiler;
import unveil.tool.StringStream;
import sweet.functor.IFunction;
import sweet.functor.builder.IBuilder;
import unveil.tool.VPathAccessor;

/**
 * ...
 * @author 
 */

 
typedef IExpression = IFunction<Dynamic,Dynamic>;
typedef IExpressionBuilder = IBuilder<Dynamic,Array<Dynamic>>;

interface IExpressionCompiler {
	public function apply( s :StringStream, aStopToken :Array<String> ) :IExpression;
}
class ExpressionCompiler implements IExpressionCompiler {
	
	//static var _REGEXP_INTEGER = ~/^\d+$/;
	//static var _REGEXP_FLOAT = ~/^[\d.]+$/;
	//static var _REGEXP_FLOAT = ~/^render *(\w+) *(with)? *({.*})?$/;
	
	static var _mUnaryOperator :StringMap<IExpressionBuilder> = [
        '!' => new BuilderDefault(Not),
        '-' => new BuilderDefault(Negative),
    ];
	static var _mOperator :StringMap<IExpressionBuilder> = [
		'%' => new BuilderDefault(Mod),
		'*' => new BuilderDefault(Mult),
		'/' => new BuilderDefault(Div),
        '+' => new BuilderDefault(Add),
        '-' => new BuilderDefault(Sub),
        '&&' => new BuilderDefault(And),
        '||' => new BuilderDefault(Or),
        '...' => new BuilderDefault(Iterate),
        '==' => new BuilderDefault(Equal),
        '!=' => new BuilderDefault(Diff),
        '<' => new BuilderDefault(Inferior),
        '<=' => new BuilderDefault(InferiorEqual),
        '>' => new BuilderDefault(Superior),
        '>=' => new BuilderDefault(SuperiorEqual),
    ];
	
	public function new() {
	}
	
	public function apply( s :StringStream, aStopToken :Array<String> ) :IExpression {
		var lScanned = new List<Dynamic>();
		
		// Scan
		while( true ) {
			s.ignoreWhitespace();
			
			// Stop token
			var bStop = false;
			for ( sToken in aStopToken )
				if ( s.startWith( sToken ) )
					bStop = true;
			if ( bStop )
				break;
			
			// Process operator
			var sTokenFound = null;
			for ( sToken in _mOperator.keys() ) {
				if ( s.startWith( sToken ) ) {
					sTokenFound = sToken;
					break;
				}				
			}
			if ( sTokenFound != null ) {
				lScanned.push( _mOperator.get( sTokenFound ) );
				s.read( sTokenFound.length );
				continue;
			}
			
			// Process unary operator
			var sTokenFound = null;
			for ( sToken in _mUnaryOperator.keys() ) {
				if ( ! s.startWith( sToken ) )
					continue;
				sTokenFound = sToken;
				break;
				
			}
			if ( sTokenFound != null ) {
				lScanned.push( _mOperator.get( sTokenFound ) );
				s.read( sTokenFound.length );
				continue;
			}
			
			
			
			// Get Const
			var oExpr = getValueExpr( s );
			
			if ( oExpr != null ) {
				lScanned.push( oExpr );
				continue;
			}
			
			// Parenthesis
			if ( s.startWith('(') ) {
				s.read(1);
				var oExpr = this.apply( s, [')'] );
				s.read(1);
				lScanned.push( oExpr );
				continue;
			}
			
			// Anno nymous structure
			oExpr = _compileAnnonStructure( s );
			if ( oExpr != null ) {
				lScanned.push( oExpr );
				continue;
			}
			
			
				
			throw 'Invalid string at #' + s.getPosition() + ' near ' + s.getRemaining();
		}
		
		if ( lScanned.isEmpty() )
			throw 'Exepected expression got empty';
		
		//_____________________________
		// Parse
		
		// Solve unary expr
		var lTmp = new List<Dynamic>();
		var oIterator = lScanned.iterator();
		for ( o in oIterator ) {
			if ( 
				! Std.is( o, IBuilder ) 
				|| ! Std.is( untyped o.getClass(), AExprUnary )
			) {
				lTmp.add( o );
				continue;
			}
			
			var oBuilder :IExpressionBuilder = cast o;
			if ( ! oIterator.hasNext() ) throw 'expected value expression';
			var oRightExpr = oIterator.next();
			
			lTmp.add( oBuilder.create( [oRightExpr] ) );
			
		}
		lScanned = lTmp;
		
		
		// TODO : solve composite expr
		
		var oTopExpr :IExpression = null;
		var oIterator = lScanned.iterator();
		for ( o in oIterator ) {
			if ( Std.is( o, IExpression ) ) {
				if ( oTopExpr != null ) 
					throw 'expected ';
				oTopExpr = o;
				continue;
			} else if ( 
				Std.is( o, IBuilder ) 
			) {
				
				var oBuilder :IExpressionBuilder = cast o;
				if ( ! oIterator.hasNext() ) throw 'expected value expression';
				var oRightExpr = oIterator.next();
				
				if ( oTopExpr == null ) throw 'missing left expression for ' + oBuilder;
				
				oTopExpr = oBuilder.create( [[oTopExpr, oRightExpr]] );
				continue;
			}
			throw 'invalid token expect IExpression or IBuilder, got '+o;
		}
		
		return oTopExpr;
		
	}
	
	public function getValueExpr( s :StringStream ) :IExpression {
		
		// Case : const NULL
		if ( 
			s.startWith( 'null' ) 
			&& ! StringStream.isAlphaNum( s.charAt(4) ) 
		) {
			s.read('null'.length);
			return new Const( null ); //TODO : re-use same instance
		}
		
		// Int / float
		var oConst = _getConstNumber( s );
		if ( oConst != null ) return oConst;
		
		// Const string
		var oConst = _getConstString( s );
		if ( oConst != null ) return oConst;
			
		// Get VPathAccess
		var oVPath = _getVPathAccessor( s );
		if ( oVPath != null) return oVPath; 
		
		return null;
	}
	
	function _getVPathAccessor( s : StringStream ) {
		var i = 0;
		while ( true ) {
			
			if ( 
				StringStream.isAlpha( s.charAt( i ) ) 
				|| s.charAt( i ) == '.'
				|| s.charAt( i ) == '_'
			) {
				i++;
				continue;
			}
			break;
		}
		if ( i != 0 )
			return new VPathAccessor( s.read( i ) );
		
		return null;
	}
	
	function _getConstString( s : StringStream ) {
		var i = 0;
		if ( ['\'', '"'].indexOf( s.charAt(0) ) == -1 ) 
			return null;
		s.read(1);
		
		var oRes = null;
		var sString = '';
		while( true ) {
			oRes = s.getClosest(['"','\'','\\']);
			if ( oRes == null )
				throw 'Missing end of const string';
			
			sString += s.read( oRes.position - s.getPosition() );
			
			// Case : escaped char
			if ( 
				s.charAt( 0 ) == '\\'
			) {
				s.read(1);
				sString += s.read(1);
				continue;
			}
			
			s.read(1); // closing quote
			break;
		}
		
		return new Const( sString );
	}
	
	function _getConstNumber( s : StringStream ) {
		var i = 0;
		var bFloat = false;
		var bNegative = false;
		while ( true ) {
			if ( StringStream.isNum( s.charAt( i ) )  ) {
				i++;
				continue;
			}
			if ( bFloat != false && s.charAt( i ) == '.' ) {
				i++;
				bFloat = true;
				continue;
			}
			break;
		}
		if ( i != 0 ){
			if ( bFloat )
				return new Const( Std.parseFloat(s.read(i)) );
			else
				return new Const( Std.parseInt(s.read(i)) );
		}
		return null;
	}
	
	function _compileAnnonStructure( s:StringStream ) {
		if ( !s.startWith('{') ) 
			return null;
			
		var m = new StringMap();
			
		s.read(1);// read opening tag "{"
		
		s.ignoreWhitespace();
		if ( s.startWith('}') ) {
			s.read(1);
			return new AnnonObject( m );
		}
		
		while ( true ) {
			// TODO : ignore encapsulating "'" ? 
			s.ignoreWhitespace();
			var sFieldName = s.getNextWord();
			if ( sFieldName == null ) throw 'Expected field name';
			s.ignoreWhitespace();
			if ( s.read(1) != ':' ) throw 'Expected ":"';
			s.ignoreWhitespace();
			m.set( sFieldName, this.apply( s, [',', '}']) );
			
			var sEndToken = s.read(1);
			if( sEndToken == '}' ) 
				break;
		}
		
		return new AnnonObject( m );
	}
}

//_____________________________________________________________________________


class ASubCompiler {
	
	
	public function apply( 
		lStack :List<IExpression>,
		s :StringStream
	) {
		throw 'override me';
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
interface IExprComposite extends IExpression {
	public function addChild( o :IFunction<Dynamic,Dynamic> ) :Void;
}
class AExprComposite implements IExprComposite {
	var _aChildren :Array<IFunction<Dynamic,Dynamic>>;
	
	public function new( 
		aChildren :Array<IFunction<Dynamic,Dynamic>>
	) {
		_aChildren = aChildren;
	}
	
	public function addChild( o :IFunction<Dynamic,Dynamic> ) {
		_aChildren.push(o );
	}
	
	public function apply( o :Dynamic ) {
		throw 'override me';
		return null;
	};
}

class AnnonObject implements IExpression {
	var _aField :StringMap<IExpression>;
	
	public function new( 
		aField :StringMap<IExpression>
	) {
		_aField = aField;
	}
	
	public function apply( oContext :Dynamic ) {
		var o = {};
		for ( sName => oExpr in _aField )
			Reflect.setField(o, sName, oExpr.apply( oContext ) );
		return o;
	}
	
}


class AExprCompositeReduce implements IExprComposite {
	var _aChildren :Array<IFunction<Dynamic,Dynamic>>;
	
	public function new( 
		aChildren :Array<IFunction<Dynamic,Dynamic>>
	) {
		_aChildren = aChildren;
	}
	
	public function addChild( o :IFunction<Dynamic,Dynamic> ) {
		_aChildren.push(o );
	}
	
	public function apply( oContext :Dynamic ) {
		if ( _aChildren.length == 0 ) throw '!!!';
		var res :Dynamic = _aChildren[0].apply( oContext );
		for ( i in 1..._aChildren.length )
			res = reduce( res, _aChildren[i].apply( oContext ) );
		return res;
	}
	
	public function reduce( oCarry :Dynamic, oItem :Dynamic ) :Dynamic {
		throw 'override me';
	}
}

class Add extends AExprCompositeReduce {
	override public function reduce( oCarry :Dynamic, oItem :Dynamic ) :Dynamic  {
		return oCarry + oItem;
	}
}

class Sub extends AExprCompositeReduce {
	override public function reduce( oCarry :Dynamic, oItem :Dynamic ) :Dynamic {
		return oCarry - oItem;
	}
}

class Div extends AExprCompositeReduce {
	override public function reduce( oCarry :Dynamic, oItem :Dynamic ) :Dynamic {
		return oCarry / oItem;
	}
}

class Mult extends AExprCompositeReduce {
	override public function reduce( oCarry :Dynamic, oItem :Dynamic ) :Dynamic {
		return oCarry * oItem;
	}
}

class Mod extends AExprCompositeReduce {
	override public function reduce( oCarry :Dynamic, oItem :Dynamic ) :Dynamic {
		return oCarry % oItem;
	}
}

class And extends AExprCompositeReduce {
	override public function reduce( oCarry :Dynamic, oItem :Dynamic ) :Dynamic {
		return oCarry && oItem;
	}
}
class Or extends AExprCompositeReduce {
	override public function reduce( oCarry :Dynamic, oItem :Dynamic ) :Dynamic {
		return oCarry || oItem;
	}
}

class Iterate extends AExprCompositeReduce {
	override public function reduce( oCarry :Dynamic, oItem :Dynamic ) :Dynamic {
		return oCarry ... oItem;
	}
}

class Equal extends AExprCompositeReduce {
	override public function reduce( oCarry :Dynamic, oItem :Dynamic ) :Dynamic {
		return oCarry == oItem;
	}
}

class Diff extends AExprCompositeReduce {
	override public function reduce( oCarry :Dynamic, oItem :Dynamic ) :Dynamic {
		return oCarry != oItem;
	}
}

class Inferior extends AExprCompositeReduce {
	override public function reduce( oCarry :Dynamic, oItem :Dynamic ) :Dynamic {
		return oCarry < oItem;
	}
}

class InferiorEqual extends AExprCompositeReduce {
	override public function reduce( oCarry :Dynamic, oItem :Dynamic ) :Dynamic {
		return oCarry <= oItem;
	}
}

class Superior extends AExprCompositeReduce {
	override public function reduce( oCarry :Dynamic, oItem :Dynamic ) :Dynamic {
		return oCarry > oItem;
	}
}

class SuperiorEqual extends AExprCompositeReduce {
	override public function reduce( oCarry :Dynamic, oItem :Dynamic ) :Dynamic {
		return oCarry >= oItem;
	}
}

class AExprUnary implements IExpression {
	var _oChild :IExpression;
	
	public function new( 
		oChild :IExpression
	) {
		_oChild = oChild;
	}
	
	public function setChild( o :IExpression ) {
		_oChild = o;
	}
	
	public function apply( o :Dynamic ):Dynamic {
		throw 'override me';
	};
}

class Not extends AExprUnary {
	override public function apply( oContext :Dynamic ) :Dynamic {
		return ! _oChild.apply( oContext );
	}
}

class Negative extends AExprUnary {
	override public function apply( oContext :Dynamic ) :Dynamic {
		return - _oChild.apply( oContext );
	}
}

/*
class UnaryMinus extends AExprComposite {
	
	public function new( 
		aChildren :Array<IFunction<Dynamic,Dynamic>>
	) {
		super( aChildren );
	}
	
	public function apply( o :Dynamic ) {
		return -_aChildren[0].apply( o );
	}
	
	public function isFilled() {
		return _aChildren.length >= 1;
	}
}*/