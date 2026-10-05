package;

import tini.TINI;

class NewTypesTest {
	public static function main() {
		print("  New Types Test  ");
		print("------------------");

		var obj:Dynamic = {
			myArray: ([["Hello, world", true, 10.2], true, 10.2] : Array<Dynamic>),
			myMap: (["uno" => 1.12, "dos" => true, "tres" => ["uno-grouped" => "Hello", "dos-grouped" => "World!"]] : Map<String, Dynamic>)
		}

		var retVal:String = TINI.stringify(obj);

		print(retVal);
	}

	public static inline function print(str:Dynamic) {
		haxe.Log.trace(Std.string(str), null);
	}
}
