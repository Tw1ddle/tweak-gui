package tweak.backend.haxeui;

import haxe.ui.toolkit.containers.VBox;
import haxe.ui.toolkit.controls.Button;
import haxe.ui.toolkit.core.Root;
import haxe.ui.toolkit.core.StyleableDisplayObject;
import haxe.ui.toolkit.core.Toolkit;
import haxe.ui.toolkit.core.interfaces.InvalidationFlag;
import haxe.ui.toolkit.themes.GradientTheme;
import tweak.elements.Folder;
import tweak.elements.FunctionProperty;
import tweak.elements.IProperty;

// A haxeui backend
@:access(tweak.elements.Folder)
class HaxeUIBackend implements IBackend {
	private var root:VBox;
	
	public function new() {
		Toolkit.theme = new GradientTheme();
		Toolkit.init();
		root = new VBox();
		root.text = "Root";
		Toolkit.openFullscreen(function(root:Root) {
			root.addChild(this.root);
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
	
	public function removeProperty(folder:Folder, property:IProperty):Bool {
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
	
	public function addPlaceholder(folder:Folder, property:IProperty):Void {
		var f = findFolder(folder);
		f.addChild(makeProperty(property));
		//f.layout.refresh();
	}
	
	//public function addBooleanSwitch(folder:Folder, property:IProperty):Void; /* Unimplemented */
	
	public function addBooleanCheckbox(folder:Folder, property:IProperty):Void {
		var f = findFolder(folder);
		f.addChild(makeProperty(property));
		//f.layout.refresh();
	}
	
	public function addColorPicker(folder:Folder, property:IProperty):Void {
		var f = findFolder(folder);
		f.addChild(makeProperty(property));
		//f.layout.refresh();
	}
	
	public function addEnumSelect(folder:Folder, property:IProperty):Void {
		var f = findFolder(folder);
		f.addChild(makeProperty(property));
		//f.layout.refresh();
	}
	
	public function addStringSelect(folder:Folder, property:IProperty, options:Array<String>):Void {
		var f = findFolder(folder);
		f.addChild(makeProperty(property));
		//f.layout.refresh();
	}
	
	public function addNumericSlider(folder:Folder, property:IProperty, min:Float, max:Float):Void {
		var f = findFolder(folder);
		f.addChild(makeProperty(property));
		//f.layout.refresh();
	}
	
	public function addNumericSpinbox(folder:Folder, property:IProperty):Void {
		var f = findFolder(folder);
		f.addChild(makeProperty(property));
		//f.layout.refresh();
	}
	
	public function addStringEdit(folder:Folder, property:IProperty):Void {
		var f = findFolder(folder);
		f.addChild(makeProperty(property));
		//f.layout.refresh();
	}
	
	public function addFunction(folder:Folder, property:FunctionProperty):Void {
		var f = findFolder(folder);
		f.addChild(makeProperty(property));
		//f.layout.refresh();
	}
	
	public function addNumericGraph(folder:Folder, property:IProperty):Void {
		var f = findFolder(folder);
		f.addChild(makeProperty(property));
		//f.layout.refresh();
	}
	
	public function addWatchTextArea(folder:Folder, property:IProperty, history:Int):Void {
		var f = findFolder(folder);
		f.addChild(makeProperty(property));
		//f.layout.refresh();
	}
	
	private function makeProperty(property:IProperty):Button {
		var item = new Button();
		item.id = getPropertyId(property);
		item.text = property.name;
		return item;
	}
	
	private inline function getFolderId(f:Folder):String {
		return Std.string(f.id);
	}
	
	private inline function getPropertyId(p:IProperty):String {
		return Std.string(p.id);
	}
	
	private inline function findFolder(folder:Folder):StyleableDisplayObject {
		var folder = root.findChild(getFolderId(folder), null, true);
		Sure.sure(folder != null);
		return folder;
	}
	
	private inline function findProperty(property:IProperty, folder:Folder):StyleableDisplayObject {
		var f = findFolder(folder);
		var property = f.findChild(getFolderId(folder), null, true);
		Sure.sure(property != null);
		return property;
	}
}