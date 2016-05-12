package tweak.backend.luxe;

import tweak.backend.IBackend;
import tweak.elements.Folder;
import tweak.elements.FunctionProperty;
import tweak.elements.IProperty;

// Luxe engine backend
class LuxeBackend implements IBackend {
	public function new() {
		trace("Initializing stub tweak-gui backend");
	}
	
	public function show(folder:Folder):Void {
		trace("Showing folder " + folder.name);
	}
	
	public function hide(folder:Folder):Void {
		trace("Hiding folder " + folder.name);
	}
	
	public function addFolder(folder:Folder):Bool {
		trace("Adding folder " + folder.name);
		return true;
	}
	
	public function removeFolder(folder:Folder):Bool {
		trace("Removing folder " + folder.name);
		return true;
	}
	
	public function removeProperty(folder:Folder, property:IProperty):Bool {
		trace("Removing property " + property.name + " from folder " + folder.name);
		return true;
	}
	
	public function openFolder(folder:Folder):Void {
		trace("Opening folder " + folder.name);
	}
	
	public function closeFolder(folder:Folder):Void {
		trace("Closing folder " + folder.name);
	}
	
	public function addPlaceholder(folder:Folder, property:IProperty):Void {
		trace("Adding placeholder " + property.name + " to folder " + folder.name);
	}
	
	//public function addBooleanSwitch(folder:Folder, property:IProperty):Void; /* Unimplemented */
	
	public function addBooleanCheckbox(folder:Folder, property:IProperty):Void {
		trace("Adding boolean checkbox " + property.name + " to folder " + folder.name);
	}
	
	public function addColorPicker(folder:Folder, property:IProperty):Void {
		trace("Adding color picker " + property.name + " to folder " + folder.name);
	}
	
	public function addEnumSelect(folder:Folder, property:IProperty):Void {
		trace("Adding enum select " + property.name + " to folder " + folder.name);
	}
	
	public function addStringSelect(folder:Folder, property:IProperty, options:Array<String>):Void {
		trace("Adding string select " + property.name + " to folder " + folder.name + " with options " + options);
	}
	
	public function addNumericSlider(folder:Folder, property:IProperty, min:Float, max:Float):Void {
		trace("Adding numeric slider " + property.name + " to folder " + folder.name + " with min/max " + min + "/" + max);
	}
	
	public function addNumericSpinbox(folder:Folder, property:IProperty):Void {
		trace("Adding numeric spinbox select " + property.name + " to folder " + folder.name);
	}
	
	public function addStringEdit(folder:Folder, property:IProperty):Void {
		trace("Adding string edit " + property.name + " to folder " + folder.name);
	}
	
	public function addFunction(folder:Folder, property:FunctionProperty):Void {
		trace("Adding function " + property.name + " to folder " + folder.name);
	}
	
	public function addNumericGraph(folder:Folder, property:IProperty):Void {
		trace("Adding numeric graph " + property.name + " to folder " + folder.name);
	}
	
	public function addWatchTextArea(folder:Folder, property:IProperty, history:Int):Void {
		trace("Adding watch text area " + property.name + " to folder " + folder.name + " with a history of " + history);
	}
}