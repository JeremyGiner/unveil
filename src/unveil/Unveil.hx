package unveil;
import js.Browser;
import js.html.DOMElement;
import js.html.Event;
import unveil.compiler.ExpressionCompiler;
import unveil.template.Compiler;
import unveil.template.ITemplate;
import haxe.ds.StringMap;
import js.lib.RegExp;
import unveil.controller.PageController;
import unveil.loader.ILoader;

typedef Route = {
	var path_pattern :RegExp;
	var page_data :Dynamic;
}

typedef TemplateItem = {
	var key :String;
	var template :String;
}

/**
 * ...
 * @author 
 */
class Unveil {
	var _oModel :Model;
	var _oView :View;
	var _oPageController :PageController;
	
	public function new( 
		mModel :StringMap<Dynamic>,
		mPageHandle :Array<PageHandle>, 
		aTemplate :Array<TemplateItem> 
	) {
		_oModel = new Model();
		for ( s => o in mModel )
			if ( Std.is( o, ILoader ) )
				_oModel.setEntityLoader( s, o, false );
			else
				_oModel.setEntity( s, o );
		_oView = new View( _oModel );
		
		
		var oCompiler = new Compiler( Compiler.getDefaultConfig( new ExpressionCompiler(),_oView));
		
		for ( oItem in aTemplate ) {
			_oView.addTemplate( oItem.key, oCompiler.compile(oItem.template) );
		}
		
		
		_oPageController = new PageController( _oModel, _oView );
		for ( o in mPageHandle ) _oPageController.addPageHandler(o);
		_oPageController.goto( Browser.location.pathname );
	}
	
	public function getModel() {
		return _oModel;
	}

	public function getPageController() {
		return _oPageController;
	}
}