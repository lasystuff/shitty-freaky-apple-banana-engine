package backend;

import flixel.util.FlxSave;
import flixel.input.keyboard.FlxKey;
import flixel.input.gamepad.FlxGamepadInputID;

import states.TitleState;
import states.StoryMenuState;

// Add a variable here and it will get automatically saved
@:structInit @:publicFields class SaveVariables {
	// note colors

	/** Note colors for not-pixel stages */
	var arrowRGB:Array<Array<FlxColor>> = [
		[0xFFC24B99, 0xFFFFFFFF, 0xFF3C1F56],
		[0xFF00FFFF, 0xFFFFFFFF, 0xFF1542B7],
		[0xFF12FA05, 0xFFFFFFFF, 0xFF0A4447],
		[0xFFF9393F, 0xFFFFFFFF, 0xFF651038]];
	/** Note colors for pixel stages */
	var arrowRGBPixel:Array<Array<FlxColor>> = [
		[0xFFE276FF, 0xFFFFF9FF, 0xFF60008D],
		[0xFF3DCAFF, 0xFFF4FFFF, 0xFF003060],
		[0xFF71E300, 0xFFF6FFE6, 0xFF003100],
		[0xFFFF884E, 0xFFFFFAF5, 0xFF6C0000]];

	// adjust delay and combo
	/** Note offset of song, can be usable when you have bluetooth headphones */
	var noteOffset:Int = 0;
	/** Combo offsets: [ratingX, ratingY, comboX, comboY] */
	var comboOffset:Array<Int> = [0, 0, 0, 0];


	// graphics

	/** If `true`, disables some background details */
	var lowQuality:Bool = false;
	/** Is anti-aliasing allowed? */
	var antialiasing:Bool = true;
	/** Is shaders allowed? */
	var shaders:Bool = true;
	/** If checked, textures will be cached on GPU.\nIf GPU is 75% or more full, RAM caching will be used */
	var cacheOnGPU:Bool = #if !switch false #else true #end; //From Stilic
	/** Draw/update fps cap of game */
	var framerate:Int = 60;


	// visuals and ui

	/** Current note skin */
	var noteSkin:String = 'Default';
	/** Current note splash skin */
	var splashSkin:String = 'Psych';
	/** Alpha of note splash texture */
	var splashAlpha:Float = 0.6;
	/** If `true`, hides most HUD elements */
	var hideHud:Bool = false;
	/** Current time bar type */
	var timeBarType:String = 'Time Left';
	/** Current design of menus */
	var logoState:String = 'revisited';
	/** If `false`, hides most of flashing lights */
	var flashing:Bool = true;
	/** If `false`, camera won't zoom in on a beat hit */
	var camZooms:Bool = true;
	/** If `false`, score text won't zoom on a note hit */
	var scoreZoom:Bool = true;
	/** Alpha of health bar */
	var healthBarAlpha:Float = 1;
	/** If `false`, hides fps from counter */
	var showFPS:Bool = true;
	/** If `false`, hides memory from counter */
	var memoryCounter:Bool = true;
	/** Current pause music */
	var pauseMusic:String = 'Tea Time';
	/** If `false`, hides Discord Rich Presence */
	var discordRPC:Bool = true;
	/** If `false`, ratings and combo won't stack */
	var comboStacking:Bool = true;
	/** Transition type */
	var transType:String = BaseTransition.transitions[0];


	// gameplay

	/** If `true`, notes go Down instead of Up */
	var downScroll:Bool = false;
	/** If `true`, notes get centered */
	var middleScroll:Bool = false;
	/** If `false`, opponent notes get hidden */
	var opponentStrums:Bool = true;
	/** If `true`, you won't get misses from pressing keys while there are no notes able to be hit */
	var ghostTapping:Bool = true;
	/** If `true`, game pauses if screen isn't on focus */
	var autoPause:Bool = true;
	/** If `true`, disables reset button */
	var noReset:Bool = false;
	/** Volume of hitsounds */
	var hitsoundVolume:Float = 0;
	/** How late/early you have to hit for a "Sick!" */
	var ratingOffset:Int = 0;
	/** Amount of time you have for hitting a "Sick!" in ms */
	var sickWindow:Int = 45;
	/** Amount of time you have for hitting a "Good" in ms */
	var goodWindow:Int = 90;
	/** Amount of time you have for hitting a "Bad" in ms */
	var badWindow:Int = 135;
	/** Amount of frames you have for hitting a note */
	var safeFrames:Float = 10;
	/** If `true`, Hold Notes can't be pressed if you miss, and count as a single Hit/Miss */
	var guitarHeroSustains:Bool = true;
	/** Current choosed language */
	var language:String = 'en-US';


	// other

	/** Gameplay settings, for example `scrollspeed`. Can be accessed with `ClientPrefs.gameplaySettings` too! */
	var gameplaySettings:GameplaySettings = {};
	/** Key bindings, can be accessed `ClientPrefs.keyBinds` too! */
	var keyBinds(get, never):Map<String, Array<FlxKey>>;
	/** Gamepad bindings, can be accessed `ClientPrefs.gamepadBinds` too! */
	var gamepadBinds(get, never):Map<String, Array<FlxGamepadInputID>>;

	@:noCompletion function get_keyBinds() return ClientPrefs.keyBinds;
	@:noCompletion function get_gamepadBinds() return ClientPrefs.gamepadBinds;
}
@:structInit @:publicFields class GameplaySettings {
	/** Current speed of notes */
	var scrollspeed:Float = 1.0;
	/** Current type of note speed */
	var scrolltype:String = 'multiplicative';
	/** Current playback rate of song, multiplier */
	var songspeed:Float = 1.0;
	/** Uses for calculating health gain on note hit, multiplier */
	var healthgain:Float = 1.0;
	/** Uses for calculating health loss on note miss, multiplier */
	var healthloss:Float = 1.0;
	/** If `true`, note miss insta-kills you */
	var instakill:Bool = false;
	/** If `true`, enables practice mode */
	var practice:Bool = false;
	/** If `true`, game will hit notes automatically */
	var botplay:Bool = false;
	/** Does nothing in our mod as in psych lol */
	var opponentplay:Bool = false;

	@:noCompletion private var fields(default, never):Array<String> = [];

	function new() {
		for (f in Reflect.fields(this))
			if (f != 'fields' && !Reflect.isFunction(Reflect.getProperty(this, f)))
				fields.push(f);
	}

	function set(key:String, value:Dynamic) {
		if (!fields.contains(key)) return;
		Reflect.setProperty(this, key, value);
	}

	function get(key:String):Dynamic {
		if (!fields.contains(key)) return null;
		return Reflect.getProperty(this, key);
	}

	function exists(key:String):Bool
		return fields.contains(key);

	function toMap():Map<String, Dynamic> {
		var map:Map<String, Dynamic> = [];
		for (f in fields) map.set(f, Reflect.getProperty(this, f));
		return map;
	}

	function fromMap(map:Map<String, Dynamic>) {
		if (map != null) for (k => v in map) if (v != null) set(k, v);
	}
}

class ClientPrefs {
	/** Client preferences, can be accessed in states with `prefs` */
	public static var data:SaveVariables;
	public static var defaultData:SaveVariables;
	public static var gameplaySettings(get, never):GameplaySettings;

	//Every key has two binds, add your key bind down here and then add your control on options/ControlsSubState.hx and Controls.hx
	public static var keyBinds:Map<String, Array<FlxKey>> = [
		//Key Bind, Name for ControlsSubState
		'note_up'		=> [W, UP],
		'note_left'		=> [A, LEFT],
		'note_down'		=> [S, DOWN],
		'note_right'	=> [D, RIGHT],
		
		'ui_up'			=> [W, UP],
		'ui_left'		=> [A, LEFT],
		'ui_down'		=> [S, DOWN],
		'ui_right'		=> [D, RIGHT],
		
		'accept'		=> [SPACE, ENTER],
		'back'			=> [BACKSPACE, ESCAPE],
		'pause'			=> [ENTER, ESCAPE],
		'reset'			=> [R],
		
		'volume_mute'	=> [ZERO],
		'volume_up'		=> [NUMPADPLUS, PLUS],
		'volume_down'	=> [NUMPADMINUS, MINUS],
		
		'debug_1'		=> [SEVEN],
		'debug_2'		=> [EIGHT]
	];
	public static var gamepadBinds:Map<String, Array<FlxGamepadInputID>> = [
		'note_up'		=> [DPAD_UP, Y],
		'note_left'		=> [DPAD_LEFT, X],
		'note_down'		=> [DPAD_DOWN, A],
		'note_right'	=> [DPAD_RIGHT, B],
		
		'ui_up'			=> [DPAD_UP, LEFT_STICK_DIGITAL_UP],
		'ui_left'		=> [DPAD_LEFT, LEFT_STICK_DIGITAL_LEFT],
		'ui_down'		=> [DPAD_DOWN, LEFT_STICK_DIGITAL_DOWN],
		'ui_right'		=> [DPAD_RIGHT, LEFT_STICK_DIGITAL_RIGHT],
		
		'accept'		=> [A, START],
		'back'			=> [B],
		'pause'			=> [START],
		'reset'			=> [BACK]
	];
	public static var defaultKeys:Map<String, Array<FlxKey>> = null;
	public static var defaultButtons:Map<String, Array<FlxGamepadInputID>> = null;

	public static function resetKeys(controller:Null<Bool> = null) //Null = both, False = Keyboard, True = Controller
	{
		if(controller != true)
			for (key in keyBinds.keys())
				if(defaultKeys.exists(key))
					keyBinds.set(key, defaultKeys.get(key).copy());

		if(controller != false)
			for (button in gamepadBinds.keys())
				if(defaultButtons.exists(button))
					gamepadBinds.set(button, defaultButtons.get(button).copy());
	}

	public static function clearInvalidKeys(key:String)
	{
		var keyBind:Array<FlxKey> = keyBinds.get(key);
		var gamepadBind:Array<FlxGamepadInputID> = gamepadBinds.get(key);
		while(keyBind != null && keyBind.contains(NONE)) keyBind.remove(NONE);
		while(gamepadBind != null && gamepadBind.contains(NONE)) gamepadBind.remove(NONE);
	}

	public static function loadDefaultKeys() {
		data = {};
		defaultData = {};

		defaultKeys = keyBinds.copy();
		defaultButtons = gamepadBinds.copy();
	}

	public static function saveSettings() {
		var no = ['gameplaySettings', 'keyBinds', 'gamepadBinds'];
		for (key in Reflect.fields(data)) if (!no.contains(key))
			Reflect.setField(FlxG.save.data, key, Reflect.field(data, key));

		FlxG.save.data.gameplaySettings = gameplaySettings.toMap();

		#if ACHIEVEMENTS_ALLOWED Achievements.save(); #end
		FlxG.save.flush();

		//Placing this in a separate save so that it can be manually deleted without removing your Score and stuff
		var save:FlxSave = new FlxSave();
		save.bind('controls_v3', CoolUtil.getSavePath());
		save.data.keyboard = keyBinds;
		save.data.gamepad = gamepadBinds;
		save.flush();
		FlxG.log.add("Settings saved!");
	}

	public static var initialized:Bool = false;
	public static function loadPrefs() {
		if (initialized) return;

		FlxG.save.bind('funkin', CoolUtil.getSavePath());
		#if ACHIEVEMENTS_ALLOWED Achievements.load(); #end

		var no = ['gameplaySettings', 'keyBinds', 'gamepadBinds'];
		for (key in Reflect.fields(data)) if (!no.contains(key) && Reflect.hasField(FlxG.save.data, key))
			Reflect.setField(data, key, Reflect.field(FlxG.save.data, key));

		gameplaySettings.fromMap(FlxG.save.data.gameplaySettings);

		if(FlxG.save.data.fullscreen != null)
			FlxG.fullscreen = FlxG.save.data.fullscreen;
		Main.onFullscreenChange.add(() -> {
			FlxG.save.data.fullscreen = FlxG.fullscreen;
		});

		#if (!html5 && !switch)
		FlxG.autoPause = data.autoPause;

		if(FlxG.save.data.framerate == null)
			data.framerate = FlxG.stage.application.window.displayMode.refreshRate;
		#end

		if(data.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = data.framerate;
			FlxG.drawFramerate = data.framerate;
		}
		else
		{
			FlxG.drawFramerate = data.framerate;
			FlxG.updateFramerate = data.framerate;
		}

		if (FlxG.save.data.weekCompleted != null)
			StoryMenuState.weekCompleted = FlxG.save.data.weekCompleted;

		// flixel automatically saves your volume!
		if(FlxG.save.data.volume != null)
			FlxG.sound.volume = FlxG.save.data.volume;
		if (FlxG.save.data.mute != null)
			FlxG.sound.muted = FlxG.save.data.mute;

		FlxSprite.defaultAntialiasing = FlxG.save.data.antialiasing;

		DiscordClient.check();

		// controls on a separate save file
		var save:FlxSave = new FlxSave();
		save.bind('controls_v3', CoolUtil.getSavePath());
		if(save != null)
		{
			if(save.data.keyboard != null)
			{
				var loadedControls:Map<String, Array<FlxKey>> = save.data.keyboard;
				for (control => keys in loadedControls)
					if(keyBinds.exists(control)) keyBinds.set(control, keys);
			}
			if(save.data.gamepad != null)
			{
				var loadedControls:Map<String, Array<FlxGamepadInputID>> = save.data.gamepad;
				for (control => keys in loadedControls)
					if(gamepadBinds.exists(control)) gamepadBinds.set(control, keys);
			}
			reloadVolumeKeys();
		}
	}

	inline public static function getGameplaySetting(name:String, ?uselessArg1:Dynamic = null, ?uselessArg2:Bool = false):Dynamic
		return gameplaySettings.get(name);

	public static function reloadVolumeKeys()
	{
		TitleState.muteKeys = keyBinds.get('volume_mute').copy();
		TitleState.volumeDownKeys = keyBinds.get('volume_down').copy();
		TitleState.volumeUpKeys = keyBinds.get('volume_up').copy();
		toggleVolumeKeys(true);
	}
	public static function toggleVolumeKeys(?turnOn:Bool = true)
	{
		FlxG.sound.muteKeys = turnOn ? TitleState.muteKeys : [];
		FlxG.sound.volumeDownKeys = turnOn ? TitleState.volumeDownKeys : [];
		FlxG.sound.volumeUpKeys = turnOn ? TitleState.volumeUpKeys : [];
	}

	@:noCompletion static function get_gameplaySettings():GameplaySettings return data.gameplaySettings;
}