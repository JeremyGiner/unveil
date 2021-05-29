package unveil.tool;

/**
 * ...
 * @author 
 */

class StringStream {
	
	var _s :String;
	var _i :Int;
	
	// Debug info
	var _iLine :Int;
	var _iColumn :Int;
	
	public function new( s :String ) {
		_s = s;
		if ( s == null ) throw '!!!';
		_i = 0;
		_iLine = 0;
		_iColumn = 0;
	}
	
	public function getPosition() {
		return _i;
	}
	
	public function getRemaining() {
		return _s.substr( _i );
	}
	
	public function getNextWord() {
		var iPos = _i;
		while ( iPos < _s.length ){
			if ( ! StringStream.isAlphaNum( _s.charAt( iPos ) ) ) {
				break;
			}
			iPos++;
		}
		
		// Case : no word
		if ( iPos <= _i ) return null;
		
		
		return this.read( iPos - _i );
	}
	
	public function getDebugInfo() {
		return [
			'line' => _iLine,
			'column' => _iColumn,
		];
	}
	
	public function getClosest( aNeedle :Array<String> ) :{position:Int,needle:String} {
		for ( i in _i..._s.length  ) 
		for ( sNeedle in aNeedle  ) {
			if ( 
				sNeedle.charAt(0) == _s.charAt(i)
				&& _s.substr( i, sNeedle.length ) == sNeedle
			)
				return {
					position: i,
					needle: sNeedle
				};
		}
		return null;
	}
	
	public function move( i :Int ) {
		if ( i >= _s.length ) throw '!!!';
		_i = i;
		trace('move:'+i);
	}
	
	public function ignoreWhitespace() {
		while ( _i < _s.length ) {
			
			var char = _s.charAt( _i );
			if ( 
				char != ' ' 
				&& char != '\n' 
				&& char != '\r' 
				&& char != '\t' 
			)
				return;
			
			_i++;
		}
	}
	
	public function startWith( s :String ) {
		for ( i in 0...s.length )
			if ( _s.charAt(_i + i) != s.charAt(i) )
				return false;
		return true;
	}
	
	public function charAt( i :Int) {
		if ( _i + i >= _s.length ) throw '!!!';
		return _s.charAt( _i + i );
	}
	
	public function read( iLength :Int ) {
		if ( _i + iLength >= _s.length ) throw '!!!';
		var s = _s.substr( _i, iLength );
		_i += iLength;
		trace(s);
		return s;
	}
	
	public function eat( s :String ) {
		if ( !startWith( s ) ) throw 'Expected "'+s+'" got "'+_s.substr( _i, s.length ) + '" '+getDebugInfo().toString();
		return read( s.length );
	}
	
	static public function isAlpha( s :String ) {
		return ('a' <= s && s <= 'z') 
			|| ('A' <= s && s <= 'Z') 
		;
	}
	
	static public function isNum( s :String ) {
		return ('0' <= s && s <= '9');
	}
	
	static public function isAlphaNum( s :String ) {
		return isAlpha( s ) || isNum( s );
	}
	
	
}
