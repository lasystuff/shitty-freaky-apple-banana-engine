package funkin.util;

import sys.FileSystem;
import funkin.modding.ModManager;

class Paths
{
	public static function get(key:String):String
	{
		for (d in ModManager.mods)
		{
			if (d.exists(key))
				return d.getPath(key);
		}

		return "res/" + key;
	}

	public static function read(key:String):Array<String>
	{
		var result = FileSystem.readDirectory("res/" + key);
		for (d in ModManager.mods)
		{
			result = result.concat(FileSystem.readDirectory(d.getPath(key)));
		}

		return result;
	}
}