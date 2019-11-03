import unveil.tool.VPathAccessor;


class User {
    var _a :Array<User>;
    var _data :Dynamic;
    
    public function new() {
        _a = [this];
        _data = {
            type: 'titi',
        }
    }
    public function getName() {
        return 'toto';
    }
}

class VPathAccessorTest {
    static function main() {
        var oUser = new User();
        trace( oUser.getName() );
            
		//trace( 'getName()'.substring(0, 'getName()'.length-2) );
        
        var a = [1,2,3];
        trace( Reflect.field( oUser, 'getame' ) );
        
        var oAccessor = new VPathAccessor( '_a.0.toto.type' );
        trace('acessing : '+ oAccessor.apply(oUser) );
    }
}

