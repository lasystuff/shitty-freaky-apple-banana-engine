package funkin.game.note;

import funkin.game.song.Chart.ChartNote;
import flixel.FlxSprite;

enum NoteStatus
{
    NEUTRAL;
    HITTABLE;
    HIT;
    MISSED;
}

class Note extends FlxSprite
{
    public var data:ChartNote;

    public var strum:Strumline;
    public var status:NoteStatus = NEUTRAL;
    public var followStrum:Bool = true;
    public var hitDiff:Float = 0;

    public var safeZone:Float = 160;

    public function new(data:ChartNote, ?strum:Strumline)
    {
        super();
        this.strum = strum;
        this.data = data;

        frames = FunkinAssets.getSparrow(Paths.get("game/ui/" + PlayState.song.assets.ui + "/assets/notes"));

        animation.addByPrefix('scroll', Constants.NOTE_COLORS[data.id].toLowerCase() + '0');
		animation.play('scroll');
        
        setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
    }

    public function updateStatus():Void
    {
        if (status == HIT || status == MISSED)
            return;

        if (data.time > PlayState.instance.conductor.position - safeZone && data.time < PlayState.instance.conductor.position + safeZone)
            status = HITTABLE;
        else if (data.time < PlayState.instance.conductor.position - safeZone)
        {
            status = MISSED;
            this.alpha = 0.4;
        }
    }
}