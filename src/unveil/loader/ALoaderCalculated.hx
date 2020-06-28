package unveil.loader;
import js.html.XMLHttpRequest;
import unveil.Model;
import unveil.loader.ALoader;
import js.lib.Promise;


/**
 * ...
 * @author ...
 */
class ALoaderCalculated<C> extends ALoader<C> {

	var _oModel :Model;
	var _aInputKey :Array<String>;
	
	
	public function new( 
		oModel :Model,
		aInputKey :Array<String>
	) {
		super();
		_oModel = oModel;
		_aInputKey = aInputKey;
		
	}
	
	override public function callback(resolve:C->Void, reject:Dynamic->Void) {
		
		var aPromise = [];
		for ( s in _aInputKey )
			aPromise.push( _oModel.loadEntity(s) );
		Promise.all( aPromise ).then(function( a :Array<Dynamic> ) {
			resolve(calc( a )); 
		});
	}
	
	public function calc( a :Array<Dynamic> ) :C {
		throw 'override me';
		return null;
	}
	
}