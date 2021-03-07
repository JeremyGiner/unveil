package unveil.tool;
import sweet.functor.IFunction;
import haxe.ds.StringMap;

class VPathAccessor implements IFunction<Dynamic,Dynamic> {
    
    var _aPath :Array<String>;
    
    public function new( sPath :String ) {
        _aPath = parsePath( sPath );
    }
    
    public function apply( o :Dynamic ) {
        var oRes = o;
        for ( sPathPart in _aPath ) {
			try {
				oRes = getAccess( oRes, sPathPart );
			} catch ( e :Dynamic ) {
				throw 'cannot access "' + _aPath + '" because : ' + e;
			}
		}
        return oRes;
    }
    
    function getAccess( o :Dynamic, sPathPart :String ) :Dynamic {
		if( o == null )
			throw sPathPart + ' parent is null';
		
		// Case string map
		if ( Std.is( o, StringMap ) )
			return cast(o, StringMap<Dynamic>).get( sPathPart );
		
        var oRes = Reflect.field( o, sPathPart );
        
		// Case : method
		if( Reflect.isFunction( oRes ) )
            oRes = Reflect.callMethod( o, oRes, [] );
		
		// Case : member
		return oRes;
    }
    
    static public function parsePath( sPath :String ) {
        
		// Split
		var a = sPath.split('.');

		// Remove trailling ()
		a = a.map( function( s :String ) { 
			if( s.substr(-2) == '()' ) 
				return s.substring(0, s.length-2); 
			return s; 
		});
            
        return a;
    }
}
