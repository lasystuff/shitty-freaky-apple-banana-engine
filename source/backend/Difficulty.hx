package backend;

class Difficulty
{
	public static final defaultList:Array<String> = [
		'Easy',
		'Normal',
		'Hard'
	];
	private static final defaultDifficulty:String = 'Normal'; //The chart that has no postfix and starting difficulty on Freeplay/Story Mode

	public static var list:Array<String> = [];

	public static function getFilePath(?num:Int) {
		num ??= PlayState.storyDifficulty;

		var filePostfix:String = list[num];
		if(filePostfix != null && Paths.formatToSongPath(filePostfix) != Paths.formatToSongPath(defaultDifficulty))
			filePostfix = '-' + filePostfix;
		else
			filePostfix = '';

		return Paths.formatToSongPath(filePostfix);
	}

	public static function loadFromWeek(?week:WeekData) {
		week ??= WeekData.getCurrentWeek();

		var diffStr:String = week.difficulties;
		if(diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.trim().split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if(diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if(diffs[i].length < 1) diffs.remove(diffs[i]);
				}
				--i;
			}

			if(diffs.length > 0 && diffs[0].length > 0)
				list = diffs;
		}
		else resetList();
	}

	inline public static function resetList()
		list = defaultList.copy();

	inline public static function copyFrom(diffs:Array<String>)
		list = diffs.copy();

	inline public static function getString(?num:Int, ?canTranslate:Bool = true):String {
		var diffName:String = list[num ?? PlayState.storyDifficulty] ?? defaultDifficulty;
		return canTranslate ? Language.getPhrase('difficulty_$diffName', diffName) : diffName;
	}

	inline public static function getDefault():String
		return defaultDifficulty;
}