package stages.notetypes;

class BaseNoteType extends BaseStageObject {
	@:noCompletion var notesToChange:Array<Note> = []; 
	/** DONT LOAD FLXBASICS OR SUM SHIT IN NEW() */
	public function new(?blank:Bool = false) {
		super(blank);

		if (!blank) {
			for (note in game.unspawnNotes) if (note.noteType == name)
				notesToChange.push(note);

			onCreate();
		}
	}

	override function getLoadTraceFormat()
		return 'Loaded note type: ' + '%name%'.toCMD(WHITE_BOLD) + ' (${notesToChange.length} found)'.toCMD(YELLOW);

	function setupNote(cb:Note->Void) {
		for (note in notesToChange)
			cb(note);
	}
}