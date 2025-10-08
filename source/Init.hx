package;

import psychlua.HScript;
import flixel.util.FlxSignal;
#if LUA_ALLOWED
import llua.Lua;
#end
import debug.GPUStats;

class Init extends MusicBeatState
{
	/** if `false`, you cant change fullscreen by `Alt+Enter` or `F11` */
	public static var fullscreenAllowed:Bool = true;
	/** dispatches on each fullscreen change */
	public static var onFullscreenChange:FlxSignal = new FlxSignal();

	public static var initScripts:Array<HScript> = [];

	override public function create()
	{
		#if LUA_ALLOWED Lua.set_callbacks_function(cpp.Callable.fromStaticFunction(psychlua.CallbackHandler.call)); #end
		Controls.instance = new Controls();
		ClientPrefs.loadDefaultKeys();
		Paths.resetDirectories();
		util.ScriptUtil.initCallback();

		#if debug
		var classesToRegister:Array<Class<Dynamic>> = [
			Main,
			backend.ClientPrefs,
			backend.Conductor,
			backend.Controls,
			backend.CoolUtil,
			backend.Difficulty,
			backend.Highscore,
			backend.Json,
			backend.Language,
			backend.Mods,
			backend.MusicBeatState,
			backend.MusicBeatSubstate,
			backend.Paths,
			backend.Song,
			backend.WeekData,
			psychlua.LuaUtils,
			states.PlayState,
			util.StaticExtensions,

			#if windows
			debug.GPUStats,
			backend.native.Windows,
			#end

			#if !flash
			shaders.Shaders,
			#end
		];
		for (cl in classesToRegister) FlxG.game.debugger.console.registerClass(cl);
		#end

		FlxG.stage.addEventListener("keyDown", event -> {
			if (event.keyCode == openfl.ui.Keyboard.F11 || (event.altKey && event.keyCode == openfl.ui.Keyboard.ENTER)) {
				if (fullscreenAllowed)
					new FlxTimer().start(FlxG.elapsed * 5, tmr -> { onFullscreenChange.dispatch(); });
				else
					@:privateAccess FlxG.stage.application.__backend.toggleFullscreen = false; // if setted to false, bro doesnt let toggle fullscreen in only NEXT toggle
			}
		});
		onFullscreenChange.add(function() FlxG.fullscreen = !FlxG.fullscreen);

		#if linux
		var icon = Image.fromFile("icon.png");
		Lib.current.stage.window.setIcon(icon);
		#end

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		FlxG.keys.preventDefaultKeys = [TAB];

		DiscordClient.prepare();

		// shader coords fix
		FlxG.signals.gameResized.add(function (w, h) {
		     if (FlxG.cameras != null) {
			   for (cam in FlxG.cameras.list) {
				if (cam?.filters != null)
					resetSpriteCache(cam.flashSprite);
			   }
			}

			if (FlxG.game != null)
			resetSpriteCache(FlxG.game);
		});

		#if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		ClientPrefs.loadPrefs();
		//Language.reloadPhrases(); // commented cuz it already does that in Paths.clearStoredMemory()
		GPUStats.init();

		reloadInitScripts();

		super.create();
		
		MusicBeatState.switchState(new states.TitleState());
	}

	// yeah thats it lol
	public static function reloadInitScripts()
	{
		for (script in initScripts)
		{
			script.executeFunction("destroy");
			script.destroy();
			initScripts.remove(script);
		}
		for (file in Paths.directoriesWithFile("init.hx"))
		{
			var script = new HScript(null, file);
			initScripts.push(script);
		}
	}

	static function resetSpriteCache(sprite:openfl.display.Sprite):Void {
		@:privateAccess {
		        sprite.__cacheBitmap = null;
			sprite.__cacheBitmapData = null;
		}
	}
}
