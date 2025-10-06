package stages;

#if BASE_GAME_FILES
import objects.Character;

class StageWeek1 extends BaseStage {
	var dadbattleBlack:BGSprite;
	var dadbattleLight:BGSprite;
	var dadbattleFog:DadBattleFog;
	override function onCreate() {
		var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
		add(bg);

		var stageFront:BGSprite = new BGSprite('stagefront', -650, 600, 0.9, 0.9);
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		add(stageFront);

		if(!ClientPrefs.data.lowQuality) {
			var stageLight:BGSprite = new BGSprite('stage_light', -125, -100, 0.9, 0.9);
			stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
			stageLight.updateHitbox();
			add(stageLight);
			var stageLight:BGSprite = new BGSprite('stage_light', 1225, -100, 0.9, 0.9);
			stageLight.setGraphicSize(Std.int(stageLight.width * 1.1));
			stageLight.updateHitbox();
			stageLight.flipX = true;
			add(stageLight);

			var stageCurtains:BGSprite = new BGSprite('stagecurtains', -500, -300, 1.3, 1.3);
			stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
			stageCurtains.updateHitbox();
			add(stageCurtains);
		}

	}

	override function onEventPushed(name:String, v1:String, v2:String, time:Float) {
		switch(name)
		{
			case "Dadbattle Spotlight":
				dadbattleBlack = new BGSprite(null, -800, -400, 0, 0);
				dadbattleBlack.makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
				dadbattleBlack.alpha = 0.25;
				dadbattleBlack.visible = false;
				add(dadbattleBlack);

				dadbattleLight = new BGSprite('spotlight', 400, -400);
				dadbattleLight.alpha = 0.375;
				dadbattleLight.blend = ADD;
				dadbattleLight.visible = false;
				add(dadbattleLight);

				dadbattleFog = new DadBattleFog();
				dadbattleFog.visible = false;
				add(dadbattleFog);
		}
	}

	override function onEvent(name:String, v1:String, v2:String, time:Float) {
		switch(name)
		{
			case "Dadbattle Spotlight":
				var flValue1 = Std.parseFloat(v1);
				if(flValue1 == Math.NaN) flValue1 = 0;
				var val:Int = Math.round(flValue1);

				switch(val)
				{
					case 1, 2, 3: //enable and target dad
						if(val == 1) //enable
						{
							dadbattleBlack.visible = true;
							dadbattleLight.visible = true;
							dadbattleFog.visible = true;
							defaultCamZoom += 0.12;
						}

						var who:Character = dad;
						if(val > 2) who = boyfriend;
						//2 only targets dad
						dadbattleLight.alpha = 0;
						new FlxTimer().start(0.12, function(tmr:FlxTimer) {
							dadbattleLight.alpha = 0.375;
						});
						dadbattleLight.setPosition(who.getGraphicMidpoint().x - dadbattleLight.width / 2, who.y + who.height - dadbattleLight.height + 50);
						FlxTween.tween(dadbattleFog, {alpha: 0.7}, 1.5, {ease: FlxEase.quadInOut});

					default:
						dadbattleBlack.visible = false;
						dadbattleLight.visible = false;
						defaultCamZoom -= 0.12;
						FlxTween.tween(dadbattleFog, {alpha: 0}, 0.7, {onComplete: function(twn:FlxTween) dadbattleFog.visible = false});
				}
		}
	}
}

class DadBattleFog extends FlxSpriteGroup
{
	public function new()
	{
		super();
		
		alpha = 0;
		blend = ADD;

		var offsetX = 200;
		var smoke:BGSprite = new BGSprite('smoke', -1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
		smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
		smoke.updateHitbox();
		smoke.velocity.x = FlxG.random.float(15, 22);
		smoke.active = true;
		add(smoke);

		var smoke:BGSprite = new BGSprite('smoke', 1550 + offsetX, 660 + FlxG.random.float(-20, 20), 1.2, 1.05);
		smoke.setGraphicSize(Std.int(smoke.width * FlxG.random.float(1.1, 1.22)));
		smoke.updateHitbox();
		smoke.velocity.x = FlxG.random.float(-15, -22);
		smoke.active = true;
		smoke.flipX = true;
		add(smoke);
	}
}
#end