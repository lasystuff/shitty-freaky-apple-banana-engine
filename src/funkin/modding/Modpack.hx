package funkin.modding;

import sys.FileSystem;
import haxe.Json;
import haxe.io.Path;

class Modpack
{
	public var folder:String = "";
	public var id:String = "";
	public var global:Bool = false;

	public function new():Void{}

	public function exists(file:String):Bool
		return FileSystem.exists(getPath(file));

	public function getPath(file:String):String
		return Path.join([Constants.MODS_DIRECTORY, folder, file]);
}