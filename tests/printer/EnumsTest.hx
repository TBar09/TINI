package;

import tini.TINI;

class EnumsTest {
	public static function main() {
		print("  Enums Test  ");
		print("--------------");

		var obj:Dynamic = {
			mySimpleEnum: Vehicle.BICYCLE,
			myArgumentEnum: Vehicle.CUSTOM("Tesla", 152, true),
			myNestedEnum: Vehicle.HYBRID(CUSTOM("Super Tesla", 250, false), TRUCK)
		}

		var retVal:String = TINI.stringify(obj);

		print(retVal);
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