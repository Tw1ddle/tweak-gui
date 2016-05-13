package tweak.gui;

import msignal.Signal.Signal2;

/**
 * A Property is a visual representation of a value/field that you can watch and/or manipulate. This property works for any parameter type, except functions.
 */
class Property extends BaseProperty {
	/**
	 * The object whose field the property uses.
	 */
	private var object(default, null):Dynamic;
	
	/**
	 * The name of the field that the property uses.
	 */
	private var field(default, null):String;
	
	/**
	 * The current value of the property.
	 */
	public var value(get, set):Dynamic;
	
	/**
	 * The last known value of the property.
	 * Used internally for checking whether the value was changed since the last update.
	 */
	private var lastValue:Dynamic;
	
	/**
	 * Creates a new property.
	 * @param	object	The object that the property will be looking at.
	 * @param	field	The field of the object the property will observe.
	 * @param	name	The display name for the property UI element.
	 */
	public function new(object:Dynamic, field:String, ?name:String) {
		Sure.sure(object != null);
		Sure.sure(field != null);
		
		if(name == null) {
			super(field);
		} else {
			super(name);
		}
		
		this.object = object;
		this.field = field;

		// TODO make sure initial value is either standardized or the UI gets it right
		lastValue = value;
	}
	
	/**
	 * Updates the property.
	 * Dispatches the changed signal if the value of the property has changed.
	 */
	override public function update():Void {
		if (object == null) {
			return;
		}
		
		if (lastValue != Reflect.getProperty(object, field)) {
			signal_changed.dispatch(lastValue, value);
			lastValue = value;
		}
	}
	
	/**
	 * Gets the current value of the property.
	 * @return The current property value.
	 */
	public function get_value():Dynamic {
		Sure.sure(object != null && field != null);
		return Reflect.getProperty(object, field);
	}
	
	/**
	 * Sets the property with a new value.
	 * @return The new value the property has been set to.
	 */
	public function set_value(v:Dynamic):Dynamic {
		Sure.sure(object != null && field != null);
		signal_changed.dispatch(lastValue, v);
		Reflect.setProperty(object, field, v);
		return v;
	}
}