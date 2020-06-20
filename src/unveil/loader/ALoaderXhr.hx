package unveil.loader;
import js.html.XMLHttpRequest;
import sweet.functor.IFunction;
import sweet.functor.builder.IFactory;
import unveil.loader.LoaderDefault;
import js.html.XMLHttpRequestResponseType;

typedef Pair<C> = {
	var left :C;
	var right :C;
}

/**
 * ...
 * @author ...
 */
class ALoaderXhr extends ALoader<Dynamic> {

	var _sMethod :String;
	var _sUri :String;
	var _aHeader :Array<Pair<String>>;
	var _oResponseHandler :IFunction<XMLHttpRequest,Dynamic>;
	var _eResponseType :XMLHttpRequestResponseType;
	
	
	public function new( 
		sMethod :String,
		sUri :String,
		aHeader :Array<Pair<String>>,
		oResponseHandler :IFunction<XMLHttpRequest,Dynamic> = null,
		eResponseType :XMLHttpRequestResponseType = XMLHttpRequestResponseType.TEXT
	) {
		super();
		
		_sMethod = sMethod;
		_sUri = sUri;
		_aHeader = aHeader;
		_oResponseHandler = oResponseHandler;
		_eResponseType = eResponseType;
	}
	
	override public function callback(resolve:String->Void, reject:Dynamic->Void) {
		var oReq = new XMLHttpRequest();
		oReq.responseType = _eResponseType;
		oReq.onreadystatechange = function() {
			// Only run if the request is complete
			if (oReq.readyState != 4) return;
			
			// Process the response
			if (oReq.status >= 200 && oReq.status < 300) {
				// If successful
				if ( _oResponseHandler != null )
					return resolve(_oResponseHandler.apply( oReq ));
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
			_sMethod, 
			_sUri
		);
		for( oHeader in _aHeader ) 
			oReq.setRequestHeader(oHeader.left, oHeader.right);
			//oReq.setRequestHeader("Content-Type", "application/json");
		//oReq.send( Json.stringify( untyped _this.payload.innerHTML) );
		oReq.send( getBody() );
	}
	
	public function getBody() :String {
		throw 'override me';
		return null;
	}
	
}