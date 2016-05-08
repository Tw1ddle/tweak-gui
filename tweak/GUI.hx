package tweak;

import tweak.elements.Folder;

#if customdomrenderer
import tweak.backend.dom.CustomDOMBackend;
#elseif threejsrenderer
import tweak.backend.three.ThreeJSBackend;
#elseif haxeuirenderer
import tweak.backend.haxeui.HaxeUIBackend;
#end

// A top level GUI object. Create and add folders to it.
class GUI extends Folder {
	#if customdomrenderer
	private function new(name:String) {
		super(name, null);
		backend = new CustomDOMBackend();
		backend.addFolder(this);
	}
	#elseif threejsrenderer
	private function new(name:String) {
		super(name, null);
		backend = new ThreeJSBackend();
		backend.addFolder(this);
	}
	#elseif haxeuirenderer
	private function new(name:String) {
		super(name, null);
		backend = new HaxeUIBackend();
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