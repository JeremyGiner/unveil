package unveil.template;
import sweet.functor.IFunction;
import unveil.tool.VPathAccessor;

/**
 * Proxy for template use
 * @author 
 */
class PrintVarTemplate implements ITemplate {

	var _oFn :IFunction<Dynamic,Dynamic>;
	
	public function new( oFn :IFunction<Dynamic,Dynamic> ) {
		_oFn = oFn;
	}
	
	public function render( oContext :Dynamic, oBuffer :StringBuf = null  ) {
		oBuffer = oBuffer == null ? new StringBuf() : oBuffer;
		oBuffer.add( _oFn.apply( oContext ) );
		return oBuffer;
	}
}