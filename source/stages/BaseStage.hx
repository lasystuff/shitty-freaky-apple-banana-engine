package stages;

import flixel.FlxBasic;
import flixel.FlxObject;
import flixel.util.typeLimit.OneOfTwo;

import objects.Character;

enum Countdown
{
	THREE;
	TWO;
	ONE;
	GO;
	START;
}

class BaseStage extends BaseStageWithoutDefaultStageObjects {
	// add here stage objects which will be loaded in any hardcoded stage
}

// IM TIRED FROM PLAYSTATE.HX 9000 LINES
// now without stupid buggy macro ehehe - Leer
@:access(backend.MusicBeatState)
class BaseStageWithoutDefaultStageObjects {
	public var name:String;

	public function getPrecacheList():Array<String> return [];
	public function getStageFile():StageFile return null;

	public function call(event:String, ?args:Array<Dynamic>):FunctionState {
		var ret = Function_Continue;
		if (game == null) return ret;

		args ??= [];
		var stageFunc = Reflect.field(this, event);
		if (stageFunc != null) {
			for (obj in stageObjects) {
				var val = Reflect.callMethod(obj, Reflect.field(obj, event), args);
				if (val is String && val != Function_Continue) ret = val;
			}
			var val = Reflect.callMethod(this, stageFunc, args);
			if (val is String && val != Function_Continue) ret = val;
		}
		else trace('bro $event is null i cant call it!!!!'.toCMD(RED));
		return ret;
	}

	public function initNoteType(noteType:String):BaseNoteType {
		var o = stageObjects.get(noteType);
		if (o != null) return cast o;

		noteType = noteType.replace(' ', '');
		var cl = Type.resolveClass('stages.notetypes.$noteType');
		return cl != null ? Type.createInstance(cl, []) : null;
	}

	public function initEvent(event:String):BaseEvent {
		var o = stageObjects.get(event);
		if (o != null) return cast o;

		event = event.replace(' ', '');
		var cl = Type.resolveClass('stages.events.$event');
		return cl != null ? Type.createInstance(cl, []) : null;
	}

	var game(get, never):PlayState;
	var prefs(get, never):SaveVariables;
	public var stageObjects(get, never):Map<String, BaseStageObject>;

	var curBeat(get, never):Int;
	var curStep(get, never):Int;
	var curSection(get, never):Int;

	var controls(get, never):Controls;

	var paused(get, never):Bool;
	var songName(get, never):String;
	var isStoryMode(get, never):Bool;
	var seenCutscene(get, set):Bool;
	var inCutscene(get, set):Bool;
	var canPause(get, set):Bool;
	var members(get, never):Dynamic;

	var boyfriend(get, never):Character;
	var dad(get, never):Character;
	var gf(get, never):Character;
	var boyfriendGroup(get, never):FlxSpriteGroup;
	var dadGroup(get, never):FlxSpriteGroup;
	var gfGroup(get, never):FlxSpriteGroup;
	
	var camGame(get, never):FlxCamera;
	var camHUD(get, never):FlxCamera;
	var camOther(get, never):FlxCamera;

	var defaultCamZoom(get, set):Float;
	var camFollow(get, never):FlxObject;

	var skipNextTransIn(get, set):Bool;
	var skipNextTransOut(get, set):Bool;

	function addBGSprite(image:String, x:Float = 0, y:Float = 0, ?scrollX:Float = 1, ?scrollY:Float = 1, ?scaleX:Float = 1, ?scaleY:Float = 1, ?anim:String = null, ?loop:Bool = true):BGSprite {
		var spr = new BGSprite(image, x, y, scrollX, scrollY, anim == null ? null : [anim], loop);
		spr.scale.set(scaleX, scaleY);
		add(spr);
		return spr;
	}

	function triggerEvent(name:String, value1:OneOfTwo<Float, String>, value2:OneOfTwo<Float, String>) return game.triggerEvent(name, value1, value2);
	inline function startCountdown() return game.startCountdown();
	inline function endSong() return game.endSong();
	inline function moveCamera(isDad:Bool) return game.moveCamera(isDad);
	inline function moveCameraSection(?sec:Null<Int>) return game.moveCameraSection(sec);

	inline function add(object:FlxBasic) return game.add(object);
	inline function remove(object:FlxBasic, splice:Bool = false) return game.remove(object, splice);
	inline function insert(position:Int, object:FlxBasic) return game.insert(position, object);

	inline function addBehindGF(obj:FlxBasic) return game.addBehindGF(obj);
	inline function addBehindBF(obj:FlxBasic) return game.addBehindBF(obj);
	inline function addBehindDad(obj:FlxBasic) return game.addBehindDad(obj);

	//Fix for the Chart Editor on Base Game stages
	function setDefaultGF(name:String) {
		var gfVersion:String = PlayState.SONG.gfVersion;
		if(!gfVersion.strNotEmpty()) {
			gfVersion = name;
			PlayState.SONG.gfVersion = gfVersion;
		}
	}

	//start/end callback functions
	inline function setStartCallback(myfn:Void->Void) game.startCallback = myfn;
	inline function setEndCallback(myfn:Void->Void) game.endCallback = myfn;

	// init stuff
	function onCreate() {}
	function onStartCountdown():FunctionState return Function_Continue;
	function onCountdownTick(tick:Countdown, counter:Int) {}
	function onCountdownStarted() {}
	function onSongStart() {}
	function onCreatePost() {}

	// event stuff
	function eventEarlyTrigger(event:String, value1:String, value2:String, strumTime:Float) {}
	function onEventPushed(event:String, value1:String, value2:String, strumTime:Float) {}
	function onEvent(event:String, value1:String, value2:String, strumTime:Float) {}

	// updatin stuff
	function onUpdate(elapsed:Float) {}
	function onUpdatePost(elapsed:Float) {}
	function preUpdateScore(miss:Bool):FunctionState return Function_Continue;
	function onUpdateScore(miss:Bool) {}
	function onStepHit() {}
	function onBeatHit() {}
	function onSectionHit() {}
	function onRecalculateRating():FunctionState return Function_Continue;
	function onResume() {}
	function onPause():FunctionState return Function_Continue;
	function onChartEditor():FunctionState return Function_Continue;
	function onCharacterEditor():FunctionState return Function_Continue;
	function onMoveCamera(char:String) {}

	// dialogue stuff
	function onNextDialogue(dialogueCount:Float) {}
	function onSkipDialogue(dialogueCount:Bool) {}

	// end stuff
	function onEndSong():FunctionState return Function_Continue;
	function onGameOver():FunctionState return Function_Continue;
	function onGameOverStart() {}
	function onGameOverConfirm(end:Bool) {}
	function onDestroy() {}
	/** Calls on quitting PlayState entirely (for example from pause or ending song) */
	function onQuit() {}

	// note pressing/missing stuff
	function onSpawnNote(note:Note) {}
	function onKeyPressPre(key:Int):FunctionState return Function_Continue;
	function onKeyPress(key:Int) {}
	function onKeyReleasePre(key:Int):FunctionState return Function_Continue;
	function onKeyRelease(key:Int) {}
	function opponentNoteHitPre(note:Note) {}
	function opponentNoteHit(note:Note) {}
	function goodNoteHitPre(note:Note) {}
	function goodNoteHit(note:Note) {}
	function onGhostTap(key:Int) {}
	function noteMissPress(noteData:Int) {}
	function noteMiss(note:Note) {}

	// useless functions but it need to be here cuz i using Reflect stuff in callStageFunction
	function onTimerCompleted(tag:String, loops:Int, loopsLeft:Int) {}
	function onTweenCompleted(tag:String) {}
	function onSoundFinished(tag:String) {}
	function onCustomSubstateCreate(name:String) {}
	function onCustomSubstateCreatePost(name:String) {}
	function onCustomSubstateUpdate(name:String, elapsed:Float) {}
	function onCustomSubstateUpdatePost(name:String, elapsed:Float) {}
	function onCustomSubstateDestroy(name:String) {}

	// backend shit
	function getLoadTraceFormat()
		return 'Loaded stage: ' + '%name%'.toCMD(WHITE_BOLD);

	/** DONT LOAD FLXBASICS OR SUM SHIT IN NEW() */
	public function new(?blank:Bool = false) {
		if (!blank) {
			name = CoolUtil.getClassNameWithoutPath(this);
			// :trollface:
			new FlxTimer().start(FlxG.elapsed, _ -> {
				trace(getLoadTraceFormat().replace('%name%', name));
			});
		}
	}

	@:noCompletion inline function get_game() return PlayState.instance;
	@:noCompletion inline function get_prefs() return ClientPrefs.data;
	@:noCompletion inline function get_stageObjects() return PlayState.stageObjects;

	@:noCompletion inline function get_curBeat() return game.curBeat;
	@:noCompletion inline function get_curStep() return game.curStep;
	@:noCompletion inline function get_curSection() return game.curSection;

	@:noCompletion inline function get_controls() return Controls.instance;

	@:noCompletion inline function get_paused() return game.paused;
	@:noCompletion inline function get_songName() return game.songName;
	@:noCompletion inline function get_isStoryMode() return PlayState.isStoryMode;
	@:noCompletion inline function get_seenCutscene() return PlayState.seenCutscene;
	@:noCompletion inline function set_seenCutscene(value:Bool) return PlayState.seenCutscene = value;
	@:noCompletion inline function get_inCutscene() return game.inCutscene;
	@:noCompletion inline function set_inCutscene(value:Bool) return game.inCutscene = value;
	@:noCompletion inline function get_canPause() return game.canPause;
	@:noCompletion inline function set_canPause(value:Bool) return game.canPause = value;
	@:noCompletion inline function get_members() return game.members;

	@:noCompletion inline function get_boyfriend() return game.boyfriend;
	@:noCompletion inline function get_dad() return game.dad;
	@:noCompletion inline function get_gf() return game.gf;

	@:noCompletion inline function get_boyfriendGroup() return game.boyfriendGroup;
	@:noCompletion inline function get_dadGroup() return game.dadGroup;
	@:noCompletion inline function get_gfGroup() return game.gfGroup;
	
	@:noCompletion inline function get_camGame() return FlxG.camera;
	@:noCompletion inline function get_camHUD() return game.camHUD;
	@:noCompletion inline function get_camOther()return game.camOther;

	@:noCompletion inline function get_defaultCamZoom() return game.defaultCamZoom;
	@:noCompletion inline function set_defaultCamZoom(value:Float) return game.defaultCamZoom = value;
	@:noCompletion inline function get_camFollow() return game.camFollow;

	@:noCompletion inline function get_skipNextTransIn() return game.skipNextTransIn;
	@:noCompletion inline function set_skipNextTransIn(value:Bool) return game.skipNextTransIn = value;
	@:noCompletion inline function get_skipNextTransOut() return game.skipNextTransOut;
	@:noCompletion inline function set_skipNextTransOut(value:Bool) return game.skipNextTransOut = value;
}