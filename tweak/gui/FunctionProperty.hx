package tweak.gui;

import msignal.Signal.Signal2;

/**
 * A FunctionProperty is a visual representation of a function that you can call with tweakable parameters. This property works for functions.
 */
class FunctionProperty extends BaseProperty {
	/**
	 * A string containing the shorthand parameter types of the function, if any.
	 * For example: Void->Void is the empty string.
	 * String->Int->Float->Int is sif (final Int is excluded because it is a return type).
	 */
	public var parameters(default, null):String;
	
	/**
	 * The current value of the property.
	 */
	@:isVar public var value(get, set):Dynamic;
	
	/**
	 * Creates a new function property.
	 * @param	func	The function the property will be looking at.
	 * @param	parameters	A string containing the shorthand parameter types of the function, if any.
	 * @param	name	The display name for the function property UI element.
	 */
	public function new(func:Dynamic, parameters:String, ?name:String) {
		Sure.sure(func != null);
		Sure.sure(parameters != null);
		
		if(name == null) {
			super(Std.string(parameters.length) + "-ary Function");
		} else {
			super(name);
		}
		this.signal_changed = new Signal2<Dynamic, Dynamic>();
		this.parameters = parameters;
		this.value = func;
	}
	
	/**
	 * Updates the property.
	 * Note that function properties do not usually need to listen for changes not made through set_value, so no checks are done here.
	 */
	override public function update():Void {
		// Intentionally empty
	}
	
	/**
	 * Gets the current value of the property.
	 * @return	The current property value.
	 */
	public function get_value():Dynamic {
		return value;
	}
	
	/**
	 * Sets the property with a new value.
	 * @param	v The new property value.
	 * @return	The new value the property has been set to.
	 */
	public function set_value(v:Dynamic):Dynamic {
		var tmp = value;
		value = v;
		signal_changed.dispatch(tmp, v);
		return value;
	}
}