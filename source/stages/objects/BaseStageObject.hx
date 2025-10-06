package stages.objects;

class BaseStageObject extends BaseStageWithoutDefaultStageObjects {
	var stage(get, never):BaseStage;

	override function getLoadTraceFormat()
		return 'Loaded stage object: ' + '%name%'.toCMD(WHITE_BOLD);

	/** DONT LOAD FLXBASICS OR SUM SHIT IN NEW() */
	public function new(?blank:Bool = false) {
		super(blank);

		if (!blank) {
			var className:String = Type.getClassName(Type.getClass(this));
			className = className.substring(className.lastIndexOf('.') + 1);
			stage.stageObjects.set(className, this);
		}
	}

	@:noCompletion inline function get_stage():BaseStage return PlayState.stage;
}