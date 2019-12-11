package unveil.template;

/**
 * ...
 * @author 
 */
class CompositeTemplate implements ITemplate {

	var _aTemplate :Array<ITemplate>;
	
	public function new() {
		_aTemplate = new Array<ITemplate>();
	}
	
	public function render( oContext :Dynamic, oBuffer :StringBuf = null  ) {
		oBuffer = oBuffer == null ? new StringBuf() : oBuffer;
		for ( o in _aTemplate )
			o.render(oContext,oBuffer);
		
		return oBuffer;
	}
	
	public function addPart( oPart :ITemplate ) {
		_aTemplate.push( oPart );
	}
}