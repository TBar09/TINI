package tini;

using StringTools;
class TINI {
	/**
	 * The default rules that all parser/printer instances and TINI's
	 * `.parse`/`.stringify` use if a custom ruleset isn't set.
	 *
	 * You can edit edit this if you wan't to use a certain ruleset
	 * for all following uses.
	 */
	public static var defaultRules:IniRules = {
		ASSIGN_KEY: "=",
		COMMENT_KEY: ";",
		ARGUMENT_DELIMITER: ",",
		ROOT_KEYWORD_ALLOWED: true,
		ANON_STRUCTURES_ALLOWED: true,
		CLASSES_ALLOWED: true,
		ENUM_ALLOWED: true,
		CLASS_KEY: "__ini_cls__",
		ENUM_KEY: "__ini_enm__"
	};

	/**
	 * Parses an ini-syntax string and returns it as an anonymous structure.
	 *
	 * @param str			The string to parse.
	 * @param customRule	If present, can use custom rules when parsing.
	 *						Defaults to `defaultRules`.
	 * 
	 * @return The parsed ini structure.
	 */
	public static inline function parse(str:String, ?customRule:IniRules):Dynamic {
		return new IniParser(customRule != null ? customRule : defaultRules).parse(str);
	}

	/**
	 * Transforms an anonymous structure into an ini-syntax string.
	 *
	 * @param data			The structure to stringify.
	 * @param customRule	If present, can use custom rules when transforming.
	 *						Defaults to `defaultRules`.
	 * 
	 * @return The ini string.
	 */
	public static inline function stringify(data:Dynamic, ?customRule:IniRules):String {
		return new IniPrinter(customRule != null ? customRule : defaultRules).stringify(data);
	}
}

typedef IniRules = {
	/** The character to tell the parser where to split the key and value of a line. */
	@:optional @:default("=")
	var ASSIGN_KEY:String;

	/** The character to tell the parser if the line is a comment. */
	@:optional @:default(";")
	var COMMENT_KEY:String;

	/** The string to split arguments to an enum constructor or a class instance. */
	@:optional @:default(",")
	var ARGUMENT_DELIMITER:String;

	/** Whether group names can use "__root__" to add key-values outside of groups again. */
	@:optional @:default(true)
	var ROOT_KEYWORD_ALLOWED:Bool;

	/** Whether anonymous structures are allowed. */
	@:optional @:default(true)
	var ANON_STRUCTURES_ALLOWED:Bool;

	/** Whether classes are allowed. */
	@:optional @:default(true)
	var CLASSES_ALLOWED:Bool;

	/** The ID to tell the parser that the value is a class. */
	@:optional @:default("__ini_cls__")
	var CLASS_KEY:String;

	/** Whether enums are allowed. */
	@:optional @:default(true)
	var ENUM_ALLOWED:Bool;

	/** The ID to tell the parser that the value is an enum. */
	@:optional @:default("__ini_enm__")
	var ENUM_KEY:String;
}

class IniParser {
	public var rules:IniRules;
	public var position:Int;
	public var variables:Map<String, Dynamic>;
	public var onError:String->Bool;

	public function new(rules:IniRules) {
		this.rules = rules;
		this.variables = new Map();
		this.position = 1;

		this.floatRegex = ~/^[+-]?[0-9]*\.[0-9]*$/;
		this.intRegex = ~/^[+-]?[0-9]+$/;
		this.hexaRegex = ~/^[+-]?(?:0x)[0-9a-f]+$/i;
	}

	/**
	 * Parses an ini string text into an anonymous structure.
	 */
	public function parse(str:String):Dynamic {
		var retVal:Dynamic = {};
		var curGroup:String = null;

		var lines:Array<String> = str.split('\n');
		lines = lines.slice(position - 1, lines.length);
		position--;

		// Iterate through every line
		for(line in lines) {
			position++;

			if(line.ltrim().length <= 0) continue; // Skip blank lines

			var trimmedLine:String = line.trim();
			if(trimmedLine.startsWith(rules.COMMENT_KEY)) continue; // Skip single line comments

			// The line is a group declaration
			if(trimmedLine.fastCodeAt(0) == '['.code) {
				curGroup = getInnerStringText(trimmedLine).trim();

				// If the group's name is "__root__", then the current group is dropped and any further
				// key-value assigns will be added to the root structure.
				if(rules.ROOT_KEYWORD_ALLOWED && curGroup == "__root__") {
					curGroup = null;
					continue;
				}

				// If the group is missing from the structure, add it!
				if(!Reflect.hasField(retVal, curGroup)) {
					Reflect.setField(retVal, curGroup, {});
				}
				continue;
			}

			// The line is a key->value assign
			if(line.indexOf(rules.ASSIGN_KEY) != -1) {
				assignValue((curGroup == null ? retVal : Reflect.field(retVal, curGroup)), line, line.indexOf(rules.ASSIGN_KEY));
				continue;
			}

			error("Line can't be parsed!");
		}

		return retVal;
	}

	/**
	 * Removes the beginning and trailing character, like "", [], {}, etc.
	 */
	inline function getInnerStringText(line:String):String {
		return line.substring(1, line.length - 1);
	}

	/**
	 * Parses an assign line ("key=value") into an assign.
	 * Adds/sets the specified value to field `key` in `struct`.
	 * `index` is the line at which the assign key appears in
	 * (Usually the first instance of it reading from left to right).
	 */
	function assignValue(struct:Dynamic, line:String, index:Int):Void {
		var key:String = line.substring(0, index).trim();
		var valueStr:String = line.substring(index + 1).trim();
		var value:Dynamic = stringToType(valueStr);

		variables.set(key, value);
		Reflect.setField(struct, key, value);
	}

	/**
	 * Transforms a string into a proper value, depending on the string's contents.
	 *
	 * If the string contains surrounding "", then the quotes are removed and a string is returned.
	 * If the string references a class & classes are allowed, it will return a class instance.
	 * If the string references an enum & enums are allowed, it will return an enum value.
	 * If the value is a past declared key, then the key's value is returned.
	 * If the string references an anonymous structure and structures are allowed, it will return a structure.
	 *
	 * Maps (Specifically string maps), Arrays, Floats, Ints, Bools, and Null are supported.
	 *
	 * If all else fails, it returns the string as itself to keep compatability with original ini syntax.
	 */
	function stringToType(str:String):Dynamic {
		if(str.fastCodeAt(0) == '"'.code || str.fastCodeAt(0) == "'".code) // String in quotes
		{
			return parseStringDecl(getInnerStringText(str), false);
		}
		else if(rules.CLASSES_ALLOWED && str.startsWith(rules.CLASS_KEY)) // Class as a string
		{
			return parseClassDecl(str.substring(rules.CLASS_KEY.length));
		}
		else if(rules.ENUM_ALLOWED && str.startsWith(rules.ENUM_KEY)) // Enum as a string
		{
			return parseEnumDecl(str.substring(rules.ENUM_KEY.length));
		}
		else if(variables.exists(str)) // From an earlier declared variable
		{
			return variables.get(str);
		}
		else if(rules.ANON_STRUCTURES_ALLOWED && canBeAnonStruct(str)) // Anonymous Structure
		{
			return parseAnonStructDecl(str);
		}
		else if(canBeMap(str)) // Map
		{
			return parseMapDecl(str);
		}
		else if(canBeArray(str)) // Array
		{
			return parseArrayDecl(str);
		}
		else if(canBeInt(str)) // Int
		{
			return Std.parseInt(str);
		}
		else if(canBeFloat(str)) // Float
		{
			return Std.parseFloat(str);
		}
		else if(str == "true" || str == "false") // Bool
		{
			return (str == "true");
		}
		else if(str == "null") // Null
		{
			return null;
		}

		return str;
	}

	private var floatRegex:EReg;
	private var intRegex:EReg;
	private var hexaRegex:EReg;

	/**
	 * Returns true if the string can be a float.
	 */
	inline function canBeFloat(val:String):Bool {
		return floatRegex.match(val) || (intRegex.match(val) && {
			var intStr:String = intRegex.matched(0); // For integer overflow stuff
			intStr > (intStr.charCodeAt(0) == '-'.code ? "-2147483648" : "2147483647");
		});
	}

	/**
	 * Returns true if the string can be an integer.
	 */
	inline function canBeInt(val:String):Bool {
		return (intRegex.match(val) || hexaRegex.match(val));
	}

	/**
	 * Returns true if the string can be an array.
	 */
	inline function canBeArray(val:String):Bool {
		return (val.fastCodeAt(0) == '['.code && val.fastCodeAt(val.length - 1) == ']'.code);
	}

	/**
	 * Returns true if the string can be a map.
	 */
	inline function canBeMap(val:String):Bool {
		return canBeArray(val) && (val.indexOf("=>") != -1);
	}

	/**
	 * Returns true if the string can be an anonymous structure.
	 */
	inline function canBeAnonStruct(val:String):Bool {
		return (val.fastCodeAt(0) == '{'.code && val.fastCodeAt(val.length - 1) == '}'.code);
	}

	/**
	 * Transforms a regular string with literal "\\n" non-escape characters into a string
	 * with escape characters, if present.
	 *
	 * If `interpolationAllowed` is true, then string interpolation ($ and ${}) from single
	 * quoted strings are allowed.
	 *
	 * NOTE: This is only used if the value was wrapped in "" or '', If it's a
	 * legacy ini string (No quotes around it) then It doesn't run this and just returns itself.
	 */
	function parseStringDecl(str:String, interpolationAllowed:Bool):String {
		var newStr:StringBuf = new StringBuf();
		var waitQueue:Int = 0;

		for(i in 0...str.length) {
			var charCode:Int = str.charCodeAt(i);

			// This is primarily for escape characters, where we don't
			// wanna re-add additional characters used in the escape as real
			// characters, so we skip those after an escape character.
			if(waitQueue > 0) {
				waitQueue--;
				continue;
			}

			// If the current character is an escape character.
			if(charCode == '\\'.code) {
				var nextCharCode:Int = str.charCodeAt(i+1);
				switch(nextCharCode) {
					case 'n'.code:
						newStr.add("\n");

						waitQueue = 1;
						continue;

					case 't'.code:
						newStr.add("\t");

						waitQueue = 1;
						continue;

					case 'r'.code:
						newStr.add("\r");

						waitQueue = 1;
						continue;

					case '"'.code | "'".code | '\\'.code:
						newStr.add(String.fromCharCode(nextCharCode));

						waitQueue = 1;
						continue;

					case '/'.code:
						newStr.add("\\/");

						waitQueue = 1;
						continue;

					case 'u'.code:
						var hexValue:Int = 0;

						// TODO: Support for "\NNN", "\xNN", and "\u{N...}"
						for (ui in 0...4) {
							// The current position of the "u" after the escape character,
							// plus the following hex characters.
							var nextUnicodePos:Int = (i+1) + (ui+1);

							// If the unicode escape is ended early by EOF, then we throw an error.
							if (nextUnicodePos >= str.length) {
								error("Unfinished unicode character in string!");
								continue;
							}

							// Now if the current code is a valid hexidecimal digit, then we
							// add it to the final unicode escape.
							var unicodeCharCode:Int = str.charCodeAt((i+1) + (ui+1));
							hexValue = hexValue << 4;

							if(unicodeCharCode >= '0'.code && unicodeCharCode <= '9'.code) // 0...9
								hexValue += (unicodeCharCode - 48);
							else if(unicodeCharCode >= 'A'.code && unicodeCharCode <= 'F'.code) // A...F
								hexValue += (10 + unicodeCharCode - 65);
							else if(unicodeCharCode >= 'a'.code && unicodeCharCode <= 'f'.code) // a...f
								hexValue += (10 + unicodeCharCode - 95);
							else {
								error("String unicode escape contains non-hexidecimal digit!");
								continue;
							}
						}

						newStr.addChar(hexValue);

						waitQueue = 5;
						continue;
				}
			}

			newStr.addChar(charCode);
		}

		return newStr.toString();
	}

	/**
	 * Parses an array declaration into an actual array.
	 *
	 * This is also used to parse a class/enum constructor's argument list.
	 */
	function parseArrayDecl(str:String):Array<Dynamic> {
		var values:Array<Dynamic> = new Array();
		var curRecordedValue:String = "";

		var inString:Bool = false;
		var inArray:Bool = false;
		var inParenthesis:Bool = false;

		inline function inAnotherDecl():Bool {
			return (inString || inArray || inParenthesis);
		}

		var plainArr:String = getInnerStringText(str); // Removes the [] or ()
		for(i in 0...plainArr.length) {
			var char:String = plainArr.charAt(i);

			// If a " or ' is checked, then we switch to string mode.
			// This means that commas won't push the current value.
			if(char == '"' || char == "'") {
				inString = !inString;

				// We want to include the "" in the string so the parser immediately knows it's a string
				// continue;
			}

			// Same as strings, except for nested arrays and/or maps.
			if(char == '[') inArray = true;
			else if(char == ']') inArray = false;

			// Same as strings and arrays, except for class and enum constructing.
			if(char == '(' || char == '{') inParenthesis = true;
			else if(char == ')' || char == '}') inParenthesis = false;

			// If we are not inside a string, array, map, class, or enum and we hit a comma, then we parse
			// the current value and push it to the return array.
			if(!inAnotherDecl() && char == rules.ARGUMENT_DELIMITER) {
				var targetValue:Dynamic = stringToType(curRecordedValue.trim());
				values.push(targetValue);

				curRecordedValue = "";
				continue;
			}

			curRecordedValue += char;
		}

		if (inString) {
			error("Array contains unterminated string!");
			return null;
		}

		// If there is anything else in curRecordedValue that needs to be pushed, then
		// we do so here.
		if(curRecordedValue != null && curRecordedValue.length > 0) {
			var targetValue:Dynamic = stringToType(curRecordedValue.trim());
			values.push(targetValue);

			curRecordedValue = "";
		}

		return values;
	}

	/**
	 * Parses an map declaration into an actual map.
	 * String maps are the only supported map type, for now.
	 */
	function parseMapDecl(str:String):Map<Dynamic, Dynamic> {
		var values:Map<Dynamic, Dynamic> = new Map<Dynamic, Dynamic>();
		var canTypeValue:Bool = false;

		var inString:Bool = false;
		var inArray:Bool = false;
		var inParenthesis:Bool = false;

		inline function inAnotherDecl():Bool {
			return (inString || inArray || inParenthesis);
		}

		var curRecordedKey:String = "";
		var curRecordedValue:String = "";
		var cachedKeyVal:Dynamic = null;

		var plainArr:String = getInnerStringText(str); // Removes the []
		for(i in 0...plainArr.length) {
			var char:String = plainArr.charAt(i);

			if(char == '"' || char == "'") {
				inString = !inString;
				// continue;
			}

			if(char == '[') inArray = true;
			else if(char == ']') inArray = false;

			if(char == '(' || char == '{') inParenthesis = true;
			else if(char == ')' || char == '}') inParenthesis = false;

			/*
			 * If we are not inside a string, array, or map and we hit a "=>" operator, then we stop
			 * recording the key name, save it to the map, and then start recording the
			 * key's value.
			 */
			if(!inAnotherDecl() && char == '=') {
				// This conditional is here and not in the conditional above so we can
				// have a special error when you use "=" instead of "=>" for key value splitting.
				if(plainArr.charAt(i + 1) == '>') {
					cachedKeyVal = stringToType(curRecordedKey.trim());
					values.set(cachedKeyVal, null);

					canTypeValue = true;
					continue;
				} else {
					error("Maps do not use \"" + char + plainArr.charAt(i + 1) + "\" for assigning. Use the \"=>\" operator instead!");
					break;
				}
			}

			// If we are not inside a string, array, map, class, or enum and we hit a comma,
			// then we parse the current value and push it to the return map.
			if(!inAnotherDecl() && char == rules.ARGUMENT_DELIMITER) {
				var targetValue:Dynamic = stringToType(curRecordedValue.substr(1).trim());
				values.set(cachedKeyVal, targetValue);

				canTypeValue = false;
				curRecordedKey = "";
				curRecordedValue = "";
				cachedKeyVal = null;

				continue;
			}

			if(canTypeValue)
				curRecordedValue += char;
			else
				curRecordedKey += char;
		}

		if(inString) {
			error('Map contains unterminated string!');
			return null;
		}

		// If there is anything else in curRecordedValue that needs to be pushed, then
		// we do so here.
		if(curRecordedValue != null && curRecordedValue.length > 0) {
			var targetValue:Dynamic = stringToType(curRecordedValue.substr(1).trim());
			values.set(cachedKeyVal, targetValue);
		}

		return values;
	}

	/**
	 * Parses an anonymous structure declaration into an actual structure.
	 * Under the hood, this works exactly like the map parser!
	 */
	function parseAnonStructDecl(str:String):Dynamic {
		var values:Dynamic = {};
		var canTypeValue:Bool = false;

		var inString:Bool = false;
		var inArray:Bool = false;
		var inParenthesis:Bool = false;

		inline function inAnotherDecl():Bool {
			return (inString || inArray || inParenthesis);
		}

		var curRecordedKey:String = "";
		var curRecordedValue:String = "";
		var cachedKeyVal:Dynamic = null;

		var plainArr:String = getInnerStringText(str); // Removes the {}
		for(i in 0...plainArr.length) {
			var char:String = plainArr.charAt(i);

			if(char == '"' || char == "'") {
				inString = !inString;
				// continue;
			}

			if(char == '[') inArray = true;
			else if(char == ']') inArray = false;

			if(char == '(' || char == '{') inParenthesis = true;
			else if(char == ')' || char == '}') inParenthesis = false;

			if(!inAnotherDecl() && char == ':') {
				canTypeValue = true;
				continue;
			}

			if(!inAnotherDecl() && char == rules.ARGUMENT_DELIMITER) {
				var targetValue:Dynamic = stringToType(curRecordedValue.substr(1).trim());
				Reflect.setField(values, curRecordedKey.trim(), targetValue);

				canTypeValue = false;
				curRecordedKey = "";
				curRecordedValue = "";

				continue;
			}

			if(canTypeValue)
				curRecordedValue += char;
			else
				curRecordedKey += char;
		}

		if(inString) {
			error("Anonymous Structure contains unterminated string!");
			return null;
		}

		if(curRecordedValue != null && curRecordedValue.length > 0) {
			var targetValue:Dynamic = stringToType(curRecordedValue.substr(1).trim());
			Reflect.setField(values, curRecordedKey.trim(), targetValue);
		}

		return values;
	}

	/**
	 * Parses an enum declaration into an actual enum instance.
	 * Example: `__ini_enm__my_path_MyEnum.VALUE("Hello"\|"World")`
	 *
	 * Current issue: Problem with nested enums.
	 */
	function parseEnumDecl(str:String):Dynamic {
		var __dotIndex:Int = str.indexOf('.');

		var enumConstructorName:String = str.substring(0, __dotIndex).replace("_", ".");
		var enumValue:String = str.substr(__dotIndex + 1);

		var hasParams:Bool = (enumValue.indexOf('(') != -1);
		var enumValueName:String = enumValue.substr(0, (hasParams ? enumValue.indexOf('(') : null));

		// Actual arguments going into the createInstance
		var enmConst:Enum<Dynamic> = Type.resolveEnum(enumConstructorName);
		var args:Array<Dynamic> = [];

		if(enmConst == null) {
			error('Enum "${enumConstructorName}" was not found! Does it exist?');
			return null;
		}

		// Iterate through all args
		if(hasParams) {
			args = parseArrayDecl(enumValue.substring(enumValue.indexOf('('), enumValue.lastIndexOf(')') + 1));
		}

		return Type.createEnum(enmConst, enumValueName, (hasParams ? args : null));
	}

	/**
	 * Parses a class declaration into an actual class instance. All of the class's
	 * fields are set in a map.
	 * Example: `__ini_cls__my_path_MyClass(["Hello" => 10, "World" => false])`
	 */
	function parseClassDecl(str:String):Class<Dynamic> {
		var __paranthesisIndex:Int = str.indexOf('(');

		var hasParams:Bool = (__paranthesisIndex != -1);

		// If the paranthesis is not found, then we switch it to the length of the
		// string for the line below.
		if(__paranthesisIndex == -1) __paranthesisIndex = str.length;

		var className:String = str.substring(0, __paranthesisIndex).replace("_", ".");

		// Actual arguments going into the createInstance
		var clsConst:Class<Dynamic> = Type.resolveClass(className);
		var args:Map<Dynamic, Dynamic> = null;

		if(clsConst == null) {
			error('Class "${className}" was not found! Does it exist?');
			return null;
		}

		var clsRetInst:Class<Dynamic> = Type.createEmptyInstance(clsConst);

		// Iterate through all args & set their respective property in the newly created
		// class instance.
		if(hasParams) {
			var clsArgs:String = str.substring(str.indexOf('['), str.lastIndexOf(']') + 1);
			args = parseMapDecl(clsArgs);

			/*
			 * We only want variables to be added to the new class instance. Functions
			 * are always something when an empty instance is created, so we check if the
			 * current field is null before assigning it something to avoid assigning
			 * something to a function.
			 */
			for(field => value in args) {
				if(Reflect.field(clsRetInst, field) == null) {
					Reflect.setProperty(clsRetInst, field, value);
				}
			}
		}

		return clsRetInst;
	}

	/**
	 * Errors out the parser with a `throw`. If `onError` is not null
	 * and returns true on call, the error will be prevented.
	 */
	public function error(msg:String) {
		if(onError != null && onError(msg) == true) return;
		throw 'Line ${Std.string(position)}: $msg';
	}
}

class IniPrinter {
	public var rules:IniRules;

	public function new(rules:IniRules) {
		this.rules = rules;
	}

	/**
	 * Transforms an anonymous structure into a `.ini` string.
	 */
	public function stringify(data:Dynamic):String {
		var retVal:StringBuf = new StringBuf();
		var grouped:Array<Dynamic> = [];

		retVal.add(rules.COMMENT_KEY + " Generated by the TINI library\n\n");

		inline function printFields(struct:Dynamic) {
			for(field in Reflect.fields(struct)) {
				var fieldValue:Dynamic = Reflect.field(struct, field);

				if(Type.typeof(fieldValue) == TObject) // If it's a sub-group, we add it to a cache for later
				{
					grouped.push({name: field, value: fieldValue});
				}
				else // Else we just print out the field regularly
				{
					retVal.add(field + rules.ASSIGN_KEY + stringifyType(fieldValue) + "\n");
				}
			}
		}

		printFields(data);

		// We print out the groups after so we don't add out-of-group values into the group for being declared after.
		// TODO: Support for subgroups?
		for(field in grouped) {
			retVal.add('\n[${field.name}]\n');
			printFields(field.value);
		}

		return retVal.toString();
	}

	/**
	 * Stringifies an object.
	 * This differs from `Std.string` as it detects an enum instance
	 * and has a special parser for it.
	 *
	 * @see `stringifyClassDecl`
	 * @see `stringifyEnumDecl`
	 * @see `stringifyMapDecl`
	 * @see `stringifyArrayDecl`
	 */
	function stringifyType(obj:Dynamic):String {
		if(obj is String) //Strings
		{
			return '"' + stringifyStringDecl(obj) + '"';
		}
		else if(obj is haxe.Constraints.IMap) //Maps
		{
			return stringifyMapDecl(obj);
		}
		else if(obj is Array) // Arrays
		{
			return stringifyArrayDecl(obj);
		}

		return switch(Type.typeof(obj)) {
			case TEnum(_) if(rules.ENUM_ALLOWED):
				stringifyEnumDecl(obj);

			case TClass(_) if(rules.CLASSES_ALLOWED):
				stringifyClassDecl(obj);

			default:
				Std.string(obj);

		}
	}

	/**
	 * Transforms a string with escape characters (\n, \t) into a string that explicitly
	 * shows the escape character (\\n, \\t) for use in an ini string.
	 *
	 * We can't do \u since their 4-digit codes aren't available to type explicitly.
	 */
	inline function stringifyStringDecl(strVal:String):String {
		return strVal.replace("\\", "\\\\").replace("\r", "\\r").replace("\n", "\\n").replace("\t", "\\t").replace("\'", "\\'").replace('\"', '\\"');
	}

	/**
	 * Stringifies an array for use in an ini string.
	 */
	inline function stringifyArrayDecl(arrVal:Array<Dynamic>):String {
		return "[" + [for(val in arrVal) stringifyType(val)].join(rules.ARGUMENT_DELIMITER + " ") + "]";
	}

	/**
	 * Stringifies a map for use in an ini string.
	 */
	function stringifyMapDecl(mapVal:Map<Dynamic, Dynamic>):String {
		var retStrBuf:StringBuf = new StringBuf();

		retStrBuf.add('[');
		for(key => value in mapVal) {
			retStrBuf.add(stringifyType(key) + ' => ' + stringifyType(value));
			retStrBuf.add(rules.ARGUMENT_DELIMITER + " ");
		}

		var str:String = retStrBuf.toString();
		return str.substring(0, str.length-2) + "]";
	}
	
	/**
	 * Stringifies a class for use in an ini string.
	 */
	function stringifyClassDecl(clsVal:Dynamic):String {
		var cls:Class<Dynamic> = Type.getClass(clsVal);
		var classPath:String = Type.getClassName(cls);

		var args:Map<String, Dynamic> = [];
		for(fieldName in Type.getInstanceFields(cls)) {
			var propVal:Dynamic = Reflect.getProperty(clsVal, fieldName);

			// We can't stringify functions. Would be interesting tho
			if(Reflect.isFunction(propVal) == true) {
				continue;
			}

			args.set(fieldName, propVal);
		}

		var paramContainerStr:StringBuf = new StringBuf();

		// If the class has fields (which it most likely does), we add it here
		if(args != null) {
			paramContainerStr.add("(");
			paramContainerStr.add(stringifyMapDecl(args));
			paramContainerStr.add(")");
		}

		return rules.CLASS_KEY + classPath.replace(".", "_") + paramContainerStr.toString();
	}

	/**
	 * Stringifies an enum for use in an ini string.
	 */
	function stringifyEnumDecl(enmVal:EnumValue):String {
		var enumValueName:String = Type.enumConstructor(enmVal);
		var enumPath:String = Type.getEnumName(Type.getEnum(enmVal));

		var args:Array<String> = [for(arg in Type.enumParameters(enmVal)) stringifyType(arg)];
		var paramContainerStr:StringBuf = new StringBuf();

		// If the enum value has arguments, we add it here
		if(args != null && args.length > 0) {
			paramContainerStr.add("(");
			paramContainerStr.add(args.join(rules.ARGUMENT_DELIMITER));
			paramContainerStr.add(")");
		}

		return rules.ENUM_KEY + enumPath.replace(".", "_") + "." + enumValueName + paramContainerStr.toString();
	}
}
