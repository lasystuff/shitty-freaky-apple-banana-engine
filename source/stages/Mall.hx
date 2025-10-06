package stages;

#if BASE_GAME_FILES
class Mall extends BaseStage {
	var upperBoppers:BGSprite;
	var bottomBoppers:MallCrowd;
	var santa:BGSprite;

	override function onCreate() {
		var bg:BGSprite = new BGSprite('christmas/bgWalls', -1000, -500, 0.2, 0.2);
		bg.setGraphicSize(Std.int(bg.width * 0.8));
		bg.updateHitbox();
		add(bg);

		if(!prefs.lowQuality) {
			upperBoppers = new BGSprite('christmas/upperBop', -240, -90, 0.33, 0.33, ['Upper Crowd Bob']);
			upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
			upperBoppers.updateHitbox();
			add(upperBoppers);

			var bgEscalator:BGSprite = new BGSprite('christmas/bgEscalator', -1100, -600, 0.3, 0.3);
			bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
			bgEscalator.updateHitbox();
			add(bgEscalator);
		}

		var tree:BGSprite = new BGSprite('christmas/christmasTree', 370, -250, 0.40, 0.40);
		add(tree);

		bottomBoppers = new MallCrowd(-300, 140);
		add(bottomBoppers);

		var fgSnow:BGSprite = new BGSprite('christmas/fgSnow', -600, 700);
		add(fgSnow);

		santa = new BGSprite('christmas/santa', -840, 150, 1, 1, ['santa idle in fear']);
		add(santa);
		Paths.sound('Lights_Shut_off');
		setDefaultGF('gf-christmas');

		if(isStoryMode && !seenCutscene)
			setEndCallback(eggnogEndCutscene);
	}

	override function onCountdownTick(count:Countdown, num:Int) everyoneDance();
	override function onBeatHit() everyoneDance();

	override function onEvent(name:String, v1:String, v2:String, time:Float) {
		switch(name) {
			case "Hey!":
				switch(v1.toLowerCase().trim()) {
					case 'bf' | 'boyfriend' | '0':
						return;
				}
				bottomBoppers.animation.play('hey', true);
				bottomBoppers.heyTimer = Std.parseFloat(v2);
		}
	}

	function everyoneDance()
	{
		if(!prefs.lowQuality)
			upperBoppers.dance(true);

		bottomBoppers.dance(true);
		santa.dance(true);
	}

	function eggnogEndCutscene()
	{
		if(PlayState.storyPlaylist[1] == null)
		{
			endSong();
			return;
		}

		var nextSong:String = Paths.formatToSongPath(PlayState.storyPlaylist[1]);
		if(nextSong == 'winter-horrorland')
		{
			FlxG.sound.play(Paths.sound('Lights_Shut_off'));

			var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
				-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
			blackShit.scrollFactor.set();
			add(blackShit);
			camHUD.visible = false;

			inCutscene = true;
			canPause = false;

			new FlxTimer().start(1.5, function(tmr:FlxTimer) {
				endSong();
			});
		}
		else endSong();
	}
}

class MallCrowd extends BGSprite
{
	public var heyTimer:Float = 0;
	public function new(x:Float = 0, y:Float = 0, sprite:String = 'christmas/bottomBop', idle:String = 'Bottom Level Boppers Idle', hey:String = 'Bottom Level Boppers HEY')
	{
		super(sprite, x, y, 0.9, 0.9, [idle]);
		animation.addByPrefix('hey', hey, 24, false);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if(heyTimer > 0) {
			heyTimer -= elapsed;
			if(heyTimer <= 0) {
				dance(true);
				heyTimer = 0;
			}
		}
	}

	override function dance(?forceplay:Bool = false)
	{
		if(heyTimer > 0) return;
		super.dance(forceplay);
	}
}
#end