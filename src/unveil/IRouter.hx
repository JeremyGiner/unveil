package unveil;
import js.html.Location;

/**
 * @author 
 */
interface IRouter {
	public function getTemplate( oLocation :Location ) :ITemplate;
}