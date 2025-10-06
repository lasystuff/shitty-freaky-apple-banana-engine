package debug;

import openfl.system.System;
import openfl.text.TextField;
import openfl.text.TextFormat;

import flixel.FlxG;
import flixel.util.FlxStringUtil;

import states.MainMenuState;

/**
	The FPS class provides an easy-to-use monitor to display
	the current frame rate of an OpenFL project
**/
class FPSCounter extends TextField
{
	/**
		The current frame rate, expressed using frames-per-second
	**/
	public var currentFPS(default, null):Float;

	/**
		The current RAM usage (WARNING: this is NOT your total program memory usage, rather it shows the garbage collector memory)
	**/
	public var memoryMegas(get, never):Float;

	/**
	 * Format of fps counter text
	 * 
	 * WARNING: Resets to default on calling `resetTextFormat()`
	 */
	public var textFormat:String;

	public var lowFPSColor:FlxColor = FlxColor.RED;
	public var normalColor:FlxColor = FlxColor.WHITE;

	var prefs:SaveVariables = ClientPrefs.data;

	var displayFPS:String = "0.3 fps";
	var _updateTimer:Float = 0;
	#if !debug
	var _frameCount:Int = 0;
	var _itvTime:Int = FlxG.game.ticks;
	#end

	var UPDATE_DELAY:Int = 500;

	public function new(x:Float = 10, y:Float = 10, color:Int = 0x000000)
	{
		super();

		this.x = x;
		this.y = y;

		currentFPS = 0;
		selectable = false;
		mouseEnabled = false;
		defaultTextFormat = new TextFormat("_sans", 14, color);
		autoSize = LEFT;
		multiline = true;
		text = "";

		#if debug
		var debruh = FlxG.debugger;
		debruh.visibilityChanged.add(() -> this.y = debruh.visible ? 20 : y);
		#end

		resetTextFormat();
	}

	/** Usually used before `MusicBeatState.switchState` or in start of `create()` */
	public function tweenToColor(color:FlxColor, ?withDelay:Bool) {
		if (normalColor == color) return;
		var dur:Float = BaseTransition.DURATION;

		function lol(?idk)
			CoolUtil.tweenColor(this, {normalColor: color}, dur);

		if (withDelay) FlxG.signals.preStateCreate.addOnce(lol);
		else lol();
	}

	@:noCompletion var pressedF3(default, set):Bool = false;
	public var wasPressedF3:Bool = false;
	@:noCompletion inline function set_pressedF3(pressedF3:Bool):Bool {
		if (pressedF3) {
			FlxG.save.data.wasPressedF3 = wasPressedF3 = true;
			FlxG.save.flush();
		}
		this.pressedF3 = pressedF3;
		resetTextFormat();
		return pressedF3;
	}

	// Event Handlers
	private override function __enterFrame(deltaTime:Float):Void
	{
		if (FlxG.keys.justPressed.F3) pressedF3 = !pressedF3;

		#if !debug
		_frameCount++;
		#end
		_updateTimer += deltaTime;
		if (_updateTimer > UPDATE_DELAY) {
			#if !debug
			currentFPS = _frameCount / ((FlxG.game.ticks - _itvTime) / 1000);
			displayFPS = '$currentFPS';
			if (displayFPS.contains('.')) displayFPS = displayFPS.substring(0, displayFPS.indexOf('.'));

			_frameCount = 0;
			_itvTime = FlxG.game.ticks;
			#else
			@:privateAccess var txt = FlxG.game.debugger.stats.fpsGraph.curLabel.text;
			txt = txt.substring(0, txt.length - 4);
			displayFPS = txt;
			currentFPS = txt.toFloat();
			#end
			_updateTimer -= UPDATE_DELAY;
		}

		updateText();
	}

	var pressedF3Lines:Array<String> = [
		'%file% %modVer% (%psychVer%)',
		'%fps% fps T: %maxFPS% %quality% %antialiasing%',
		'RAM: %ram% GPU: %gpuUsgMem% %caching%',
		'GPU: %gpuUsg%% (%gpuUsgGlobal%%) %shaders%',
		'',
		'mouseXY: %mouseX% / %mouseY%',
		'',
		'haxe: %haxe%',
		'lime: %lime%',
		'openfl: %openfl%',
		'flixel: %flixel%',
		'flixel-addons: %flixel-addons%',
		#if tjson
		'tjson: %tjson%',
		#end
		#if LUA_ALLOWED
		'linc_luajit: %linc_luajit%',
		'%lua%',
		'%luajit%',
		#end
		#if HSCRIPT_ALLOWED
		'hscript-iris: %hscript-iris%',
		#end
		#if VIDEOS_ALLOWED
		'hxvlc: %hxvlc%',
		#end
		#if DISCORD_ALLOWED
		'hxdiscord_rpc: %hxdiscord_rpc%',
		#end
		#if flxanimate
		'flxanimate: %flxanimate%'
		#end
	];

	/**
	 * Resets `textFormat` variable to default.
	 * 
	 * Also calls `updateText()`
	 */
	public dynamic function resetTextFormat() {
		var lines:Array<String> = [];
		#if windows
		if (pressedF3)
			lines = lines.concat(pressedF3Lines);
		else {
			lines.push(states.MainMenuState.modVersion + (prefs.showFPS ? ' | FPS: %fps%' : ''));

			if (prefs.memoryCounter)
				lines.push('Mem: %ram% / %gpuUsgMem%');
			if (!wasPressedF3)
				lines.push('F3 to expand (press to close tip)');
		}
		#else
			if (prefs.showFPS) lines.push('FPS: %fps%');
			if (prefs.memoryCounter) lines.push('Memory: %ram%');
		#end

		textFormat = lines.join('\n');
		updateText();
	}

	public function replaceVars(text:String) {
		var d = Main.defines;
		var replaces = [
			'fps' => displayFPS,
			'ram' => FlxStringUtil.formatBytes(memoryMegas),
			#if windows
			'gpuUsgMem' => (GPUStats.errorMessage == null ? FlxStringUtil.formatBytes(GPUStats.memoryUsage) : 'Error!'),
			'file' => FlxG.stage.application.meta.get('file'),
			'modVer' => MainMenuState.modVersion,
			'psychVer' => '${MainMenuState.psychEngineVersion} (${MainMenuState.psychEngineLastCommit})',
			'maxFPS' => prefs.framerate + '',
			'quality' => (prefs.lowQuality ? 'low' : 'high') + 'Quality',
			'antialiasing' => (prefs.antialiasing ? 'a' : 'noA') + 'ntialiasing',
			'shaders' => (prefs.shaders ? 's' : 'noS') + 'haders',
			'caching' => (prefs.cacheOnGPU ? 'gpu' : 'ram') + 'Caching',
			'gpuUsg' => Std.int(GPUStats.usage) + '',
			'gpuUsgGlobal' => Std.int(GPUStats.globalUsage) + '',
			'mouseX' => FlxG.mouse.screenX + '',
			'mouseY' => FlxG.mouse.screenY + '',
			'haxe' => d.get('haxe'),
			'lime' => d.get('lime'),
			'openfl' => d.get('openfl'),
			'flixel' => d.get('flixel'),
			'flixel-addons' => d.get('flixel-addons'),
			#if tjson
			'tjson' => d.get('tjson'),
			#end
			#if LUA_ALLOWED
			'linc_luajit' => d.get('linc_luajit'),
			'lua' => llua.Lua.version(),
			'luajit' => llua.Lua.versionJIT(),
			#end
			#if HSCRIPT_ALLOWED
			'hscript-iris' => d.get('hscript'),
			#end
			#if VIDEOS_ALLOWED
			'hxvlc' => d.get('hxvlc'),
			#end
			#if DISCORD_ALLOWED
			'hxdiscord_rpc' => d.get('hxdiscord_rpc'),
			#end
			#if flxanimate
			'flxanimate' => d.get('flxanimate'),
			#end
			#end
		];

		var _text:String = text;
		for (f => r in replaces) _text = _text.replace('%$f%', r);
		return _text;
	}

	public function getTextColor():FlxColor
		return (currentFPS < FlxG.drawFramerate * 0.5 && !pressedF3) ? lowFPSColor : normalColor;

	public dynamic function updateText():Void { // so people can override it in hscript
		text = replaceVars(textFormat);
		textColor = getTextColor();
	}

	inline function get_memoryMegas():Float
		return cpp.vm.Gc.memInfo64(cpp.vm.Gc.MEM_INFO_USAGE);
}
