package;

import tini.TINI;

class GroupTest {
	public static function main() {
		print("  Group Test  ");
		print("--------------");

		var obj:Dynamic = {
			myStr: "Outside of group.",
			myCoolGroup: {
				myBool: true,
				myFloat: 10.22
			}
		}

		var retVal:String = TINI.stringify(obj);

		print(retVal);
	}

	public static inline function print(str:Dynamic) {
		haxe.Log.trace(Std.string(str), null);
	}
}
