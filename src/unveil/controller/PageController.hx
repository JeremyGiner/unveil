package unveil.controller;
import haxe.ds.StringMap;
import js.html.DOMElement;
import js.html.Event;
import js.html.Element;
import js.lib.RegExp;

typedef PageHandle = {
	var path_pattern :RegExp;
	var page_data :Dynamic;
}

/**
 * ...
 * @author 
 */
class PageController implements IController {

	var _oView :View;
	var _mPathToPage :StringMap<PageHandle>;
	var _oCurrentPageWrapper :Element;
	
	public function new( mPathToPage :StringMap<PageHandle>, oView :View ) {
		_mPathToPage = mPathToPage;
		_oView = oView;
		_oCurrentPageWrapper = null;
		// listen click link
		
		js.Browser.document.addEventListener( 'click', handleClickEvent );
		
	}
	
	public function handleClickEvent( event :Event ) {
		
		// Handle link click
		// TODO : make sure to have the least priority on click event
		// TODO : handle form
		var oTarget :DOMElement = cast event.originalTarget;
		if ( !Std.is( oTarget, DOMElement ) )
			return;
		if ( oTarget.hasAttribute('href') ) {
			event.preventDefault();
			// TODO : Filter : uri#id
			
			goto( oTarget.getAttribute('href') );
		}
		//trace(js.Browser.location);
    }
	
	public function goto( sPath :String ) {
		
		// Get page key
		var sPageKey :String = null;
		var oPageData :Dynamic = null;
		for ( sKey => oPageHandle in _mPathToPage ) {
			var o = oPageHandle.path_pattern.exec( sPath );
			if ( o == null )
				continue;
			// TODO : put route param somewhere 
			sPageKey = sKey;
			oPageData = oPageHandle.page_data;
		}
		
		// Case : page not found
		if ( sPageKey == null )
			sPageKey = 'not_found';
		
		// Push state
		js.Browser.window.history.pushState(
			{id: 0},
			"hellototo",
			js.Browser.location.protocol+'//'+ js.Browser.location.hostname+':'+ js.Browser.location.port + sPath
		);
		
		if ( _oCurrentPageWrapper != null )
			_oCurrentPageWrapper.remove();
		
		_oView.setPageData( oPageData );
		_oCurrentPageWrapper = _oView.diplay( sPageKey );
	}
	
}