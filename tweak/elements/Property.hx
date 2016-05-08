package tweak.elements;

import msignal.Signal.Signal2;

// Property for anything except functions
class Property extends BaseElement implements IProperty {
	private var object(default, null):Dynamic;
	private var field(default, null):String;
	
	public var value(get, set):Dynamic;
	
	// For on-change events/listening to the values
	public var signal_changed(default, null):Signal2<Dynamic, Dynamic>;
	private var lastValue:Dynamic;
	
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
		this.signal_changed = new Signal2<Dynamic, Dynamic>(); // TODO replace all the dynamic types with generics?
		
		// TODO make sure initial value is either standardized or the UI gets it right
		lastValue = value;
	}
	
	public function update():Void {
		if (object == null) {
			return;
		}
		
		if (lastValue != Reflect.getProperty(object, field)) {
			signal_changed.dispatch(lastValue, value);
			lastValue = value;
		}
	}
	
	public function get_value():Dynamic {
		Sure.sure(object != null && field != null);
		return Reflect.getProperty(object, field);
	}
	
	public function set_value(v:Dynamic):Dynamic {
		Sure.sure(object != null && field != null);
		signal_changed.dispatch(lastValue, v);
		Reflect.setProperty(object, field, v);
		return v;
	}
}