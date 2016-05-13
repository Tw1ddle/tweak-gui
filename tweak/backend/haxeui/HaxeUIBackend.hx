package tweak.backend.haxeui;

import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.controls.VScroll;
import haxe.ui.toolkit.core.Root;
import haxe.ui.toolkit.core.StyleableDisplayObject;
import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.core.interfaces.IDisplayObject;
import haxe.ui.toolkit.core.interfaces.InvalidationFlag;
import haxe.ui.toolkit.themes.GradientTheme;
import tweak.gui.Folder;
import tweak.gui.FunctionProperty;
import tweak.gui.Property;
import tweak.util.FileReader;

/**
 * A haxeui 1.* backend for tweak-gui.
 */ 
@:access(tweak.gui.Folder)
class HaxeUIBackend implements IBackend {
	private var root:VScroll;
	
	public function new() {
		Toolkit.theme = new GradientTheme();
		Toolkit.init();
		var view:IDisplayObject = Toolkit.processXml(Xml.parse(FileReader.readFile("lib/tweak/backend/haxeui/root_layout.xml")));
		root = new VScroll();
		root.text = "Root";
		Toolkit.openFullscreen(function(root:Root) {
			//root.addChild(this.root);
			
			// TODO populate a skeleton root view with elements, and define xml/code layouts for common skeleton items e.g. properties, folders etc
			root.addChild(view);
		});
	}
	
	public function show(folder:Folder):Void {
		root.visible = true;
	}
	
	public function hide(folder:Folder):Void {
		root.visible = false;
	}
	
	public function addFolder(folder:Folder):Bool {
		var list = new VBox();
		list.width = 100;
		list.height = 100;
		list.text = folder.name;
		list.id = getFolderId(folder);
		
		if (folder.parent == null) {
			root.addChild(list);
		} else {
			var f = findFolder(folder.parent);
			f.addChild(list);
		}
		
		root.invalidate(InvalidationFlag.ALL, true);
		root.layout.refresh();
		return true;
	}
	
	public function removeFolder(folder:Folder):Bool {
		var child = root.findChild(getFolderId(folder));
		Sure.sure(child != null);
		var removed = root.removeChild(child, true);
		return removed != null;
	}
	
	public function removeProperty(folder:Folder, property:Property):Bool {
		var f = findFolder(folder);
		var prop = findProperty(property, folder);
		var removed = f.removeChild(prop, true);
		//f.layout.refresh();
		return removed != null;
	}
	
	public function openFolder(folder:Folder):Void {
		
	}
	
	public function closeFolder(folder:Folder):Void {
		
	}
	
	public function addPlaceholder(folder:Folder, property:Property):Void {
		var f = findFolder(folder);
		f.addChild(makeProperty(property));
		//f.layout.refresh();
	}
	
	//public function addBooleanSwitch(folder:Folder, property:Property):Void; /* Unimplemented */
	
	public function addBooleanCheckbox(folder:Folder, property:Property):Void {
		var f = findFolder(folder);
		f.addChild(makeProperty(property));
		//f.layout.refresh();
	}
	
	public function addColorPicker(folder:Folder, property:Property):Void {
		var f = findFolder(folder);
		f.addChild(makeProperty(property));
		//f.layout.refresh();
	}
	
	public function addEnumSelect(folder:Folder, property:Property):Void {
		var f = findFolder(folder);
		f.addChild(makeProperty(property));
		//f.layout.refresh();
	}
	
	public function addStringSelect(folder:Folder, property:Property, options:Array<String>):Void {
		var f = findFolder(folder);
		f.addChild(makeProperty(property));
		//f.layout.refresh();
	}
	
	public function addNumericSlider(folder:Folder, property:Property, min:Float, max:Float):Void {
		var f = findFolder(folder);
		f.addChild(makeProperty(property));
		//f.layout.refresh();
	}
	
	public function addNumericSpinbox(folder:Folder, property:Property):Void {
		var f = findFolder(folder);
		f.addChild(makeProperty(property));
		//f.layout.refresh();
	}
	
	public function addStringEdit(folder:Folder, property:Property):Void {
		var f = findFolder(folder);
		f.addChild(makeProperty(property));
		//f.layout.refresh();
	}
	
	public function addFunction(folder:Folder, property:FunctionProperty):Void {
		var f = findFolder(folder);
		f.addChild(makeProperty(property));
		//f.layout.refresh();
	}
	
	public function addNumericGraph(folder:Folder, property:Property):Void {
		var f = findFolder(folder);
		f.addChild(makeProperty(property));
		//f.layout.refresh();
	}
	
	public function addWatchTextArea(folder:Folder, property:Property, history:Int):Void {
		var f = findFolder(folder);
		f.addChild(makeProperty(property));
		//f.layout.refresh();
	}
	
	private function makeProperty(property:Property):Button {
		var item = new Button();
		item.id = getPropertyId(property);
		item.text = property.name;
		return item;
	}
	
	private inline function getFolderId(f:Folder):String {
		return Std.string(f.id);
	}
	
	private inline function getPropertyId(p:Property):String {
		return Std.string(p.id);
	}
	
	private inline function findFolder(folder:Folder):StyleableDisplayObject {
		var folder = root.findChild(getFolderId(folder), null, true);
		Sure.sure(folder != null);
		return folder;
	}
	
	private inline function findProperty(property:Property, folder:Folder):StyleableDisplayObject {
		var f = findFolder(folder);
		var property = f.findChild(getFolderId(folder), null, true);
		Sure.sure(property != null);
		return property;
	}
}