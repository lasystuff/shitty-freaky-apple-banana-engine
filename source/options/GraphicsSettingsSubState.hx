package options;

import objects.Character;

class GraphicsSettingsSubState extends BaseOptionsMenu
{
	var antialiasingOption:Int;
	var boyfriend:Character = null;
	public function new()
	{
		title = Language.getPhrase('graphics_menu', 'Graphics Settings');
		rpcTitle = 'In the Graphics Settings Menu'; //for Discord Rich Presence

		boyfriend = new Character(840, 170, 'bf', true);
		boyfriend.setGraphicSize(Std.int(boyfriend.width * 0.75));
		boyfriend.updateHitbox();
		boyfriend.dance();
		boyfriend.animation.finishCallback = function (name:String) boyfriend.dance();
		boyfriend.visible = false;

		//I'd suggest using "Low Quality" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Low Quality', //Name
			'If checked, disables some background details,\ndecreases loading times and improves performance.', //Description
			'lowQuality', //Save data variable name
			BOOL); //Variable type
		addOption(option);

		var option:Option = new Option('Anti-Aliasing',
			'If unchecked, disables anti-aliasing, increases performance\nat the cost of sharper visuals.',
			'antialiasing',
			BOOL);
		option.onChange = onChangeAntiAliasing; //Changing onChange is only needed if you want to make a special interaction after it changes the value
		addOption(option);
		antialiasingOption = optionsArray.length-1;

		var option:Option = new Option('Loading Screen',
			"If unchecked, will disable all loading screens.",
			'loadingScreen',
			BOOL);
		//option.onChange = () -> OptionsState.reloadAssetsOnQuit = true;
		addOption(option);

		var option:Option = new Option('Cache Menu Assets',
			"If unchecked, will skip caching all menu assets,\ndoing nothing if loading screens are disabled.",
			'cacheMenuAssets',
			BOOL);
		//option.onChange = () -> OptionsState.reloadAssetsOnQuit = true;
		addOption(option);

		var option:Option = new Option('Shaders', //Name
			"If unchecked, disables shaders.\nIt's used for some visual effects, and also CPU intensive for weaker PCs.", //Description
			'shaders',
			BOOL);
		addOption(option);

		var option:Option = new Option('GPU Caching', //Name
			#if windows "If checked, textures will be cached on GPU.\nIf GPU is 75% or more full, RAM caching will be used" #else "If checked, textures will be cached on GPU." #end, //Description
			'cacheOnGPU',
			BOOL);
		option.onChange = onChangeGPUCaching;
		addOption(option);

		#if !html5 //Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		var option:Option = new Option('Framerate',
			"Pretty self explanatory, isn't it?",
			'framerate',
			INT);
		addOption(option);

		final refreshRate:Int = FlxG.stage.application.window.displayMode.refreshRate;
		option.changeValue = 5;
		option.minValue = 30;
		option.maxValue = 1000;
		option.defaultValue = Std.int(FlxMath.bound(refreshRate, option.minValue, option.maxValue));
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;
		#end

		super();
		insert(1, boyfriend);
	}

	function onChangeGPUCaching() {
		Main.fpsVar.resetTextFormat();
		//OptionsState.reloadAssetsOnQuit = true;
	}

	function onChangeAntiAliasing() {
		CoolUtil.changeVarLooped(FlxG.state.members.concat(FlxG.state.subState?.members), 'antialiasing', prefs.antialiasing);
		FlxSprite.defaultAntialiasing = prefs.antialiasing;
	}

	function onChangeFramerate()
		Main.setFramerate(prefs.framerate);

	override function changeSelection(change:Int = 0)
	{
		super.changeSelection(change);
		boyfriend.visible = (antialiasingOption == curSelected);
	}
}