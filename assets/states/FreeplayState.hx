import flixel.FlxG;
import states.MainMenuState;

function create()
{
    trace("hi");
}

function update(elapsed:Float)
{
    trace([elapsed, curStep]);
    if (FlxG.keys.justPressed.ENTER)
        MusicBeatState.switchState(new MainMenuState());
}