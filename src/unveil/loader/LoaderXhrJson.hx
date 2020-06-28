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
class LoaderXhrJson<C> extends LoaderXhrFunctor<C> {
	
	public function new( 
		sMethod :String,
		sUri :String,
		aHeader :Array<Pair<String>>,
		oBodyFactory :IFactory<Dynamic>,
		oResponseHandler :IFunction<XMLHttpRequest,C> = null,
		eResponseType :XMLHttpRequestResponseType = XMLHttpRequestResponseType.TEXT
	) {
		aHeader.push({left: "Content-Type", right: "application/json"});
		super(sMethod,sUri,aHeader,new JsonFactory(oBodyFactory),oResponseHandler,eResponseType);
	}
	
}

class JsonFactory implements IFactory<String> {
	var _o :IFactory<Dynamic>;
	public function new( o :IFactory<Dynamic> ) {
		_o = o;
	}
	public function create() {
		return Json.stringify(_o.create());
	}
}