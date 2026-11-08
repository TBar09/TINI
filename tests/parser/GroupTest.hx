package;

import tini.TINI;

class GroupTest {
	static var INI_FILEPATH:String = "./assets/My Test Ini.ini";
	static var INI_SUBGROUPS_FILEPATH:String = "./assets/Sub Groups Test.ini";

	public static function main() {
		print("  Group Test  ");
		print("--------------");

		var retVal:Dynamic = TINI.parse(sys.io.File.getContent(INI_FILEPATH));

		var myCoolGroup:Dynamic = Reflect.field(retVal, "My Cool Group");
		var myOtherGroup:Dynamic = Reflect.field(retVal, "My Other Group");

		trace("Cool Group) myOtherStr: " + Std.string(myCoolGroup.myOtherStr));
		trace("Other Group) myNullVal: " + Std.string(myOtherGroup.myNullVal));

		print("\n  Sub Group Test  ");
		print("------------------");

		var retVal:Dynamic = TINI.parse(sys.io.File.getContent(INI_SUBGROUPS_FILEPATH));

		var myGroup:Dynamic = Reflect.field(retVal, "My Group");
		var mySubGroup:Dynamic = Reflect.field(myGroup, "My Sub Group");
		var myCoolGroup:Dynamic = Reflect.field(Reflect.field(myGroup, "Other Group"), "Super Cool");
		var myAwesomeGroup:Dynamic = Reflect.field(Reflect.field(myGroup, "My Sub Group"), "Awesome");

		trace("myGroup) myStr: " + Std.string(myGroup.myStr));
		trace("My Group.My Sub Group) myStr: " + Std.string(mySubGroup.myStr));
		trace("My Group.Other Group.Super Cool) myInt: " + Std.string(myCoolGroup.myInt));
		trace("My Group.Other Group.Super Cool) myBool: " + Std.string(myCoolGroup.myBool));
		trace("My Group.My Sub Group.Awesome) myFloat: " + Std.string(myAwesomeGroup.myFloat));
		trace("My Group.My Sub Group.Awesome) myOtherStr: " + Std.string(myAwesomeGroup.myOtherStr));
	}

	public static inline function print(str:Dynamic) {
		haxe.Log.trace(Std.string(str), null);
	}
}
