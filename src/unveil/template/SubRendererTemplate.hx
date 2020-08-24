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
	
	public function new( oView :View, sTemplateKey :String ) {
		_oView = oView;
		_sTemplateKey = sTemplateKey;
	}
	
	public function render( oContext :Dynamic, oBuffer :StringBuf = null  ) {
		var oTemplate = _oView.getTemplate( _sTemplateKey );
		if ( oTemplate == null )
			throw 'Missing template "' + _sTemplateKey + '" for render instruction';
		return oTemplate.render( oContext, oBuffer );
	}
}