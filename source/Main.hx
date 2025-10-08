package;

import openfl.Lib;
import openfl.events.Event;
import openfl.display.Sprite;
import openfl.display.StageScaleMode;

import flixel.FlxGame;

import backend.AudioUtil;
import backend.Highscore;
import debug.GPUStats;
import debug.FPSCounter;

//crash handler stuff
#if CRASH_HANDLER
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import haxe.CallStack;
import openfl.events.UncaughtErrorEvent;
#end

#if windows
import backend.native.Windows;
#end

#if linux
import lime.graphics.Image;

@:cppInclude('./external/gamemode_client.h')
@:cppFileCode('
	#define GAMEMODE_AUTO
')
#end

enum TitleWindowColorMode {
	/** lerps from red to default colors */
	RED_GLOW;

	RAINBOW;

	DEFAULT;

	/** with this title window will not be changed by game so u can change it by yourself in hscript or lua */
	DISABLED;
}

@:build(macros.Defines.add())
class Main extends Sprite
{
	public var game = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		initialState: Init, // initial game state
		zoom: -1.0, // game state bounds
		framerate: 60, // default framerate
		skipSplash: true, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};

	public static var fpsVar:FPSCounter;
	public static var instance:Main;

	/** If dark mode is allowed on this system, works on Windows target only */
	public static var isDarkMode(default, null):Bool = false;
	/** Color mode of title window, works on Windows target only */
	public static var titleWindowColorMode:TitleWindowColorMode = DEFAULT;

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	/** Sets framerate of game and updates fps graph of flixel debugger */
	public static function setFramerate(value:Int) {
		if(value > FlxG.drawFramerate)
			FlxG.updateFramerate = FlxG.drawFramerate = value;
		else
			FlxG.drawFramerate = FlxG.updateFramerate = value;
		#if debug
		@:privateAccess FlxG.game.debugger.stats.fpsGraph.maxValue = value; // we need to update this cuz flixel doesnt do that lol
		#end
	}

	public function new()
	{
		super();
		instance = this;

		// Credits to MAJigsaw77 (he's the og author for this code)
		#if ios
		Sys.setCwd(lime.system.System.applicationStorageDirectory);
		#end

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	static function startOfTrace(fileName:String, lineNumber:Int) {
		// so its like:    [03:17:48] [debug/GPUStats:75] Traced string yeah
		// and colors are:    blue           cyan            basic (white)
		var time = ('[' + DateTools.format(Date.now(), '%H:%M:%S') + ']').toCMD(BLUE);
		var path = ('[' + (fileName.substring(fileName.startsWith('source/') ? (fileName.indexOf('/') + 1) : 0, fileName.length - 3)) + ':' + lineNumber + ']').toCMD(CYAN);

		return '$time $path ';
	}

	public static function println(str:Dynamic) {
		#if js
		if (js.Syntax.typeof(untyped console) != "undefined" && (untyped console).log != null)
			(untyped console).log(str);
		#elseif lua
		untyped __define_feature__("use._hx_print", _hx_print(str));
		#elseif sys
		Sys.println(str);
		#else
		throw new haxe.exceptions.NotImplementedException()
		#end
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (game.zoom == -1.0)
		{
			var ratioX:Float = stageWidth / game.width;
			var ratioY:Float = stageHeight / game.height;
			game.zoom = Math.min(ratioX, ratioY);
			game.width = Math.ceil(stageWidth / game.zoom);
			game.height = Math.ceil(stageHeight / game.zoom);
		}

		// cuz idk if it will work on other platforms
		// cool improving of trace() thing! - TheLeerName
		// useful batch btw!
		haxe.Log.trace = (v:Dynamic, ?infos:haxe.PosInfos) -> {
			var v:String = v;
			if (infos.customParams?.length > 0) v += ' ' + infos.customParams.join(' ');
			println(startOfTrace(infos.fileName, infos.lineNumber) + v);
			// i got a funny bug! (it fixed, i just wanted to write about it here)
			// infos.fileName returns source/backend/Discord.hx, but 2nd arg of FilePos in StackItem returns backend/Discord.hx
			// so Paths.callStackTrace displays states/TitleState.hx, and trace displays states/TitleState
			// haha!
		}

		addChild(new FlxGame(game.width, game.height, game.initialState, game.framerate, game.framerate, game.skipSplash, game.startFullscreen));

		#if !mobile
		fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
		addChild(fpsVar);
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
		#end

		#if CRASH_HANDLER
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);
		#end
	}

	// Code was entirely made by sqirra-rng for their fnf engine named "Izzy Engine", big props to them!!!
	// very cool person for real they don't get enough credit for their work
	#if CRASH_HANDLER
	function onCrash(e:UncaughtErrorEvent):Void
	{
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		dateNow = dateNow.replace(" ", "_");
		dateNow = dateNow.replace(":", "'");

		path = "./crash/" + FlxG.stage.window.application.meta.get('file') + "_" + dateNow + ".txt";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += file + " (line " + line + ")\n";
				default:
					println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error;
		/*
		 * remove if you're modding and want the crash log message to contain the link
		 * please remember to actually modify the link for the github page to report the issues to.
		*/
		// ok maybe later - Leer
		#if officialBuild
		errMsg += "\nPlease report this error to the GitHub page: https://github.com/ShadowMario/FNF-PsychEngine\n\n> Crash Handler written by: sqirra-rng";
		#end

		if (!FileSystem.exists("./crash/"))
			FileSystem.createDirectory("./crash/");

		Paths.saveFile(path, errMsg + "\n");

		println(errMsg);
		println("Crash dump saved in " + Path.normalize(path));

		FlxG.stage.window.alert(errMsg, "Error!");
		DiscordClient.shutdown();
		Sys.exit(1);
	}
	#end
}
