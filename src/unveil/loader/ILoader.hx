package unveil.loader;
import js.lib.Promise;

/**
 * @author 
 */
interface ILoader<C> {
	public function load() :Promise<C>;
}