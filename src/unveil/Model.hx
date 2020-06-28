package unveil;
import haxe.ds.StringMap;
import js.Promise.PromiseHandler;
import js.lib.Promise;
import unveil.loader.ILoader;

typedef Model_EntityHandler = {
	var loader :ILoader<Dynamic>;
	var cache :Dynamic;
	var cache_policy :Bool;
}

/**
 * ...
 * @author 
 */
class Model {

	var _mEntityHandler :StringMap<Model_EntityHandler>;
	
	public function new() {
		// todo create loader
		
		_mEntityHandler = new StringMap<Model_EntityHandler>();
	}
	/**
	 * 
	 * @param	s
	 * @param	o
	 * @param	bCachePolicy  if false: cache refresh on load
	 */
	public function setEntityLoader( s :String, o :ILoader<Dynamic>, bCachePolicy :Bool = true ) {
		_mEntityHandler.set( s, {loader: o, cache: null, cache_policy: bCachePolicy } );
	}
	public function setEntity( s :String, o :Dynamic ) {
		_mEntityHandler.set( s, {loader:null, cache: o, cache_policy: true } );
	}
	
	public function getEntity( s :String ) :Dynamic {
		if( !_mEntityHandler.exists(s) )
			return null;
		return _mEntityHandler.get(s).cache;
	}
	public function loadEntity( s :String ) :Promise<Dynamic> {
		
		// Case : does not exist
		if ( !_mEntityHandler.exists(s) )
			return Promise.reject(s);
		// TODO
		// try cache, try 
		
		var oEntityHandler = _mEntityHandler.get(s);

		// Case : already loading
		if ( Std.is(oEntityHandler.cache, Promise) )
			return oEntityHandler.cache;
		
		// Case : load
		if ( 
			oEntityHandler.loader != null 
			&& (
				oEntityHandler.cache == null 
				|| oEntityHandler.cache_policy == false
			)
		) {
			var oLoader :ILoader<Dynamic> = oEntityHandler.loader;
			var oPromise = oLoader.load();
			
			oEntityHandler.cache = oPromise;
			
			oPromise.then(function( oValue :Dynamic ) {
				oEntityHandler.cache = oValue;
			}).catchError(function(onRejected :PromiseHandler<Dynamic, Array<Dynamic>> ) {
				oEntityHandler.cache = null;
			});
			return oPromise;
		}
		
		// Case : already loaded
		return Promise.resolve( oEntityHandler.cache );
		
		
		
	}
}