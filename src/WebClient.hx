import js.html.EventListener;
import js.html.Event;

class Test {
  static function main() {
      trace( js.Browser.location.pathname );
      var o =new LinkClickEL();
      js.Browser.document.addEventListener( 'click', o.handleClickEvent );
      js.Browser.document.addEventListener( 'popstate', o.handlePopStateEvent );
      
      
      trace(js.Browser.location.protocol+'//'+ js.Browser.location.hostname+ '/toto');
      js.Browser.window.history.pushState(
          {},
          "hellototo",
          js.Browser.location.protocol+'//'+ js.Browser.location.hostname+ '/toto'
      );
      
    var sample = "My name is <strong>::_name::</strong>, <em>::age::</em> years old";
    var user = new User();
    var template = new haxe.Template(sample);
    var output = template.execute(user);
    trace(output);
  }
}

class User {
    var _name :String;
    var _age :Int;
    
    public var self :User;
    
    public function new() {
        _name = 'toto';
        _age = 2;
        self = this;
    }
    
    public function getName() {
        return _name;
    }
    
    public function getAge() {
        return _age;
    }
    public function toString() {
        return 'hello';
    }
}

class LinkClickEL {
    public function new() {
        
    }
    
    public function handleClickEvent( event :Event ) {
       trace(js.Browser.location);
    }
    
    public function handlePopStateEvent( event :Event ) {
        trace('popping state : '+js.Browser.location);
    }
}