package backend;

class Language
{
	public static var language(get, set):String;
	public static var defaultLangName:String = 'English (US)'; //en-US

	static var phrases:Map<String, String> = [];
	public static function reloadPhrases(?stackItem:StackItem) {
		#if TRANSLATIONS_ALLOWED
		stackItem = Paths.getStackItem(stackItem);

		var langFile:String = ClientPrefs.data.language;
		if (langFile == ClientPrefs.defaultData.language)
			return AlphaCharacter.loadAlphabetData(stackItem);

		var loadedText:Array<String> = Paths.mergeAllTextsNamed('data/$langFile.lang');
		//trace(loadedText);

		phrases.clear();
		var hasPhrases:Bool = false;
		for (num => phrase in loadedText) {
			phrase = phrase.trim();
			if(num < 1 && !phrase.contains(':')) {
				//First line ignores formatting and shit if the line doesn't have ":" because its language_name
				phrases.set('language_name', phrase.trim());
				continue;
			}

			if(phrase.length < 4 || phrase.startsWith('//')) continue; 

			var n:Int = phrase.indexOf(':');
			if(n < 0) continue;

			var key:String = phrase.substr(0, n).trim().toLowerCase();

			var value:String = phrase.substr(n);
			n = value.indexOf('"');
			if(n < 0) continue;

			//trace("Mapped to " + key);
			phrases.set(key, value.substring(n+1, value.lastIndexOf('"')).replace('\\n', '\n'));
			hasPhrases = true;
		}

		if(!hasPhrases) ClientPrefs.data.language = ClientPrefs.defaultData.language;

		var alphaPath:String = getFileTranslation('images/alphabet');
		if(alphaPath.startsWith('images/')) alphaPath = alphaPath.substr('images/'.length);
		var pngPos:Int = alphaPath.indexOf('.png');
		if(pngPos > -1) alphaPath = alphaPath.substring(0, pngPos);
		AlphaCharacter.loadAlphabetData(alphaPath);
		#else
		AlphaCharacter.loadAlphabetData();
		#end
	}

	public static function getPhrase(key:String, ?defaultPhrase:String, values:Array<Dynamic> = null):String {
		var str:String = #if TRANSLATIONS_ALLOWED phrases.get(formatKey(key)) ?? #end defaultPhrase ?? key;

		if(values != null)
			for (num => value in values)
				str = str.replace('{${num+1}}', value);

		return str;
	}

	// More optimized for file loading
	public static function getFileTranslation(key:String):String
		return #if TRANSLATIONS_ALLOWED phrases.get(key.trim().toLowerCase()) ?? #end key;

	#if TRANSLATIONS_ALLOWED
	static function formatKey(key:String) {
		final hideChars = ~/[~&;:<>#.,'"%?!]/g;
		return hideChars.replace(key.replace(' ', '_'), '').toLowerCase().trim();
	}
	#end

	#if LUA_ALLOWED
	public static function implementLua(lua:psychlua.FunkinLua) {
		lua.set("getTranslationPhrase", getPhrase);
		lua.set("getFileTranslation", getFileTranslation);
	}
	#end

	@:noCompletion inline static function get_language() return ClientPrefs.data?.language ?? 'en-US';
	@:noCompletion inline static function set_language(v:String) return ClientPrefs.data != null ? ClientPrefs.data.language = v : v;
}