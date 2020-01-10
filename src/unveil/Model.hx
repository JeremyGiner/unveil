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
		// TODO
		// try cache, try 
		
		// Case : does not exist
		if ( !_mEntity.exists(s) )
			return Promise.reject(s);
		
		// Case : already loaded
		var oEntity = _mEntity.get(s);
		if ( !Std.is(oEntity, ILoader) )
			return Promise.resolve( oEntity );
		
		var oLoader :ILoader<Dynamic> = cast oEntity;
		return oLoader.load().then(function( oValue :Dynamic ) { setEntity( s, oValue ); });
		
	}
}