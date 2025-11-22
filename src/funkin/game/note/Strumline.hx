package funkin.game.note;

import funkin.game.song.Chart.ChartNote;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup;
import flixel.util.FlxSignal.FlxTypedSignal;

import flixel.tweens.FlxTween;
import flixel.FlxSprite;

enum StrumInitAnimType
{
	DEFAULT;
	INSTANT;
}

class Strumline extends FlxTypedSpriteGroup<FlxSprite>
{
	public var inputs:Array<String> = ["note_left", "note_down", "note_up", "note_right"];


    public var notes:FlxTypedGroup<Note> = new FlxTypedGroup<Note>();

    public var spawnDistance:Float = 3000;

    public var speed:Float = 1;
    public var downscroll:Bool = false;
    public var splash:Bool = false;
    public var cpu:Bool = false;

    var queuedNotes:Array<ChartNote> = [];

	public var onNoteHit:FlxTypedSignal<(Note, Bool)->Void> = new FlxTypedSignal<(Note, Bool)->Void>();

    override public function new(x:Float, y:Float, initAnim:StrumInitAnimType = DEFAULT, cpu:Bool = false, speed:Float = 1, downscroll:Bool = false):Void
    {
        super(x, y);
        this.cpu = cpu;
		this.speed = speed;
        this.downscroll = downscroll;

        for (i in 0...4)
        {
            var strum = new FlxSprite();
            strum.frames = FunkinAssets.getSparrow(Paths.get("game/ui/" + PlayState.song.assets.ui + "/assets/notes"));
            strum.x += (160 * 0.7) * i;

            strum.animation.addByPrefix('default', 'arrow' + Constants.NOTE_DIRECTIONS[i]);
            strum.animation.addByPrefix('pressed', Constants.NOTE_DIRECTIONS[i].toLowerCase() + ' press', 24, false);
			strum.animation.addByPrefix('confirm', Constants.NOTE_DIRECTIONS[i].toLowerCase() + ' confirm', 24, false);

            // offset thingy
			strum.animation.onFrameChange.add(function(anim, frame, index)
			{
				if (frame == 0)
				{
					strum.centerOffsets();
					switch (anim)
					{
						case "confirm":
							strum.offset.x += -13;
							strum.offset.y += -13;
					}
				}
			});

			strum.animation.onFinish.add(function(anim:String)
			{
				if (anim == "confirm")
					if (cpu)
						strum.animation.play('default', true);
			});

			// fuuuk scaling fuck fuck fuck
			strum.setGraphicSize(Std.int(strum.width * 0.7));
			strum.updateHitbox();
			strum.animation.play('default');
			// strum.x += 50;
			add(strum);
        }

        switch (initAnim)
		{
			default: // instant
			case DEFAULT:
				for (i in 0...members.length)
				{
					members[i].y -= 10;
					members[i].alpha = 0;

					FlxTween.tween(members[i], {y: members[i].y + 10, alpha: 1}, 1, {ease: flixel.tweens.FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
				}
		}

		onNoteHit.add(_noteHit);
    }

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (queuedNotes.length > 0)
		{
			var raw = queuedNotes[0];
			if (raw.time - PlayState.instance.conductor.position <= spawnDistance)
			{
				notes.add(new Note(raw, this));
				queuedNotes.remove(raw);
			}
		}

		if (!cpu)
			input(elapsed);

		for (note in notes.members)
		{
			note.updateStatus();
			if (note.followStrum)
			{
				note.x = members[note.data.id].x;
				note.y = members[note.data.id].y - (PlayState.instance.conductor.position - note.data.time) * (0.45 * speed);
			}

			if (cpu && PlayState.instance.conductor.position >= note.data.time && note.status == HITTABLE)
				onNoteHit.dispatch(note, false);
		}
	}

	public function addNoteToQueue(note:ChartNote):Void
	{
		queuedNotes.push(note);
		queuedNotes.sort(function(a:ChartNote, b:ChartNote)
		{
			if (a.time > b.time)
				return 1;
			else
				return -1;
		});
	}

	function _noteHit(note:Note, sustain:Bool):Void
	{
		members[note.data.id].animation.play("confirm", true);
		if (!sustain)
		{
			note.status = HIT;
			note.destroy();
		}
	}

	var notePressTimer:Array<Float> = [0, 0, 0, 0];

	function input(elapsed:Float):Void
	{
		for (i in 0...4)
		{
			if (Controls.instance.justReleased(inputs[i]))
				members[i].animation.play("default");
			if (Controls.instance.justPressed(inputs[i]))
			{
				members[i].animation.play("pressed");
				notePressTimer[i] = 1;

				var frameDirections:Array<Int> = [];
				for (note in notes.members)
				{
					if (note.status == HITTABLE && notePressTimer[note.data.id] > 0 && !frameDirections.contains(note.data.id))
					{
						notePressTimer[note.data.id] = 0;
						frameDirections.push(note.data.id);
						note.hitDiff = PlayState.instance.conductor.position - note.data.time;
						onNoteHit.dispatch(note, false);
					}
				}
			}

			notePressTimer[i] -= elapsed*5;
			if (notePressTimer[i] <= 0)
			{
				notePressTimer[i] = 0;
			}
		}
	}
}