package unveil.loader;
import js.lib.Promise;

/**
 * ...
 * @author ...
 */
class ALoader<CData> implements ILoader<CData> {
	
	public function new() {
		
	}
	
	public function load() {
		return new Promise<CData>(this.callback);
	}
	
	public function callback( resolve :CData->Void, reject:Dynamic->Void ) {
		throw 'callback: override me';
	}
	
}