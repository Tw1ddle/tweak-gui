package tweak.backend;

import tweak.gui.Folder;
import tweak.gui.FunctionProperty;
import tweak.gui.Property;

/**
 * An interface to the tweak-gui backends. Backends implement this.
 */
interface IBackend {	
	public function show(folder:Folder):Void;
	public function hide(folder:Folder):Void;
	
	public function addFolder(folder:Folder):Bool;
	public function removeFolder(folder:Folder):Bool;
	public function removeProperty(folder:Folder, property:Property):Bool;
	public function openFolder(folder:Folder):Void;
	public function closeFolder(folder:Folder):Void;
	
	public function addPlaceholder(folder:Folder, property:Property):Void;
	//public function addBooleanSwitch(folder:Folder, property:Property):Void; /* Unimplemented */
	public function addBooleanCheckbox(folder:Folder, property:Property):Void;
	public function addColorPicker(folder:Folder, property:Property):Void;
	public function addEnumSelect(folder:Folder, property:Property):Void;
	public function addStringSelect(folder:Folder, property:Property, options:Array<String>):Void;
	public function addNumericSlider(folder:Folder, property:Property, min:Float, max:Float):Void;
	public function addNumericSpinbox(folder:Folder, property:Property):Void;
	public function addStringEdit(folder:Folder, property:Property):Void;
	public function addFunction(folder:Folder, property:FunctionProperty):Void;
	public function addNumericGraph(folder:Folder, property:Property):Void;
	public function addWatchTextArea(folder:Folder, property:Property, history:Int):Void;
}