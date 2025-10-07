package psychlua;

import flixel.FlxObject;

// basic simple custom state implementation real!!!!

class CustomState extends MusicBeatState
{
	public var script:HScript;
	public static var name:String = 'Unnamed';

	public function new(?_name:String)
	{
		if (_name != null)
			name = _name;

		// Todo: add debug texts etc
		script = new HScript(null, Paths.path('states/$name.hx'));

		script.set("add", add);
		script.set("remove", remove);
		script.set("members", members);

		script.set("controls", controls);
		script.set("prefs", prefs);
		script.set("gameplayPrefs", gameplayPrefs);

		script.set("setSkipNextTransOut", function(v:Bool) skipNextTransOut = v);
		script.set("setSkipNextTransIn", function(v:Bool) skipNextTransIn = v);

		super();
	}

	override public function create()
	{
		super.create();
		script.executeFunction('create');
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		script.set("curStep", curStep);
		script.set("curBeat", curBeat);

		script.set("curDecStep", curDecStep);
		script.set("curDecBeat", curDecBeat);

		if (FlxG.keys.justPressed.F5)
		{
			FlxG.resetState();
			return;
		}

		script.executeFunction('update', [elapsed]);
	}

	override public function stepHit()
	{
		super.stepHit();
		script.executeFunction('stepHit');
	}

	override public function beatHit()
	{
		super.beatHit();
		script.executeFunction('beatHit');
	}

	// only destroy() will run script's function before
	override public function destroy()
	{
		script.executeFunction('destroy');
		script.destroy();

		super.destroy();
	}
}
