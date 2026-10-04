package;

import tini.TINI;

class CustomRulesTest {
	static var INI_FILEPATH:String = "./assets/Custom Rules Test.ini";

	public static function main() {
		print("  Custom Rules Test  ");
		print("---------------------");

		var customRules:IniRules = {
			ASSIGN_KEY: ">",
			COMMENT_KEY: "#",
			ARGUMENT_DELIMITER: "|",
			ROOT_KEYWORD_ALLOWED: false,
			ANON_STRUCTURES_ALLOWED: false,
			CLASSES_ALLOWED: true,
			ENUM_ALLOWED: true,
			CLASS_KEY: "__ini_cls__",
			ENUM_KEY: "__ini_enm__"
		};

		var iniParser:IniParser = new IniParser(customRules);
		var retVal:Dynamic = iniParser.parse(sys.io.File.getContent(INI_FILEPATH));

		trace("legacyStr: " + retVal.legacyStr);
		trace("myStr: " + retVal.myStr);

		trace("myFloat: " + Std.string(retVal.myFloat));
		trace("myInt: " + Std.string(retVal.myInt));

		trace("myArray: " + Std.string(retVal.myArray));
		trace("myObject (Should be string): " + Std.string(retVal.myObject)); //This should print as a string because of the rules
		trace("myMap: " + Std.string(retVal.myMap));
	}

	public static inline function print(str:Dynamic) {
		haxe.Log.trace(Std.string(str), null);
	}
}
