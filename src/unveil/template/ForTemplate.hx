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
		for ( o in _oExpression.apply( oContext ) ) {
			var oCurrentContext = Reflect.copy(oContext);
			Reflect.setField( oCurrentContext, _sVarName, o);
			oBuffer = super.render( oCurrentContext, oBuffer );
		}
		return oBuffer;
	}
}