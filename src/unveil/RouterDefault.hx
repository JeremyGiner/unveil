package unveil;
import haxe.ds.StringMap;
import js.html.Location;

/**
 * ...
 * @author 
 */
class RouterDefault implements IRouter {
	
	var _aTemplate :StringMap<ITemplate>;

	public function new( aTemplate :StringMap<ITemplate> ) {
		_aTemplate = aTemplate;
	}
	
	public function getTemplate( oLocation :Location ) {
		
		return _aTemplate.get( oLocation.pathname );
	}
	
}