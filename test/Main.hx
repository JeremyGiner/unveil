package;
import js.lib.RegExp;
import unveil.template.Compiler;
import unveil.Template;
import unveil.Unveil;
import haxe.Resource;

class Main {

	static public function main() {
		
		var sTemplate = "::page.content::
::if(page.hello)::
Hello !
::else::
Not hello
::endif::
::for( sItem in page.array )::
	<p>::sItem::</p>
::endfor::";
		
		//TODO : create context and model
		new Unveil( [
			'home' => {
				path_pattern: new RegExp('\\/'),
				page_data: {
					hello: true,
					content: 'page content',
					array: ['item0','item1'],
				}
			},
			'not_found' => {
				path_pattern: new RegExp('\\/not-found'),
				page_data: null,
			}
		], [
			'home' => sTemplate,
		]);
	}
	
}