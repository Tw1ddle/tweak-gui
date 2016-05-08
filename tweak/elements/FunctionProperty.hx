package tweak.elements;

import msignal.Signal.Signal2;

// Property for functions
class FunctionProperty extends BaseElement implements IProperty {
	public var parameters(default, null):String;
	@:isVar public var value(get, set):Dynamic;
	
	public var signal_changed(default, null):Signal2<Dynamic, Dynamic>;
	
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
	
	public function update():Void {
		// Function properties do not listen for changes to themselves. Mostly because if something external changes the function itself, then you're probably doing something weird
	}
	
	public function get_value():Dynamic {
		return value;
	}
	
	public function set_value(v:Dynamic):Dynamic {
		var tmp = value;
		value = v;
		signal_changed.dispatch(tmp, v);
		return value;
	}
}