package unveil.template;
import sweet.functor.IFunction;
import unveil.View;

/**
 * ...
 * @author 
 */
class SubRendererTemplate implements ITemplate {
	var _oView :View;
	var _sTemplateKey :String;
	var _oWith :IFunction<Dynamic,Dynamic>;
	
	public function new( oView :View, sTemplateKey :String, oWith :IFunction<Dynamic,Dynamic> ) {
		_oView = oView;
		_sTemplateKey = sTemplateKey;
		_oWith = oWith;
	}
	
	public function render( oContext :Dynamic, oBuffer :StringBuf = null  ) {
		
		if ( _oWith != null )
			oContext = _oWith.apply( oContext );
		
		var oTemplate = _oView.getTemplate( _sTemplateKey );
		if ( oTemplate == null )
			throw 'Missing template "' + _sTemplateKey + '" for render instruction';
		return oTemplate.render( oContext, oBuffer );
	}
}