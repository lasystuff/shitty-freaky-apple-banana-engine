package;

import flixel.FlxGame;
import openfl.display.Sprite;

import funkin.game.PlayState;
import funkin.modding.ModManager;

class Main extends Sprite
{
	public static var game:FlxGame;
	public function new()
	{
		super();

		ModManager.reload();
		// moonchart.backend.FormatDetector.registerFormat(moonchart.formats.fnf.FNFShittyFreaky.__getFormat());

		game = new FlxGame(0, 0, PlayState, 60, 60, true);
		addChild(game);
	}
}