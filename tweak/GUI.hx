package tweak;

#if tweak_customdombackend
import tweak.backend.dom.CustomDOMBackend;
#elseif tweak_threejsbackend
import tweak.backend.three.ThreeJSBackend;
#elseif tweak_haxeuibackend
import tweak.backend.haxeui.HaxeUIBackend;
#elseif tweak_flixelbackend
import tweak.backend.flixel.FlixelBackend;
#elseif tweak_stubbackend
import tweak.backend.stub.StubBackend;
#end

import tweak.backend.IBackend;
import tweak.gui.Folder;

/**
 * A GUI is a top level graphical container for Folders and Properties. A GUI instance is the starting point for all tweak-gui projects.
 * Multiple GUIs can be instantiated and exist side-by-side. A GUI is actually a type of folder, and may be identical, depending on the tweak-gui backend used.
 */
class GUI extends Folder {
	/**
	 * Instantiate a new GUI with the given display name.
	 * @param	name	The display name of the GUI folder.
	 * @return	The new GUI for chaining.
	 */ 
	public static function create(name:String):GUI {
		Sure.sure(name != null);
		return new GUI(name);
	}
	
	/**
	 * Instantiate a new GUI.
	 * Private constructor, because the tweak-gui interface is fluent.
	 * @param	name	The display name of the GUI folder.
	 */
	private function new(name:String) {
		super(name, null);
		this.backend = instantiateBackend();
		this.backend.addFolder(this);
	}
	
	/**
	 * Instantiate a backend for this GUI instance.
	 * @return	A backend instance for this GUI.
	 */ 
	private inline function instantiateBackend():IBackend {
		#if tweak_customdombackend
		return new CustomDOMBackend();
		#elseif tweak_threejsbackend
		return new ThreeJSBackend();
		#elseif tweak_haxeuibackend
		return new HaxeUIBackend();
		#elseif tweak_flixelbackend
		return new FlixelBackend();
		#elseif tweak_stubbackend
		return new StubBackend();
		#else
		#error "No backend configured for this platform. Set the desired tweak-gui backend in your build configuration."
		#end
	}
}