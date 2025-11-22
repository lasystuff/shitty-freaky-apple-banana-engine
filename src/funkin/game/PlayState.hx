package funkin.game;

import flixel.FlxState;
import flixel.FlxG;
import flixel.sound.FlxSound;
import flixel.math.FlxMath;

import funkin.game.song.*;

class PlayState extends FlxState
{
	public static var playlist:Array<Song> = [];
	
	public static var song(get, never):Song;
	private static function get_song():Song
		return playlist[0];
	
	public static var chart(get, never):Chart;
	private static function get_chart():Chart
		return song.charts.get(difficulty);

	public static var difficulty:String = "normal";

	public var conductor:Conductor;

	public var inst:FlxSound;
	public var opponentVoice:FlxSound;
	public var playerVoice:FlxSound;

	override public function create():Void
	{
		// temp stuff
		difficulty = "hard";
		playlist.push(Song.fromId("manifest"));
		//

		super.create();

		conductor = new Conductor();
		conductor.bpm = chart.bpm;
		conductor.mapBPMChange(chart);

		conductor.onStepHit.add(onStepHit);
		conductor.onBeatHit.add(onBeatHit);

		inst = new FlxSound();
		inst.loadEmbedded(Paths.get('game/songs/${song.id}/audio/Inst${song._postfix}.ogg') ?? Paths.get('game/songs/${song.id}/audio/Inst.ogg'));
		FlxG.sound.list.add(inst);

		if (FunkinAssets.exists(Paths.get('game/songs/${song.id}/audio/Voices-${song.assets.opponent}.ogg')))
		{
			opponentVoice = new FlxSound();
			opponentVoice.loadEmbedded(Paths.get('game/songs/${song.id}/audio/Voices-${song.assets.opponent}.ogg'));
			FlxG.sound.list.add(opponentVoice);
		}

		if (FunkinAssets.exists(Paths.get('game/songs/${song.id}/audio/Voices-${song.assets.player}.ogg')) || FunkinAssets.exists(Paths.get('game/songs/${song.id}/audio/Voices.ogg')))
		{
			playerVoice = new FlxSound();
			playerVoice.loadEmbedded(Paths.get('game/songs/${song.id}/audio/Voices-${song.assets.player}.ogg') ?? Paths.get('game/songs/${song.id}/audio/Voices.ogg'));
			FlxG.sound.list.add(playerVoice);
		}

		inst.play();
		if (playerVoice != null) playerVoice.play();
		if (opponentVoice != null) opponentVoice.play();
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		if (inst.playing)
		{
			// Conductor Syncing
			conductor.position += elapsed * 1000;
			conductor.position = FlxMath.lerp(inst.time, conductor.position, Math.exp(-elapsed * 5));
			var timeDiff:Float = Math.abs(inst.time - conductor.position);
			if (timeDiff > 1000)
				conductor.position = conductor.position + 1000 * FlxMath.signOf(timeDiff);

			if (opponentVoice != null)
				if ((inst.time - opponentVoice.time) > 10)
					opponentVoice.time = inst.time;
			if (playerVoice != null)
				if ((inst.time - playerVoice.time) > 10)
					playerVoice.time = inst.time;
			//
		}
	}

	public function onStepHit(step:Int):Void
	{

	}

	public function onBeatHit(beat:Int):Void
	{
		trace(beat);
	}
}