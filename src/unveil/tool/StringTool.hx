package unveil.tool;

/**
 * ...
 * @author 
 */
class StringTool {

	static public function titleCase( s :String) {
		throw 'TODO';
	}
	static public function ucfirst( s :String) {
		
		return s.charAt(0).toUpperCase() 
			+ s.substr(1)
		;
	}
	
	static public function ltrim( sSubject :String, sMask :String ) {
		var i = 0;
		while( sSubject.charAt(i) == sMask.charAt(0) ) i++;
		return sSubject.substr(i);
	}
	static public function rtrim( sSubject :String, sMask :String ) {
		var i = sSubject.length-1;
		while( sSubject.charAt(i) == sMask.charAt(0) ) i--;
		return sSubject.substring(0, i+1);
	}
	
	static public function trim( sSubject :String, sMask :String ) {
		return rtrim(ltrim(sSubject,sMask),sMask);
	}
}