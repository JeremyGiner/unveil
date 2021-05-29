package unveil.template;
import haxe.ds.StringMap;
import sweet.functor.IFunction;
import sweet.functor.IBiFunction;
import unveil.View;
import unveil.compiler.ExpressionCompiler;
import unveil.tool.StringStream;
import unveil.template.ITemplate;
import unveil.tool.StringTool;

using StringTools;


typedef Config = {
	var instruction_ar :StringMap<IInstructionCompiler>;
}

/**
 * ...
 * @author 
 */
class Compiler {
	
	var _oConfig :Config;
	
	public function new( oConfig :Config ) {
		_oConfig = oConfig;
	}
	
	
	static public function getDefaultConfig( oExprCompiler :IExpressionCompiler, oView :View ) :Config {
		return {
			instruction_ar: [
				'{{' => new PrintInstructionCompiler(oExprCompiler,'}}'),
				'{%' => new InstructionCompiler(
					InstructionCompiler.getDefaultConfig( 
						oExprCompiler, oView, '%}' 
					),
					'%}'
				),
			],
		};
	}
	
	public function compile( s :String ) {
		
		var lStack = new List<CompositeTemplate>();
		lStack.push( new CompositeTemplate() );
		
		var oStream = new StringStream( s );
		
		while ( true ) {
			var oResult = oStream.getClosest( [for(key in _oConfig.instruction_ar.keys()) key] );
			
			// Case : no more instructions
			if ( oResult == null ) {
				lStack.first().addPart( 
					new TemplateString( oStream.getRemaining() )
				);
				break;
			}
			
			// Case : something to print before opening tag
			if( oResult.position - 1 != oStream.getPosition() )
				lStack.first().addPart( new TemplateString( oStream.read( oResult.position - oStream.getPosition() ) ) );
			
			var oSubCompiler = _oConfig.instruction_ar.get( oResult.needle );
			oStream.move( oResult.position + oResult.needle.length );
			lStack = oSubCompiler.apply( lStack, oStream );
		}
		
		
		// TODO : explain
		if ( lStack.length != 1 )
			throw 'parsing failed, missing closing token '+lStack.first() + '  near '+s;
		
		return lStack.first();
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


typedef ITemplateCompiler = IBiFunction<Compiler,StringStream,ITemplate>;
class ATemplateCompiler implements ITemplateCompiler {
	
	var _sEndToken :String;
	
	public function new( sEndToken :String ) {
		_sEndToken = sEndToken;
	}
	public function processEndToken( s :StringStream ) {
		s.ignoreWhitespace();
		s.eat( _sEndToken );
	}
	
	public function apply( oCompiler :Compiler, s :StringStream ) {
		throw 'override me';
		return null;
	}
}


typedef IInstructionCompiler = IBiFunction<List<CompositeTemplate>,StringStream,List<CompositeTemplate>>;

class AInstructionCompiler implements IInstructionCompiler {
	
	var _sEndToken :String;
	
	public function new( sEndToken :String ) {
		_sEndToken = sEndToken;
	}
	
	public function processEndToken( s :StringStream ) {
		s.ignoreWhitespace();
		s.eat( _sEndToken );
	}
	
	public function apply( lParent :List<CompositeTemplate>, s :StringStream ) {
		throw 'override me';
		return null;
	}
}
class AInstructionCompilerAware extends AInstructionCompiler {
	var _oCompiler :IExpressionCompiler;
	public function new( oCompiler :IExpressionCompiler, sEndToken :String ) {
		_oCompiler = oCompiler;
		super( sEndToken );
	}
}

class PrintInstructionCompiler extends AInstructionCompilerAware {
	override public function apply( 
		lParent :List<CompositeTemplate>, 
		s :StringStream 
	) {
		var oTemplate = new PrintVarTemplate( _oCompiler.apply( 
			s, [ _sEndToken ]
		) );
		processEndToken( s );
		
		lParent.first().addPart( oTemplate );
		return lParent;
	}
}
class InstructionCompiler extends AInstructionCompiler {
	
	var _mInstructionCompiler :StringMap<IInstructionCompiler>;
	
	public function new( 
		mInstructionCompiler :StringMap<IInstructionCompiler>,
		sEndToken :String
	) {
		_mInstructionCompiler = mInstructionCompiler;
		super( sEndToken );
	}
	
	static public function getDefaultConfig( 
		oCompiler :IExpressionCompiler, 
		oView :View, 
		sEndToken :String 
	) :StringMap<IInstructionCompiler> {
		return [
			'for' => new ForCompiler( oCompiler, sEndToken ),
			'endfor' => new EndBlock( sEndToken ),
			'render' => new SubRendererCompiler( oCompiler, oView, sEndToken ), 
			'if' => new IfCompiler( oCompiler, sEndToken ),
			'endif' => new EndBlock( sEndToken ),
			'else' => new ElseCompiler( sEndToken ),
			//'set' => 
		];
	}
	
	override public function apply( lParent :List<CompositeTemplate>, s :StringStream ) {
		
		s.ignoreWhitespace();
		
		// sort by length desc
		var aKey = [for( k in _mInstructionCompiler.keys() ) k]; 
		aKey.sort(Reflect.compare);
		aKey.reverse();
		
		// test each
		var oInstructionCompiler = null;
		for( sKey in aKey )
			if ( s.startWith( sKey ) && ! StringStream.isAlphaNum( s.charAt( sKey.length ) ) ) {
				s.read( sKey.length );
				oInstructionCompiler = _mInstructionCompiler.get( sKey );
				break;
			}
		
		// Delegate to instructions
		return oInstructionCompiler.apply( lParent, s );
	};
	
}




class SubRendererCompiler extends AInstructionCompilerAware {
	var _oView :View;
	public function new( oCompiler :IExpressionCompiler,oView :View, sEndToken :String ) {
		_oView = oView;
		super( oCompiler, sEndToken );
	}
	override public function apply( lParent :List<CompositeTemplate>, s :StringStream ) {
		
		var oExpr = _oCompiler.apply( s, ['%}','with '] ); // TODO : use parameter
		var oExprWith = null;
		if ( s.startWith('with ') ) {
			s.read( 'with '.length );
			oExprWith = _oCompiler.apply( s, [ _sEndToken ] );// TODO : use parameter
		}
		processEndToken( s );
		
		lParent.first().addPart( new SubRendererTemplate( _oView, cast oExpr, oExprWith ) );
		return lParent;
	}
}

class ForCompiler extends AInstructionCompilerAware {
	
	override public function apply( lParent :List<CompositeTemplate>, s :StringStream ) {
		// Get first variable name
		var sVarLabel = getVarLabel( s );
		if ( sVarLabel == null )
			throw 'Expected var label';
		
		// Get second variable name
		var sVarKeyLabel = null;
		s.ignoreWhitespace();
		if ( s.startWith('=>') ) {
			s.eat('=>');
			sVarKeyLabel = sVarLabel;
			sVarLabel = getVarLabel( s );
			
			if ( sVarLabel == null )
				throw 'Expected var label';
		}
		
		s.ignoreWhitespace();
		s.eat('in');
		
		// Get expression
		var oExpr = _oCompiler.apply( s, [ _sEndToken ] );
		
		processEndToken( s );
		
		// Create template
		var oTemplate = ( sVarKeyLabel != null )?
			new ForKeyValueTemplate( 
				cast oExpr,
				sVarKeyLabel,
				sVarLabel
			) : new ForTemplate( 
				cast oExpr,
				sVarLabel
			)
		;
		lParent.push( oTemplate );
		return lParent;
	}
	
	function getVarLabel( s :StringStream ) {
		s.ignoreWhitespace();
		var i = 0;
		while ( true ) {
			
			if ( 
				StringStream.isAlpha( s.charAt( i ) ) 
				|| s.charAt( i ) == '_'
			) {
				i++;
				continue;
			}
			break;
		}
		if ( i == 0 )
			return null;
		
		return s.read( i );
	}
}


class IfCompiler extends AInstructionCompilerAware {
	override public function apply( lParent :List<CompositeTemplate>, s :StringStream ) {
		// Get expression
		var oExpr = _oCompiler.apply( s, [ _sEndToken ] );
		processEndToken( s );
		
		// Create template
		lParent.push( new IfTemplate( cast oExpr )  );
	
		return lParent;
	}
	
}

class ElseCompiler extends AInstructionCompiler {
	override public function apply( lParent :List<CompositeTemplate>, s :StringStream ) {
		var oTemplate = lParent.first();
		
		if ( Std.is( oTemplate, ForTemplate ) ) { // TODO : use commun interface isntead
			var oForTemplate :ForTemplate = cast oTemplate;
			oForTemplate.setElseBlock();
		}
		if ( Std.is( oTemplate, IfTemplate ) ) {
			var oIfTemplate :IfTemplate = cast oTemplate;
			oIfTemplate.setElseBlock();
		}
		processEndToken( s );
		return lParent;
	}
}

class EndBlock extends AInstructionCompiler {
	override public function apply( lParent :List<CompositeTemplate>, s :StringStream ) {
		var o = lParent.pop();
		if ( lParent.isEmpty() ) throw '!!!';
		lParent.first().addPart( o );
		processEndToken( s );
		return lParent;
	}
}

