package tweak.backend.dom;

import js.Browser.document;
import js.html.ButtonElement;
import js.html.DOMError;
import js.html.DivElement;
import js.html.Element;
import js.html.InputElement;
import js.html.LIElement;
import js.html.SelectElement;
import js.html.TextAreaElement;
import js.html.UListElement;
import tweak.gui.Folder;
import tweak.gui.FunctionProperty;
import tweak.gui.Property;
import tweak.util.Util.TypeMapping;
import tweak.gui.BaseElement;

/**
 * A custom JavaScript/DOM backend for tweak-gui.
 */ 
@:access(tweak.gui.Folder)
class CustomDOMBackend implements IBackend {
	private var rootContainer:DivElement;
	private var rootFolder:UListElement;
	private var rootToggleButton:ButtonElement;
	
	public function new() {
		rootContainer = createRootContainer();
		rootFolder = createRootFolder();
		rootToggleButton = createRootToggleButton();
		
		rootContainer.appendChild(rootFolder);
		rootContainer.appendChild(rootToggleButton);
		document.body.appendChild(rootContainer);
		
		rootToggleButton.onclick = function(event) {
			if (isFolderOpen(rootFolder)) {
				closeRootFolder();
			} else {
				openRootFolder();
			}
		}
		openRootFolder();
	}
	
	public function show(folder:Folder):Void {
		document.getElementById(getIdForFolderContainer(folder)).style.display = "visible";
	}
	
	public function hide(folder:Folder):Void {
		document.getElementById(getIdForFolderContainer(folder)).style.display = "none";
	}
	
	public function openRootFolder():Void {
		showElement(rootFolder, rootToggleButton);
		rootToggleButton.innerHTML = "Close Controls";
	}
	
	public function closeRootFolder():Void {
		closeElement(rootFolder, rootToggleButton);
		rootToggleButton.innerHTML = "Open Controls";
	}
	
	public function addFolder(folder:Folder):Bool {
		var isRoot = folder.parent == null;
		
		var folderContainer = createFolderContainer();
		folderContainer.id = getIdForFolderContainer(folder);
		
		var folderButtonContainer = createFolderButtonContainer();
		
		var folderToggle = createFolderToggleButton(folder.name);
		var folderRemove = createFolderRemoveButton();
		
		var folderList = createFolderList();
		folderList.id = getIdForFolderList(folder);
		
		folderButtonContainer.appendChild(folderToggle);
		
		if(!isRoot) {
			folderButtonContainer.appendChild(folderRemove);
		}
		
		folderContainer.appendChild(folderButtonContainer);
		folderContainer.appendChild(folderList);
		
		if(isRoot) {
			rootFolder.appendChild(folderContainer);
		} else {
			document.getElementById(getIdForFolderList(folder.parent)).appendChild(folderContainer);
		}
		
		folderToggle.onclick = function(event) {
			if (isFolderOpen(folderList)) {
				closeElement(folderList, folderToggle);
			} else {
				showElement(folderList, folderToggle);
			}
		}
		
		folderRemove.onclick = function(event) {
			folder.remove();
		}
		
		showElement(folderContainer, folderToggle);
		
		return true;
	}
	
	public function removeFolder(folder:Folder):Bool {
		var folderContainer = document.getElementById(getIdForFolderContainer(folder));
		
		try {
			folderContainer.parentNode.removeChild(folderContainer);
		} catch (error:DOMError) {
			return false;
		}
		return true;
	}
	
	public function openFolder(folder:Folder):Void {
		var folderList = document.getElementById(getIdForFolderList(folder));
		var folderButton = document.getElementById(getIdForFolderToggleButton(folder));
		showElement(folderList, folderButton);
	}
	
	public function closeFolder(folder:Folder):Void {
		var folderList = document.getElementById(getIdForFolderList(folder));
		var folderButton = document.getElementById(getIdForFolderToggleButton(folder));
		closeElement(folderList, folderButton);
	}
	
	// Helper function to add common property label contents, and styling for the colored swatch
	private function addLabelPropertyShell(folder:Folder, property:BaseElement, swatchClass:String):LIElement {
		var folderList = document.getElementById(getIdForFolderList(folder));
		
		var propertySwatchItem = createPropertySwatchElement(swatchClass);
		
		var propertyListItem = createPropertyListElement();
		propertyListItem.id = getIdForPropertyContainer(property);
		
		var propertyLabel = createPropertyLabel();
		propertyLabel.appendChild(document.createTextNode(property.name));
		
		propertyListItem.appendChild(propertySwatchItem);
		propertyListItem.appendChild(propertyLabel);
		folderList.appendChild(propertyListItem);
		
		return propertyListItem;
	}
	
	// Helper function to add a set of function parameter controls to the provided container
	private function addFunctionActivator(property:FunctionProperty, container:LIElement):Void {
		var id = property.name + "-" + Std.string(property.id);
		
		// TODO make the function property gather the values of these properties and run when the button is pressed!
		/*
		for (i in 0...property.parameters.length) {
			container.appendChild(switch(property.parameters.charAt(i)) {
				case TypeMapping.BOOL:
					createCheckbox(property);
				case TypeMapping.FLOAT:
					createNumericSpinbox(property);
				case TypeMapping.INT:
					createNumericSpinbox(property);
				case TypeMapping.STRING:
					createStringEdit(property);
				default:
					throw "Unsupported parameter type";
			});
		}
		*/
		
		var buttonElement = document.createButtonElement();
		buttonElement.className = "tweak-gui-call-function-button";
		buttonElement.id = id;
		buttonElement.addEventListener('click', function(e):Void {
			property.value();
		}, true);
		
		container.appendChild(buttonElement);
	}
	
	public function removeProperty(folder:Folder, property:Property):Bool {
		var folderList = document.getElementById(getIdForFolderList(folder));
		var propertyContainer = document.getElementById(getIdForPropertyContainer(property));
		
		try {
			folderList.removeChild(propertyContainer);
		} catch (error:DOMError) {
			return false;
		}
		
		return true;
	}
	
	public function addPlaceholder(folder:Folder, property:Property):Void {
		var propertyListItem = addLabelPropertyShell(folder, property, "tweak-gui-placeholder-swatch");
		var placeholder = createPlaceholder(property);
		propertyListItem.appendChild(placeholder);
	}
	
	/*
	public function addBooleanSwitch(folder:Folder, property:Property):Void {
		var propertyListItem = addLabelPropertyShell(folder, property, "tweak-gui-boolean-switch-swatch");
		var switchElement = createSwitch(property);
		propertyListItem.appendChild(switchElement);
	}
	*/
	
	public function addBooleanCheckbox(folder:Folder, property:Property):Void {
		var propertyListItem = addLabelPropertyShell(folder, property, "tweak-gui-boolean-checkbox-swatch");
		var checkbox = createCheckbox(property);
		propertyListItem.appendChild(checkbox);
	}
	
	public function addFunction(folder:Folder, property:FunctionProperty):Void {
		var propertyListItem = addLabelPropertyShell(folder, property, "tweak-gui-function-swatch");
		addFunctionActivator(property, propertyListItem);
	}
	
	public function addStringSelect(folder:Folder, property:Property, options:Array<String>):Void {
		var propertyListItem = addLabelPropertyShell(folder, property, "tweak-gui-string-select-swatch");
		var select = createStringSelect(property, options);
		propertyListItem.appendChild(select);
	}
	
	public function addEnumSelect(folder:Folder, property:Property):Void {
		var propertyListItem = addLabelPropertyShell(folder, property, "tweak-gui-enum-select-swatch");
		var select = createEnumSelect(property);
		propertyListItem.appendChild(select);
	}
	
	public function addNumericSpinbox(folder:Folder, property:Property):Void {
		var propertyListItem = addLabelPropertyShell(folder, property, "tweak-gui-numeric-spinbox-swatch");
		var spinbox = createNumericSpinbox(property);
		propertyListItem.appendChild(spinbox);
	}
	
	public function addNumericSlider(folder:Folder, property:Property, min:Float, max:Float):Void {
		var propertyListItem = addLabelPropertyShell(folder, property, "tweak-gui-numeric-slider-swatch");
		var slider = createNumericSlider(property, min, max);
		propertyListItem.appendChild(slider);		
	}
	
	public function addStringEdit(folder:Folder, property:Property):Void {
		var propertyListItem = addLabelPropertyShell(folder, property, "tweak-gui-string-edit-swatch");
		var stringEdit = createStringEdit(property);
		propertyListItem.appendChild(stringEdit);
	}
	
	public function addColorPicker(folder:Folder, property:Property):Void {
		var propertyListItem = addLabelPropertyShell(folder, property, "tweak-gui-color-picker-swatch");
		// TODO
	}
	
	public function addWatchTextArea(folder:Folder, property:Property, history:Int):Void {
		var propertyListItem = addLabelPropertyShell(folder, property, "tweak-gui-watch-view-swatch");
		var watchView = createWatchView(property, propertyListItem, history);
		propertyListItem.appendChild(watchView);
	}
	
	public function addNumericGraph(folder:Folder, property:Property):Void {
		// TODO
	}
	
	private inline function showElement(listElement:Element, toggleButton:Element):Void {
		if (isFolderOpen(listElement)) {
			return;
		}
		listElement.classList.toggle("collapsed");
		toggleButton.classList.toggle("folder-open");
	}
	
	private inline function closeElement(listElement:Element, toggleButton:Element):Void {
		if (!isFolderOpen(listElement)) {
			return;
		}
		listElement.classList.toggle("collapsed");
		toggleButton.classList.toggle("folder-open");
	}
	
	private inline function isFolderOpen(element:Element):Bool {
		return !element.classList.contains("collapsed");
	}
	
	private inline function createRootContainer():DivElement {
		var container = document.createDivElement();
		container.className = "tweak-gui-root-folder-container";
		return container;
	}
	
	private inline function createRootToggleButton():ButtonElement {
		var button = document.createButtonElement();
		button.className = "tweak-gui-root-toggle-button";
		return button;
	}
	
	private inline function createRootFolder():UListElement {
		var folder = document.createUListElement();
		folder.className = "tweak-gui-root-folder";
		return folder;
	}
	
	private inline function createFolderContainer():LIElement {
		var container = document.createLIElement();
		container.className = "tweak-gui-folder-container";
		return container;
	}
	
	private inline function createFolderButtonContainer():DivElement {
		var container = document.createDivElement();
		container.className = "tweak-gui-folder-button-container";
		return container;
	}
	
	private inline function createFolderToggleButton(text:String):ButtonElement {
		var button = document.createButtonElement();
		button.className = "tweak-gui-folder-toggle-button";
		button.textContent = text;
		return button;
	}
	
	private inline function createFolderRemoveButton():ButtonElement {
		var button = document.createButtonElement();
		button.className = "tweak-gui-folder-remove-button";
		return button;
	}
	
	private inline function createFolderList():UListElement {
		var list = document.createUListElement();
		list.className = "tweak-gui-folder-list";
		return list;
	}
	
	private inline function createPropertyListElement():LIElement {
		var element = document.createLIElement();
		element.className = "tweak-gui-property-container";
		return element;
	}
	
	private inline function createPropertyLabel():DivElement {
		var label = document.createDivElement();
		label.className = "tweak-gui-property-label";
		return label;
	}
	
	private inline function createPropertySwatchElement(swatchClass:String):DivElement {
		var swatch = document.createDivElement();
		swatch.className = "tweak-gui-property-swatch";
		swatch.classList.add(swatchClass);
		return swatch;
	}
	
	private inline function createPlaceholder(property:Property):DivElement {
		var id = property.name + "-" + Std.string(property.id);
		
		var element = document.createDivElement();
		element.className = "tweak-gui-placeholder";
		element.id = id;
		
		return element;
	}
	
	private inline function createCheckbox(property:Property):InputElement {
		var id = property.name + "-" + Std.string(property.id);
		
		var checkbox = document.createInputElement();
		checkbox.type = "checkbox";
		checkbox.className = "tweak-gui-checkbox";
		checkbox.id = id;
		
		// TODO do this if we're not already "listening", otherwise just do the above?
		property.signal_changed.add(function(last:Dynamic, current:Dynamic):Void {
			checkbox.checked = current;
		});
		
		checkbox.addEventListener('change', function(e):Void {
			property.value = checkbox.checked;
		}, true);
		
		return checkbox;
	}
	
	/*
	private inline function createSwitch(property:Property):DivElement {
		var id = property.name + "-" + Std.string(property.id);
		
		var switchContainer = document.createDivElement();
		switchContainer.className = "tweak-gui-onoffswitch";
		
		var inputElement = document.createInputElement();
		inputElement.type = "checkbox";
		inputElement.name = "tweak-gui-onoffswitch";
		inputElement.className = "tweak-gui-onoffswitch-checkbox";
		inputElement.id = id;
		inputElement.checked = property.value;
		
		var labelElement = document.createLabelElement();
		labelElement.className = "tweak-gui-onoffswitch-label";
		labelElement.setAttribute("for", id);
		
		var innerSpanElement = document.createSpanElement();
		innerSpanElement.className = "tweak-gui-onoffswitch-inner";
		
		var switchBlockElement = document.createSpanElement();
		switchBlockElement.className = "tweak-gui-onoffswitch-switch";
		
		labelElement.appendChild(innerSpanElement);
		labelElement.appendChild(switchBlockElement);
		switchContainer.appendChild(inputElement);
		switchContainer.appendChild(labelElement);
		
		// TODO do this if we're not already "listening", otherwise just do the above?
		property.signal_changed.add(function(last:Dynamic, current:Dynamic):Void {
			inputElement.checked = current;
		});
		
		inputElement.addEventListener('change', function(e):Void {
			property.value = inputElement.checked;
		}, true);
		
		return switchContainer;
	}
	*/
	
	private inline function createStringEdit(property:Property):InputElement {
		var id = property.name + "-" + Std.string(property.id);
		
		var textElement = document.createInputElement();
		textElement.type = "text";
		textElement.className = "tweak-gui-stringedit";
		textElement.id = id;
		textElement.value = property.value;
		textElement.setAttribute("spellcheck", "disabled");
		
		property.signal_changed.add(function(last:Dynamic, current:Dynamic):Void {
			textElement.value = current;
		});
		
		textElement.addEventListener('change', function(e):Void {
			property.value = textElement.value;
		}, true);
		
		return textElement;
	}
	
	private inline function createStringSelect(property:Property, options:Array<String>):SelectElement {
		var id = property.name + "-" + Std.string(property.id);
		
		var select = document.createSelectElement();
		select.className = "tweak-gui-string-select";
		select.id = id;
		
		for (option in options) {
			var o = document.createOptionElement();
			o.text = option;
			select.add(o);
		}
		
		select.addEventListener('change', function(e):Void {
			property.value = select.value;
		}, true);
		
		return select;
	}
	
	private inline function createEnumSelect(property:Property):SelectElement {
		var id = property.name + "-" + Std.string(property.id);
		
		var select = document.createSelectElement();
		select.className = "tweak-gui-enum-select";
		select.id = id;
		
		var options = Type.allEnums(Type.getEnum(property.value));
		
		for (option in options) {
			var o = document.createOptionElement();
			o.text = Std.string(option);
			select.add(o);
		}
		
		select.addEventListener('change', function(e):Void {
			property.value = Type.allEnums(Type.getEnum(property.value))[select.selectedIndex];
		}, true);
		
		return select;
	}
	
	var lastDragY:Float = 0; // For keeping track of mouse drag events, so the user can press and move the mouse to change the numeric value
	private inline function createNumericSpinbox(property:Property):InputElement {
		var id = property.name + "-" + Std.string(property.id);
		
		var inputElement = document.createInputElement();
		inputElement.type = "number";
		inputElement.className = "tweak-gui-numericspinbox";
		inputElement.id = id;
		inputElement.value = property.value;
		
		property.signal_changed.add(function(last:Dynamic, current:Dynamic):Void {
			inputElement.value = current;
		});
		
		inputElement.addEventListener('change', function(e):Void {
			property.value = Std.parseFloat(inputElement.value);
		}, true);
		
		var getClientY = function(e):Float {
			if (Std.is(e.clientY, String)) {
				return Std.parseFloat(e.clientY);
			}
			return cast e.clientY;
		}

		var onMouseDrag = function(e):Void {
			var dy = lastDragY - getClientY(e);
			property.value += dy;
			lastDragY = getClientY(e);
		}
		var onMouseUp:Dynamic->Void = null;
		onMouseUp = function(e):Void {
			document.removeEventListener('mousemove', onMouseDrag);
			document.removeEventListener('mouseup', onMouseUp);
		}
		inputElement.addEventListener('mousedown', function(e):Void {
			lastDragY = getClientY(e);
			document.addEventListener('mousemove', onMouseDrag);
			document.addEventListener('mouseup', onMouseUp);
		}, true);
		
		return inputElement;
	}
	
	private inline function createNumericSlider(property:Property, min:Float, max:Float):InputElement {
		var id = property.name + "-" + Std.string(property.id);
		
		var inputElement = document.createInputElement();
		inputElement.type = "range";
		inputElement.className = "tweak-gui-numericslider";
		inputElement.id = id;
		inputElement.value = property.value;
		inputElement.min = Std.string(min);
		inputElement.max = Std.string(max);
		
		property.signal_changed.add(function(last:Dynamic, current:Dynamic):Void {
			inputElement.value = current;
		});
		
		inputElement.addEventListener('change', function(e):Void {
			property.value = Std.parseFloat(inputElement.value);
		}, true);
		
		return inputElement;
	}
	
	private inline function createWatchView(property:Property, propertyListItem:Element, history:Int):TextAreaElement {
		var id = property.name + "-" + Std.string(property.id);
		
		var textAreaElement = document.createTextAreaElement();
		textAreaElement.className = "tweak-gui-watch-view";
		textAreaElement.id = id;
		textAreaElement.setAttribute("readonly", "true");
		textAreaElement.setAttribute("rows", Std.string(history));
		textAreaElement.setAttribute("spellcheck", "disabled");
		
		// TODO respect the "history" variable
		property.signal_changed.add(function(last:Dynamic, current:Dynamic):Void {
			// textAreaElement.value = Std.string(current) + "\r\n" + textAreaElement.value;
			textAreaElement.value = Std.string(current);
			
			// TODO add an animation to show it changed
			//propertyListItem.classList.add("tweak-gui-watch-changed-animation");
		});
		
		/*
		var removeWatchChangedAnimation = function(e):Void {
			propertyListItem.classList.remove("tweak-gui-watch-changed-animation");
		};
		var animationEndEvents = ['animationend', 'webkitAnimationEnd', 'mozAnimationEnd', 'MSAnimationEnd', 'oAnimationEnd'];
		for (evt in animationEndEvents) {
			propertyListItem.addEventListener(evt, removeWatchChangedAnimation, false);
		}
		*/
		
		textAreaElement.value += Std.string(property.value) + "\r\n";
		
		return textAreaElement;
	}
	
	private inline function getIdForFolderContainer(element:Folder):String {
		return "tweak-gui-folder-container" + Std.string(element.id);
	}
	
	private inline function getIdForFolderList(element:Folder):String {
		return "tweak-gui-folder-list" + Std.string(element.id);
	}
	
	private inline function getIdForFolderToggleButton(element:Folder):String {
		return "tweak-gui-folder-toggle-button" + Std.string(element.id);
	}
	
	private inline function getIdForPropertyContainer(element:BaseElement):String {
		return "tweak-gui-property-container" + Std.string(element.id);
	}
}