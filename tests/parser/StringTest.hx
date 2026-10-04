package;

import tini.TINI;

class StringTest {
	static var INI_FILEPATH:String = "./assets/String Test.ini";

	public static function main() {
		print("  Basic Types Test  ");
		print("--------------------");

		var retVal:Dynamic = TINI.parse(sys.io.File.getContent(INI_FILEPATH));

		trace("myTabStr: " + retVal.myTabStr);
		trace("myNewLineStr: " + retVal.myNewLineStr);
		//trace("myNewRLineStr: " + retVal.myNewRLineStr);
		trace("myBackslashStr: " + retVal.myBackslashStr);
		trace("myQuoteStr: " + retVal.myQuoteStr);
		trace("myUnicodeStr: " + retVal.myUnicodeStr);
	}

	public static inline function print(str:Dynamic) {
		haxe.Log.trace(Std.string(str), null);
	}
}
