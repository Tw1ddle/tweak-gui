package tweak.backend;

import tweak.gui.Folder;
import tweak.gui.FunctionProperty;
import tweak.gui.Property;

/**
 * An interface to the tweak-gui backends. Backends implement this to provide widget rendering and event handling for a platform/framework.
 */
interface IBackend {		
	// Folder operations.
	
	/**
	 * Makes the specified folder visible/unhidden.
	 * @param	folder	The folder to be made visible.
	 */
	public function show(folder:Folder):Void;
	
	/**
	 * Makes the specified folder invisible/hidden.
	 * @param	folder	The folder to be hidden.
	 */
	public function hide(folder:Folder):Void;
	
	/**
	 * Expands the folder from a closed state, if it was not already open.
	 * @param	folder	The folder to open.
	 */
	public function openFolder(folder:Folder):Void;
	
	/**
	 * Retracts the folder from an open state, if it was not already closed.
	 * @param	folder	The folder to close.
	 */
	public function closeFolder(folder:Folder):Void;
	
	/**
	 * Adds a child folder to the specified folder, as a subfolder.
	 * @param	folder	The folder which will have a subfolder added to it.
	 * @return	True if the folder was successfully added, false if the folder could not be added.
	 */
	public function addFolder(folder:Folder):Bool;
	
	/**
	 * Removes the specified folder from the backend.
	 * @param	folder	The folder to remove from the backend.
	 * @return	True if the folder was successfully removed, false if the folder could not be removed.
	 */
	public function removeFolder(folder:Folder):Bool;
	
	// Property operations.
	
	/**
	 * Removes a property from a folder.
	 * @param	folder	The folder to remove the property from.
	 * @param	property	The property to remove.
	 * @return 	True if the property was successfully removed from the folder, false if the property could not be removed.
	 */
	public function removeProperty(folder:Folder, property:Property):Bool;
	
	/**
	 * Adds a placeholder property to a folder.
	 * @param	folder	The folder to add the property to.
	 * @param	property	The placeholder property to add.
	 */
	public function addPlaceholder(folder:Folder, property:Property):Void;
	
	/**
	 * Adds a boolean checkbox property to a folder.
	 * @param	folder	The folder to add the property to.
	 * @param	property	The boolean property to add.
	 */
	public function addBooleanCheckbox(folder:Folder, property:Property):Void;
	
	/**
	 * Adds a color picker property to a folder.
	 * @param	folder	The folder to add the property to.
	 * @param	property	The color property to add.
	 */
	public function addColorPicker(folder:Folder, property:Property):Void;
	
	/**
	 * Adds an enum select property to a folder.
	 * @param	folder	The folder to add the property to.
	 * @param	property	The enum value property to add.
	 */
	public function addEnumSelect(folder:Folder, property:Property):Void;
	
	/**
	 * Adds a string select property to a folder.
	 * @param	folder	The folder to add the property to.
	 * @param	property	The string property to add.
	 * @param	options	The possible string values available to the user.
	 */
	public function addStringSelect(folder:Folder, property:Property, options:Array<String>):Void;
	
	/**
	 * Adds a numeric slider property to a folder.
	 * @param	folder	The folder to add the property to.
	 * @param	property	The numeric property to add.
	 * @param	min	The minimum value of the numeric slider.
	 * @param	max	The maximum value of the numeric slider.
	 */
	public function addNumericSlider(folder:Folder, property:Property, min:Float, max:Float):Void;
	
	/**
	 * Adds a numeric spinbox property to a folder.
	 * @param	folder	The folder to add the property to.
	 * @param	property	The numeric property to add.
	 */
	public function addNumericSpinbox(folder:Folder, property:Property):Void;
	
	/**
	 * Adds a string edit property to a folder.
	 * @param	folder	The folder to add the property to.
	 * @param	property	The string property to add.
	 */
	public function addStringEdit(folder:Folder, property:Property):Void;
	
	/**
	 * Adds a function triggering property to a folder.
	 * @param	folder	The folder to add the property to.
	 * @param	property	The function property to add.
	 */
	public function addFunction(folder:Folder, property:FunctionProperty):Void;
	
	/**
	 * Adds a readonly text area to a folder, that records previous values of the property it watches.
	 * @param	folder	The folder to add the property to.
	 * @param	property	The property to add.
	 * @param	history	The number of previous property values to retain in the text area.
	 */
	public function addWatchTextArea(folder:Folder, property:Property, history:Int):Void;
	
	/**
	 * Adds a numeric graph element that graphs the previous values of the property it watches.
	 * @param	folder	The folder to add the property to.
	 * @param	property	The property to add.
	 */
	public function addNumericGraph(folder:Folder, property:Property):Void;
}