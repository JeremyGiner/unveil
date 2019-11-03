package unveil;
import js.Browser;
import js.html.DOMElement;
import js.html.Event;

/**
 * ...
 * @author 
 */
class Unveil {

	var _oRouter :RouterDefault;
	
	
	public function new( oRouter :RouterDefault ) {
		_oRouter = oRouter;
		
		js.Browser.document.addEventListener( 'click', handleClickEvent );
		
		updateView();
	}
	
	public function goto( sPath :String ) {
		
		// TODO : convert sPath to relative
		
		js.Browser.window.history.pushState(
			{id: 0},
			"hellototo",
			js.Browser.location.protocol+'//'+ js.Browser.location.hostname + sPath
		);
		
		updateView();
	}
	
	public function updateView() {
		var oTemplate = _oRouter.getTemplate( js.Browser.location );
		
		Browser.document.body.innerHTML = oTemplate.render(null).toString();
	}
	
	public function handleClickEvent( event :Event ) {
		
		// Handle link click
		// TODO : make sure to have the least priority on click event
		// TODO : handle form
		var oTarget :DOMElement = cast event.currentTarget;
		if ( oTarget.hasAttribute('href') ) {
			event.preventDefault();
			goto( oTarget.getAttribute('href') );
		}
		//trace(js.Browser.location);
    }
	
}