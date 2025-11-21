package funkin.game;

import flixel.FlxState;
import flixel.sound.FlxSound;

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

	public var instrumental:FlxSound;
	public var opponentVoices:Array<FlxSound> = [];
	public var playerVoices:Array<FlxSound> = [];

	override public function create()
	{
		// temp stuff
		difficulty = "hard";
		playlist.push(Song.fromId("dad-battle"));
		//

		super.create();

		conductor = new Conductor();
		conductor.bpm = chart.bpm;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}