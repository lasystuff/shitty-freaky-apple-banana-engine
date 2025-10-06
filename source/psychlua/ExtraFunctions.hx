package psychlua;

import flixel.util.FlxSave;

//
// Things to trivialize some dumb stuff like splitting strings on older Lua
//

class ExtraFunctions
{
	public static function implementLua(lua:FunkinLua)
	{
		var game = PlayState.instance;

		// Keyboard & Gamepads
		lua.set("keyboardJustPressed", function(name:String) return Reflect.getProperty(FlxG.keys.justPressed, name));
		lua.set("keyboardPressed", function(name:String) return Reflect.getProperty(FlxG.keys.pressed, name));
		lua.set("keyboardReleased", function(name:String) return Reflect.getProperty(FlxG.keys.justReleased, name));

		lua.set("anyGamepadJustPressed", function(name:String) return FlxG.gamepads.anyJustPressed(name));
		lua.set("anyGamepadPressed", function(name:String) FlxG.gamepads.anyPressed(name));
		lua.set("anyGamepadReleased", function(name:String) return FlxG.gamepads.anyJustReleased(name));

		lua.set("gamepadAnalogX", function(id:Int, ?leftStick:Bool = true)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return 0.0;

			return controller.getXAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		lua.set("gamepadAnalogY", function(id:Int, ?leftStick:Bool = true)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return 0.0;

			return controller.getYAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		lua.set("gamepadJustPressed", function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return false;

			return Reflect.getProperty(controller.justPressed, name) == true;
		});
		lua.set("gamepadPressed", function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return false;

			return Reflect.getProperty(controller.pressed, name) == true;
		});
		lua.set("gamepadReleased", function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return false;

			return Reflect.getProperty(controller.justReleased, name) == true;
		});

		lua.set("keyJustPressed", function(name:String = '') {
			name = name.toLowerCase().trim();
			switch(name) {
				case 'left': return game.controls.NOTE_LEFT_P;
				case 'down': return game.controls.NOTE_DOWN_P;
				case 'up': return game.controls.NOTE_UP_P;
				case 'right': return game.controls.NOTE_RIGHT_P;
				default: return game.controls.justPressed(name);
			}
			return false;
		});
		lua.set("keyPressed", function(name:String = '') {
			name = name.toLowerCase().trim();
			switch(name) {
				case 'left': return game.controls.NOTE_LEFT;
				case 'down': return game.controls.NOTE_DOWN;
				case 'up': return game.controls.NOTE_UP;
				case 'right': return game.controls.NOTE_RIGHT;
				default: return game.controls.pressed(name);
			}
			return false;
		});
		lua.set("keyReleased", function(name:String = '') {
			name = name.toLowerCase().trim();
			switch(name) {
				case 'left': return game.controls.NOTE_LEFT_R;
				case 'down': return game.controls.NOTE_DOWN_R;
				case 'up': return game.controls.NOTE_UP_R;
				case 'right': return game.controls.NOTE_RIGHT_R;
				default: return game.controls.justReleased(name);
			}
			return false;
		});

		var variables = MusicBeatState.getVariables();
		// Save data management
		lua.set("initSaveData", function(name:String, ?folder:String = 'psychenginemods') {
			if(!variables.exists('save_$name'))
			{
				var save:FlxSave = new FlxSave();
				// folder goes unused for flixel 5 users. @BeastlyGhost
				save.bind(name, CoolUtil.getSavePath() + '/' + folder);
				variables.set('save_$name', save);
				return;
			}
			lua.debugPrint('initSaveData: Save file already initialized: $name');
		});
		lua.set("flushSaveData", function(name:String) {
			if(variables.exists('save_$name')) {
				variables.get('save_$name').flush();
				return;
			}
			lua.debugPrint('flushSaveData: Save file not initialized: $name', FlxColor.RED);
		});
		lua.set("getDataFromSave", function(name:String, field:String, ?defaultValue:Dynamic = null) {
			if(variables.exists('save_$name'))
			{
				var saveData = variables.get('save_$name').data;
				if(Reflect.hasField(saveData, field))
					return Reflect.field(saveData, field);
				else
					return defaultValue;
			}
			lua.debugPrint('getDataFromSave: Save file not initialized: $name', FlxColor.RED);
			return defaultValue;
		});
		lua.set("setDataFromSave", function(name:String, field:String, value:Dynamic) {
			if(variables.exists('save_$name'))
			{
				Reflect.setField(variables.get('save_$name').data, field, value);
				return;
			}
			lua.debugPrint('setDataFromSave: Save file not initialized: $name', FlxColor.RED);
		});
		lua.set("eraseSaveData", function(name:String)
		{
			if (variables.exists('save_$name'))
			{
				variables.get('save_$name').erase();
				return;
			}
			lua.debugPrint('eraseSaveData: Save file not initialized: $name', FlxColor.RED);
		});

		// File management
		lua.set("checkFileExists", function(filename:String, ?absolute:Bool = false) {
			return absolute ? Paths.existsAbsolute(filename) : Paths.exists(filename);
		});
		lua.set("saveFile", function(path:String, content:String, ?absolute:Bool = false)
		{
			try {
				if(!absolute)
					Paths.saveFile(Paths.modsPath(path), content);
				else
					Paths.saveFile(path, content);

				return true;
			} catch (e:Dynamic) {
				lua.debugPrint('saveFile: Error trying to save $path: $e', FlxColor.RED);
			}
			return false;
		});
		lua.set("deleteFile", function(path:String, ?ignoreModFolders:Bool = false, ?absolute:Bool = false)
		{
			#if sys
			try {
				var path = absolute ? (Paths.existsAbsolute(path) ? path : null) : Paths.path(path, ignoreModFolders);
				if (path == null) throw CoolUtil.prettierNotFoundException(Paths.lastError);
				Paths.deleteFile(path);
			} catch (e:Dynamic) {
				lua.debugPrint('deleteFile: Error trying to delete $path: $e', FlxColor.RED);
			}
			#end
			return false;
		});
		lua.set("getTextFromFile", Paths.getTextFromFile);
		lua.set("directoryFileList", Paths.readDirectory);

		// String tools
		lua.set("stringStartsWith", StringTools.startsWith);
		lua.set("stringEndsWith", StringTools.endsWith);
		lua.set("stringTrim", StringTools.trim);
		lua.set("stringSplit", function(str:String, split:String) {
			return str.split(split);
		});

		// Randomization
		lua.set("getRandomInt", function(min:Int, max:Int = FlxMath.MAX_VALUE_INT, exclude:String = '') {
			var excludeArray:Array<String> = exclude.split(',');
			var toExclude:Array<Int> = [];
			for (i in 0...excludeArray.length)
			{
				if (exclude == '') break;
				toExclude.push(Std.parseInt(excludeArray[i].trim()));
			}
			return FlxG.random.int(min, max, toExclude);
		});
		lua.set("getRandomFloat", function(min:Float, max:Float = 1, exclude:String = '') {
			var excludeArray:Array<String> = exclude.split(',');
			var toExclude:Array<Float> = [];
			for (i in 0...excludeArray.length)
			{
				if (exclude == '') break;
				toExclude.push(Std.parseFloat(excludeArray[i].trim()));
			}
			return FlxG.random.float(min, max, toExclude);
		});
		lua.set("getRandomBool", FlxG.random.bool);
	}
}
