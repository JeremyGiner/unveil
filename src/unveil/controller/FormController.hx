package unveil.controller;
import haxe.ds.StringMap;
import js.Browser;
import js.html.DOMElement;
import js.html.Event;
import js.html.InputElement;
import js.html.ButtonElement;
import js.html.Element;
import js.html.XMLHttpRequest;

import unveil.controller.PageController;
import sweet.functor.IFunction;
import js.html.FormElement;

/**
 * TODO : handle 
 * @author ...
 */
class FormController {
	
	var _sFormId :String;
	var _m :StringMap<IFunction<FormElement,Void>>;
	
	public function new( m :StringMap<IFunction<FormElement,Void>> ) {
		_m = m;
		Browser.document.addEventListener( 'submit', handleEvent );
	}
	
	public function handleEvent( event :Event ) {
		
		// Handle link click
		// TODO : make sure to have the least priority on click event
		// TODO : handle form
		var oTarget :DOMElement = cast event.originalTarget;
		if ( 
			!Std.is( oTarget, DOMElement ) 
			|| !_m.exists( oTarget.id )
		)
			return;
			
		event.preventDefault();
		// TODO : Filter : uri#id
		
		//trace(js.Browser.location);
		var oForm :js.html.FormElement = cast oTarget;
		
		_m.get( oTarget.id ).apply( oForm );
    }
	
	static public function getInputMap( oForm :js.html.FormElement ) :Dynamic {
		var m = {};
		
		for ( i in 0...oForm.length ) {
			var oElement :Element = cast oForm[i];
			if ( 
				untyped oElement.name == null 
				|| untyped oElement.name == '' 
				|| untyped oElement.value == null 
			)
				continue;
			//TODO : handle select
			Reflect.setField( m, untyped oElement.name, untyped oElement.value );
		}
		
		return m;
	}
	
	
}