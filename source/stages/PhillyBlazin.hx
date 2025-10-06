package stages;

#if BASE_GAME_FILES
import shaders.RainShader;

import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.display.FlxTiledSprite;

import objects.Note;
import objects.Character;
import substates.GameOverSubstate;

#if funkin.vis
import funkin.vis.dsp.SpectralAnalyzer;
#end

class PhillyBlazin extends BaseStage
{
	var rainShader:RainShader;
	var rainTimeScale:Float = 1;

	var scrollingSky:FlxTiledSprite;
	var skyAdditive:BGSprite;
	var lightning:BGSprite;
	var foregroundMultiply:BGSprite;
	var additionalLighten:FlxSprite;
	
	var lightningTimer:Float = 3.0;

	var abot:ABotSpeaker;

	override function onCreate()
	{
		FlxTransitionableState.skipNextTransOut = true; //skip the original transition fade
		function setupScale(spr:BGSprite)
		{
			spr.scale.set(1.75, 1.75);
			spr.updateHitbox();
		}

		if(!ClientPrefs.data.lowQuality)
		{
			var skyImage = Paths.image('phillyBlazin/skyBlur');
			scrollingSky = new FlxTiledSprite(skyImage, Std.int(skyImage.width * 1.1) + 475, Std.int(skyImage.height / 1.1), true, false);
			scrollingSky.antialiasing = ClientPrefs.data.antialiasing;
			scrollingSky.setPosition(-500, -120);
			scrollingSky.scrollFactor.set();
			add(scrollingSky);

			skyAdditive = new BGSprite('phillyBlazin/skyBlur', -600, -175, 0.0, 0.0);
			setupScale(skyAdditive);
			skyAdditive.visible = false;
			add(skyAdditive);
			
			lightning = new BGSprite('phillyBlazin/lightning', -50, -300, 0.0, 0.0, ['lightning0'], false);
			setupScale(lightning);
			lightning.visible = false;
			add(lightning);
		}
		
		var phillyForegroundCity:BGSprite = new BGSprite('phillyBlazin/streetBlur', -600, -175, 0.0, 0.0);
		setupScale(phillyForegroundCity);
		add(phillyForegroundCity);
		
		if(!ClientPrefs.data.lowQuality)
		{
			foregroundMultiply = new BGSprite('phillyBlazin/streetBlur', -600, -175, 0.0, 0.0);
			setupScale(foregroundMultiply);
			foregroundMultiply.blend = MULTIPLY;
			foregroundMultiply.visible = false;
			add(foregroundMultiply);
			
			additionalLighten = new FlxSprite(-600, -175).makeGraphic(1, 1, FlxColor.WHITE);
			additionalLighten.scrollFactor.set();
			additionalLighten.scale.set(2500, 2500);
			additionalLighten.updateHitbox();
			additionalLighten.blend = ADD;
			additionalLighten.visible = false;
			add(additionalLighten);
		}

		abot = new ABotSpeaker(gfGroup.x, gfGroup.y + 550);
		add(abot);
		
		if(ClientPrefs.data.shaders)
			setupRainShader();

		var _song = PlayState.SONG;
		if(_song.gameOverSound == null || _song.gameOverSound.trim().length < 1) GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pico-gutpunch';
		if(_song.gameOverLoop == null || _song.gameOverLoop.trim().length < 1) GameOverSubstate.loopSoundName = 'gameOver-pico';
		if(_song.gameOverEnd == null || _song.gameOverEnd.trim().length < 1) GameOverSubstate.endSoundName = 'gameOverEnd-pico';
		if(_song.gameOverChar == null || _song.gameOverChar.trim().length < 1) GameOverSubstate.characterName = 'pico-blazin';
		GameOverSubstate.deathDelay = 0.15;

		setDefaultGF('nene');
		precache();
		
		if (isStoryMode)
		{
			switch (songName)
			{
				case 'blazin':
					setEndCallback(function()
					{
						game.endingSong = true;
						inCutscene = true;
						canPause = false;
						FlxTransitionableState.skipNextTransIn = true;
						FlxG.camera.visible = false;
						camHUD.visible = false;
						game.startVideo('blazinCutscene');
					});
			}
		}
	}

	override function onCreatePost()
	{
		FlxG.camera.focusOn(camFollow.getPosition());
		FlxG.camera.fade(FlxColor.BLACK, 1.5, true, null, true);

		for (character in boyfriendGroup.members)
		{
			if(character == null) continue;
			character.color = 0xFFDEDEDE;
		}
		for (character in dadGroup.members)
		{
			if(character == null) continue;
			character.color = 0xFFDEDEDE;
		}
		for (character in gfGroup.members)
		{
			if(character == null) continue;
			character.color = 0xFF888888;
		}
		abot.color = 0xFF888888;

		var unspawnNotes:Array<Note> = cast game.unspawnNotes;
		for (note in unspawnNotes)
		{
			if(note == null) continue;

			//override animations for note types
			note.noAnimation = true;
			note.noMissAnimation = true;
		}
		remove(dadGroup, true);
		addBehindBF(dadGroup);
	}

	override function onBeatHit()
	{
		//if(curBeat % 2 == 0) abot.beatHit();
	}

	override function onSongStart()
	{
		abot.snd = FlxG.sound.music;
	}

	function setupRainShader()
	{
		rainShader = new RainShader();
		rainShader.scale = FlxG.height / 200;
		rainShader.intensity = 0.5;
		FlxG.camera.addShader(rainShader);
	}

	function precache()
	{
		for (i in 1...4)
		{
			Paths.sound('lightning/Lightning$i');
		}
	}

	override function onUpdate(elapsed:Float)
	{
		if(scrollingSky != null) scrollingSky.scrollX -= elapsed * 35;

		if(rainShader != null)
		{
			rainShader.updateViewInfo(FlxG.width, FlxG.height, FlxG.camera);
			rainShader.update(elapsed * rainTimeScale);
			rainTimeScale = FlxMath.lerp(0.02, Math.min(1, rainTimeScale), Math.exp(-elapsed / (1/3)));
		}
		
		lightningTimer -= elapsed;
		if (lightningTimer <= 0)
		{
			applyLightning();
			lightningTimer = FlxG.random.float(7, 15);
		}
	}
	
	function applyLightning():Void
	{
		if(ClientPrefs.data.lowQuality || game.endingSong) return;

		final LIGHTNING_FULL_DURATION = 1.5;
		final LIGHTNING_FADE_DURATION = 0.3;

		skyAdditive.visible = true;
		skyAdditive.alpha = 0.7;
		FlxTween.tween(skyAdditive, {alpha: 0.0}, LIGHTNING_FULL_DURATION, {onComplete: function(_)
		{
			skyAdditive.visible = false;
			lightning.visible = false;
			foregroundMultiply.visible = false;
			additionalLighten.visible = false;
		}});

		foregroundMultiply.visible = true;
		foregroundMultiply.alpha = 0.64;
		FlxTween.tween(foregroundMultiply, {alpha: 0.0}, LIGHTNING_FULL_DURATION);

		additionalLighten.visible = true;
		additionalLighten.alpha = 0.3;
		FlxTween.tween(additionalLighten, {alpha: 0.0}, LIGHTNING_FADE_DURATION);

		lightning.visible = true;
		lightning.animation.play('lightning0', true);

		if(FlxG.random.bool(65))
			lightning.x = FlxG.random.int(-250, 280);
		else
			lightning.x = FlxG.random.int(780, 900);

		// Darken characters
		FlxTween.color(boyfriend, LIGHTNING_FADE_DURATION, 0xFF606060, 0xFFDEDEDE);
		FlxTween.color(dad, LIGHTNING_FADE_DURATION, 0xFF606060, 0xFFDEDEDE);
		FlxTween.color(gf, LIGHTNING_FADE_DURATION, 0xFF606060, 0xFF888888);
		FlxTween.color(abot, LIGHTNING_FADE_DURATION, 0xFF606060, 0xFF888888);

		// Sound
		FlxG.sound.play(Paths.soundRandom('lightning/Lightning', 1, 3));
	}

	// Note functions
	var picoFight:PicoBlazinHandler = new PicoBlazinHandler();
	var darnellFight:DarnellBlazinHandler = new DarnellBlazinHandler();
	override function goodNoteHit(note:Note)
	{
		//trace('hit note! ${note.noteType}');
		rainTimeScale += 0.7;
		picoFight.noteHit(note);
		darnellFight.noteHit(note);
	}
	override function noteMiss(note:Note)
	{
		//trace('missed note!');
		picoFight.noteMiss(note);
		darnellFight.noteMiss(note);
	}

	override function noteMissPress(direction:Int)
	{
		//trace('misinput!');
		picoFight.noteMissPress(direction);
		darnellFight.noteMissPress(direction);
	}

	// Darnell Note functions
	override function opponentNoteHit(note:Note)
	{
		//trace('opponent hit!');
		picoFight.noteMiss(note);
		darnellFight.noteMiss(note);
	}
}

class ABotSpeaker extends FlxSpriteGroup
{
	final VIZ_MAX = 7; //ranges from viz1 to viz7
	final VIZ_POS_X:Array<Float> = [0, 59, 56, 66, 54, 52, 51];
	final VIZ_POS_Y:Array<Float> = [0, -8, -3.5, -0.4, 0.5, 4.7, 7];

	public var bg:FlxSprite;
	public var vizSprites:Array<FlxSprite> = [];
	public var eyeBg:FlxSprite;
	public var eyes:FlxAnimate;
	public var speaker:FlxAnimate;

	#if funkin.vis
	var analyzer:SpectralAnalyzer;
	#end
	var volumes:Array<Float> = [];

	public var snd(default, set):FlxSound;
	function set_snd(changed:FlxSound)
	{
		snd = changed;
		#if funkin.vis
		initAnalyzer();
		#end
		return snd;
	}

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);

		var antialias = ClientPrefs.data.antialiasing;

		bg = new FlxSprite(90, 20).loadGraphic(Paths.image('abot/stereoBG'));
		bg.antialiasing = antialias;
		add(bg);

		var vizX:Float = 0;
		var vizY:Float = 0;
		var vizFrames = Paths.getSparrowAtlas('abot/aBotViz');
		for (i in 1...VIZ_MAX+1)
		{
			volumes.push(0.0);
			vizX += VIZ_POS_X[i-1];
			vizY += VIZ_POS_Y[i-1];
			var viz:FlxSprite = new FlxSprite(vizX + 140, vizY + 74);
			viz.frames = vizFrames;
			viz.animation.addByPrefix('VIZ', 'viz$i', 0);
			viz.animation.play('VIZ', true);
			viz.animation.curAnim.finish(); //make it go to the lowest point
			viz.antialiasing = antialias;
			vizSprites.push(viz);
			viz.updateHitbox();
			viz.centerOffsets();
			add(viz);
		}

		eyeBg = new FlxSprite(-30, 215).makeGraphic(1, 1, FlxColor.WHITE);
		eyeBg.scale.set(160, 60);
		eyeBg.updateHitbox();
		add(eyeBg);

		eyes = new FlxAnimate(-10, 230);
		Paths.loadAnimateAtlas(eyes, 'abot/systemEyes');
		eyes.anim.addBySymbolIndices('lookleft', 'a bot eyes lookin', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17], 24, false);
		eyes.anim.addBySymbolIndices('lookright', 'a bot eyes lookin', [18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35], 24, false);
		eyes.anim.play('lookright', true);
		eyes.anim.curFrame = eyes.anim.length - 1;
		add(eyes);

		speaker = new FlxAnimate(-65, -10);
		Paths.loadAnimateAtlas(speaker, 'abot/abotSystem');
		speaker.anim.addBySymbol('anim', 'Abot System', 24, false);
		speaker.anim.play('anim', true);
		speaker.anim.curFrame = speaker.anim.length - 1;
		speaker.antialiasing = antialias;
		add(speaker);
	}

	#if funkin.vis
	var levels:Array<Bar>;
	var levelMax:Int = 0;
	override function update(elapsed:Float):Void
	{
		super.update(elapsed);
		if(analyzer == null) return;

		levels = analyzer.getLevels(levels);
		var oldLevelMax = levelMax;
		levelMax = 0;
		for (i in 0...Std.int(Math.min(vizSprites.length, levels.length)))
		{
			var animFrame:Int = Math.round(levels[i].value * 5);
			animFrame = Std.int(Math.abs(FlxMath.bound(animFrame, 0, 5) - 5)); // shitty dumbass flip, cuz dave got da shit backwards lol!
		
			vizSprites[i].animation.curAnim.curFrame = animFrame;
			levelMax = Std.int(Math.max(levelMax, 5 - animFrame));
		}

		if(levelMax >= 4)
		{
			//trace(levelMax);
			if(oldLevelMax <= levelMax && (levelMax >= 5 || speaker.anim.curFrame >= 3))
				beatHit();
		}
	}
	#end

	public function beatHit()
	{
		speaker.anim.play('anim', true);
	}

	#if funkin.vis
	public function initAnalyzer()
	{
		@:privateAccess
		analyzer = new SpectralAnalyzer(snd._channel.__audioSource, 7, 0.1, 40);
	
		#if desktop
		// On desktop it uses FFT stuff that isn't as optimized as the direct browser stuff we use on HTML5
		// So we want to manually change it!
		analyzer.fftN = 256;
		#end
	}
	#end

	var lookingAtRight:Bool = true;
	public function lookLeft()
	{
		if(lookingAtRight) eyes.anim.play('lookleft', true);
		lookingAtRight = false;
	}
	public function lookRight()
	{
		if(!lookingAtRight) eyes.anim.play('lookright', true);
		lookingAtRight = true;
	}
}

// Pico Note functions
class PicoBlazinHandler
{
	public function new() {}

	var cantUppercut = false;
	public function noteHit(note:Note)
	{
		if (wasNoteHitPoorly(note.rating) && isPlayerLowHealth() && isDarnellPreppingUppercut())
		{
			playPunchHighAnim();
			return;
		}

		if (cantUppercut)
		{
			playBlockAnim();
			cantUppercut = false;
			return;
		}

		switch(note.noteType)
		{
			case "weekend-1-punchlow":
				playPunchLowAnim();
			case "weekend-1-punchlowblocked":
				playPunchLowAnim();
			case "weekend-1-punchlowdodged":
				playPunchLowAnim();
			case "weekend-1-punchlowspin":
				playPunchLowAnim();

			case "weekend-1-punchhigh":
				playPunchHighAnim();
			case "weekend-1-punchhighblocked":
				playPunchHighAnim();
			case "weekend-1-punchhighdodged":
				playPunchHighAnim();
			case "weekend-1-punchhighspin":
				playPunchHighAnim();

			case "weekend-1-blockhigh":
				playBlockAnim();
			case "weekend-1-blocklow":
				playBlockAnim();
			case "weekend-1-blockspin":
				playBlockAnim();

			case "weekend-1-dodgehigh":
				playDodgeAnim();
			case "weekend-1-dodgelow":
				playDodgeAnim();
			case "weekend-1-dodgespin":
				playDodgeAnim();

			// Pico ALWAYS gets punched.
			case "weekend-1-hithigh":
				playHitHighAnim();
			case "weekend-1-hitlow":
				playHitLowAnim();
			case "weekend-1-hitspin":
				playHitSpinAnim();

			case "weekend-1-picouppercutprep":
				playUppercutPrepAnim();
			case "weekend-1-picouppercut":
				playUppercutAnim(true);

			case "weekend-1-darnelluppercutprep":
				playIdleAnim();
			case "weekend-1-darnelluppercut":
				playUppercutHitAnim();

			case "weekend-1-idle":
				playIdleAnim();
			case "weekend-1-fakeout":
				playFakeoutAnim();
			case "weekend-1-taunt":
				playTauntConditionalAnim();
			case "weekend-1-tauntforce":
				playTauntAnim();
			case "weekend-1-reversefakeout":
				playIdleAnim(); // TODO: Which anim?
		}
	}

	public function noteMiss(note:Note)
	{
		//trace('missed note!');
		if (isDarnellInUppercut())
		{
			playUppercutHitAnim();
			return;
		}

		if (willMissBeLethal())
		{
			playHitLowAnim();
			return;
		}

		if (cantUppercut)
		{
			playHitHighAnim();
			return;
		}

		switch (note.noteType)
		{
			// Pico fails to punch, and instead gets hit!
			case "weekend-1-punchlow":
				playHitLowAnim();
			case "weekend-1-punchlowblocked":
				playHitLowAnim();
			case "weekend-1-punchlowdodged":
				playHitLowAnim();
			case "weekend-1-punchlowspin":
				playHitSpinAnim();

			// Pico fails to punch, and instead gets hit!
			case "weekend-1-punchhigh":
				playHitHighAnim();
			case "weekend-1-punchhighblocked":
				playHitHighAnim();
			case "weekend-1-punchhighdodged":
				playHitHighAnim();
			case "weekend-1-punchhighspin":
				playHitSpinAnim();

			// Pico fails to block, and instead gets hit!
			case "weekend-1-blockhigh":
				playHitHighAnim();
			case "weekend-1-blocklow":
				playHitLowAnim();
			case "weekend-1-blockspin":
				playHitSpinAnim();

			// Pico fails to dodge, and instead gets hit!
			case "weekend-1-dodgehigh":
				playHitHighAnim();
			case "weekend-1-dodgelow":
				playHitLowAnim();
			case "weekend-1-dodgespin":
				playHitSpinAnim();

			// Pico ALWAYS gets punched.
			case "weekend-1-hithigh":
				playHitHighAnim();
			case "weekend-1-hitlow":
				playHitLowAnim();
			case "weekend-1-hitspin":
				playHitSpinAnim();

			// Fail to dodge the uppercut.
			case "weekend-1-picouppercutprep":
				playPunchHighAnim();
				cantUppercut = true;
			case "weekend-1-picouppercut":
				playUppercutAnim(false);

			// Darnell's attempt to uppercut, Pico dodges or gets hit.
			case "weekend-1-darnelluppercutprep":
				playIdleAnim();
			case "weekend-1-darnelluppercut":
				playUppercutHitAnim();

			case "weekend-1-idle":
				playIdleAnim();
			case "weekend-1-fakeout":
				playHitHighAnim();
			case "weekend-1-taunt":
				playTauntConditionalAnim();
			case "weekend-1-tauntforce":
				playTauntAnim();
			case "weekend-1-reversefakeout":
				playIdleAnim();
		}
	}
	
	public function noteMissPress(direction:Int)
	{
		if (willMissBeLethal())
			playHitLowAnim(); // Darnell throws a punch so that Pico dies.
		else 
			playPunchHighAnim(); // Pico wildly throws punches but Darnell dodges.
	}

	function movePicoToBack()
	{
		var bfPos:Int = FlxG.state.members.indexOf(boyfriendGroup);
		var dadPos:Int = FlxG.state.members.indexOf(dadGroup);
		if(bfPos < dadPos) return;

		FlxG.state.members[dadPos] = boyfriendGroup;
		FlxG.state.members[bfPos] = dadGroup;
	}

	function movePicoToFront()
	{
		var bfPos:Int = FlxG.state.members.indexOf(boyfriendGroup);
		var dadPos:Int = FlxG.state.members.indexOf(dadGroup);
		if(bfPos > dadPos) return;

		FlxG.state.members[dadPos] = boyfriendGroup;
		FlxG.state.members[bfPos] = dadGroup;
	}

	var alternate:Bool = false;
	function doAlternate():String
	{
		alternate = !alternate;
		return alternate ? '1' : '2';
	}

	function playBlockAnim()
	{
		boyfriend.playAnim('block', true);
		FlxG.camera.shake(0.002, 0.1);
		moveToBack();
	}

	function playCringeAnim()
	{
		boyfriend.playAnim('cringe', true);
		moveToBack();
	}

	function playDodgeAnim()
	{
		boyfriend.playAnim('dodge', true);
		moveToBack();
	}

	function playIdleAnim()
	{
		boyfriend.playAnim('idle', false);
		moveToBack();
	}

	function playFakeoutAnim()
	{
		boyfriend.playAnim('fakeout', true);
		moveToBack();
	}

	function playUppercutPrepAnim()
	{
		boyfriend.playAnim('uppercutPrep', true);
		moveToFront();
	}

	function playUppercutAnim(hit:Bool)
	{
		boyfriend.playAnim('uppercut', true);
		if (hit) FlxG.camera.shake(0.005, 0.25);
		moveToFront();
	}

	function playUppercutHitAnim()
	{
		boyfriend.playAnim('uppercutHit', true);
		FlxG.camera.shake(0.005, 0.25);
		moveToBack();
	}

	function playHitHighAnim()
	{
		boyfriend.playAnim('hitHigh', true);
		FlxG.camera.shake(0.0025, 0.15);
		moveToBack();
	}

	function playHitLowAnim()
	{
		boyfriend.playAnim('hitLow', true);
		FlxG.camera.shake(0.0025, 0.15);
		moveToBack();
	}

	function playHitSpinAnim()
	{
		boyfriend.playAnim('hitSpin', true);
		FlxG.camera.shake(0.0025, 0.15);
		moveToBack();
	}

	function playPunchHighAnim()
	{
		boyfriend.playAnim('punchHigh' + doAlternate(), true);
		moveToFront();
	}

	function playPunchLowAnim()
	{
		boyfriend.playAnim('punchLow' + doAlternate(), true);
		moveToFront();
	}

	function playTauntConditionalAnim()
	{
		if (boyfriend.getAnimationName() == "fakeout")
			playTauntAnim();
		else
			playIdleAnim();
	}

	function playTauntAnim()
	{
		boyfriend.playAnim('taunt', true);
		moveToBack();
	}

	function willMissBeLethal()
	{
		return PlayState.instance.health <= 0.0 && !PlayState.instance.practiceMode;
	}
	
	function isDarnellPreppingUppercut()
	{
		return dad.getAnimationName() == 'uppercutPrep';
	}

	function isDarnellInUppercut()
	{
		return dad.getAnimationName() == 'uppercut' || dad.getAnimationName() == 'uppercut-hold';
	}

	function wasNoteHitPoorly(rating:String)
	{
		return (rating == "bad" || rating == "shit");
	}

	function isPlayerLowHealth()
	{
		return PlayState.instance.health <= 0.3 * 2;
	}
	
	function moveToBack()
	{
		var bfPos:Int = FlxG.state.members.indexOf(boyfriendGroup);
		var dadPos:Int = FlxG.state.members.indexOf(dadGroup);
		if(bfPos < dadPos) return;

		FlxG.state.members[dadPos] = boyfriendGroup;
		FlxG.state.members[bfPos] = dadGroup;
	}

	function moveToFront()
	{
		var bfPos:Int = FlxG.state.members.indexOf(boyfriendGroup);
		var dadPos:Int = FlxG.state.members.indexOf(dadGroup);
		if(bfPos > dadPos) return;

		FlxG.state.members[dadPos] = boyfriendGroup;
		FlxG.state.members[bfPos] = dadGroup;
	}

	var boyfriend(get, never):Character;
	var dad(get, never):Character;
	var boyfriendGroup(get, never):FlxSpriteGroup;
	var dadGroup(get, never):FlxSpriteGroup;
	function get_boyfriend() return PlayState.instance.boyfriend;
	function get_dad() return PlayState.instance.dad;
	function get_boyfriendGroup() return PlayState.instance.boyfriendGroup;
	function get_dadGroup() return PlayState.instance.dadGroup;
}

class DarnellBlazinHandler
{
	public function new() {}

	var cantUppercut:Bool = false;
	public function noteHit(note:Note)
	{
		// SPECIAL CASE: If Pico hits a poor note at low health (at 30% chance),
		// Darnell may duck below Pico's punch to attempt an uppercut.
		// TODO: Maybe add a cooldown to this?
		if (wasNoteHitPoorly(note.rating) && isPlayerLowHealth() && FlxG.random.bool(30))
		{
			playUppercutPrepAnim();
			return;
		}

		if (cantUppercut)
		{
			playPunchHighAnim();
			return;
		}

		// Override the hit note animation.
		switch (note.noteType)
		{
			case "weekend-1-punchlow":
				playHitLowAnim();
			case "weekend-1-punchlowblocked":
				playBlockAnim();
			case "weekend-1-punchlowdodged":
				playDodgeAnim();
			case "weekend-1-punchlowspin":
				playSpinAnim();

			case "weekend-1-punchhigh":
				playHitHighAnim();
			case "weekend-1-punchhighblocked":
				playBlockAnim();
			case "weekend-1-punchhighdodged":
				playDodgeAnim();
			case "weekend-1-punchhighspin":
				playSpinAnim();

			// Attempt to punch, Pico dodges or gets hit.
			case "weekend-1-blockhigh":
				playPunchHighAnim();
			case "weekend-1-blocklow":
				playPunchLowAnim();
			case "weekend-1-blockspin":
				playPunchHighAnim();

			// Attempt to punch, Pico dodges or gets hit.
			case "weekend-1-dodgehigh":
				playPunchHighAnim();
			case "weekend-1-dodgelow":
				playPunchLowAnim();
			case "weekend-1-dodgespin":
				playPunchHighAnim();

			// Attempt to punch, Pico ALWAYS gets hit.
			case "weekend-1-hithigh":
				playPunchHighAnim();
			case "weekend-1-hitlow":
				playPunchLowAnim();
			case "weekend-1-hitspin":
				playPunchHighAnim();

			// Fail to dodge the uppercut.
			case "weekend-1-picouppercutprep":
				// Continue whatever animation was playing before
				// playIdleAnim();
			case "weekend-1-picouppercut":
				playUppercutHitAnim();

			// Attempt to punch, Pico dodges or gets hit.
			case "weekend-1-darnelluppercutprep":
				playUppercutPrepAnim();
			case "weekend-1-darnelluppercut":
				playUppercutAnim();

			case "weekend-1-idle":
				playIdleAnim();
			case "weekend-1-fakeout":
				playCringeAnim();
			case "weekend-1-taunt":
				playPissedConditionalAnim();
			case "weekend-1-tauntforce":
				playPissedAnim();
			case "weekend-1-reversefakeout":
				playFakeoutAnim();
		}

		cantUppercut = false;
	}
	
	public function noteMiss(note:Note)
	{
		// SPECIAL CASE: Darnell prepared to uppercut last time and Pico missed! FINISH HIM!
		if (dad.getAnimationName() == 'uppercutPrep')
		{
			playUppercutAnim();
			return;
		}

		if (willMissBeLethal())
		{
			playPunchLowAnim();
			return;
		}

		if (cantUppercut)
		{
			playPunchHighAnim();
			return;
		}

		// Override the hit note animation.
		switch (note.noteType)
		{
			// Pico tried and failed to punch, punch back!
			case "weekend-1-punchlow":
				playPunchLowAnim();
			case "weekend-1-punchlowblocked":
				playPunchLowAnim();
			case "weekend-1-punchlowdodged":
				playPunchLowAnim();
			case "weekend-1-punchlowspin":
				playPunchLowAnim();

			// Pico tried and failed to punch, punch back!
			case "weekend-1-punchhigh":
				playPunchHighAnim();
			case "weekend-1-punchhighblocked":
				playPunchHighAnim();
			case "weekend-1-punchhighdodged":
				playPunchHighAnim();
			case "weekend-1-punchhighspin":
				playPunchHighAnim();

			// Attempt to punch, Pico dodges or gets hit.
			case "weekend-1-blockhigh":
				playPunchHighAnim();
			case "weekend-1-blocklow":
				playPunchLowAnim();
			case "weekend-1-blockspin":
				playPunchHighAnim();

			// Attempt to punch, Pico dodges or gets hit.
			case "weekend-1-dodgehigh":
				playPunchHighAnim();
			case "weekend-1-dodgelow":
				playPunchLowAnim();
			case "weekend-1-dodgespin":
				playPunchHighAnim();

			// Attempt to punch, Pico ALWAYS gets hit.
			case "weekend-1-hithigh":
				playPunchHighAnim();
			case "weekend-1-hitlow":
				playPunchLowAnim();
			case "weekend-1-hitspin":
				playPunchHighAnim();

			// Successfully dodge the uppercut.
			case "weekend-1-picouppercutprep":
				playHitHighAnim();
				cantUppercut = true;
			case "weekend-1-picouppercut":
				playDodgeAnim();

			// Attempt to punch, Pico dodges or gets hit.
			case "weekend-1-darnelluppercutprep":
				playUppercutPrepAnim();
			case "weekend-1-darnelluppercut":
				playUppercutAnim();

			case "weekend-1-idle":
				playIdleAnim();
			case "weekend-1-fakeout":
				playCringeAnim(); // TODO: Which anim?
			case "weekend-1-taunt":
				playPissedConditionalAnim();
			case "weekend-1-tauntforce":
				playPissedAnim();
			case "weekend-1-reversefakeout":
				playFakeoutAnim(); // TODO: Which anim?
		}
		cantUppercut = false;
	}

	public function noteMissPress(direction:Int)
	{
		if (willMissBeLethal())
			playPunchLowAnim(); // Darnell alternates a punch so that Pico dies.
		else
		{
			// Pico wildly throws punches but Darnell alternates between dodges and blocks.
			var shouldDodge = FlxG.random.bool(50); // 50/50.
			if (shouldDodge)
				playDodgeAnim();
			else
				playBlockAnim();
		}
	}
	
	var alternate:Bool = false;
	function doAlternate():String
	{
		alternate = !alternate;
		return alternate ? '1' : '2';
	}

	function playBlockAnim()
	{
		dad.playAnim('block', true);
		PlayState.instance.camGame.shake(0.002, 0.1);
		moveToBack();
	}

	function playCringeAnim()
	{
		dad.playAnim('cringe', true);
		moveToBack();
	}

	function playDodgeAnim()
	{
		dad.playAnim('dodge', true, false);
		moveToBack();
	}

	function playIdleAnim()
	{
		dad.playAnim('idle', false);
		moveToBack();
	}

	function playFakeoutAnim()
	{
		dad.playAnim('fakeout', true);
		moveToBack();
	}

	function playPissedConditionalAnim()
	{
		if (dad.getAnimationName() == "cringe")
			playPissedAnim();
		else
			playIdleAnim();
	}

	function playPissedAnim()
	{
		dad.playAnim('pissed', true);
		moveToBack();
	}

	function playUppercutPrepAnim()
	{
		dad.playAnim('uppercutPrep', true);
		moveToFront();
	}

	function playUppercutAnim()
	{
		dad.playAnim('uppercut', true);
		moveToFront();
	}

	function playUppercutHitAnim()
	{
		dad.playAnim('uppercutHit', true);
		moveToBack();
	}

	function playHitHighAnim()
	{
		dad.playAnim('hitHigh', true);
		PlayState.instance.camGame.shake(0.0025, 0.15);
		moveToBack();
	}

	function playHitLowAnim()
	{
		dad.playAnim('hitLow', true);
		PlayState.instance.camGame.shake(0.0025, 0.15);
		moveToBack();
	}

	function playPunchHighAnim()
	{
		dad.playAnim('punchHigh' + doAlternate(), true);
		moveToFront();
	}

	function playPunchLowAnim()
	{
		dad.playAnim('punchLow' + doAlternate(), true);
		moveToFront();
	}

	function playSpinAnim()
	{
		dad.playAnim('hitSpin', true);
		PlayState.instance.camGame.shake(0.0025, 0.15);
		moveToBack();
	}
	
	function willMissBeLethal()
	{
		return PlayState.instance.health <= 0.0 && !PlayState.instance.practiceMode;
	}
	
	function wasNoteHitPoorly(rating:String)
	{
		return (rating == "bad" || rating == "shit");
	}

	function isPlayerLowHealth()
	{
		return PlayState.instance.health <= 0.3 * 2;
	}
	
	function moveToBack()
	{
		var dadPos:Int = FlxG.state.members.indexOf(dadGroup);
		var bfPos:Int = FlxG.state.members.indexOf(boyfriendGroup);
		if(dadPos < bfPos) return;

		FlxG.state.members[bfPos] = dadGroup;
		FlxG.state.members[dadPos] = boyfriendGroup;
	}

	function moveToFront()
	{
		var dadPos:Int = FlxG.state.members.indexOf(dadGroup);
		var bfPos:Int = FlxG.state.members.indexOf(boyfriendGroup);
		if(dadPos > bfPos) return;

		FlxG.state.members[bfPos] = dadGroup;
		FlxG.state.members[dadPos] = boyfriendGroup;
	}

	var boyfriend(get, never):Character;
	var dad(get, never):Character;
	var boyfriendGroup(get, never):FlxSpriteGroup;
	var dadGroup(get, never):FlxSpriteGroup;
	function get_boyfriend() return PlayState.instance.boyfriend;
	function get_dad() return PlayState.instance.dad;
	function get_boyfriendGroup() return PlayState.instance.boyfriendGroup;
	function get_dadGroup() return PlayState.instance.dadGroup;
}
#end