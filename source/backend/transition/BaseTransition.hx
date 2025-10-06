package backend.transition;

/**
 * TUTORIAL HOW TO ADD CUSTOM TRANSITION:
 * 1. make new class in backend.transition package:
 * ```haxe
class YourTransition extends BaseTransition {
	override function open() {
		// this function works like create() method
		// ALSO PLS DONT OVERRIDE create()
		// to end transition, call close()
		// for examples check backend.transition.FunkinFade class
	}
}
 * ```
 * 2. go to class `BaseTransition`
 * 3. add new entry in `transitions` array, this entry must contain name of your transition class, for example: `"YourTransition",`
 * 4. now you can set this transition in visuals settings
 */
class BaseTransition extends MusicBeatSubstate {
	public static var transitions:Array<String> = [
		"FunkinFade",
	];

	/**
	 * Returns instance of current transition, for example:
	 * ```haxe
	 * openSubState(BaseTransition.get([false, onOutroComplete]));
	 * ```
	 */
	public static function get(args:Array<Dynamic>):BaseTransition
		return Type.createInstance(Type.resolveClass('backend.transition.${ClientPrefs.data.transType}') ?? Type.resolveClass('backend.transition.${transitions[0]}'), args);

	public static final DURATION:Float = 0.5;

	var isTransIn:Bool;
	var finishCallback:()->Void;

	public function new(isTransIn:Bool, finishCallback:()->Void) {
		super();
		this.isTransIn = isTransIn;
		this.finishCallback = finishCallback;
	}

	function open()
		close();

	override function close() {
		super.close();

		if(finishCallback != null)
			finishCallback();
	}

	/** DONT OVERRIDE THIS, BETTER OVERRIDE `open()`, it does the same */
	override function create() {
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
		super.create();
		open();
	}
}