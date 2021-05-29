package unveil.template;
import sweet.functor.IFunction;

/**
 * ...
 * @author 
 */
class ForTemplate extends CompositeTemplate {
	var _oExpression :IFunction<Dynamic,Iterable<Dynamic>>;
	var _sVarName :String;
	var _oElseblock :CompositeTemplate;
	
	public function new( oExpression :IFunction<Dynamic,Iterable<Dynamic>>, sVarName :String ) {
		super();
		_oExpression = oExpression;
		_sVarName = sVarName;
		_oElseblock = null;
	}
	
	override public function render( oContext :Dynamic, oBuffer :StringBuf = null  ) {
		var a = _oExpression.apply( oContext );
		var oIterator :Iterator<Dynamic> = null;
		try {
			oIterator = a.iterator();
		} catch( e :Dynamic ) {
			throw a + ' is not iterable';// TODO : stringify expression
		}
		
		// Case : empty
		if ( !oIterator.hasNext() && _oElseblock != null ) 
			return _oElseblock.render( Reflect.copy(oContext), oBuffer );
			
		// Render loop
		for ( o in oIterator ) {
			var oCurrentContext = Reflect.copy(oContext);
			Reflect.setField( oCurrentContext, _sVarName, o);
			oBuffer = super.render( oCurrentContext, oBuffer );
		}
		return oBuffer;
	}
	
	
//_____________________________________________________________________________
// Modifier

	override public function addPart( oPart :ITemplate ) {
		if ( _oElseblock == null )
			return super.addPart( oPart );
		_oElseblock.addPart( oPart );
	}
	
	public function setElseBlock() {
		_oElseblock = new CompositeTemplate();
	}
}