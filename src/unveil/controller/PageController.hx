package unveil.controller;
import haxe.ds.StringMap;
import js.html.DOMElement;
import js.html.Event;
import js.html.Element;
import js.lib.RegExp;
import unveil.Model;
import js.lib.Promise;
import sweet.functor.builder.IBuilder;

typedef PageHandle = {
	var path_pattern :RegExp;
	var page_data :Dynamic;
	var model_load :StringMap<IBuilder<Dynamic,Dynamic>>;
}

/**
 * ...
 * @author 
 */
class PageController implements IController {

	var _oModel :Model;
	var _oView :View;
	var _mPathToPage :StringMap<PageHandle>;
	var _oCurrentPageWrapper :Element;
	
	public function new( 
		mPathToPage :StringMap<PageHandle>, 
		oModel :Model,
		oView :View
	) {
		_mPathToPage = mPathToPage;
		_oModel = oModel;
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
		var oPageHandleCurrent :PageHandle = null;
		for ( sKey => oPageHandle in _mPathToPage ) {
			var o = oPageHandle.path_pattern.exec( sPath );
			if ( o == null )
				continue;
			// TODO : put route param somewhere 
			sPageKey = sKey;
			oPageHandleCurrent = oPageHandle;
		}
		
		// Case : page not found
		if ( sPageKey == null )
			sPageKey = 'not_found';
		
		// Load model part
		//TODO : show loading style
		if (  oPageHandleCurrent.model_load == null )
			oPageHandleCurrent.model_load = cast  new StringMap<Dynamic>();
		var aPromise = [for ( s in oPageHandleCurrent.model_load.keys() ) _oModel.loadEntity( s )];
		
		Promise.all(aPromise).then(function( oValue :Array<Dynamic> ) {
			
			// Update view data
			if ( oPageHandleCurrent.page_data == null )
				oPageHandleCurrent.page_data = {};
			for ( s => o in oPageHandleCurrent.model_load ) {
				Reflect.setField( 
					oPageHandleCurrent.page_data, 
					s, o.create( _oModel.getEntity( s ) ) 
				);
			}
			
			// Push state
			js.Browser.window.history.pushState(
				{id: 0},
				"hellototo",
				js.Browser.location.protocol+'//'+ js.Browser.location.hostname+':'+ js.Browser.location.port + sPath
			);
			
			if ( _oCurrentPageWrapper != null )
				_oCurrentPageWrapper.remove();
			
			_oView.setPageData( oPageHandleCurrent.page_data );
			_oCurrentPageWrapper = _oView.diplay( sPageKey );
		});
		
		
	}
	
}