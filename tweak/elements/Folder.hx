package tweak.elements;

import msignal.Signal.Signal1;
import msignal.Signal.Signal2;
import tweak.backend.IBackend;
import tweak.elements.IProperty;

// TODO disable folder updates when closed, or add an option for that
// TODO disable properties (stop them from being edited) and disable/enable all folder contents
// TODO addFolder/WatchForTypes (only add/watch specific types, exclude only specific types, named fields etc...)

// Base class for tweak GUI folders.
// A folder contains properties, child folders, and can be opened or closed.
class Folder extends BaseElement {
	private var backend:IBackend; // Handle to the platform/rendering backend for the GUI
	private var parent:Folder; // Parent folder. Null if and only if the folder is at the root of a hierarchy
	private var folders:Array<Folder>; // Child folders i.e. subfolders
	private var properties:Array<IProperty>; // Properties i.e. individual entries within folders
	
	public var signal_didUpdate(default, null) = new Signal1<Folder>(); // Triggers after it and all child folders have updated
	public var signal_didAddFolder(default, null) = new Signal2<Folder, Folder>(); // Triggers after a folder is added to this folder
	public var signal_didRemoveFolder(default, null) = new Signal2<Folder, Folder>(); // Triggers after a folder is removed from this folder
	public var signal_didAddProperty(default, null) = new Signal2<Folder, IProperty>(); // Triggers after a property is added to this folder
	public var signal_didRemoveProperty(default, null) = new Signal2<Folder, IProperty>(); // Triggers after a property is removed from this folder
	public var signal_didOpen(default, null) = new Signal1<Folder>(); // Triggers after this folder is opened
	public var signal_didClose(default, null) = new Signal1<Folder>(); // Triggers after this folder is closed
	
	// Updates all folders and properties
	public function update():Void {
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
	
	// Show the folder
	public function show():Folder {
		backend.show(this);
		return this;
	}
	
	// Hide the folder
	public function hide():Folder {
		backend.hide(this);
		return this;
	}
	
	// Open the folder
	public function open():Folder {
		backend.openFolder(this);
		signal_didOpen.dispatch(this);
		return this;
	}
	
	// Collapse/close the folder
	public function close():Folder {
		backend.closeFolder(this);
		signal_didClose.dispatch(this);
		return this;
	}
	
	// Add a subfolder to the folder with the given name
	// Returns the newly added folder, note that this makes it unlike the rest of the interface
	public function addFolder(name:String, updateWhenClosed:Bool = true):Folder {
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
	
	// Remove self from the GUI
	// Removes itself from the parent, and then from the backend
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
	
	// Attempts to add a property control automatically by reflecting on the property type
	public function addProperty(object:Dynamic, field:String):Folder {
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
			addPlaceholder(object, field); // Cannot get the number of parameters dynamically in a simple cross platform way, so add a label instead
		} else if (Reflect.isEnumValue(property)) {
			addEnumSelect(object, field);
		} else if (Reflect.isObject(property)) {
			var folder = addFolder(field);
			folder.addObject(property); // Note, beware of reference loops, can cause infinite loops
		}
		
		return this;
	}
	
// Adds a readonly view containing the values of the property, with a history of the last 'history' number of values
	public function addWatch(object:Dynamic, field:String, history:Int):Folder {
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
	
	// Remove a property from the folder
	public function removeProperty(property:IProperty):Folder {
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
	
	// Add a placeholder entry for items tweak-gui cannot properly represent
	public function addPlaceholder(object:Dynamic, field:String, ?name:String):Folder {
		backend.addPlaceholder(this, makeProperty(object, field, name));
		return this;
	}
	
	public function addWatchTextArea(object:Dynamic, field:String, history:Int):Folder {
		Sure.sure(object != null);
		Sure.sure(field != null && field.length > 0);
		
		backend.addWatchTextArea(this, makeProperty(object, field), history);
		
		return this;
	}
	
	public function addBooleanCheckbox(object:Dynamic, field:String, ?name:String):Folder {
		Sure.sure(verifyField(object, field));
		backend.addBooleanCheckbox(this, makeProperty(object, field, name));
		return this;
	}
	
	/*
	public function addBooleanSwitch(object:Dynamic, field:String, ?name:String):Folder {
		Sure.sure(verifyField(object, field));
		backend.addBooleanSwitch(this, makeProperty(object, field, name));
		return this;
	}
	*/
	
	public function addColorPicker(object:Dynamic, field:String, ?name:String):Folder {
		// TODO sure rgb/xyz?
		backend.addColorPicker(this, makeProperty(object, field, name));
		return this;
	}
	
	public function addEnumSelect(object:Dynamic, field:String, ?name:String):Folder {
		Sure.sure(verifyField(object, field));
		backend.addEnumSelect(this, makeProperty(object, field, name));
		return this;
	}
	
	public function addStringSelect(object:Dynamic, field:String, options:Array<String>, ?name:String):Folder {
		Sure.sure(verifyField(object, field));
		backend.addStringSelect(this, makeProperty(object, field, name), options);
		return this;
	}
	
	public function addItemSelect<T>(object:Dynamic, field:String, items:Array<T>, ?name:String):Folder {
		// TODO? dropdown list of anything
		return this;
	}
	
	public function addNumericSlider(object:Dynamic, field:String, ?name:String, ?min:Null<Float>, ?max:Null<Float>):Folder {
		Sure.sure(verifyField(object, field));
		
		if (min == null) {
			min = -1e20;
		}
		if (max == null) {
			max = 1e20;
		}
		
		backend.addNumericSlider(this, makeProperty(object, field, name), min, max);
		return this;
	}
	
	// TODO add min, max, step
	public function addNumericSpinbox(object:Dynamic, field:String, ?name:String):Folder {
		Sure.sure(verifyField(object, field));
		backend.addNumericSpinbox(this, makeProperty(object, field, name));
		return this;
	}
	
	//public function addNumericGraph // TODO
	
	public function addStringEdit(object:Dynamic, field:String, ?name:String):Folder {
		Sure.sure(object != null);
		Sure.sure(verifyField(object, field));
		
		backend.addStringEdit(this, makeProperty(object, field, name));
		return this;
	}
	
	public function addFunction(func:Dynamic, parameterTypes:String, ?name:String):Folder {
		Sure.sure(func != null);
		Sure.sure(Reflect.isFunction(func));
		Sure.sure(parameterTypes != null);
		
		backend.addFunction(this, makeFunctionProperty(func, parameterTypes, name));
		return this;
	}
	
	// Convenience method that creates a new folder, adds the object to it, and adds it to this folder
	public function addFolderForObject(object:Dynamic, name:String):Folder {
		Sure.sure(object != null);
		Sure.sure(name != null && name.length > 0);
		
		var folder = addFolder(name);
		folder.addObject(object);
		return this;
	}
	
	// Add the object's fields to the GUI as properties
	public function addObject(object:Dynamic):Folder {
		Sure.sure(object != null);
		
		var fields = getFields(object);
		
		for (field in fields) {
			addProperty(object, field);
		}
		
		return this;
	}
	
	public function addFolderForObjectWatch(object:Dynamic, name:String, history:Int = 50):Folder {
		Sure.sure(object != null);
		Sure.sure(name != null && name.length > 0);
		
		var folder = addFolder(name);
		folder.addWatchObject(object, name, history);
		return this;
	}
	
	// Adds the object's fields to the GUI as watches
	public function addWatchObject(object:Dynamic, name:String, history:Int):Folder {
		Sure.sure(object != null);
		Sure.sure(name != null && name.length > 0);
		Sure.sure(history >= 0);
		
		var fields = getFields(object);
		
		for(field in fields) {
			addWatch(object, field, history);
		}
		
		return this;
	}
	
	// Adds a graph widget that plots the value every time it changes
	public function addNumericGraph(object:Dynamic, field:String, ?name:String):Folder {
		Sure.sure(object != null);
		Sure.sure(field != null && field.length > 0);
		
		return this;
	}
	
	// Adds an object's fields the GUI, excluding fields in the provided array
	public function addObjectExcludingFields(object:Dynamic, excludeFields:Array<String>):Folder {
		Sure.sure(object != null);
		Sure.sure(excludeFields != null);
		
		var fields = Reflect.fields(object);
		
		for (field in fields) {
			if (excludeFields != null && excludeFields.indexOf(field) == -1) {
				continue;
			}
			
			addProperty(object, field);
		}
		
		return this;
	}
	
	// Attempts to add only the provided fields to the object's GUI
	public function addObjectIncludingFields(object:Dynamic, includeFields:Array<String>):Folder {
		Sure.sure(object != null);
		Sure.sure(includeFields != null);
		
		var fields = Reflect.fields(object);
		
		for (field in includeFields) {
			Sure.sure(Reflect.hasField(object, field));
			addProperty(object, field);
		}
		
		return this;
	}
	
	private inline function makeProperty(object:Dynamic, field:String, ?name:String):IProperty {
		Sure.sure(object != null);
		Sure.sure(field != null);
		
		var property = new Property(object, field, name);
		properties.push(property);
		signal_didAddProperty.dispatch(this, property);
		return property;
	}
	
	private inline function makeFunctionProperty<T>(func:T, parameterTypes:String, ?name:String):FunctionProperty {
		Sure.sure(func != null);
		Sure.sure(parameterTypes != null);
		
		var property = new FunctionProperty(func, parameterTypes, name);
		properties.push(property);
		signal_didAddProperty.dispatch(this, property);
		return property;
	}
	
	// Folders aren't created directly, use addFolder
	private function new(name:String, parent:Folder) {
		super(name);
		if (parent != null) {
			this.parent = parent;
			this.backend = parent.backend;
		}
		this.folders = new Array<Folder>();
		this.properties = new Array<IProperty>();
	}
	
	private function getFields(object:Dynamic):Array<String> {
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
	}
	
	#if debug
	private static inline function verifyField(object:Dynamic, field:String):Bool {		
		#if js
		return object != null && Reflect.hasField(object, field);
		#else
		return true;
		#end
	}
	#else
	private static inline function verifyField(object:Dynamic, field:String):Bool { return true;  }
	#end
}