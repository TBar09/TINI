package;

import tini.TINI;

class BasicTypesTest {
	static var INI_FILEPATH:String = "./assets/My Test Ini.ini";

	public static function main() {
		print("  Basic Types Test  ");
		print("--------------------");

		var retVal:Dynamic = TINI.parse(sys.io.File.getContent(INI_FILEPATH));

		trace("legacyStr: " + retVal.legacyStr);
		trace("myStr: " + retVal.myStr);

		trace("myFloat: " + Std.string(retVal.myFloat));
		trace("myInt: " + Std.string(retVal.myInt));
	}

	public static inline function print(str:Dynamic) {
		haxe.Log.trace(Std.string(str), null);
	}
}
