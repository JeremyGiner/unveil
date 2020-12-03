package unveil.controller;
import js.Browser;
import js.html.Element;
import js.html.MouseEvent;

/**
 * ...
 * @author 
 */
class ClickController {

	var _sId :String;
	var _bProcessing :Bool;
	
	public function new( sId :String ) {
		_sId = sId;
		_bProcessing = false;
		Browser.document.addEventListener('click', process);
	}
	
	public function process( oEvent :MouseEvent ) {
		
		// Prevent parallel processing
		if ( _bProcessing ) return;
		_bProcessing = true; 
		
		_process( oEvent );
		_bProcessing = false; 
	}
	
	function _process( oEvent :MouseEvent ) {
		
		var oElement :Element = cast oEvent.target;
		oElement = oElement.closest('[data-click="'+_sId+'"]');
		if ( oElement == null ) 
			return;
		
		_onClick( oElement );
	}
	
	function _onClick( oElement :Element ) {
		throw 'override me';
	}
}