package stages.events;

class BaseEvent extends BaseStageObject {
	@:noCompletion var eventCount:Int;
	/** DONT LOAD FLXBASICS OR SUM SHIT IN NEW() */
    public function new(?blank:Bool = false) {
		super(blank);

		if (!blank) {
			for (e in game.eventNotes) if (e.event == name)
				eventCount++;

			onCreate();
		}
	}

	override function getLoadTraceFormat()
		return 'Loaded event: ' + '%name%'.toCMD(WHITE_BOLD) + ' ($eventCount found)'.toCMD(YELLOW);
}