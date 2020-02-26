package unveil.loader;
import js.html.XMLHttpRequest;
import sweet.functor.IFunction;
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
class LoaderXhr extends ALoader<Dynamic> {

	var _sMethod :String;
	var _sUri :String;
	var _aHeader :Array<Pair<String>>;
	var _sBody :String;
	var _oResponseHandler :IFunction<XMLHttpRequest,Dynamic>;
	
	
	public function new( 
		sMethod :String,
		sUri :String,
		aHeader :Array<Pair<String>>,
		sBody :String,
		oResponseHandler :IFunction<XMLHttpRequest,Dynamic> = null
	) {
		super();
		
		_sMethod = sMethod;
		_sUri = sUri;
		_aHeader = aHeader;
		_sBody = sBody;
		_oResponseHandler = oResponseHandler;
	}
	
	override public function callback(resolve:String->Void, reject:Dynamic->Void) {
		var oReq = new XMLHttpRequest();
		oReq.responseType = XMLHttpRequestResponseType.ARRAYBUFFER;
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
		oReq.send( _sBody );
	}
	
}