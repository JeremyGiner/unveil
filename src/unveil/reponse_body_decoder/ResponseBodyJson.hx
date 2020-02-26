package unveil.response_handler;
import sweet.functor.IFunction;
import js.html.XMLHttpRequest;
import haxe.Json;

/**
 * ...
 * @author ...
 */
class ResponseHandlerJson implements IFunction<XMLHttpRequest,Dynamic> {

	public function new() {
		
	}
	
	public function apply( oReq :XMLHttpRequest ) {
		if ( oReq.getResponseHeader('Content-Type') != 'application/json' )
			throw 'invalid content type "'+oReq.getResponseHeader('Content-Type')+'", expecting "application/json"';
		return Json.parse( oReq.responseText );
	}
}