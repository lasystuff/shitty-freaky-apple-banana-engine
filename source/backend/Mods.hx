package backend;

#if MODS_ALLOWED
typedef ModsList = {
	enabled:Array<String>,
	disabled:Array<String>,
	all:Array<String>
};

@:access(backend.Paths)
class Mods
{
	static public var currentModDirectory:String;
	public static final ignoreModFolders:Array<String> = [
		'characters',
		'custom_events',
		'custom_notetypes',
		'data',
		'songs',
		'music',
		'sounds',
		'shaders',
		'videos',
		'images',
		'stages',
		'weeks',
		'fonts',
		'scripts',
		'achievements'
	];

	private static var globalMods:Array<String> = [];

	inline public static function getGlobalMods()
		return globalMods;

	public static function pushGlobalMods() // prob a better way to do this but idc
	{
		globalMods.clearArray();
		for(mod in parseList().enabled)
		{
			var pack:Dynamic = getPack(mod);
			if(pack?.runsGlobally) globalMods.push(mod);
		}
		return globalMods;
	}

	public static function setModDirectory(?folder:String) {
		Mods.currentModDirectory = folder.strNotEmpty() ? folder : null;
		Paths.resetDirectories();
	}

	public static function getModDirectories():Array<String> {
		var list:Array<String> = [];
		if(Paths.existsAbsolute(Paths.MODS_DIRECTORY)) {
			for (folder in Paths.readDirectory(Paths.MODS_DIRECTORY)) {
				var path = haxe.io.Path.join([Paths.MODS_DIRECTORY, folder]);
				if (Paths.isDirectory(path) && !ignoreModFolders.contains(folder) && !list.contains(folder)) {
					list.push(folder);
				}
			}
		}
		return list;
	}

	public static function getPack(?folder:String):Dynamic
		return Json.parse(Paths.text(Paths.modsPath('${folder ?? Mods.currentModDirectory}/pack.json')));

	public static var updatedOnState:Bool = false;
	public static function parseList():ModsList {
		if(!updatedOnState) updateModList();
		var list:ModsList = {enabled: [], disabled: [], all: []};

		if (Paths.existsAbsolute('modsList.txt')) for (mod in CoolUtil.coolTextFile('modsList.txt'))
		{
			//trace('Mod: $mod');
			if(mod.trim().length < 1) continue;

			var dat = mod.split("|");
			list.all.push(dat[0]);
			if (dat[1] == "1")
				list.enabled.push(dat[0]);
			else
				list.disabled.push(dat[0]);
		}
		return list;
	}
	
	private static function updateModList()
	{
		// Find all that are already ordered
		var list:Array<Array<Dynamic>> = [];
		var added:Array<String> = [];
		if (Paths.existsAbsolute('modsList.txt')) for (mod in CoolUtil.coolTextFile('modsList.txt'))
		{
			var dat:Array<String> = mod.split("|");
			var folder:String = dat[0];
			if(folder.trim().length > 0 && Paths.isDirectory(Paths.modsPath(folder)) && !added.contains(folder))
			{
				added.push(folder);
				list.push([folder, (dat[1] == "1")]);
			}
		}
		
		// Scan for folders that aren't on modsList.txt yet
		for (folder in getModDirectories())
		{
			if(folder.trim().length > 0 && Paths.isDirectory(Paths.modsPath(folder)) &&
			!ignoreModFolders.contains(folder.toLowerCase()) && !added.contains(folder))
			{
				added.push(folder);
				list.push([folder, true]); //i like it false by default. -bb //Well, i like it True! -Shadow Mario (2022)
				//Shadow Mario (2023): What the fuck was bb thinking
			}
		}

		// Now save file
		var fileStr:String = '';
		for (values in list)
		{
			if(fileStr.length > 0) fileStr += '\n';
			fileStr += values[0] + '|' + (values[1] ? '1' : '0');
		}

		if (fileStr.length > 0)
			Paths.saveFile('modsList.txt', fileStr);
		updatedOnState = true;
		//trace('Saved modsList.txt');
	}

	public static function loadTopMod()
	{
		var dir:Null<String> = null;
		var list:Array<String> = Mods.parseList().enabled;
		if(list != null && list[0] != null)
			dir = list[0];

		setModDirectory(dir);
	}
}
#end