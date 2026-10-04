package;

import tini.TINI;

class NewTypesTest {
	static var INI_FILEPATH:String = "./assets/My Test Ini.ini";

	public static function main() {
		print("  New Types Test  ");
		print("------------------");

		var retVal:Dynamic = TINI.parse(sys.io.File.getContent(INI_FILEPATH));

		trace("myArray: " + Std.string(retVal.myArray));
		trace("myObject: " + Std.string(retVal.myObject));
		trace("myMap: " + Std.string(retVal.myMap));
	}

	public static inline function print(str:Dynamic) {
		haxe.Log.trace(Std.string(str), null);
	}
}
