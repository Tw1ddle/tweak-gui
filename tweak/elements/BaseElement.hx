package tweak.elements;

// Base class for all tweak GUI elements
class BaseElement {	
	public var name(default, null):String; // Display name
	public var id(default, null):UInt; // Unique id
	
	public function new(name:String = "Unnamed Element") {
		this.name = name;
		this.id = nextId();
	}
	
	private static var _id:UInt = 0;
	private static inline function nextId():UInt {
		return _id++;
	}
}