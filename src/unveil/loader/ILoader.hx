package unveil.loader;
import js.html.XMLHttpRequest;

/**
 * @author 
 */
interface ILoader<C> {
	public function load() :Void;
	public function getData() :C;
	public function onLoad( fn :ILoader<C>->Void ) :Void;
}