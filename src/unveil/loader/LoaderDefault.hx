package unveil.loader;
import js.lib.Promise;

/**
 * ...
 * @author ...
 */
class LoaderDefault<CData> implements ILoader<CData> {

	var _fnInit :(resolve:(value:CData) -> Void, reject:(reason:Dynamic) -> Void) -> Void;
	
	public function new( fnInit :(resolve:(value:CData) -> Void, reject:(reason:Dynamic) -> Void) -> Void ) {
		_fnInit = fnInit;
	}
	
	public function load() {
		return new Promise(_fnInit);
	}
	
}