package tweak.backend;

import tweak.elements.Folder;
import tweak.elements.FunctionProperty;
import tweak.elements.IProperty;

// tweak-gui backends implement this
interface IBackend {	
	public function show(folder:Folder):Void;
	public function hide(folder:Folder):Void;
	
	public function addFolder(folder:Folder):Bool;
	public function removeFolder(folder:Folder):Bool;
	public function removeProperty(folder:Folder, property:IProperty):Bool;
	public function openFolder(folder:Folder):Void;
	public function closeFolder(folder:Folder):Void;
	
	public function addPlaceholder(folder:Folder, property:IProperty):Void;
	//public function addBooleanSwitch(folder:Folder, property:IProperty):Void; /* Unimplemented */
	public function addBooleanCheckbox(folder:Folder, property:IProperty):Void;
	public function addColorPicker(folder:Folder, property:IProperty):Void;
	public function addEnumSelect(folder:Folder, property:IProperty):Void;
	public function addStringSelect(folder:Folder, property:IProperty, options:Array<String>):Void;
	public function addNumericSlider(folder:Folder, property:IProperty, min:Float, max:Float):Void;
	public function addNumericSpinbox(folder:Folder, property:IProperty):Void;
	public function addStringEdit(folder:Folder, property:IProperty):Void;
	public function addFunction(folder:Folder, property:FunctionProperty):Void;
	public function addNumericGraph(folder:Folder, property:IProperty):Void;
	public function addWatchTextArea(folder:Folder, property:IProperty, history:Int):Void;
}