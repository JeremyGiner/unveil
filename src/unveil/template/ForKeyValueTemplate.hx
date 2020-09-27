package unveil.template;
import sweet.functor.IFunction;

/**
 * ...
 * @author 
 */
class ForKeyValueTemplate extends CompositeTemplate {
	var _oExpression :IFunction<Dynamic,KeyValueIterable<Dynamic,Dynamic>>;
	var _sKeyName :String;
	var _sVarName :String;
	
	public function new( 
		oExpression :IFunction<Dynamic,KeyValueIterable<Dynamic,Dynamic>>, 
		sKeyName :String,
		sVarName :String 
	) {
		super();
		_oExpression = oExpression;
		_sVarName = sVarName;
		_sKeyName = sKeyName;
	}
	
	override public function render( oContext :Dynamic, oBuffer :StringBuf = null  ) {
		for ( k => v in _oExpression.apply( oContext ) ) {
			var oCurrentContext = Reflect.copy(oContext);
			Reflect.setField( oCurrentContext, _sKeyName, k);
			Reflect.setField( oCurrentContext, _sVarName, v);
			oBuffer = super.render( oCurrentContext, oBuffer );
		}
		return oBuffer;
	}
}