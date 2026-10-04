package;

import tini.TINI;

class GroupTest {
	static var INI_FILEPATH:String = "./assets/My Test Ini.ini";

	public static function main() {
		print("  Group Test  ");
		print("--------------");

		var retVal:Dynamic = TINI.parse(sys.io.File.getContent(INI_FILEPATH));

		var myCoolGroup:Dynamic = Reflect.field(retVal, "My Cool Group");
		var myOtherGroup:Dynamic = Reflect.field(retVal, "My Other Group");

		trace("Cool Group) myOtherStr: " + Std.string(myCoolGroup.myOtherStr));
		trace("Other Group) myNullVal: " + Std.string(myOtherGroup.myNullVal));
	}

	public static inline function print(str:Dynamic) {
		haxe.Log.trace(Std.string(str), null);
	}
}
