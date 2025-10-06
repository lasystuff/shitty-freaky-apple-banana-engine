package stages;

class Template extends BaseStage {
	override function onCreate() {
		// Spawn your stage sprites here.
		// Characters are not ready yet on this function, so you can't add things above them yet.
		// Use onCreatePost() if that's what you want to do.
	}

	override function onCreatePost() {
		// Use this function to layer things above characters!
	}

	override function onUpdate(elapsed:Float) {
		// Code here
	}

	override function onDestroy() {
		// Code here
	}

	override function onCountdownTick(count:Countdown, num:Int) {
		switch(count) {
			case THREE: //num 0
			case TWO: //num 1
			case ONE: //num 2
			case GO: //num 3
			case START: //num 4
		}
	}

	override function onSongStart() {
		// Code here
	}

	// Steps, Beats and Sections:
	//    curStep, curDecStep
	//    curBeat, curDecBeat
	//    curSection
	override function onStepHit() {
		// Code here
	}
	override function onBeatHit() {
		// Code here
	}
	override function onSectionHit() {
		// Code here
	}

	// Substates for pausing/resuming tweens and timers
	override function onResume() {
		//timer.active = true;
		//tween.active = true;
	}
	override function onPause():FunctionState {
		//timer.active = false;
		//tween.active = false;
		return Function_Continue;
	}

	// For events
	override function onEvent(name:String, v1:String, v2:String, time:Float)
	{
		switch(name) {
			case "My Event":
		}
	}

	override function onEventPushed(name:String, v1:String, v2:String, time:Float) {
		// used for preloading assets
		switch(name) {
			case "My Event":
				//precacheImage('myImage') //preloads images/myImage.jpg or images/myImage.png
				//precacheSound('mySound') //preloads sounds/mySound.ogg
				//precacheMusic('myMusic') //preloads music/myMusic.ogg
		}
	}

	// Note Hit/Miss
	override function goodNoteHit(note:Note) {
		// Code here
	}
	override function opponentNoteHit(note:Note) {
		// Code here
	}
	override function noteMiss(note:Note) {
		// Code here
	}
	override function noteMissPress(direction:Int) {
		// Code here
	}
}