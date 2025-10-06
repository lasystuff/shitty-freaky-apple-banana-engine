package backend;

typedef WeekFile =
{
	// JSON variables
	var songs:Array<Dynamic>;
	var weekCharacters:Array<String>;
	var weekBackground:String;
	var weekBefore:String;
	var storyName:String;
	var weekName:String;
	var startUnlocked:Bool;
	var hiddenUntilUnlocked:Bool;
	var hideStoryMode:Bool;
	var hideFreeplay:Bool;
	var difficulties:String;
}

class WeekData {
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();
	public static var weeksLoaded:Map<String, WeekData> = new Map<String, WeekData>();
	public static var weeksList:Array<String> = [];
	public var folder:String = '';

	// JSON variables
	public var songs:Array<Dynamic>;
	public var weekCharacters:Array<String>;
	public var weekBackground:String;
	public var weekBefore:String;
	public var storyName:String;
	public var weekName:String;
	public var startUnlocked:Bool;
	public var hiddenUntilUnlocked:Bool;
	public var hideStoryMode:Bool;
	public var hideFreeplay:Bool;
	public var difficulties:String;

	public var fileName:String;

	public static function createWeekFile():WeekFile {
		var weekFile:WeekFile = {
			#if BASE_GAME_FILES
			songs: [["Bopeebo", "face", [146, 113, 253]], ["Fresh", "face", [146, 113, 253]], ["Dad Battle", "face", [146, 113, 253]]],
			weekCharacters: ['dad', 'bf', 'gf'],
			weekBackground: 'stage',
			weekBefore: 'tutorial',
			#else
			songs: [["Song", "face", [146, 113, 253]]],
			weekCharacters: ['bf', 'bf', 'gf'],
			weekBackground: '',
			weekBefore: '',
			#end
			storyName: 'Your New Week',
			weekName: 'Custom Week',
			startUnlocked: true,
			hiddenUntilUnlocked: false,
			hideStoryMode: false,
			hideFreeplay: false,
			difficulties: ''
		};
		return weekFile;
	}

	// HELP: Is there any way to convert a WeekFile to WeekData without having to put all variables there manually? I'm kind of a noob in haxe lmao
	public function new(weekFile:WeekFile, fileName:String) {
		// here ya go - MiguelItsOut
		var fields = Reflect.fields(this);
		for (field in Reflect.fields(weekFile))
			if(fields.contains(field)) // Reflect.hasField() won't fucking work :/
				Reflect.setProperty(this, field, Reflect.getProperty(weekFile, field));

		this.fileName = fileName;
	}

	public static function reloadWeekFiles(?isStoryMode:Bool)
	{
		weeksList.clearArray();
		weeksLoaded.clear();

		for (i => dir in Paths.directoriesWithFile('weeks'))
			for (file in Paths.readDirectory(dir)) if (file.hasExtension("json"))
				addWeek(file.removeExtension(), '$dir/$file', dir);
	}

	private static function addWeek(weekToCheck:String, path:String, directory:String)
	{
		if(!weeksLoaded.exists(weekToCheck))
		{
			var week:WeekFile = getWeekFile(path);
			if(week != null)
			{
				var weekFile:WeekData = new WeekData(week, weekToCheck);
				#if MODS_ALLOWED
				if(directory.contains(Paths.modsPath()))
					weekFile.folder = directory.substring(Paths.modsPath().length, directory.length-1);
				#end
				if((PlayState.isStoryMode && !weekFile.hideStoryMode) || (!PlayState.isStoryMode && !weekFile.hideFreeplay))
				{
					weeksLoaded.set(weekToCheck, weekFile);
					weeksList.push(weekToCheck);
				}
			}
		}
	}

	/** @param path Absolute path to json file. */
	private static function getWeekFile(path:String):WeekFile
		return cast Json.parse(Paths.text(path));

	//   FUNCTIONS YOU WILL PROBABLY NEVER NEED TO USE

	//To use on PlayState.hx or Highscore stuff
	public static function getWeekFileName():String {
		return weeksList[PlayState.storyWeek];
	}

	//Used on LoadingState, nothing really too relevant
	public static function getCurrentWeek():WeekData {
		return weeksLoaded.get(weeksList[PlayState.storyWeek]);
	}

	public static function setDirectoryFromWeek(?data:WeekData)
		setDirectory(data?.folder);

	public static function setDirectory(?folder:String)
		#if MODS_ALLOWED Mods.setModDirectory(folder); #else return; #end
}
