package unveil.template;
import sweet.functor.IFunction;

/**
 * ...
 * @author 
 */
class SubRendererTemplate implements ITemplate {
	var _oTemplate :ITemplate;
	
	public function new( oTemplate :ITemplate ) {
		_oTemplate = oTemplate;
	}
	
	public function render( oContext :Dynamic, oBuffer :StringBuf = null  ) {
		return _oTemplate.render( oContext, oBuffer );
	}
}