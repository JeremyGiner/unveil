package unveil.loader;
import js.html.XMLHttpRequest;
import sweet.functor.IFunction;
import sweet.functor.builder.IFactory;
import unveil.loader.ALoader;
import js.html.XMLHttpRequestResponseType;

typedef Pair<C> = {
	var left :C;
	var right :C;
}

/**
 * ...
 * @author ...
 */
class ALoaderXhr<C> extends ALoader<C> {

	var _sMethod :String;
	var _sUri :String;
	var _aHeader :Array<Pair<String>>;
	var _eResponseType :XMLHttpRequestResponseType;
	
	
	public function new( 
		sMethod :String,
		sUri :String,
		aHeader :Array<Pair<String>>,
		eResponseType :XMLHttpRequestResponseType = XMLHttpRequestResponseType.TEXT
	) {
		super();
		
		_sMethod = sMethod;
		_sUri = sUri;
		_aHeader = aHeader;
		_eResponseType = eResponseType;
	}
	
	override public function callback(resolve:C->Void, reject:Dynamic->Void) {
		var oReq = new XMLHttpRequest();
		oReq.responseType = _eResponseType;
		oReq.onreadystatechange = function() {
			// Only run if the request is complete
			if (oReq.readyState != 4) return;
			
			// Process the response
			if (oReq.status >= 200 && oReq.status < 300) {
				// If successful
				return resolve( handleResponse( oReq ) );
			} else {
				// If failed
				return reject({
					status: oReq.status,
					statusText: oReq.statusText
				});
			}
		}
		oReq.open(
			_sMethod, 
			_sUri
		);
		for( oHeader in _aHeader ) 
			oReq.setRequestHeader(oHeader.left, oHeader.right);
			//oReq.setRequestHeader("Content-Type", "application/json");
		//oReq.send( Json.stringify( untyped _this.payload.innerHTML) );
		oReq.send( getBody() );
	}
	
	public function handleResponse( oReq :XMLHttpRequest ) :C {
		throw 'override me';
		return null;
	}
	
	public function getBody() :String {
		throw 'override me';
		return null;
	}
	
}