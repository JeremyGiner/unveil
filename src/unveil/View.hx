package unveil;
import haxe.ds.StringMap;
import js.html.Element;
import unveil.template.ITemplate;
import unveil.Model;
import unveil.loader.ILoader;


typedef Context = {
	var template :StringMap<ITemplate>;
	var model :Dynamic;
	var page :Dynamic;
}

/**
 * ...
 * @author 
 */
class View {

	var _mTemplate :StringMap<ITemplate>; 
	var _mTemplateLoader :StringMap<ILoader<ITemplate>>;
	var _oContext :Context;
	
//_____________________________________________________________________________
// Constructor
	
	public function new( oModel :Dynamic ) {
		_mTemplate = new StringMap<ITemplate>(); 
		_mTemplateLoader = new StringMap<ILoader<ITemplate>>();
		_oContext = {
			template: _mTemplate,
			model: oModel,
			page: {}
		}
	}
	
//_____________________________________________________________________________
// Accessor
	
	public function getTemplate(sKey) {
		return _mTemplate.get(sKey);
	}
	
//_____________________________________________________________________________
// Modifier
	
	public function setPageData( oData :Dynamic ) {
		_oContext.page = oData;
	}
	
	public function addTemplate( sKey :String, oTemplate :ITemplate ) {
		
		if ( _mTemplate.exists(sKey) )
			throw 'template '+sKey+' already exist';
		
		_mTemplate.set(sKey,oTemplate);
	}
	
	public function addPageTemplateLoader( sKey :String, oTemplate :ILoader<ITemplate> ) {
		
		if ( _mTemplate.exists(sKey) || _mTemplateLoader.exists(sKey) )
			throw 'template ' + sKey + ' already exist';
			
		_mTemplateLoader.set(sKey,oTemplate);
	}
	
//_____________________________________________________________________________
// Process
	
	public function diplay( sPageKey ) {
		
		if ( _mTemplateLoader.exists(sPageKey) )
			_mTemplateLoader.get(sPageKey).load();
		
		// Get template
		if ( !_mTemplate.exists(sPageKey) )
			throw 'template '+sPageKey+' does not exist';
		
		// Display loading placeholder
		// Acquire all loader from model
		var aLoader = [];
		// Case : no loader render immediatly
		if ( aLoader.length == 0 ) {
			
		}
		
		var oTemplate = _mTemplate.get(sPageKey);
		
		// Get wrapper
		var oWrapper = js.Browser.document.getElementById( sPageKey );
		if( oWrapper == null ) {
			oWrapper = js.Browser.document.createElement('div');
			oWrapper.id = sPageKey;
			js.Browser.document.body.append( oWrapper );
		}
		
		// Render
		oWrapper.innerHTML = oTemplate.render(_oContext).toString();
		
		return oWrapper;
	}
}