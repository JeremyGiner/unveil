package unveil;

/**
 * @author 
 */
interface ITemplate {
	public function render( oContext :Dynamic, oStringBuf :StringBuf = null ) :StringBuf;
}