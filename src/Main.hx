package;

import flixel.FlxGame;
import openfl.display.Sprite;

import moonchart.Moonchart;

import funkin.game.PlayState;
import funkin.modding.ModManager;

class Main extends Sprite
{
	public static var game:FlxGame;
	public function new()
	{
		super();

		Moonchart.init();

		ModManager.reload();

		game = new FlxGame(0, 0, PlayState, 60, 60, true);
		addChild(game);
	}
}