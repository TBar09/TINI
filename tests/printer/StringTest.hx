package;

import tini.TINI;

class StringTest {
	static var INI_FILEPATH:String = "./assets/String Test.ini";

	public static function main() {
		print("  Basic Types Test  ");
		print("--------------------");

		var obj:Dynamic = {
			myTabStr: "I	am	a	tab.",
			myNewLineStr: "Hello\nfrom\na
new
line",
			myBackslashStr: "This is a \\",
			myQuoteStr: "I could say \"Hello world!\", or I could say \'World hello!\'."
		}

		var retVal:String = TINI.stringify(obj);

		print(retVal);
	}

	public static inline function print(str:Dynamic) {
		haxe.Log.trace(Std.string(str), null);
	}
}
