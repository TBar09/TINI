package;

import tini.TINI;

class ClassesTest {
	static var INI_FILEPATH:String = "./assets/Classes Test.ini";

	public static function main() {
		print("  Classes Test  ");
		print("----------------");

		var retVal:Dynamic = TINI.parse(sys.io.File.getContent(INI_FILEPATH));

		trace(retVal.mySingleCar.toString());
		trace(retVal.myBackupCar.toString());
	}

	public static inline function print(str:Dynamic) {
		haxe.Log.trace(Std.string(str), null);
	}
}

@:keep
class Car {
	var hybrid:Bool;

	var speed:Int;
	var name:String;
	var onError:String->Void;

	public function new(name:String, ?speed:Int = 10) {
		this.name = name;
		this.speed = speed;
	}

	function runClassError() {
		if(onError != null) onError(name);
	}

	public function toString():String {
		return '${this.name} is going ${this.speed} MPH${(hybrid == true ? " and is a hybrid" : "")}.';
	}
}