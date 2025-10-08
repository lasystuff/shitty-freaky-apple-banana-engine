package backend;

import flixel.FlxState;
import flixel.addons.transition.FlxTransitionableState;

import backend.PsychCamera;
import psychlua.HScript;
import psychlua.CustomState;

class MusicBeatState extends FlxState
{
	public static final UNSCRIPTABLE_STATE:Array<String> = ["Init", "PlayState", "CustomState", "ChartingState"];
	public var script:HScript;

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

	// public var variables:Map<String, Dynamic> = [];
	// deprecated
	public static function getVariables()
		return util.ScriptUtil.variables;

	override function create() {
		#if MODS_ALLOWED Mods.updatedOnState = false; #end

		if(!_psychCameraInitialized) initPsychCamera();

		super.create();

		if(!skipNextTransOut)
			openSubState(BaseTransition.get([true, null]));

		skipNextTransOut = false;
		timePassedOnState = 0;

		if (!UNSCRIPTABLE_STATE.contains(getName()) && Paths.path('states/${getName()}.hx') != null)
		{
			// Todo: add debug texts etc
			if (script == null)
				script = new HScript(null, Paths.path('states/${getName()}.hx'));

			script.set("add", add);
			script.set("remove", remove);
			script.set("members", members);

			script.set("controls", controls);
			script.set("prefs", prefs);
			script.set("gameplayPrefs", gameplayPrefs);

			script.set("setSkipNextTransOut", function(v:Bool) skipNextTransOut = v);
			script.set("setSkipNextTransIn", function(v:Bool) skipNextTransIn = v);
		}

		script?.executeFunction('create');
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

		if (FlxG.keys.justPressed.F5)
			FlxG.resetState();

		super.update(elapsed);

		script?.set("curStep", curStep);
		script?.set("curBeat", curBeat);

		script?.set("curDecStep", curDecStep);
		script?.set("curDecBeat", curDecBeat);

		script?.executeFunction('update', [elapsed]);
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
	public static function switchState(nextState:MusicBeatState, ?dumpCache:Bool = false) {
		if (dumpCache) FlxG.signals.preStateCreate.addOnce(_ -> Paths.clearStoredMemory());

		if (!UNSCRIPTABLE_STATE.contains(nextState.getName()) && Paths.path('states/override/${nextState.getName()}.hx') != null)
			nextState = new CustomState('override/${nextState.getName()}');

		FlxG.switchState(nextState);
	}

	public static function switchCustomState(nextState:String, ?dumpCache:Bool = false) {
		if (dumpCache) FlxG.signals.preStateCreate.addOnce(_ -> Paths.clearStoredMemory());
		FlxG.switchState(new CustomState(nextState));
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
		script?.executeFunction('stepHit');
	}

	public function beatHit():Void
	{
		script?.executeFunction('beatHit');
		//trace('Beat: ' + curBeat);
	}

	public function sectionHit():Void
	{
		//trace('Section: ' + curSection + ', Beat: ' + curBeat + ', Step: ' + curStep);
	}

	// only destroy() will run script's function before
	override public function destroy()
	{
		script?.executeFunction('destroy');
		script?.destroy();

		super.destroy();
	}

	function getBeatsOnSection():Float
		return Conductor.getSectionBeatsFromSong(curSection);

	public function getName()
		return Type.getClassName(Type.getClass(this)).split(".")[Type.getClassName(Type.getClass(this)).split(".").length - 1];

	@:noCompletion function get_skipNextTransOut():Bool return FlxTransitionableState.skipNextTransOut;
	@:noCompletion function set_skipNextTransOut(v:Bool):Bool return FlxTransitionableState.skipNextTransOut = v;
	@:noCompletion function get_skipNextTransIn():Bool return FlxTransitionableState.skipNextTransIn;
	@:noCompletion function set_skipNextTransIn(v:Bool):Bool return FlxTransitionableState.skipNextTransIn = v;
}
