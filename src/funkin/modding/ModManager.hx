package funkin.modding;

import sys.FileSystem;
import sys.io.File;
import haxe.Json;

class ModManager
{
	public static var mods:Array<Modpack> = [];

	public static function reload():Void
	{
		mods = [];

		FunkinAssets.clearCache();

		for (folder in FileSystem.readDirectory(Constants.MODS_DIRECTORY))
		{
			if (!FileSystem.isDirectory(folder))
				continue;
			var metaFile:String = haxe.io.Path.join([Constants.MODS_DIRECTORY, folder, "modpack.json"]);
			var data:Modpack = FileSystem.exists(metaFile) ? Json.parse(File.getContent(metaFile)) : new Modpack();
			data.folder = folder;
			mods.push(data);
		}
	}
}