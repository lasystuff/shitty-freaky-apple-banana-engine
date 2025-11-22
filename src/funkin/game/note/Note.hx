package funkin.game.note;

import funkin.game.song.Chart.ChartNote;
import flixel.FlxSprite;

enum NoteStatus
{
    HITTABLE;
    HIT;
    MISSED;
}

class Note extends FlxSprite
{
    public var data:ChartNote;

    public var strum:Strumline;
    public var status:NoteStatus = HITTABLE;
    public var followStrum:Bool = true;
    public var hitDiff:Float = 0;

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
}