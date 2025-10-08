package psychlua;

import flixel.FlxObject;

// basic simple custom state implementation real!!!!

class CustomState extends MusicBeatState
{
	public static var name:String = 'Unnamed';

	public function new(?_name:String)
	{
		super();

		if (_name != null)
			name = _name;
	}

	override public function create()
	{
		script = new HScript(null, Paths.path('states/$name.hx'));

		super.create();
	}
}
