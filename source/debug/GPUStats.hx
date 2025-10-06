package debug;

import flixel.util.FlxSignal;
#if windows
import lime.app.Future;
import sys.io.Process;
#end

/**
 * To start tracking GPU stats, call `init()` function.
 * 
 * Works only on Windows target.
 * @author TheLeerName
 */
#if windows
@:cppInclude('windows.h')
#end
@:publicFields
@:access(debug.FPSCounter)
class GPUStats {
	/** Total dedicated GPU memory in bytes. */
	static var totalMemory(default, null):Float = -1;

	/** Current dedicated GPU memory usage in bytes of this application. */
	static var memoryUsage(default, null):Float = -1;
	/** Current dedicated GPU memory usage in bytes of all applications on PC. */
	static var globalMemoryUsage(default, null):Float = -1;

	/** Current GPU utilization percentage of this application. */
	static var usage(default, null):Float = -1;
	/** Current GPU utilization percentage of all applications on PC. */
	static var globalUsage(default, null):Float = -1;

	/** Will be dispatched on update of variables. Usually dispatched each second. */
	static var onUpdate:FlxSignal;
	/** Will be dispatched on error. */
	static var onError:FlxSignal;

	/** `true` if GPU stats tracking is running. */
	static var wasStarted:Bool = false;

	static var errorMessage:String;

	/** Starts tracking GPU stats, can be gotten with static variables in this class. */
	static function init() {
		#if windows
		if (wasStarted) return;
		wasStarted = true;

		onUpdate = new FlxSignal();
		onError = new FlxSignal();
		onError.addOnce(() -> Main.fpsVar.pressedF3Lines.push('\nGPU stats tracking failed! $errorMessage'));

		var first = true;
		// very cool thing!!!
		// https://stackoverflow.com/a/73496338
		var pid = Std.string(untyped __cpp__('GetCurrentProcessId()'));
		new FlxTimer().start(0.1, tmr -> {
			new Future(() -> {
				if (first) {
					var a = new Process('powershell', ['(Get-WmiObject Win32_VideoController).AdapterRAM']);
					var err = a.stderr.readAll().toString();
					if (err.length > 0) {
						trace('Getting values from tracking failed! '.toCMD(RED_BOLD) + err.toCMD(RED));
						errorMessage = 'Unknown';
						onError.dispatch();
						wasStarted = false;
						return;
					}

					totalMemory = Std.parseFloat(a.stdout.readAll().toString().trim());
					a.close();
				}

				var tr = new Process('powershell', ['((Get-Counter -Counter @("\\GPU Process Memory(pid_${pid}_*)\\Dedicated Usage", "\\GPU Engine(pid_${pid}_*)\\Utilization Percentage", "\\GPU Engine(*)\\Utilization Percentage", "\\GPU Process Memory(*)\\Dedicated Usage")).CounterSamples | where CookedValue).CookedValue']);
				var err = tr.stderr.readAll().toString();
				if (err.length > 0) {
					err = err.substring(err.indexOf('CategoryInfo          : ') + 24);
					err = err.substring(0, err.indexOf('\r\n'));
					trace('Getting values from tracking failed! '.toCMD(RED_BOLD) + err.toCMD(RED));
					errorMessage = err;
					onError.dispatch();
					wasStarted = false;
					return;
				} else if (first)
					trace('Tracking started'.toCMD(GREEN));
				first = false;

				var percent:Array<Float> = [];
				var mem:Array<Float> = [];

				var arr:Array<String> = tr.stdout.readAll().toString().trim().replace(',', '.').split('\r\n');
				for (i in 1...arr.length)
					(arr[i].contains('.') ? percent : mem).push(Std.parseFloat(arr[i]));

				memoryUsage = Std.parseFloat(arr[0]);
				globalMemoryUsage = memoryUsage;
				for (m in mem) globalMemoryUsage += m;

				usage = Std.parseFloat(arr[1]);
				globalUsage = 0;
				for (p in percent) globalUsage += p;

				onUpdate.dispatch();

				if (wasStarted) tmr.reset();
			}, true);
		});
		#else
		trace('Start of tracking failed!'.toCMD(YELLOW_BOLD), 'Not supported by target'.toCMD(YELLOW));
		#end
	}

	/** Terminates tracking GPU stats. */
	static function close() {
		if (!wasStarted) return;
		trace('Tracking stopped'.toCMD(RED));
		wasStarted = false;
	}
}