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
}