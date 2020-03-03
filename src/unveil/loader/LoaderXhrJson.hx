package unveil.loader;
import haxe.Json;
import js.html.XMLHttpRequest;
import js.html.XMLHttpRequestResponseType;
import unveil.loader.LoaderXhr.Pair;
import sweet.functor.IFunction;


/**
 * ...
 * @author ...
 */
class LoaderXhrJson extends LoaderXhr {

	public function new( 
		sMethod :String,
		sUri :String,
		aHeader :Array<Pair<String>>,
		oBody :Dynamic,
		oResponseHandler :IFunction<XMLHttpRequest,Dynamic> = null,
		eResponseType :XMLHttpRequestResponseType = XMLHttpRequestResponseType.TEXT
	) {
		aHeader.push({left: "Content-Type", right: "application/json"});
		super(sMethod, sUri, aHeader, Json.stringify( oBody ), oResponseHandler, eResponseType );
	}
	
}