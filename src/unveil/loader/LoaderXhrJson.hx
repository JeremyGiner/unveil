package unveil.loader;
import haxe.Json;
import js.html.XMLHttpRequest;
import unveil.loader.LoaderXhr.Pair;


/**
 * ...
 * @author ...
 */
class LoaderXhrJson extends LoaderXhr {

	public function new( 
		sMethod :String,
		sUri :String,
		aHeader :Array<Pair<String>>,
		oBody :Dynamic
	) {
		aHeader.push({left: "Content-Type", right: "application/json"});
		super(sMethod, sUri, aHeader, Json.stringify( oBody ) );
	}
	
}