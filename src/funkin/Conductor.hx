package funkin;

import flixel.FlxBasic;
import flixel.util.FlxSignal.FlxTypedSignal;
import funkin.game.song.Chart;

typedef BPMChange = {
	var bpm:Float;
	var time:Float;
	var step:Float;
}

class Conductor
{
	public var bpm:Float = 100;
	public var position(default, set):Float = 0;

	public var curStep:Int = 0;
	public var curBeat:Int = 0;

	public var crotchet(get, never):Float;
	function get_crotchet():Float
		return (60 / bpm) * 1000;
	public var stepCrotchet(get, never):Float;
	function get_stepCrotchet():Float
		return crotchet / 4;

	public var bpmChanges:Array<BPMChange> = [];

	public var onStepHit:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();
	public var onBeatHit:FlxTypedSignal<Int->Void> = new FlxTypedSignal<Int->Void>();

	public function new():Void{}

	public function mapBPMChange(chart:Chart)
	{
		var time:Float = 0;
		var step:Float = 0;

		var curBPM:Float = chart.bpm;

		for(e in chart.events)
		{
			if(e.name == "Change BPM")
			{
				if(e.data.bpm == curBPM)
					continue;

				var steps:Float = (e.time - time) / ((60 / curBPM) * 1000 / 4);
				step += steps;
				time = e.time;
				curBPM = e.data.bpm;

				bpmChanges.push({
					step: step,
					time: time,
					bpm: curBPM
				});
			}
		}
	}


	public function set_position(value:Float):Float
	{
		position = value;

		var bpmChange:BPMChange = {step: 0, time: 0, bpm: this.bpm};
		for (event in bpmChanges)
		{
			if (position >= event.time)
			{
				bpmChange = event;
				break;
			}
		}

		if (bpm != bpmChange.bpm)
			bpm = bpmChange.bpm;

		var oldStep:Int = curStep;
		var oldBeat:Int = curBeat;
		curStep = Math.floor((bpmChange.step + (position - bpmChange.time) / stepCrotchet));
		curBeat = Math.floor(curStep / 4);

		if(oldStep != curStep)
		{
			onStepHit.dispatch(curStep);
			if (curStep % 4 == 0 && curBeat != oldBeat)
				onBeatHit.dispatch(curBeat);
		}

		return position;
	}
}