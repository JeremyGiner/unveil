package unveil;
import haxe.ds.List;
import haxe.ds.StringMap;
import sweet.functor.IProcedure;
import sweet.functor.IFunction;
import unveil.tool.VPathAccessor;


/**
 * 
 */
/*
class Expression implements IProcedure<Dynamic> {
	
	var _fn :IFunction<Dynamic,Dynamic>;
	var _oContextHolder :ContextHolder;	
	
	public function new( 
		oContextHolder, 
		fn :Dynamic->Dynamic->Dynamic 
	) {
		_oContextHolder = oContextHolder;
	}
	
	public function process() {
		return _fn( _oContextHolder.context );
	}
}

class CompareEqual implements IFunction<Dynamic,Bool> {
	
	var _fnRight :IFunction<Dynamic,Dynamic>;
	var _fnLeft :IFunction<Dynamic,Dynamic>;
	
	public function new( 
		_fnRight :IFunction<Dynamic,Dynamic>,
		_fnLeft :IFunction<Dynamic,Dynamic>
	) {
		
	}
	
	public function apply( oContext :Dynamic ) {
		return _fnRight( oContext ) == _fnLeft.apply( oContext );
	}
	
}
*/