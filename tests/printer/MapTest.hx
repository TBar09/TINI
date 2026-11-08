package;

import tini.TINI;

class MapTest {
	public static function main() {
		print("   Map Test   ");
		print("--------------");

		var obj:Dynamic = {
			myStringMap: ["John" => "Guy", "Michael" => "Dude"],
			myIntMap: [1 => "Hello", 2 => "World", 3 => "!!!"],
			myEnumMap: [Vehicle.CAR => "This is a Car", Vehicle.TRUCK => "This is a Truck", Vehicle.BICYCLE => "This is a Bicycle"],
			myObjectMap: [new Car("Uno") => "Uno car", new Car("Dos") => "Dos car", new Car("Tres", 20) => "Tres car going 20 mph"]
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