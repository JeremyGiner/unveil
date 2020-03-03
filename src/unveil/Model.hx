package unveil;
import haxe.ds.StringMap;
import js.lib.Promise;
import unveil.loader.ILoader;

/**
 * ...
 * @author 
 */
class Model {

	var _mEntity :StringMap<Dynamic>;
	
	public function new() {
		// todo create loader
		
		_mEntity = new StringMap<Dynamic>();
	}
	
	public function setEntity( s :String, o :Dynamic ) {
		_mEntity.set( s, o );
	}
	
	public function getEntity( s :String ) :Dynamic {
		//TODO : throw on inexistant? 
		return _mEntity.get(s);
	}
	public function loadEntity( s :String ) :Promise<Dynamic> {
		
		// Case : does not exist
		if ( !_mEntity.exists(s) )
			return Promise.reject(s);
		// TODO
		// try cache, try 
		
		var oEntity = _mEntity.get(s);

		// Case : already loading
		if ( Std.is(oEntity, Promise) )
			return oEntity;
		
		// Case : load
		if ( Std.is(oEntity, ILoader) ) {
			var oLoader :ILoader<Dynamic> = cast oEntity;
			var oPromise = oLoader.load();
			setEntity(s, oPromise);
			oPromise.then(function( oValue :Dynamic ) { setEntity( s, oValue ); });
			return oPromise;
		}
		
		// Case : already loaded
		return Promise.resolve( oEntity );
		
		
		
	}
}