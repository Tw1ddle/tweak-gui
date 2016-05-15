package tweak.gui;

import haxe.Constraints.Function;
import msignal.Signal.Signal1;
import msignal.Signal.Signal2;
import tweak.backend.IBackend;
import tweak.gui.Property;
import tweak.util.Util;

// TODO disable folder updates when closed, or add an option for that?
// TODO disable properties (stop them from being edited) and disable/enable all folder contents from being edited?
// TODO addFolder/WatchForTypes (only add/watch specific types, exclude only specific types, named fields etc...)

/**
 * A tweak-gui folder. A folder holds properties and other folders.
 * Folders can be opened, closed, shown, hidden and removed from their parent Folder or GUI.
 */
class Folder extends BaseElement {
	/**
	 * Handle to the platform/rendering tweak-gui backend for this folder.
	 */
	private var backend:IBackend;
	
	/**
	 * The parent of this folder. This should only be null if the folder is at the root of a hierarchy, and is a GUI.
	 */
	private var parent:Folder;
	
	/**
	 * The immediate child folders (subfolders) that currently exist in this folder.
	 */
	private var folders:Array<Folder>;
	
	/**
	 * The properties that currently exist on this folder, not including properties on child folders.
	 */
	private var properties:Array<BaseProperty>;
	
	/**
	 * A signal that is dispatched after this folder and all child folders (and properties) have updated.
	 * @param	first	This folder.
	 */
	public var signal_didUpdate(default, null) = new Signal1<Folder>();
	
	/**
	 * A signal that is dispatched after another folder is added to this folder.
	 * @param	first	This folder.
	 * @param	second	The folder added to this folder.
	 */
	public var signal_didAddFolder(default, null) = new Signal2<Folder, Folder>();
	
	/**
	 * A signal that is dispatched after a child folder is removed from this current.
	 * @param	first	This folder.
	 * @param	second	The folder removed from this folder.
	 */
	public var signal_didRemoveFolder(default, null) = new Signal2<Folder, Folder>();
	
	/**
	 * A signal that is dispatched after a new property is added to this folder.
	 * @param	first	This folder.
	 * @param	second	The property added to this folder.
	 */
	public var signal_didAddProperty(default, null) = new Signal2<Folder, BaseProperty>();
	
	/**
	 * A signal that is dispatched after a property in this folder is removed.
	 * @param	first	This folder.
	 * @param	second	The property removed from this folder.
	 */
	public var signal_didRemoveProperty(default, null) = new Signal2<Folder, BaseProperty>();
	
	/**
	 * A signal that is dispatched after this folder is closed.
	 * @param	first	This folder.
	 */
	public var signal_didOpen(default, null) = new Signal1<Folder>();
	
	/**
	 * A signal that is dispatched after this folder is closed.
	 * @param	first	This folder.
	 */
	public var signal_didClose(default, null) = new Signal1<Folder>();
	
	/**
	 * Updates all the properties in this folder, and then calls update on all child folders in an unspecified order.
	 */
	override public function update():Void {
		for (property in properties) {
			property.update();
		}
		
		if (folders != null) {
			for (folder in folders) {
				folder.update();
			}
		}
		
		signal_didUpdate.dispatch(this);
	}
	
	/**
	 * Opens this folder to an expanded position, showing children.
	 * @return	This folder.
	 */
	public function open():Folder {
		backend.openFolder(this);
		signal_didOpen.dispatch(this);
		return this;
	}
	
	/**
	 * Collapses this folder to a closed position.
	 * @return	This folder.
	 */
	public function close():Folder {
		backend.closeFolder(this);
		signal_didClose.dispatch(this);
		return this;
	}
	
	/**
	 * Shows this folder, making it visible to the user.
	 * @return	This folder.
	 */
	public function show():Folder {
		backend.show(this);
		return this;
	}
	
	/**
	 * Hides this folder, making it invisible to the user.
	 * @return	This folder.
	 */
	public function hide():Folder {
		backend.hide(this);
		return this;
	}
	
	/**
	 * Adds a new subfolder with the given display name to this folder.
	 * @param	name	The display name for the new folder.
	 * @return	The newly added folder - this makes this method different from the rest of the fluid interface.
	 */
	public function addFolder(name:String):Folder {
		Sure.sure(name != null && name.length > 0);
		
		var folder = new Folder(name, this);
		folders.push(folder);
		var added = backend.addFolder(folder);
		Sure.sure(added);
		
		if (added) {
			signal_didAddFolder.dispatch(parent, this);
		}
		
		return folder;
	}
	
	/**
	 * Removes this folder from the GUI.
	 * The folder removes itself from it's own parent, and then from the backend.
	 * @return	This folder.
	 */
	public function remove():Folder {
		if(parent != null) {
			var removed = parent.folders.remove(this);
			Sure.sure(removed);
		}
		
		var removed = backend.removeFolder(this);
		Sure.sure(removed);
		
		if(removed) {
			signal_didRemoveFolder.dispatch(parent, this);
		}
		
		return this;
	}
	
	/**
	 * Attempts to add a property control to this folder automatically, by reflecting on the property type.
	 * Note, beware of reference loops with nested objects, as these will cause an infinite loop in this method.
	 * It is impossible to get the number of parameters a function takes in a cross platform way using reflection, so text labels are added instead of function controls.
	 * @param	object	The object whose field will be added as a property.
	 * @param	field	The name of the field on the object.
	 * @return	This folder.
	 */
	public function addProperty<T:{}>(object:T, field:String):Folder {
		Sure.sure(object != null);
		Sure.sure(field != null && field.length > 0);
		var property = Reflect.getProperty(object, field);
		
		if (Std.is(property, Int) || Std.is(property, Float)) {
			addNumericSpinbox(object, field);
		} else if (Std.is(property, String)) {
			addStringEdit(object, field);
		} else if (Std.is(property, Bool)) {
			addBooleanCheckbox(object, field);
		} else if (Reflect.isFunction(property)) {
			addPlaceholder(object, field);
		} else if (Reflect.isEnumValue(property)) {
			addEnumSelect(object, field);
		} else if (Reflect.isObject(property)) {
			var folder = addFolder(field);
			folder.addObject(property); 
		}
		
		return this;
	}
	
	/**
	 * Adds a watch property view to this folder.
	 * A watch is a way to watch the value of a variable, a bit like in a debugger.
	 * @param	object	The object whose field will be added as a property.
	 * @param	field	The name of the field on the object.
	 * @param	history	The number of previous values the watch view will display.
	 * @return	This folder.
	 */
	public function addWatch<T:{}>(object:T, field:String, history:UInt):Folder {
		Sure.sure(object != null);
		Sure.sure(field != null && field.length > 0);
		
		var property = Reflect.getProperty(object, field);
		
		if (Std.is(property, String)) {
			addWatchTextArea(object, field, history);
		} else if (Reflect.isObject(property)) {
			addFolderForObjectWatch(property, field, history);
		} else {
			addWatchTextArea(object, field, history);
		}
		
		return this;
	}
	
	/**
	 * Remove a property from this folder.
	 * @param	property	The property to remove from this folder.
	 * @return	This folder.
	 */
	public function removeProperty(property:Property):Folder {
		Sure.sure(property != null);
		
		var removed:Bool = properties.remove(property);
		
		Sure.sure(removed);
		if (!removed) {
			return this;
		}
		
		backend.removeProperty(this, property);
		signal_didRemoveProperty.dispatch(this, property);
		return this;
	}
	
	/**
	 * Add a placeholder view to this folder.
	 * A placeholder is a textual label that acts as a substitute for a regular property edit.
	 * Placeholders are used for representing properties that tweak-gui cannot handle.
	 * @param	object	The object whose field will be added as a property.
	 * @param	field	The name of the field on the object.
	 * @param	name	The display name of the placeholder.
	 * @return	This folder.
	 */
	public function addPlaceholder<T:{}>(object:T, field:String, ?name:String):Folder {
		backend.addPlaceholder(this, makeProperty(object, field, name));
		return this;
	}
	
	/**
	 * Adds a readonly text area to this folder, that records previous values of the property it watches.
	 * @param	object	The object whose field will be added as a property.
	 * @param	field	The name of the field on the object.
	 * @param	history	The number of previous property values to retain in the text area.
	 * @return	This folder.
	 */
	public function addWatchTextArea<T:{}>(object:T, field:String, history:Int):Folder {
		Sure.sure(object != null);
		Sure.sure(field != null && field.length > 0);
		
		backend.addWatchTextArea(this, makeProperty(object, field), history);
		
		return this;
	}
	
	/**
	 * Adds a boolean checkbox property to this folder.
	 * @param	object	The object whose field will be added as a property.
	 * @param	field	The name of the field on the object.
	 * @param	name	The display name of the checkbox.
	 * @return	This folder.
	 */
	public function addBooleanCheckbox<T:{}>(object:T, field:String, ?name:String):Folder {
		Util.verifyField(object, field);
		backend.addBooleanCheckbox(this, makeProperty(object, field, name));
		return this;
	}
	
	/**
	 * Adds a color picker property to this folder.
	 * @param	object	The object whose field will be added as a property.
	 * @param	field	The name of the field on the object.
	 * @param	name	The display name of the color picker.
	 * @return	This folder.
	 */
	public function addColorPicker<T:{}>(object:T, field:String, ?name:String):Folder {
		// TODO sure rgb/xyz?
		backend.addColorPicker(this, makeProperty(object, field, name));
		return this;
	}
	
	/**
	 * Adds an enum select property to this folder.
	 * @param	object	The object whose field will be added as a property.
	 * @param	field	The name of the field on the object.
	 * @param	name	The display name of the enum select.
	 * @return	This folder.
	 */
	public function addEnumSelect<T:{}>(object:T, field:String, ?name:String):Folder {
		Util.verifyField(object, field);
		backend.addEnumSelect(this, makeProperty(object, field, name));
		return this;
	}
	
	// TODO
	/**
	 * Adds an enum select property to this folder.
	 * @param	object	The object whose field will be added as a property.
	 * @param	field	The name of the field on the object.
	 * @param	name	The display name of the enum select.
	 * @return	This folder.
	 */
	/*
	public function addEnumSelectType<T:Enum>(object:T, field:String, ?name:String):Folder {
		Util.verifyField(object, field);
		backend.addEnumSelectType(this, makeProperty(object, field, name));
		return this;
	}
	*/
	
	/**
	 * Adds a string select property to this folder.
	 * @param	object	The object whose field will be added as a property.
	 * @param	field	The name of the field on the object.
	 * @param	options	The possible string values available to the user.
	 * @param	name	The display name of the string select.
	 * @return	This folder.
	 */
	public function addStringSelect<T:{}>(object:T, field:String, options:Array<String>, ?name:String):Folder {
		Util.verifyField(object, field);
		Sure.sure(options != null);
		backend.addStringSelect(this, makeProperty(object, field, name), options);
		return this;
	}
	
	/**
	 * Adds a generic item select property to this folder.
	 * @param	object	The folder to add the property to.
	 * @param	field	The name of the field on the object.
	 * @param	options	The possible item values available to the user.
	 * @param	name	The display name of the item select.
	 * @return	This folder.
	 *
	 // TODO
	/*
	public function addItemSelect<T:{}>(object:T, field:String, options:Array<T>, ?name:String):Folder {
		Util.verifyField(object, field);
		Sure.sure(options != null);
		backend.addItemSelect(this, makeProperty(object, field, name), options);
		return this;
	}
	*/
	
	/**
	 * Adds a numeric slider property to this folder.
	 * @param	object	The object whose field will be added as a property.
	 * @param	field	The name of the field on the object.
	 * @param	name	The display name of the numeric slider.
	 * @param	min	The minimum value of the slider.
	 * @param	max The maximum value of the slider.
	 * @return	This folder.
	 */
	public function addNumericSlider<T:{}>(object:T, field:String, ?name:String, ?min:Null<Float>, ?max:Null<Float>):Folder {
		// TODO add/compute step
		Util.verifyField(object, field);
		
		if (min == null) {
			min = -1e20;
		}
		if (max == null) {
			max = 1e20;
		}
		
		backend.addNumericSlider(this, makeProperty(object, field, name), min, max);
		return this;
	}
	
	/**
	 * Adds a numeric spinbox property to this folder.
	 * @param	object	The object whose field will be added as a property.
	 * @param	field	The name of the field on the object.
	 * @param	name	The display name of the numeric spinbox.
	 * @return	This folder.
	 */
	public function addNumericSpinbox<T:{}>(object:T, field:String, ?name:String):Folder {
		// TODO add/compute step
		Util.verifyField(object, field);
		backend.addNumericSpinbox(this, makeProperty(object, field, name));
		return this;
	}
	
	/**
	 * Adds a numeric graph element that graphs the previous values of the property it watches.
	 * @param	object	The object whose field will be added as a property.
	 * @param	field	The name of the field on the object.
	 * @param	name	The display name of the folder.
	 * @return	This folder.
	 */
	public function addNumericGraph<T:{}>(object:T, field:String, ?name:String):Folder {
		// TODO add/compute step
		Util.verifyField(object, field);
		backend.addNumericGraph(this, makeProperty(object, field, name));
		return this;
	}
	
	/**
	 * Adds a string edit property to this folder.
	 * @param	object	The object whose field will be added as a property.
	 * @param	field	The name of the field on the object.
	 * @param	name	The display name of the string edit.
	 * @return	This folder.
	 */
	public function addStringEdit<T:{}>(object:T, field:String, ?name:String):Folder {
		Sure.sure(object != null);
		Util.verifyField(object, field);
		
		backend.addStringEdit(this, makeProperty(object, field, name));
		return this;
	}
	
	/**
	 * Adds a function triggering property to this folder.
	 * @param	func	The function that will be added as a triggerable property.
	 * @param	parameterTypes	Shorthand representation of the type signature of the function. See the Util.hx TypeMapping.
	 * @param	name	The display name of the function property.
	 * @return	This folder.
	 */
	public function addFunction(func:Dynamic, parameterTypes:String, ?name:String):Folder {
		Sure.sure(func != null);
		Sure.sure(Reflect.isFunction(func));
		Sure.sure(parameterTypes != null);
		
		backend.addFunction(this, makeFunctionProperty(func, parameterTypes, name));
		return this;
	}
	
	/**
	 * Adds the object's fields to this folder as properties.
	 * @param	object	The object whose properties will be added to this folder.
	 * @return	This folder.
	 */
	public function addObject<T:{}>(object:T):Folder {
		Sure.sure(object != null);
		
		var fields = getFields(object);
		
		for (field in fields) {
			addProperty(object, field);
		}
		
		return this;
	}
	
	/**
	 * Convenience method that creates a new folder, adds it to this folder, and populates the new folder with properties from the given object.
	 * @param	object	The object whose fields will be added to the new folder.
	 * @param	name	The display name of the folder.
	 * @return	This folder.
	 */
	public function addFolderForObject<T:{}>(object:T, name:String):Folder {
		Sure.sure(object != null);
		Sure.sure(name != null && name.length > 0);
		
		var folder = addFolder(name);
		folder.addObject(object);
		return this;
	}
	
	/**
	 * Adds the object's fields to this folder as watch properties.
	 * @param	object	The object whose properties will be added to this folder as watch properties.
	 * @param	history	The number of previous values the watch views will display.
	 * @return	This folder.
	 */
	public function addWatchObject<T:{}>(object:T, history:Int):Folder {
		Sure.sure(object != null);
		Sure.sure(history >= 0);
		
		var fields = getFields(object);
		
		for(field in fields) {
			addWatch(object, field, history);
		}
		
		return this;
	}
	
	/**
	 * Convenience method that creates a new folder, adds it to this folder, and populates the new folder with watch properties from the given object.
	 * @param	object	The object whose fields will be added to the new folder as watch properties.
	 * @param	name	The display name of the folder.
	 * @param	history	The number of previous values the watch views will display.
	 * @return	This folder.
	 */
	public function addFolderForObjectWatch<T:{}>(object:T, name:String, history:Int = 5):Folder {
		Sure.sure(object != null);
		Sure.sure(name != null && name.length > 0);
		
		var folder = addFolder(name);
		folder.addWatchObject(object, history);
		return this;
	}
	
	/**
	 * Adds an object's fields to this folder, excluding fields in the provided array.
	 * @param	object	The object whose fields will be added to this folder.
	 * @param	excludeFields	The fields of the object that will not be added as properties.
	 * @return	This folder.
	 */
	public function addObjectExcludingFields<T:{}>(object:T, excludeFields:Array<String>):Folder {
		Sure.sure(object != null);
		Sure.sure(excludeFields != null);
		
		var fields = getFields(object);
		
		for (field in fields) {
			if (excludeFields.indexOf(field) == -1) {
				continue;
			}
			
			addProperty(object, field);
		}
		
		return this;
	}
	
	/**
	 * Adds an object's fields to this folder, only including the fields in the provided array.
	 * @param	object	The object whose fields will be added to this folder.
	 * @param	includeFields	The fields of the object that will be added as properties.
	 * @return	This folder.
	 */
	public function addObjectIncludingFields<T:{}>(object:T, includeFields:Array<String>):Folder {
		Sure.sure(object != null);
		Sure.sure(includeFields != null);
		
		var fields = getFields(object);
		
		for (field in includeFields) {
			//Sure.sure(Reflect.hasField(object, field));
			addProperty(object, field);
		}
		
		return this;
	}
	
	/**
	 * Helper method that creates a property.
	 * @param	object	The object whose field will be used to create the property.
	 * @param	field	The name of the field on the object.
	 * @return	A new property.
	 */
	private inline function makeProperty<T:{}>(object:T, field:String, ?name:String):Property {
		Sure.sure(object != null);
		Sure.sure(field != null);
		
		var property = new Property(object, field, name);
		properties.push(property);
		signal_didAddProperty.dispatch(this, property);
		return property;
	}
	
	/**
	 * Helper method that creates a function property.
	 * @param	func	The function that will be added as a triggerable property.
	 * @param	parameterTypes	Shorthand representation of the type signature of the function. See the Util.hx TypeMapping.
	 * @param	name	The display name of the function property.
	 * @return	This folder.
	 */
	private inline function makeFunctionProperty<T:Function>(func:T, parameterTypes:String, ?name:String):FunctionProperty {
		Sure.sure(func != null);
		Sure.sure(parameterTypes != null);
		
		var property = new FunctionProperty(func, parameterTypes, name);
		properties.push(property);
		signal_didAddProperty.dispatch(this, property);
		return property;
	}
	
	/**
	 * Creates a new folder. Folders aren't created directly by users, they use addFolder methods instead.
	 * @param	name	The display name of the folder.
	 * @param	parent	The parent of the folder.
	 */
	private function new(name:String, parent:Folder) {
		super(name);
		if (parent != null) {
			this.parent = parent;
			this.backend = parent.backend;
		}
		this.folders = new Array<Folder>();
		this.properties = new Array<BaseProperty>();
	}
	
	/**
	 * Returns the field names of an object in a cross-platform way.
	 * @param	object	The object whose fields will be returned.
	 * @return	The field names of the object.
	 */
	private static function getFields<T:{}>(object:T):Array<String> {
		Sure.sure(object != null);
		
		#if js
		return Reflect.fields(object);
		#end
		
		#if (flash || windows)
		var clazz = Type.getClass(object);
		if (clazz == null) {
			return Reflect.fields(object);
		} else {
			return Type.getInstanceFields(Type.getClass(object));
		}
		#end
		
		return []; // TODO
	}
}