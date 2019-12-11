package unveil.template;
import unveil.tool.VPathAccessor;

/**
 * Proxy for template use
 * @author 
 */
class PrintVarTemplate implements ITemplate {

	var _oAccessor :VPathAccessor;
	
	public function new( oAccessor :VPathAccessor ) {
		_oAccessor = oAccessor;
	}
	
	public function render( oContext :Dynamic, oBuffer :StringBuf = null  ) {
		oBuffer = oBuffer == null ? new StringBuf() : oBuffer;
		oBuffer.add( _oAccessor.apply( oContext ) );
		return oBuffer;
	}
}