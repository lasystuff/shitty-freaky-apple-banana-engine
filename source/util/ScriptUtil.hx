package util;
#if !macro
import flixel.FlxG;

class ScriptUtil
{
	public static var statics:Map<String, Dynamic> = [];
	public static var variables:Map<String, Dynamic> = [];

	public static function initCallback():Void
	{
		FlxG.signals.preStateCreate.add(function(s) variables.clear());
	}
}
#end