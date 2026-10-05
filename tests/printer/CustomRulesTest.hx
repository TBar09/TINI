package;

import tini.TINI;

class CustomRulesTest {
	public static function main() {
		print("  Custom Rules Test  ");
		print("---------------------");

		var customRules:IniRules = {
			ASSIGN_KEY: ">",
			COMMENT_KEY: "#",
			ARGUMENT_DELIMITER: "|",
			ROOT_KEYWORD_ALLOWED: false,
			ANON_STRUCTURES_ALLOWED: false,
			CLASSES_ALLOWED: false,
			ENUM_ALLOWED: false,
			CLASS_KEY: "__ini_cls__",
			ENUM_KEY: "__ini_enm__"
		};

		var obj:Dynamic = {
			myFloat: 10.12,
			myInt: 14,
			myBool: true,
			myCoolGroup: {
				myStr: "Hello world!!",
				myArray: ([["Hello, world", true, 10.2], true, 10.2] : Array<Dynamic>),
				myMap: (["uno" => 1.12, "dos" => true, "tres" => ["uno-grouped" => "Hello", "dos-grouped" => "World!"]] : Map<String, Dynamic>),

				// Should be a string since we have enums disabled
				myEnum: Vehicle.TRUCK
			}
		}

		var iniPrinter:IniPrinter = new IniPrinter(customRules);
		var retVal:String = iniPrinter.stringify(obj);

		print(retVal);
	}

	public static inline function print(str:Dynamic) {
		haxe.Log.trace(Std.string(str), null);
	}
}

@:keep
enum Vehicle {
	CAR;
	BICYCLE;
	TRUCK;
	CUSTOM(name:String, mph:Int, isCool:Bool);
	HYBRID(vehicle1:Vehicle, vehicle2:Vehicle);
}