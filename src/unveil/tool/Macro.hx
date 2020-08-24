package unveil.tool;
import haxe.io.Path;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.FileSystem;
import sys.io.File;

class Macro {
	public static function buildTemplate( s :String  ) :Array<Field> {
		
		var aFile = FileSystem.readDirectory( s );
		for ( sFileName in aFile ) {
			
			var sResName = Path.withoutExtension(sFileName);
			
			// Case : directory
			if ( FileSystem.isDirectory( Path.join([s,sFileName]) ) )
				continue;//TODO: recursive
			
			Context.addResource( sResName, File.getBytes(Path.join([s,sFileName])) );
		}
		
		// get the current fields of the class
		var fields:Array<Field> = Context.getBuildFields();
		
		
		return fields;
	}
}