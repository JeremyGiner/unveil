package unveil.loader;
import js.html.XMLHttpRequest;
import sweet.functor.IFunction;
import sweet.functor.builder.IFactory;
import js.html.XMLHttpRequestResponseType;
import unveil.loader.ALoaderXhr.Pair;

/**
 * ...
 * @author ...
 */
class LoaderXhrFunctor<C> extends ALoaderXhr<C> {
	
	var _oResponseHandler :IFunction<XMLHttpRequest,Dynamic>;
	var _oBodyFactory :IFactory<String>;
	
	public function new( 
		sMethod :String,
		sUri :String,
		aHeader :Array<Pair<String>>,
		oBodyFactory :IFactory<String>,
		oResponseHandler :IFunction<XMLHttpRequest,C> = null,
		eResponseType :XMLHttpRequestResponseType = XMLHttpRequestResponseType.TEXT
	) {
		super(sMethod,sUri,aHeader,eResponseType);
		
		_oBodyFactory = oBodyFactory;
		_oResponseHandler = oResponseHandler;
	}
	
	override public function handleResponse( oReq :XMLHttpRequest ) :C {
		return _oResponseHandler.apply(oReq);
	}
	
	
	override public function getBody() :String {
		return _oBodyFactory.create();
	}
	
	
	
}