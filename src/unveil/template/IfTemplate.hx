package unveil.template;
import sweet.functor.IFunction;

/**
 * ...
 * @author 
 */
class IfTemplate extends CompositeTemplate {
	var _oExpression :IFunction<Dynamic,Bool>;
	
	var _oElseblock :CompositeTemplate;
	
	public function new( oExpression :IFunction<Dynamic,Bool> ) {
		super();
		_oExpression = oExpression;
		_oElseblock = null;
	}
	override public function addPart( oPart :ITemplate ) {
		if ( _oElseblock == null )
			return super.addPart( oPart );
		_oElseblock.addPart( oPart );
	}
	
	public function setElseBlock() {
		_oElseblock = new CompositeTemplate();
	}
	
	override public function render( oContext :Dynamic, oBuffer :StringBuf = null  ) {
		if ( _oExpression.apply( oContext ) )
			return super.render( oContext, oBuffer );
		//else
			if ( _oElseblock != null )
				return _oElseblock.render( oContext, oBuffer );
		return oBuffer;
	}
}