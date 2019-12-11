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
		
		var oCompiler = new Compiler();
		
		//TODO : create context and model
		new Unveil( [
			'home' => {
				path_pattern: new RegExp('\\/'),
				template: oCompiler.compile( sTemplate ),
				page_data: {
					hello: true,
					content: 'page content',
					array: ['item0','item1'],
				}
			},
			'not_found' => {
				path_pattern: new RegExp('\\/not-found'),
				template: oCompiler.compile( sTemplate ),
				page_data: null,
			}
		] );
	}
	
}