package unveil.template;
import sweet.functor.IFunction;
import unveil.View;

/**
 * ...
 * @author 
 */
class SubRendererTemplate implements ITemplate {
	var _oView :View;
	var _oExpression :IFunction<Dynamic,String>;
	var _oWith :IFunction<Dynamic,Dynamic>;
	
	public function new( oView :View, oExpression :IFunction<Dynamic,String>, oWith :IFunction<Dynamic,Dynamic> ) {
		_oView = oView;
		_oExpression = oExpression;
		_oWith = oWith;
	}
	
	public function render( oContext :Dynamic, oBuffer :StringBuf = null  ) {
		
		// Get tamplate key
		var _sTemplateKey = _oExpression.apply( oContext );
		
		// Change context
		if ( _oWith != null )
			oContext = _oWith.apply( oContext );
		
		// Get & render template
		var oTemplate = _oView.getTemplate( _sTemplateKey );
		if ( oTemplate == null )
			throw 'Missing template "' + _sTemplateKey + '" for render instruction';
		return oTemplate.render( oContext, oBuffer );
	}
}