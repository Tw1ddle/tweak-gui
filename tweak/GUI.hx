package tweak;

import tweak.elements.Folder;

#if customdombackend
import tweak.backend.dom.CustomDOMBackend;
#elseif threejsbackend
import tweak.backend.three.ThreeJSBackend;
#elseif haxeuibackend
import tweak.backend.haxeui.HaxeUIBackend;
#elseif stubbackend
import tweak.backend.stub.StubBackend;
#end

// A top level GUI object. Create and add folders to it.
class GUI extends Folder {
	#if customdombackend
	private function new(name:String) {
		super(name, null);
		backend = new CustomDOMBackend();
		backend.addFolder(this);
	}
	#elseif threejsbackend
	private function new(name:String) {
		super(name, null);
		backend = new ThreeJSBackend();
		backend.addFolder(this);
	}
	#elseif haxeuibackend
	private function new(name:String) {
		super(name, null);
		backend = new HaxeUIBackend();
		backend.addFolder(this);
	}
	#elseif stubbackend
	private function new(name:String) {
		super(name, null);
		backend = new StubBackend();
		backend.addFolder(this);
	}
	#else
	#error "No backend configured for this platform. Set the tweak-gui renderer in your build configuration."
	#end
	
	// Create a new GUI with the provided name
	public static function create(name:String):GUI {
		Sure.sure(name != null);
		return new GUI(name);
	}
}