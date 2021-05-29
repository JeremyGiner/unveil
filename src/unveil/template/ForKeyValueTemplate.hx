package unveil.template;
import haxe.ds.StringMap;
import haxe.ds.IntMap;
import haxe.iterators.DynamicAccessKeyValueIterator;
import haxe.iterators.MapKeyValueIterator;
import sweet.functor.IFunction;


/**
 * ...
 * @author 
 */
class ForKeyValueTemplate extends CompositeTemplate {
	var _oExpression :IFunction<Dynamic,KeyValueIterable<Dynamic,Dynamic>>;
	var _sKeyName :String;
	var _sVarName :String;
	var _oElseblock :CompositeTemplate;
	
	public function new( 
		oExpression :IFunction<Dynamic,KeyValueIterable<Dynamic,Dynamic>>, 
		sKeyName :String,
		sVarName :String 
	) {
		super();
		_oExpression = oExpression;
		_sVarName = sVarName;
		_sKeyName = sKeyName;
		_oElseblock = null;
	}
	
	override public function render( oContext :Dynamic, oBuffer :StringBuf = null  ) {
		var o = _oExpression.apply( oContext );
		var oIterator :KeyValueIterator<Dynamic,Dynamic> = _getIterator( o );
		
		// Case : empty
		if ( !oIterator.hasNext() && _oElseblock != null ) 
			return _oElseblock.render( Reflect.copy(oContext), oBuffer );
		
		// Render loop
		for ( k => v in oIterator ) {
			var oCurrentContext = Reflect.copy(oContext);
			Reflect.setField( oCurrentContext, _sKeyName, k);
			Reflect.setField( oCurrentContext, _sVarName, v);
			oBuffer = super.render( oCurrentContext, oBuffer );
		}
		return oBuffer;
	}
	
	private function _getIterator( o :Dynamic ) :KeyValueIterator<Dynamic,Dynamic> {
		if ( 
			Std.is( o, StringMap ) 
			|| Std.is( o, IntMap ) 
		)
			return new MapKeyValueIterator( cast o );
		return new DynamicAccessKeyValueIterator( o );
	}
	
//_____________________________________________________________________________
// Modifier

	override public function addPart( oPart :ITemplate ) {
		if ( _oElseblock == null )
			return super.addPart( oPart );
		_oElseblock.addPart( oPart );
	}
	
	public function setElseBlock() {
		_oElseblock = new CompositeTemplate();
	}
}