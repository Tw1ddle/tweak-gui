package tweak.gui;

import msignal.Signal.Signal2;

/**
 * Base class for tweak-gui properties.
 */
class BaseProperty extends BaseElement {
	/**
	 * A signal that is dispatched when the value of the property changes.
	 * @param	first	The previous value of the property.
	 * @param	second	The current, new value of the property.
	 */
	public var signal_changed(default, null):Signal2<Dynamic, Dynamic>;
	
	/**
	 * Creates a BaseProperty with the specified name.
	 * @param	name	The name of the property.
	 */
	public function new(?name:String) {
		super(name);
		this.signal_changed = new Signal2<Dynamic, Dynamic>(); // TODO replace all the dynamic types with generics?
	}
}