package backend;

import haxe.Exception;

#if tjson
import tjson.TJSON;
#end

@:publicFields
class Json {
	/** Contains `haxe.Exception` object which has last error occurred in methods. Changes only if error was happened. */
	static var lastError(default, null):Exception;

	#if tjson
	/**
	 * Parses a JSON string into a haxe `Dynamic` object or `Array`.
	 * @param json              The JSON string to parse.
	 * @param fileName          The file name to which the JSON code belongs. Used for generating nice error messages.
	 * @param stringProcessor   Doesn't currently do anything in TJSON.
	 * @return `Dynamic` object (structure) / `Array` / `null` (if `json` = `null` / empty string, or error occurred)
	 */
	#else
	/**
	 * Parses a JSON string into a haxe `Dynamic` object or `Array`.
	 * @param json              The JSON string to parse.
	 * @param fileName          Doesn't currently do anything.
	 * @param stringProcessor   Doesn't currently do anything.
	 * @return `Dynamic` object (structure) / `Array` / `null` (if `json` = `null` / empty string, or error occurred)
	 */
	#end
	static function parse(json:String, ?fileName:String = "JSON Data", ?stringProcessor:String->Dynamic):Null<Dynamic> {
		var val:Dynamic = "";
		try {
			val = #if tjson TJSON.parse(json, fileName, stringProcessor) #else haxe.Json.parse(json) #end;
		} catch(e:Exception) {
			lastError = e;
		}

		return val == "" ? null : val;
	}

	#if tjson
	/**
	 * Serializes a dynamic object or an array into a JSON `String`. Works like `encode` method, but uses arguments from `haxe.Json.stringify` method.
	 * @param value      The object to be serialized.
	 * @param replacer   Doesn't currently do anything.
	 * @param space      Parameter `value` will be indented by this string. If its not `null`, the result will be pretty-printed.
	 * @return `String` / `null` (if `value` = `null`, or error occurred)
	 */
	#else
	/**
	 * Serializes a dynamic object or an array into a JSON `String`.
	 * @param value      The object to be serialized.
	 * @param replacer   If its not `null`, it is used to retrieve the actual object to be encoded. The `replacer` function takes two parameters, the key and the value being encoded. Initial key value is an empty string.
	 * @param space      Parameter `value` will be indented by this string. If its not `null`, the result will be pretty-printed.
	 * @return `String` / `null` (if `value` = `null`, or error occurred)
	 */
	#end
	static function stringify(value:Dynamic, ?replacer:(key:Dynamic, value:Dynamic) -> Dynamic, ?space:String):Null<String> {
		var val:String = "";

		try {
			val = #if tjson TJSON.encode(value, space != null ? new HaxeJsonStyle(space) : null) #else haxe.Json.stringify(value, replacer, space) #end;
		} catch(e:Exception) {
			lastError = e;
		}

		return val == "" ? null : val;
	}

	#if tjson
	/**
	 * Serializes a dynamic object or an array into a JSON `String`.
	 * @param obj     The object to be serialized.
	 * @param style   The style to use. Either an object implementing EncodeStyle interface or the strings `fancy`/`simple`/`haxe`.
	 * @return `String` / `null` (if `obj` = `null`, or error occurred)
	 */
	static function encode(obj:Dynamic, ?style:Dynamic, ?useCache:Bool = true):Null<String> {
		if (style == 'haxe')
			style = new HaxeJsonStyle();

		var val:String = "";
		try {
			val = TJSON.encode(obj, style, useCache);
		} catch(e:Exception) {
			lastError = e;
		}

		return val == "" ? null : val;
	}
	#end
}

#if tjson
class HaxeJsonStyle extends FancyStyle {
	public function new(?tab:String = "\t") {
		super(tab);
	}
	override function firstEntry(depth:Int):String {
		return charTimesN(depth+1);
	}
	override function entrySeperator(depth:Int):String {
		return ",\n"+charTimesN(depth+1);
	}
	override function keyValueSeperator(depth:Int):String {
		return ": ";
	}
}
#end