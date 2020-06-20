package unveil.loader;
import js.html.XMLHttpRequest;
import sweet.functor.IFunction;
import sweet.functor.builder.IFactory;
import unveil.loader.LoaderDefault;
import js.html.XMLHttpRequestResponseType;
import unveil.loader.ALoaderXhr.Pair;

/**
 * ...
 * @author ...
 */
class LoaderXhr extends ALoaderXhr {
	
	var _oBodyFactory :IFactory<String>;
	
	public function new( 
		sMethod :String,
		sUri :String,
		aHeader :Array<Pair<String>>,
		oBodyFactory :IFactory<String>,
		oResponseHandler :IFunction<XMLHttpRequest,Dynamic> = null,
		eResponseType :XMLHttpRequestResponseType = XMLHttpRequestResponseType.TEXT
	) {
		super(sMethod,sUri,aHeader,oResponseHandler,eResponseType);
		
		_oBodyFactory = oBodyFactory;
	}
	
	
	override public function getBody() :String {
		return _oBodyFactory.create();
	}
	
	
	
}