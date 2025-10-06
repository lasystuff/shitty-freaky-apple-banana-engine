package backend;

#if windows
import backend.native.Windows;
#end

/** @author TheLeerName */
@:publicFields
class WindowUtil {
	/** Changes size of game absolutely, i.e. without initial ratio */
	@:access(flixel.FlxGame)
	static function resizeGame(?width:Int, ?height:Int) {
		width ??= Main.instance.game.width;
		height ??= Main.instance.game.height;

		// resize game
		Reflect.setProperty(FlxG, 'width', width); // haha suck ballz
		Reflect.setProperty(FlxG, 'initialWidth', width);
		Reflect.setProperty(FlxG, 'height', height);
		Reflect.setProperty(FlxG, 'initialHeight', height);
		// dont forget about lua scripts which use this vars!
		if (FlxG.state is PlayState) {
			var game:PlayState = cast FlxG.state;
			game.setOnLuas('screenWidth', width);
			game.setOnLuas('screenHeight', height);
		}

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		for (cam in FlxG.cameras.list)
			cam.setSize(FlxG.width, FlxG.height);
		FlxG.game.resizeGame(FlxG.stage.stageWidth, FlxG.stage.stageHeight);

		trace('Changed game size to ' + '${width}x${height}'.toCMD(WHITE_BOLD));
	}

	static function resizeWindow(?width:Int, ?height:Int, ?fullscreen:Bool) {
		width ??= Main.instance.game.width;
		height ??= Main.instance.game.height;
		fullscreen ??= FlxG.fullscreen;

		var window = FlxG.stage.window;
		var wasBoundsWindow = {width: window.width, height: window.height};

		window.resize(width, height);
		if (fullscreen) {
			// centering window by monitor bounds cuz we cant get non-fullscreen window size
			window.move(Std.int((window.display.bounds.width - window.width) / 2), Std.int((window.display.bounds.height - window.height) / 2));
			// without calling change fullscreen, game will be out of monitor bounds, but when you unfocusing and focusing back to game, it will fix it tho
			FlxG.fullscreen = false;
			FlxG.fullscreen = true;
		} else {
			// centering window based on previous window size and new window size
			window.move(window.x + Std.int((wasBoundsWindow.width - window.width) / 2), window.y + Std.int((wasBoundsWindow.height - window.height) / 2));
		}

		trace('Changed window size to ' + '${width}x${height}'.toCMD(WHITE_BOLD));
	}

	static function forceWindowMode(?windowWidth:Int, ?windowHeight:Int, ?gameWidth:Int, ?gameHeight:Int) {
		windowWidth ??= Main.instance.game.width;
		windowHeight ??= Main.instance.game.height;
		gameWidth ??= windowWidth;
		gameHeight ??= windowHeight;

		var window = FlxG.stage.window;
		if (windowWidth == window.width && windowHeight == window.height) return;
		wasBounds = {width: window.width, height: window.height};

		wasFullscreen = FlxG.fullscreen;
		FlxG.fullscreen = false; // no fullscren >:(
		resizeGame(gameWidth, gameHeight);
		resizeWindow(windowWidth, windowHeight);

		window.resizable = false;
		#if windows Windows.removeMaximizeMinimizeButtons(); #end
		Main.fullscreenAllowed = false;
	}

	static function disableForceWindowMode() {
		resizeGame();
		if (wasFullscreen) {
			resizeWindow(true);
			FlxG.fullscreen = true; // go back
		} else
			resizeWindow(wasBounds.width, wasBounds.height);

		FlxG.stage.window.resizable = true;
		#if windows Windows.addMaximizeMinimizeButtons(); #end
		Main.fullscreenAllowed = true;
	}

	@:noCompletion private static var wasFullscreen:Bool;
	@:noCompletion private static var wasBounds:{width:Int, height:Int};
}