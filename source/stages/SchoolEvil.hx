package stages;

#if BASE_GAME_FILES
import flixel.addons.effects.FlxTrail;
import substates.GameOverSubstate;
import cutscenes.DialogueBox;

class SchoolEvil extends BaseStage {
	override function onCreate() {
		var _song = PlayState.SONG;
		if(!_song.gameOverSound.strNotEmpty()) GameOverSubstate.deathSoundName = 'fnf_loss_sfx-pixel';
		if(!_song.gameOverLoop.strNotEmpty()) GameOverSubstate.loopSoundName = 'gameOver-pixel';
		if(!_song.gameOverEnd.strNotEmpty()) GameOverSubstate.endSoundName = 'gameOverEnd-pixel';
		if(!_song.gameOverChar.strNotEmpty()) GameOverSubstate.characterName = 'bf-pixel-dead';

		var posX = 400;
		var posY = 200;

		var bg:BGSprite;
		if(!prefs.lowQuality)
			bg = new BGSprite('weeb/animatedEvilSchool', posX, posY, 0.8, 0.9, ['background 2'], true);
		else
			bg = new BGSprite('weeb/animatedEvilSchool_low', posX, posY, 0.8, 0.9);

		bg.scale.set(PlayState.daPixelZoom, PlayState.daPixelZoom);
		bg.antialiasing = false;
		add(bg);
		setDefaultGF('gf-pixel');

		FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
		FlxG.sound.music.fadeIn(1, 0, 0.8);
		if(isStoryMode && !seenCutscene)
		{
			initDoof();
			setStartCallback(schoolIntro);
		}
	}

	override function onCreatePost() {
		var trail:FlxTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
		addBehindDad(trail);
	}

	// Ghouls event
	var bgGhouls:BGSprite;
	override function onEvent(name:String, v1:String, v2:String, time:Float) {
		switch(name) {
			case "Trigger BG Ghouls":
				if(!prefs.lowQuality) {
					bgGhouls.dance(true);
					bgGhouls.visible = true;
				}
		}
	}

	override function onEventPushed(name:String, v1:String, v2:String, time:Float) {
		// used for preloading assets used on events
		switch(name)
		{
			case "Trigger BG Ghouls":
				if(!prefs.lowQuality)
				{
					bgGhouls = new BGSprite('weeb/bgGhouls', -100, 190, 0.9, 0.9, ['BG freaks glitch'], false);
					bgGhouls.setGraphicSize(Std.int(bgGhouls.width * PlayState.daPixelZoom));
					bgGhouls.updateHitbox();
					bgGhouls.visible = false;
					bgGhouls.antialiasing = false;
					bgGhouls.animation.finishCallback = function(name:String)
					{
						if(name == 'BG freaks glitch')
							bgGhouls.visible = false;
					}
					addBehindGF(bgGhouls);
				}
		}
	}

	var doof:DialogueBox = null;
	function initDoof()
	{
		var file:String = Paths.txtPath(songName + '/' + songName + 'Dialogue'); //Checks for vanilla/Senpai dialogue
		if (!Paths.existsAbsolute(file))
		{
			startCountdown();
			return;
		}

		doof = new DialogueBox(false, CoolUtil.coolTextFile(file));
		doof.cameras = [camHUD];
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;
		doof.nextDialogueThing = PlayState.instance.startNextDialogue;
		doof.skipDialogueThing = PlayState.instance.skipDialogue;
	}
	
	function schoolIntro():Void
	{
		inCutscene = true;
		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();
		add(red);

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += 300;
		camHUD.visible = false;

		new FlxTimer().start(2.1, function(tmr:FlxTimer)
		{
			if (doof != null)
			{
				add(senpaiEvil);
				senpaiEvil.alpha = 0;
				new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
				{
					senpaiEvil.alpha += 0.15;
					if (senpaiEvil.alpha < 1)
					{
						swagTimer.reset();
					}
					else
					{
						senpaiEvil.animation.play('idle');
						FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
						{
							remove(senpaiEvil);
							senpaiEvil.destroy();
							remove(red);
							red.destroy();
							FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
							{
								add(doof);
								camHUD.visible = true;
							}, true);
						});
						new FlxTimer().start(3.2, function(deadTime:FlxTimer)
						{
							FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
						});
					}
				});
			}
		});
	}
}
#end