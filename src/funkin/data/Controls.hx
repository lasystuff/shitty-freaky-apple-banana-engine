package funkin.data;

import flixel.addons.input.FlxControls;
import flixel.input.keyboard.FlxKey;

enum Actions
{
	LEFT;
	DOWN;
	UP;
	RIGHT;

	UI_LEFT;
	UI_DOWN;
	UI_UP;
	UI_RIGHT;
}

class Controls extends FlxControls<Actions>
{
	public static var instance:Controls;

	override public function new(?id:String):Void
	{
		super(id);

		instance = this;
	}
	
	function getDefaultMappings():ActionMap<Actions>
	{
		return [
			LEFT => [FlxKey.LEFT, FlxKey.A],
			DOWN => [FlxKey.DOWN, FlxKey.S],
			UP => [FlxKey.UP, FlxKey.W],
			RIGHT => [FlxKey.RIGHT, FlxKey.D]
		];
	}
}