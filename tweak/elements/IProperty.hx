package tweak.elements;

import msignal.Signal.Signal2;

interface IProperty
{
	public var id(default, null):UInt;
	public var name(default, null):String;
	public var signal_changed(default, null):Signal2<Dynamic, Dynamic>;
	public var value(get, set):Dynamic;
	
	public function update():Void;
}