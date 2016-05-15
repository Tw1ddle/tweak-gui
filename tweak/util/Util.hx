package tweak.util;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

/**
 * A mapping of basic Haxe types to single character ids.
 * This is used for converting basic Haxe parameter types to a shorthand string, a little like a JNI function signature.
 */
@:enum abstract TypeMapping(String) from (String) {
    var BOOL = "b";
    var FLOAT = "f";
    var INT = "i";
    var STRING = "s";
}

class Util
{
	/**
	 * Macro that returns a string representing the given function's type signature.
	 * Only works for types or abstracts extending the types in the TypeMapping enum. Throws a compile time error for unsupported types.
	 * Should work for: Bool, Float, Int and String.
	 * @param	f	The function to extract function parameter types from.
	 * @return	A string, where each character represents the type of the nth function parameter.
	 */
    public macro static function getFunctionSignature(f:Expr):ExprOf<String> {
        var type:haxe.macro.Type = Context.typeof(f);
        if (!Reflect.hasField(type, 'args')) {
            throw "Parameter has no field 'args'";
        }
		
        var args:Array<Dynamic> = Reflect.field(type, 'args')[0];
        var signature:String = "";
        for (i in 0...args.length) {
			var argType:Type = args[i].t;
            switch(args[i].t) {
                case TAbstract(t, p):
                    var underlyingTypeName = Std.string(t.get().type.getParameters()[0]);
                    switch(underlyingTypeName) {
                        case "Bool":
                            signature += TypeMapping.BOOL;
                        case "Float":
                            signature += TypeMapping.FLOAT;
                        case "Int":
                            signature += TypeMapping.INT;
                        case "String":
                            signature += TypeMapping.STRING;
                        default:
                            throw "Unhandled abstract function parameter type: " + underlyingTypeName;
                    }
                case CString:
                    signature += TypeMapping.STRING;
                default:
                    throw "Unhandled function parameter type: " + args[i];
            }
        }
		
        return macro $v{signature};
    }
	
	/**
	 * Macro that returns an array of strings containing the names of the given object's instance fields.
	 * @param	instance
	 * @return	An array of strings containing the object's instance field names.
	 */
	macro static public function getInstanceFieldNames(instance:Expr):ExprOf<Array<String>> {
		var type = Context.typeof(instance);
		var classFields = [];
		switch(type) {
			case TInst(cl, _):
				classFields = cl.get().fields.get();
			case _:
				throw "Expression is not of class instance type";
		}
		
		var result = [];
		for (i in 0...classFields.length) {
			var cf = classFields[i];
			result.push(macro $v{cf.name});
			//trace(cf.name);
		}
		return macro $a{result};
	}
	
	/**
	 * Macro that converts a string into an array of single-character strings.
	 * @param	source	The string to be split into an array of character strings.
	 * @return	The array of single-character strings.
	 */
	macro static public function stringToArray(source:String):ExprOf<Array<String>> {
		var result = [];
		for (i in 0...source.length) {
			result.push(macro $v{source.charAt(i)});
		}
		return macro $a{result};
	}
	
	/**
	 * Macro that gets the type names of the given function parameters. Doesn't support generic functions, parameters that are themselves functions, and probably many other cases.
	 * @param	f	The function to extract the parameter types from.
	 * @return	An array of strings, where each string contains the type name of a function parameter, excluding the package name.
	 */
	/* TODO
	@:dox(hide)
	public macro static function getFunctionParameterTypes(f:Expr):ExprOf<Array<String>> {
		var type:Type = Context.typeof(f);
		if (!Reflect.hasField(type, 'args')) {
			throw "Parameter has no field 'args'";
		}
		var args:Array<Dynamic> = Reflect.field(type, 'args')[0];
		
		var pos = haxe.macro.Context.currentPos();
		var signature:Array<Expr> = [];
		
		for (i in 0...args.length) {
			var argType:Type = args[i].t;
			var s;
			switch(argType) {
				case TFun(t, r):
					s = EConst(CString("Function"));
					throw "Not working with function parameters yet";
				case _:
					s = EConst(CString(argType.getParameters()[0].toString()));
			}
			signature.push({expr: s, pos: pos});
		}
		return macro $a{signature};
	}
	*/
	
	#if debug
	/**
	 * Debug-mode assertion that verifies that an object has the given instance field.
	 * @param	object	The object whose fields will be checked.
	 * @param	field	The name of the field.
	 */
	public static inline function verifyField<T:{}>(object:T, field:String):Void {
		#if js
		Sure.sure(object != null && Reflect.hasField(object, field)); // TODO
		#end
	}
	#else
	/**
	 * Debug-mode only assertion that verifies that an object has the given instance field.
	 * @param	object	The object whose fields will be checked.
	 * @param	field	The name of the field.
	 */
	public static inline function verifyField<T:{}>(object:T, field:String):Void {
	}
	#end
}