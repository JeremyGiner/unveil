package unveil.controller;
import haxe.Json;
import haxe.Timer;
import haxe.ds.StringMap;
import js.Browser;
import js.html.DOMElement;
import js.html.Event;
import js.html.Element;
import js.lib.RegExp;
import unveil.Model;
import js.lib.Promise;
import sweet.functor.builder.IBuilder;
import js.html.URL;

typedef PageHandle = {
	var id :String;
	var path_pattern :RegExp;
	var page_data :Dynamic;
	var model_load :Array<String>;
}

/**
 * ...
 * @author 
 */
class PageController implements IController {

	var _oModel :Model;
	var _oView :View;
	var _mPathToPage :StringMap<PageHandle>;
	
	var _sRouteParamKey = '_route';
	
	
//_____________________________________________________________________________
// Constructor
	
	public function new( 
		oModel :Model,
		oView :View
	) {
		_mPathToPage = new StringMap<PageHandle>();
		_oModel = oModel;
		_oView = oView;
		// listen click link
		
		js.Browser.document.addEventListener( 'click', handleClickEvent );
		Browser.window.onpopstate = function( event ) {
			goto( Browser.document.location.pathname );
		}
	}
	
//_____________________________________________________________________________
// Accessor
	
	public function getModel() {
		return _oModel;
	}

//_____________________________________________________________________________
// Modifier
	
	public function addPageHandler( o :PageHandle ) {
		_mPathToPage.set( o.id, o );
	}

//_____________________________________________________________________________
// Process

	public function handleClickEvent( event :Event ) {
		
		// Handle link click
		// TODO : make sure to have the least priority on click event
		// TODO : handle form
		var oTarget :DOMElement = cast event.target;
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
				
			_oModel.setEntity(_sRouteParamKey, {
				id: oPageHandle.id, 
				param: ( o.length > 1 ) ? o.slice(1) : null,
			});
			
			oPageHandle.path_pattern.lastIndex = 0;
			oPageHandleCurrent = oPageHandle;
		}
		
		// Case : page not found
		if ( oPageHandleCurrent == null ) {
			oPageHandleCurrent = _mPathToPage.get('not_found');
		}
		
		
		_goto(
			oPageHandleCurrent, 
			js.Browser.location.protocol + '//'
			+ js.Browser.location.hostname
			+':' + js.Browser.location.port 
			+ sPath
		);
	}
	
	//public func+tion getUrl( oPageHandle :PageHandle ) {
		//return oPageHandle.;
	//}
	
	function _goto( oPageHandle :PageHandle, sFullPath :String ) {
		// Load model part
		//TODO : show loading style
		if (  oPageHandle.model_load == null )
			oPageHandle.model_load = new Array<String>();
		var aPromise = [for ( s in oPageHandle.model_load ) _oModel.loadEntity( s )];
		
		
		
		var oPromiseLoader = Promise.all(aPromise).then(function( oValue :Array<Dynamic> ) :Dynamic {
			
			if ( oPageHandle.page_data == null )
				oPageHandle.page_data = {};
			
			//oPageHandle.page_data.route = sPageKey;
			
			// Update view data
			if ( oPageHandle.page_data == null )
				oPageHandle.page_data = {};
			for ( s in oPageHandle.model_load ) {
				Reflect.setField( 
					oPageHandle.page_data, 
					s, _oModel.getEntity( s ) 
				);
			}
			
			// Push previous state
			js.Browser.window.history.pushState(
				{id: 0},
				"hellototo",
				sFullPath
			);
			
			_oView.setPageData( oPageHandle.page_data );
			try{ 
				_oView.diplay( oPageHandle.id );
			} catch ( e :Dynamic ) {
				return Promise.reject( e );
			}
			return oValue;
		});
		
		// Reject on timeout
		var oPromiseTimeout = new Promise(function(resolve:Dynamic->Void, reject:Dynamic->Void) {
			Timer.delay(function() {
				reject('Model loading timeout');
			}, 10000 ); // 10s
		});
		Promise.race( [oPromiseTimeout, oPromiseLoader] )
			.catchError(function( onRejected :PromiseHandler<Dynamic, Array<Dynamic>> ){
				trace( onRejected );
			}
		);
	}
	
}