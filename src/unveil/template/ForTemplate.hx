package unveil.template;
import sweet.functor.IFunction;

/**
 * ...
 * @author 
 */
class ForTemplate extends CompositeTemplate {
	var _oExpression :IFunction<Dynamic,Iterable<Dynamic>>;
	var _sVarName :String;
	
	public function new( oExpression :IFunction<Dynamic,Iterable<Dynamic>>, sVarName :String ) {
		super();
		_oExpression = oExpression;
		_sVarName = sVarName;
	}
	
	override public function render( oContext :Dynamic, oBuffer :StringBuf = null  ) {
		var a = _oExpression.apply( oContext );
		var oIterator :Iterator<Dynamic> = null;
		try {
			oIterator = a.iterator();
		} catch( e :Dynamic ) {
			throw a + ' is not iterable';// TODO : stringify expression
		}
		for ( o in oIterator ) {
			var oCurrentContext = Reflect.copy(oContext);
			Reflect.setField( oCurrentContext, _sVarName, o);
			oBuffer = super.render( oCurrentContext, oBuffer );
		}
		return oBuffer;
	}
}