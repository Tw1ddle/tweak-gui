package tweak.gui;

/**
 * Base class for all tweak-gui elements.
 */
class BaseElement {
	/**
	 * Element display name.
	 */
	public var name(default, null):String;
	
	/**
	 * Unique element id.
	 */
	public var id(default, null):UInt;
	
	/**
	 * Creates a BaseElement with the specified name.
	 * @param	name	The name of the element.
	 */
	public function new(name:String = "Unnamed Element") {
		this.name = name;
		this.id = nextId();
	}
	
	/**
	 * Update method.
	 */
	public function update():Void {
		
	}
	
	/**
	 * Static counter for keeping track of elements created so far.
	 */
	private static var _id:UInt = 0;
	
	/**
	 * Gets the next element id.
	 * @return	The next element id.
	 */
	private static inline function nextId():UInt {
		return _id++;
	}
}