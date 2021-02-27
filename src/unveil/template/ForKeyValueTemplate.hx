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
	
	public function new( 
		oExpression :IFunction<Dynamic,KeyValueIterable<Dynamic,Dynamic>>, 
		sKeyName :String,
		sVarName :String 
	) {
		super();
		_oExpression = oExpression;
		_sVarName = sVarName;
		_sKeyName = sKeyName;
	}
	
	override public function render( oContext :Dynamic, oBuffer :StringBuf = null  ) {
		var o = _oExpression.apply( oContext );
		var oIterator :KeyValueIterator<Dynamic,Dynamic> = _getIterator( o );
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
}