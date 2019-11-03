package;
import unveil.Template;
import unveil.RouterDefault;
import unveil.Unveil;

/**
 * ...
 * @author 
 */
class Main {

	static public function main() {
		//TODO : create context and model
		new Unveil( new RouterDefault( [
			'/' => new Template( "Hello ::user.getName::" ),
		] ));
	}
	
}