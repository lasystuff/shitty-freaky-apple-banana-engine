package states;

import backend.WeekData;

import flixel.input.keyboard.FlxKey;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.graphics.frames.FlxFrame;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;

import openfl.display.Bitmap;
import openfl.display.BitmapData;

import debug.GPUStats;
import shaders.ColorSwap;

import states.MainMenuState;

typedef TitleData =
{
	var titlex:Float;
	var titley:Float;
	var startx:Float;
	var starty:Float;
	var gfx:Float;
	var gfy:Float;
	var backgroundSprite:String;
	var bpm:Float;
	
	@:optional var animation:String;
	@:optional var dance_left:Array<Int>;
	@:optional var dance_right:Array<Int>;
	@:optional var idle:Bool;
}

class TitleState extends MusicBeatState
{
	public static var muteKeys:Array<FlxKey> = [FlxKey.ZERO];
	public static var volumeDownKeys:Array<FlxKey> = [FlxKey.NUMPADMINUS, FlxKey.MINUS];
	public static var volumeUpKeys:Array<FlxKey> = [FlxKey.NUMPADPLUS, FlxKey.PLUS];

	public static var initialized:Bool = false;

	var credGroup:FlxGroup = new FlxGroup();
	var textGroup:FlxGroup = new FlxGroup();
	var blackScreen:FlxSprite;
	var credTextShit:Alphabet;
	var ngSpr:FlxSprite;

	var titleTextColors:Array<FlxColor> = [0xFF33FFFF, 0xFF3333CC];
	var titleTextAlphas:Array<Float> = [1, .64];

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	public static function initialize() {
		if (initialized) return;

		#if LUA_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		ClientPrefs.loadPrefs();
		//Language.reloadPhrases(); // commented cuz it already does that in Paths.clearStoredMemory()
		GPUStats.init();

		initialized = true;
	}

	override public function create():Void
	{
		Paths.clearStoredMemory();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		super.create();

		initialize();
		DiscordClient.changePresence("In the Title Menu");

		FlxG.mouse.visible = false;
		#if FREEPLAY
		MusicBeatState.switchState(new FreeplayState());
		#elseif CHARTING
		MusicBeatState.switchState(new ChartingState());
		#else
		// needs rework
		// bugs with transitions
		/*if(FlxG.save.data.flashing == null && !FlashingState.leftState) {
			skipNextTransIn = true;
			skipNextTransOut = true;
			MusicBeatState.switchState(new FlashingState());
		} else {*/
			startIntro();
		//}
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var swagShader:ColorSwap = null;

	function startIntro()
	{
		persistentUpdate = true;
		if (!(FlxG.sound.music?.playing))
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);

		loadJsonData();
		#if TITLE_SCREEN_EASTER_EGG easterEggData(); #end
		Conductor.bpm = musicBPM;

		logoBl = new FlxSprite(logoPosition.x, logoPosition.y);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = ClientPrefs.data.antialiasing;

		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();

		gfDance = new FlxSprite(gfPosition.x, gfPosition.y);
		gfDance.antialiasing = ClientPrefs.data.antialiasing;
		
		if(ClientPrefs.data.shaders)
		{
			swagShader = new ColorSwap();
			gfDance.shader = swagShader.shader;
			logoBl.shader = swagShader.shader;
		}
		
		gfDance.frames = Paths.getSparrowAtlas(characterImage);
		if(!useIdle)
		{
			gfDance.animation.addByIndices('danceLeft', animationName, danceLeftFrames, "", 24, false);
			gfDance.animation.addByIndices('danceRight', animationName, danceRightFrames, "", 24, false);
			gfDance.animation.play('danceRight');
		}
		else
		{
			gfDance.animation.addByPrefix('idle', animationName, 24, false);
			gfDance.animation.play('idle');
		}


		var animFrames:Array<FlxFrame> = [];
		titleText = new FlxSprite(enterPosition.x, enterPosition.y);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		@:privateAccess
		{
			titleText.animation.findByPrefix(animFrames, "ENTER IDLE");
			titleText.animation.findByPrefix(animFrames, "ENTER FREEZE");
		}
		
		if (newTitle = animFrames.length > 0)
		{
			titleText.animation.addByPrefix('idle', "ENTER IDLE", 24);
			titleText.animation.addByPrefix('press', ClientPrefs.data.flashing ? "ENTER PRESSED" : "ENTER FREEZE", 24);
		}
		else
		{
			titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
			titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		}
		titleText.animation.play('idle');
		titleText.updateHitbox();

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.antialiasing = ClientPrefs.data.antialiasing;
		logo.screenCenter();

		blackScreen = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		blackScreen.scale.set(FlxG.width, FlxG.height);
		blackScreen.updateHitbox();
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "", true);
		credTextShit.screenCenter();
		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = ClientPrefs.data.antialiasing;

		add(gfDance);
		add(logoBl); //FNF Logo
		add(titleText); //"Press Enter to Begin" text
		add(credGroup);
		add(ngSpr);

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	// JSON data
	var characterImage:String = 'gfDanceTitle';
	var animationName:String = 'gfDance';
	var gfPosition:FlxPoint = FlxPoint.get(512, 40);
	var logoPosition:FlxPoint = FlxPoint.get(-150, -100);
	var enterPosition:FlxPoint = FlxPoint.get(100, 576);
	
	var useIdle:Bool = false;
	var musicBPM:Float = 102;
	var danceLeftFrames:Array<Int> = [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29];
	var danceRightFrames:Array<Int> = [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14];
	function loadJsonData()
	{
		var json = Paths.loadJsonFromFile(Paths.path('images/gfDanceTitle.json'), '"images/gfDanceTitle.json"');
		if (json == null) return;
		var json:TitleData = cast json;

		gfPosition.set(json.gfx, json.gfy);
		logoPosition.set(json.titlex, json.titley);
		enterPosition.set(json.startx, json.starty);
		musicBPM = json.bpm;

		if(json.animation != null && json.animation.length > 0) animationName = json.animation;
		if(json.dance_left != null && json.dance_left.length > 0) danceLeftFrames = json.dance_left;
		if(json.dance_right != null && json.dance_right.length > 0) danceRightFrames = json.dance_right;
		useIdle = (json.idle == true);

		if (json.backgroundSprite != null && json.backgroundSprite.trim().length > 0)
		{
			var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image(json.backgroundSprite));
			bg.antialiasing = ClientPrefs.data.antialiasing;
			add(bg);
		}
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var firstArray:Array<String> = Paths.mergeAllTextsNamed('data/introText.txt');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
			swagGoodArray.push(i.split('--'));

		return swagGoodArray;
	}

	var transitioning:Bool = false;
	private static var playJingle:Bool = false;
	
	var newTitle:Bool = false;
	var titleTimer:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		var pressedEnter:Bool = FlxG.keys.justPressed.ENTER || controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null)
		{
			if (gamepad.justPressed.START)
				pressedEnter = true;

			#if switch
			if (gamepad.justPressed.B)
				pressedEnter = true;
			#end
		}
		
		if (newTitle) {
			titleTimer += FlxMath.bound(elapsed, 0, 1);
			if (titleTimer > 2) titleTimer -= 2;
		}

		// EASTER EGG

		if (initialized && !transitioning && skippedIntro)
		{
			if (newTitle && !pressedEnter)
			{
				var timer:Float = titleTimer;
				if (timer >= 1)
					timer = (-timer) + 2;
				
				timer = FlxEase.quadInOut(timer);
				
				titleText.color = FlxColor.interpolate(titleTextColors[0], titleTextColors[1], timer);
				titleText.alpha = FlxMath.lerp(titleTextAlphas[0], titleTextAlphas[1], timer);
			}
			
			if(pressedEnter)
			{
				titleText.color = FlxColor.WHITE;
				titleText.alpha = 1;
				
				if(titleText != null) titleText.animation.play('press');

				FlxG.camera.flash(prefs.flashing ? FlxColor.WHITE : 0x4CFFFFFF, 1);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;
				// FlxG.sound.music.stop();

				new FlxTimer().start(1, function(tmr:FlxTimer)
				{
					MusicBeatState.switchState(new MainMenuState());
					closedState = true;
				});
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}
		}

		if (initialized && pressedEnter && !skippedIntro)
		{
			skipIntro();
		}

		if(swagShader != null)
		{
			if(controls.UI_LEFT) swagShader.hue -= elapsed * 0.1;
			if(controls.UI_RIGHT) swagShader.hue += elapsed * 0.1;
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, ?offset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true);
			money.screenCenter(X);
			money.y += (i * 60) + 200 + offset;
			if(credGroup != null && textGroup != null) {
				credGroup.add(money);
				textGroup.add(money);
			}
		}
	}

	function addMoreText(text:String, ?offset:Float = 0)
	{
		if(textGroup != null && credGroup != null) {
			var coolText:Alphabet = new Alphabet(0, 0, text, true);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200 + offset;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	private var sickBeats:Int = 0; //Basically curBeat but won't be skipped if you hold the tab or resize the screen
	public static var closedState:Bool = false;
	override function beatHit()
	{
		super.beatHit();

		if(logoBl != null)
			logoBl.animation.play('bump', true);

		if(gfDance != null) {
			danceLeft = !danceLeft;
			if(!useIdle) {
				if (danceLeft)
					gfDance.animation.play('danceRight');
				else
					gfDance.animation.play('danceLeft');
			}
			else if(curBeat % 2 == 0) gfDance.animation.play('idle', true);
		}

		if(!closedState) {
			sickBeats++;
			switch (sickBeats)
			{
				case 1:
					//FlxG.sound.music.stop();
					FlxG.sound.playMusic(Paths.music(Paths.getMenuMusic('TitleMenu')), 0);
					FlxG.sound.music.fadeIn(4, 0, 0.7);
				case 2:
					#if PSYCH_WATERMARKS
					createCoolText(['Psych Engine by'], 40);
					#else
					createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
					#end
				case 4:
					#if PSYCH_WATERMARKS
					addMoreText('Shadow Mario', 40);
					addMoreText('Riveren', 40);
					#else
					addMoreText('present');
					#end
				case 5:
					deleteCoolText();
				case 6:
					#if PSYCH_WATERMARKS
					createCoolText(['Not associated', 'with'], -40);
					#else
					createCoolText(['In association', 'with'], -40);
					#end
				case 8:
					addMoreText('newgrounds', -40);
					ngSpr.visible = true;
				case 9:
					deleteCoolText();
					ngSpr.visible = false;
				case 10:
					createCoolText([curWacky[0]]);
				case 12:
					addMoreText(curWacky[1]);
				case 13:
					deleteCoolText();
				case 14:
					addMoreText('Friday');
				case 15:
					addMoreText('Night');
				case 16:
					addMoreText('Funkin'); // credTextShit.text += '\nFunkin';

				case 17:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;
	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);
			remove(credGroup);
			FlxG.camera.flash(FlxColor.WHITE, 4);
			skippedIntro = true;
		}
	}
}
