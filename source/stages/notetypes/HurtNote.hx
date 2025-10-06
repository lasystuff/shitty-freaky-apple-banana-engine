package stages.notetypes;

class HurtNote extends BaseNoteType {
	override function getPrecacheList():Array<String> return [
		'./images/noteSplashes/noteSplashes-electric.png',
		'./sounds/cancelMenu.ogg'
	];

	override function onCreate() {
		setupNote(note -> {
			note.ignoreNote = note.mustPress;
			//reloadNote('HURTNOTE_assets');
			//this used to change the note texture to HURTNOTE_assets,
			//but i've changed it to something more optimized with the implementation of RGBPalette:

			// note colors
			note.rgbShader.r = 0xFF101010;
			note.rgbShader.g = 0xFFFF0000;
			note.rgbShader.b = 0xFF990022;

			// splash data and colors
			//noteSplashData.r = 0xFFFF0000;
			//noteSplashData.g = 0xFF101010;
			note.noteSplashData.texture = 'noteSplashes-electric';

			// gameplay data
			note.lowPriority = true;
			note.missHealth = note.isSustainNote ? 0.25 : 0.1;
			note.hitCausesMiss = true;
			note.hitsound = 'cancelMenu';
			note.hitsoundChartEditor = false;
		});
	}

	override function goodNoteHit(note:Note) {
		if (note.noteType != name) return;

		//trace("xdeez nuts lmao");
		//game.healthDrop += 0.00025;
		//game.dropTime = 10;

		if(note.hitCausesMiss && !note.noMissAnimation && boyfriend.hasAnimation('hurt'))
		{
			boyfriend.playAnim('hurt', true);
			boyfriend.specialAnim = true;
		}
	}
}