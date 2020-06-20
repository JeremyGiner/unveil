package unveil.loader;
import haxe.Json;
import js.html.XMLHttpRequest;
import js.html.XMLHttpRequestResponseType;
import sweet.functor.builder.FactoryCloner;
import sweet.functor.IFunction;
import sweet.functor.builder.IFactory;
import unveil.loader.ALoaderXhr.Pair;


/**
 * ...
 * @author ...
 */
class LoaderXhrJson extends ALoaderXhr {
	
	var _oBodyFactory :IFactory<Dynamic>;
	
	public function new( 
		sMethod :String,
		sUri :String,
		aHeader :Array<Pair<String>>,
		oBodyFactory :IFactory<Dynamic>,
		oResponseHandler :IFunction<XMLHttpRequest,Dynamic> = null,
		eResponseType :XMLHttpRequestResponseType = XMLHttpRequestResponseType.TEXT
	) {
		aHeader.push({left: "Content-Type", right: "application/json"});
		super(sMethod,sUri,aHeader,oResponseHandler,eResponseType);
		
		_oBodyFactory = oBodyFactory;
	}
	
	
	override public function getBody() :String {
		return Json.stringify(_oBodyFactory.create());
	}
	
}