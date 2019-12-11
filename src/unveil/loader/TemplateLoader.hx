package;
import js.html.XMLHttpRequest;
import unveil.Compiler;
import unveil.ITemplate;

/**
 * ...
 * @author 
 */
class TemplateLoader implements ILoader<ITemplate> {

	var _aCallback :List<ILoader->Void>;
	var _oRequest :XMLHttpRequest;
	var _oData :ITemplate;
	var _oCompiler :Compiler;
	
	public function new( sKey :String  ) {
		_oRequest = new XMLHttpRequest();
		_oRequest.open('GET', '_res/' + sKey + '.template');
	}
	public function load() {
		_oRequest.send();
	}
	public function getHxr()
	public function getData() :C;
	public function getstatus() :Int;
	public function onLoad( fn :ILoader->Void ) {
		_oRequest.addEventListener('load',_onLoad)
	}
	
	function _onLoad() {
		
		if ( _oRequest.responseText == null )
			throw 'no response';
		
		_oData = _oCompiler.compile( _oRequest.responseText );
	}
}