package;

import tini.TINI;

class ClassesTest {
	public static function main() {
		print("  Classes Test  ");
		print("----------------");

		var backupCar:Car = new Car("My Backup Car", 257);
		@:privateAccess backupCar.hybrid = true;

		var obj:Dynamic = {
			myCar: new Car("Super Cool Car", 152),
			myBackupCar: backupCar
		}

		var retVal:String = TINI.stringify(obj);

		print(retVal);
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