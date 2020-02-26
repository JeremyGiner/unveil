package unveil.controller.process;
import sweet.functor.IFunction;
import sweet.functor.IProcedure;
import js.html.FormElement;
import haxe.Json;
import js.html.XMLHttpRequest;

/**
 * ...
 * @author ...
 */
class HxrRequestJson implements IFunction<FormElement,Dynamic> {

	
	public function new() {
		
	}
	
	public function apply( oForm :FormElement ) {
		var oReq = new XMLHttpRequest();
		oReq.addEventListener("load", function() {
			responseHandle( oReq );
		});
		oReq.open(
			oForm.method, 
			oForm.action
		);
		oReq.setRequestHeader("Content-Type", "application/json");
		//oReq.send( Json.stringify( untyped _this.payload.innerHTML) );
		oReq.send( Json.stringify( getRequestData( oForm ) );
		return oReq;
	}
	
	public function getRequestData( oForm :FormElement ) :Dynamic {
		return FormController.getInputMap( oForm );
	}
	
	public function responseHandle( oReq :XMLHttpRequest ) {
		// do nothing
	}
}