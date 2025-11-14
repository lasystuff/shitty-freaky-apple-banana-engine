package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var game:FlxGame;
	public function new()
	{
		super();
		game = FlxGame(0, 0, PlayState);
		addChild(game);
	}
}