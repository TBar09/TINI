package;

import tini.TINI;

class MapTest {
	static var INI_FILEPATH:String = "./assets/Map Test.ini";

	public static function main() {
		print("   Map Test   ");
		print("--------------");

		var retVal:Dynamic = TINI.parse(sys.io.File.getContent(INI_FILEPATH));

		var myStringMap:Map<String, Dynamic> = cast retVal.myStringMap;
		var myIntMap:Map<Int, Dynamic> = cast retVal.myIntMap;
		var myEnumMap:Map<EnumValue, Dynamic> = cast retVal.myEnumMap;
		var myObjectMap:haxe.ds.ObjectMap<Car, Dynamic> = cast retVal.myObjectMap;

		// String map
		print("myStringMap:");
		for(key in myStringMap.keys()) {
			print("\t" + key + ", " + retVal.myStringMap.get(key));
		}

		// Integer map
		print("myIntMap:");
		for(key in myIntMap.keys()) {
			print("\t" + key + ", " + retVal.myIntMap.get(key));
		}

		// enum map
		print("myEnumMap:");
		for(key in myEnumMap.keys()) {
			print("\t\"" + detectCarType(cast key) + "\", " + retVal.myEnumMap.get(key));
		}

		// object map
		/*
		print("myObjectMap:");
		for(key in myObjectMap.keys()) {
			print("\t\"" + (key : Car).toString() + "\" | " + retVal.myObjectMap.get(key));
		}
		*/
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