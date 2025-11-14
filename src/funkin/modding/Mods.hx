package funkin;

class Mods
{
	public static var modsLookup:Map<String, ModData> = [];
	public static var modsList:Array<ModData> = [];

	public static var globalMods(get, never):Array<ModData>;
	private static function get_globalMods():Array<ModData>
	{
		return modsList.filter(function(mod:ModData) return mod.global);
	}
}

@:structInit class ModData
{
	public var folder:String;
	public var name:String = "";
	public var global:Bool = false;

	public function exists(file:String):Bool
	{
		return FileSystem.exists("mods/" + folder + "/" + file);
	}

	public function get(file:String):Bool
	{
		return "mods/" + folder + "/" + file;
	}
}