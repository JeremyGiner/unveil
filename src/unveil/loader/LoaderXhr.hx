package unveil.loader;
import haxe.Json;
import js.html.XMLHttpRequest;
import unveil.loader.LoaderDefault;

typedef Pair<C> = {
	var left :C;
	var right :C;
}

/**
 * ...
 * @author ...
 */
class LoaderXhr extends LoaderDefault<Dynamic> {

	public function new( 
		sMethod :String,
		sUri :String,
		aHeader :Array<Pair<String>>,
		sBody :String
	) {
		super(function( resolve :String->Void, reject:Dynamic->Void ) {
			var oReq = new XMLHttpRequest();
			oReq.onreadystatechange = function() {
				// Only run if the request is complete
				if (oReq.readyState != 4) return;
				
				// Process the response
				if (oReq.status >= 200 && oReq.status < 300) {
					// If successful
					if ( oReq.getResponseHeader('Content-Type') == 'application/json' )
						return resolve(Json.parse( oReq.responseText ));
					return resolve( oReq.responseText );
				} else {
					// If failed
					reject({
						status: oReq.status,
						statusText: oReq.statusText
					});
				}
			}
			oReq.open(
				sMethod, 
				sUri
			);
			for( oHeader in aHeader ) 
				oReq.setRequestHeader(oHeader.left, oHeader.right);
				//oReq.setRequestHeader("Content-Type", "application/json");
			//oReq.send( Json.stringify( untyped _this.payload.innerHTML) );
			oReq.send( sBody );
		});
	}
	
}