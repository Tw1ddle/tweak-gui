package tweak.util;

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;

/**
 * A mapping of basic Haxe types to single character ids.
 * This is used for converting to 
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
    public macro static function getTypes(f:Expr):ExprOf<String> {
        var type:Type = Context.typeof(f);
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
	 * Macro that gets the type names of the given function parameters. Doesn't support generic functions, parameters that are themselves functions, and probably many other cases.
	 * @param	f	The function to extract the parameter types from.
	 * @return	An array of strings, where each string contains the type name of a function parameter, excluding the package name.
	 */ 
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
}