package unveil;
import js.Browser;
import js.html.DOMElement;
import js.html.Event;
import unveil.template.Compiler;
import unveil.template.ITemplate;
import haxe.ds.StringMap;
import js.lib.RegExp;
import unveil.controller.PageController;

typedef Route = {
	var path_pattern :RegExp;
	var page_data :Dynamic;
}

/**
 * ...
 * @author 
 */
class Unveil {
	var _oModel :Model;
	var _oView :View;
	var _oPageController :PageController;
	
	public function new( mRoute :StringMap<Route>, mTemplate :StringMap<String> ) {
		_oModel = new Model();
		_oView = new View( _oModel );
		
		
		var oCompiler = new Compiler(_oView);
		
		for ( sKey => sTemplate in mTemplate ) {
			_oView.addTemplate( sKey, oCompiler.compile(sTemplate) );
		}
		
		var mPageResolver = new StringMap<PageHandle>();// List?
		for ( sKey => oRoute in mRoute ) {
			//_oView.addTemplate( sKey, oRoute.template );
			mPageResolver.set( sKey, {
				path_pattern: oRoute.path_pattern, 
				page_data:  oRoute.page_data,
			} );
		}
		
		
		_oPageController = new PageController( mPageResolver, _oView );
		_oPageController.goto( Browser.location.pathname );
	}

	public function getPageController() {
		return _oPageController;
	}
}