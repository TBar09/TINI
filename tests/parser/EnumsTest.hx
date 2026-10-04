package;

import tini.TINI;

class EnumsTest {
	static var INI_FILEPATH:String = "./assets/Enums Test.ini";

	public static function main() {
		print("  Enums Test  ");
		print("--------------");

		var retVal:Dynamic = TINI.parse(sys.io.File.getContent(INI_FILEPATH));

		trace("mySingleCar: " + detectCarType(retVal.mySingleCar));
		trace("myCustomVar: " + detectCarType(retVal.myCustomVar));
		trace("myHybridCar: " + detectCarType(retVal.myHybridCar));
	}

	public static function detectCarType(type:Vehicle):String {
		return switch(type) {
			case CAR: "This is a car";
			case BICYCLE: "This is a bicycle";
			case TRUCK: "This is a truck";
			case CUSTOM(name, mph, isCool):
				'This is a ${name}, it can go ${Std.string(mph)} miles per hour${(isCool ? ' and is cool' : '')}';
			case HYBRID(vehicle1, vehicle2):
				'This is a hybrid | "${detectCarType(vehicle1)}" and "${detectCarType(vehicle1)}"';
		}
	}

	public static inline function print(str:Dynamic) {
		haxe.Log.trace(Std.string(str), null);
	}
}

@:keep
enum Vehicle {
	CAR;
	BICYCLE;
	TRUCK;
	CUSTOM(name:String, mph:Int, isCool:Bool);
	HYBRID(vehicle1:Vehicle, vehicle2:Vehicle);
}