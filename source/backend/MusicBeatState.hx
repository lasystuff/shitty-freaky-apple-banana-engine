package backend;

import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;

import backend.PsychCamera;

class MusicBeatState extends FlxState
{
	private var curSection:Int = 0;
	private var stepsToDo:Int = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var curDecStep:Float = 0;
	private var curDecBeat:Float = 0;
	public var controls(get, never):Controls;
	@:noCompletion function get_controls() return Controls.instance;

	public var skipNextTransOut(get, set):Bool;
	public var skipNextTransIn(get, set):Bool;

	/** Shortcut of `ClientPrefs.data` */
	public var prefs(get, never):SaveVariables;
	@:noCompletion function get_prefs() return ClientPrefs.data;

	/** Shortcut of `ClientPrefs.data.gameplaySettings` / `ClientPrefs.gameplaySettings` */
	public var gameplayPrefs(get, never):GameplaySettings;
	@:noCompletion function get_gameplayPrefs() return ClientPrefs.gameplaySettings;

	var _psychCameraInitialized:Bool = false;

	public var variables:Map<String, Dynamic> = [];
	public static function getVariables()
		return getState().variables;

	override function create() {
		#if MODS_ALLOWED Mods.updatedOnState = false; #end

		if(!_psychCameraInitialized) initPsychCamera();

		super.create();

		if(!skipNextTransOut)
			openSubState(BaseTransition.get([true, null]));

		skipNextTransOut = false;
		timePassedOnState = 0;
	}

	public function initPsychCamera():PsychCamera
	{
		var camera = new PsychCamera();
		FlxG.cameras.reset(camera);
		FlxG.cameras.setDefaultDrawTarget(camera, true);
		_psychCameraInitialized = true;
		//trace('initialized psych camera ' + Sys.cpuTime());
		return camera;
	}

	public static var timePassedOnState:Float = 0;
	override function update(elapsed:Float)
	{
		//everyStep();
		var oldStep:Int = curStep;
		timePassedOnState += elapsed;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if(curStep > 0)
				stepHit();

			if(PlayState.SONG != null)
			{
				if (oldStep < curStep)
					updateSection();
				else
					rollbackSection();
			}
		}

		if (Main.fullscreenAllowed && FlxG.keys.justPressed.F11)
			FlxG.fullscreen = !FlxG.fullscreen;

		super.update(elapsed);
	}

	private function updateSection():Void
	{
		if(stepsToDo < 1) stepsToDo = Math.round(getBeatsOnSection() * 4);
		while(curStep >= stepsToDo)
		{
			curSection++;
			var beats:Float = getBeatsOnSection();
			stepsToDo += Math.round(beats * 4);
			sectionHit();
		}
	}

	private function rollbackSection():Void
	{
		if(curStep < 0) return;

		var lastSection:Int = curSection;
		curSection = 0;
		stepsToDo = 0;
		for (i in 0...PlayState.SONG.notes.length)
		{
			if (PlayState.SONG.notes[i] != null)
			{
				stepsToDo += Math.round(getBeatsOnSection() * 4);
				if(stepsToDo > curStep) break;
				
				curSection++;
			}
		}

		if(curSection > lastSection) sectionHit();
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecBeat = curDecStep/4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - prefs.noteOffset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	override function startOutro(onOutroComplete:()->Void):Void
	{
		if (!skipNextTransIn)
			return FlxG.state.openSubState(BaseTransition.get([false, onOutroComplete]));

		skipNextTransIn = false;
		onOutroComplete();
	}

	/** @param dumpCache If `true`, calls `Paths.clearStoredMemory()` on next state pre-create, also increases loading times by a LOT. */
	public static function switchState(nextState:FlxState, ?dumpCache:Bool = false) {
		if (dumpCache) FlxG.signals.preStateCreate.addOnce(_ -> Paths.clearStoredMemory());

		trace('Switching to ' + Type.getClassName(Type.getClass(nextState)).toCMD(WHITE_BOLD));

		FlxG.switchState(nextState);
	}

	public static function resetState()
		FlxG.resetState();

	public static function getState():MusicBeatState {
		return cast (FlxG.state, MusicBeatState);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//trace('Beat: ' + curBeat);
	}

	public function sectionHit():Void
	{
		//trace('Section: ' + curSection + ', Beat: ' + curBeat + ', Step: ' + curStep);
	}

	function getBeatsOnSection():Float
		return Conductor.getSectionBeatsFromSong(curSection);

	@:noCompletion function get_skipNextTransOut():Bool return FlxTransitionableState.skipNextTransOut;
	@:noCompletion function set_skipNextTransOut(v:Bool):Bool return FlxTransitionableState.skipNextTransOut = v;
	@:noCompletion function get_skipNextTransIn():Bool return FlxTransitionableState.skipNextTransIn;
	@:noCompletion function set_skipNextTransIn(v:Bool):Bool return FlxTransitionableState.skipNextTransIn = v;
}
