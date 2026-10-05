package;

import tini.TINI;

class BasicTypesTest {
	public static function main() {
		print("  Basic Types Test  ");
		print("--------------------");

		var obj:Dynamic = {
			myStr: "Hello world!!",
			myFloat: 10.12,
			myInt: 14,
			myBool: true
		}

		var retVal:String = TINI.stringify(obj);

		print(retVal);
	}

	public static inline function print(str:Dynamic) {
		haxe.Log.trace(Std.string(str), null);
	}
}
