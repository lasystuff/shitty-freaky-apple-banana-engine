package backend;

import objects.Note;

typedef SwagSong = {
	/** It will be displayed as song name everywhere, if `null` then will use `song` */
	@:optional var songDisplay:String;
	/** Shortcut to `Paths.formatToSongPath(song)` */
	@:optional var path:String;
	/** To set it property, use `Song.setSongName()` */
	var song:String;
	var notes:Array<SwagSection>;
	var events:Array<Dynamic>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;
	var offset:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var stage:String;
	var format:String;

	@:optional var gameOverChar:String;
	@:optional var gameOverSound:String;
	@:optional var gameOverLoop:String;
	@:optional var gameOverEnd:String;

	@:optional var disableNoteRGB:Bool;

	@:optional var arrowSkin:String;
	@:optional var splashSkin:String;
}

typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var sectionBeats:Float;
	var mustHitSection:Bool;
	@:optional var altAnim:Bool;
	@:optional var gfSection:Bool;
	@:optional var bpm:Float;
	@:optional var changeBPM:Bool;
}

class Song
{
	public static function setSongName(song:SwagSong, name:String, ?displayName:String):SwagSong {
		song.songDisplay = displayName ?? name;
		song.song = name;
		song.path = Paths.formatToSongPath(name);
		return song;
	}

	/** @return Is sectionBeats was broken? */
	public static function fixSectionBeats(section:SwagSection):Bool {
		var beats:Null<Float> = cast section.sectionBeats;
		if (beats == null || Math.isNaN(beats)) {
			section.sectionBeats = Conductor.getSectionBeats(section);
			return true;
		}
		return false;
	}

	public static function convert(songJson:Dynamic) // Convert old charts to psych_v1 format
	{
		if(songJson.gfVersion == null)
		{
			songJson.gfVersion = songJson.player3;
			if(Reflect.hasField(songJson, 'player3')) Reflect.deleteField(songJson, 'player3');
		}

		if(songJson.events == null)
		{
			songJson.events = [];
			for (secNum in 0...songJson.notes.length)
			{
				var sec:SwagSection = songJson.notes[secNum];

				var i:Int = 0;
				var notes:Array<Dynamic> = sec.sectionNotes;
				var len:Int = notes.length;
				while(i < len)
				{
					var note:Array<Dynamic> = notes[i];
					if(note[1] < 0)
					{
						songJson.events.push([note[0], [[note[2], note[3], note[4]]]]);
						notes.remove(note);
						len = notes.length;
					}
					else i++;
				}
			}
		}

		var sectionsData:Array<SwagSection> = songJson.notes;
		if(sectionsData == null) return;

		for (section in sectionsData)
		{
			if (fixSectionBeats(section) && Reflect.hasField(section, 'lengthInSteps'))
				Reflect.deleteField(section, 'lengthInSteps');

			for (note in section.sectionNotes)
			{
				var gottaHitNote:Bool = (note[1] < 4) ? section.mustHitSection : !section.mustHitSection;
				note[1] = (note[1] % 4) + (gottaHitNote ? 0 : 4);

				if(note[3] != null && !Std.isOfType(note[3], String))
					note[3] = Note.defaultNoteTypes[note[3]]; //compatibility with Week 7 and 0.1-0.3 psych charts
			}
		}
	}

	public static var chartPath:String;
	public static var loadedSongName:String;
	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong {
		folder ??= jsonInput;
		var json = getChart(jsonInput, folder);
		PlayState.SONG = json;
		trace('Loaded song:', jsonInput.toCMD(WHITE_BOLD));
		StageData.loadStage(json.stage);
		loadedSongName = folder;
		chartPath = _lastPath.replace('/', '\\');
		return PlayState.SONG;
	}

	static var _lastPath:String;
	public static function getChart(jsonInput:String, ?folder:String):SwagSong {
		folder ??= jsonInput;

		var path:String = Paths.jsonPath('$folder/$jsonInput');
		if (path == null) throw CoolUtil.prettierNotFoundException(Paths.lastError);
		var rawJson:String = Paths.text(path);
		_lastPath = path;

		return parseJSON(rawJson);
	}

	public static function parseJSON(rawData:String, ?convertTo:String = 'psych_v1'):SwagSong
	{
		var songJson:SwagSong = cast Json.parse(rawData);
		if(Reflect.hasField(songJson, 'song'))
		{
			var subSong:SwagSong = Reflect.field(songJson, 'song');
			if(subSong != null && Type.typeof(subSong) == TObject)
				songJson = subSong;
		}

		if(convertTo != null && convertTo.length > 0)
		{
			var fmt:String = songJson.format ?? 'unknown';
			switch(convertTo)
			{
				case 'psych_v1':
					if(!fmt.startsWith('psych_v1')) //Convert to Psych 1.0 format
					{
						trace('Converting chart with format', fmt.toCMD(WHITE_BOLD), 'to', 'psych_v1'.toCMD(WHITE_BOLD), 'format');
						songJson.format = 'psych_v1_convert';
						convert(songJson);
					}
			}
		}
		if (songJson != null) setSongName(songJson, songJson.song, songJson.songDisplay);
		return songJson;
	}
}