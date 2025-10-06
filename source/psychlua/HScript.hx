package psychlua;

#if HSCRIPT_ALLOWED
import flixel.FlxBasic;
import objects.Character;
import psychlua.FunkinLua;
import psychlua.CustomSubstate;
import psychlua.LuaUtils.FunctionState;

import crowplexus.iris.Iris;

class HScript extends Iris
{
	public var filePath:String;
	public var modFolder:String;

	#if LUA_ALLOWED
	public var parentLua:FunkinLua;
	public static function initHaxeModule(parent:FunkinLua)
	{
		if(parent.hscript == null)
		{
			trace('initializing haxe interp for: ${parent.scriptName}');
			parent.hscript = new HScript(parent);
		}
	}

	public static function initHaxeModuleCode(parent:FunkinLua, code:String, ?varsToBring:Any = null)
	{
		var hs:HScript = try parent.hscript catch (e) null;
		if(hs == null)
		{
			trace('initializing haxe interp for: ${parent.scriptName}');
			parent.hscript = new HScript(parent, code, varsToBring);
		}
		else
		{
			try
			{
				hs.scriptCode = code;
				hs.varsToBring = varsToBring;
				hs.execute();
			}
			catch(e:Dynamic)
			{
				parent.debugPrint('ERROR (${hs.origin}) - $e', FlxColor.RED);
			}
		}
	}
	#end

	public var origin:String;
	override public function new(?parent:FunkinLua, ?file:String, ?varsToBring:Any = null)
	{
		file ??= '';
	
		super(null, {name: "hscript-iris", autoRun: false, autoPreset: false});

		#if LUA_ALLOWED
		parentLua = parent;
		if (parent != null)
		{
			this.origin = parent.scriptName;
			this.modFolder = parent.modFolder;
		}
		#end

		filePath = file;
		if (filePath != null && filePath.length > 0)
		{
			this.origin = filePath;
			#if MODS_ALLOWED
			var myFolder:Array<String> = filePath.split('/');
			if(myFolder[0] + '/' == Paths.modsPath() && (Mods.currentModDirectory == myFolder[1] || Mods.getGlobalMods().contains(myFolder[1]))) //is inside mods folder
				this.modFolder = myFolder[1];
			#end
		}

		var scriptThing:String = file;
		if(parent == null && file != null)
		{
			var f:String = file.replace('\\', '/');
			if(f.contains('/') && !f.contains('\n'))
			{
				scriptThing = Paths.text(f);
			}
		}
		this.scriptCode = scriptThing;

		preset();
		this.varsToBring = varsToBring;

		execute();
	}

	var varsToBring(default, set):Any = null;
	var game:PlayState = PlayState.instance;
	override function preset() {
		super.preset();

		// Some very commonly used classes
		set('FlxG', flixel.FlxG);
		set('FlxMath', flixel.math.FlxMath);
		set('FlxSprite', flixel.FlxSprite);
		set('FlxText', flixel.text.FlxText);
		set('FlxCamera', flixel.FlxCamera);
		set('PsychCamera', backend.PsychCamera);
		set('FlxTimer', flixel.util.FlxTimer);
		set('FlxTween', flixel.tweens.FlxTween);
		set('FlxEase', flixel.tweens.FlxEase);
		set('FlxColor', CustomFlxColor);
		set('Countdown', stages.BaseStage.Countdown);
		set('PlayState', PlayState);
		set('Paths', Paths);
		set('Conductor', Conductor);
		set('ClientPrefs', ClientPrefs);
		set('Character', Character);
		set('Alphabet', Alphabet);
		set('Note', objects.Note);
		set('CustomSubstate', CustomSubstate);
		#if (!flash && sys)
		set('FlxRuntimeShader', flixel.addons.display.FlxRuntimeShader);
		#end
		set('ShaderFilter', openfl.filters.ShaderFilter);
		set('StringTools', StringTools);
		#if flxanimate
		set('FlxAnimate', FlxAnimate);
		#end

		var variables = MusicBeatState.getVariables();
		// Functions & Variables
		set('setVar', function(name:String, value:Dynamic) {
			variables.set(name, value);
			return value;
		});
		set('getVar', function(name:String) {
			var result:Dynamic = null;
			if(variables.exists(name)) result = variables.get(name);
			return result;
		});
		set('removeVar', function(name:String) return variables.remove(name));
		set('debugPrint', debugPrint);
		set('getModSetting', function(saveTag:String, ?modName:String = null) {
			if(modName == null)
			{
				if(this.modFolder == null)
				{
					game.addTextToDebug('getModSetting: Argument #2 is null and script is not inside a packed Mod folder!', FlxColor.RED);
					return null;
				}
				modName = this.modFolder;
			}
			return LuaUtils.getModSetting(saveTag, modName);
		});

		// Keyboard & Gamepads
		set('keyboardJustPressed', function(name:String) return Reflect.getProperty(FlxG.keys.justPressed, name));
		set('keyboardPressed', function(name:String) return Reflect.getProperty(FlxG.keys.pressed, name));
		set('keyboardReleased', function(name:String) return Reflect.getProperty(FlxG.keys.justReleased, name));

		set('anyGamepadJustPressed', function(name:String) return FlxG.gamepads.anyJustPressed(name));
		set('anyGamepadPressed', function(name:String) FlxG.gamepads.anyPressed(name));
		set('anyGamepadReleased', function(name:String) return FlxG.gamepads.anyJustReleased(name));

		set('gamepadAnalogX', function(id:Int, ?leftStick:Bool = true)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return 0.0;

			return controller.getXAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		set('gamepadAnalogY', function(id:Int, ?leftStick:Bool = true)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return 0.0;

			return controller.getYAxis(leftStick ? LEFT_ANALOG_STICK : RIGHT_ANALOG_STICK);
		});
		set('gamepadJustPressed', function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return false;

			return Reflect.getProperty(controller.justPressed, name) == true;
		});
		set('gamepadPressed', function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return false;

			return Reflect.getProperty(controller.pressed, name) == true;
		});
		set('gamepadReleased', function(id:Int, name:String)
		{
			var controller = FlxG.gamepads.getByID(id);
			if (controller == null) return false;

			return Reflect.getProperty(controller.justReleased, name) == true;
		});

		var controls = game.controls;
		set('keyJustPressed', function(name:String = '') {
			name = name.toLowerCase();
			switch(name) {
				case 'left': return controls.NOTE_LEFT_P;
				case 'down': return controls.NOTE_DOWN_P;
				case 'up': return controls.NOTE_UP_P;
				case 'right': return controls.NOTE_RIGHT_P;
				default: return controls.justPressed(name);
			}
			return false;
		});
		set('keyPressed', function(name:String = '') {
			name = name.toLowerCase();
			switch(name) {
				case 'left': return controls.NOTE_LEFT;
				case 'down': return controls.NOTE_DOWN;
				case 'up': return controls.NOTE_UP;
				case 'right': return controls.NOTE_RIGHT;
				default: return controls.pressed(name);
			}
			return false;
		});
		set('keyReleased', function(name:String = '') {
			name = name.toLowerCase();
			switch(name) {
				case 'left': return controls.NOTE_LEFT_R;
				case 'down': return controls.NOTE_DOWN_R;
				case 'up': return controls.NOTE_UP_R;
				case 'right': return controls.NOTE_RIGHT_R;
				default: return controls.justReleased(name);
			}
			return false;
		});

		#if LUA_ALLOWED
		// For adding your own callbacks
		// not very tested but should work
		set('createGlobalCallback', function(name:String, func:Dynamic)
		{
			for (script in game.luaArray)
				if(script?.lua != null && !script.closed)
					script.set(name, func);
			FunkinLua.customFunctions.set(name, func);
		});

		// this one was tested
		set('createCallback', function(name:String, func:Dynamic, ?lua:FunkinLua = null)
		{
			lua ??= parentLua;
			
			if(lua != null) lua.addLocalCallback(name, func);
			else debugPrint('createCallback ($name): 3rd argument is null', FlxColor.RED);
		});
		#end

		set('addHaxeLibrary', function(libName:String, ?libPackage:String = '') {
			try {
				var str:String = '';
				if(libPackage.length > 0)
					str = libPackage + '.';

				set(libName, Type.resolveClass(str + libName));
			}
			catch (e:Dynamic) {
				var msg:String = e.message.substr(0, e.message.indexOf('\n'));
				#if LUA_ALLOWED
				if(parentLua != null)
				{
					FunkinLua.lastCalledScript = parentLua;
					msg = origin + ":" + parentLua.lastCalledFunction + " - " + msg;
				}
				#end
				debugPrint('$origin - $msg', FlxColor.RED);
			}
		});
		set('parentLua', #if LUA_ALLOWED parentLua #else null #end);
		set('this', this);
		set('game', FlxG.state);
		set('controls', Controls.instance);

		set('buildTarget', LuaUtils.getBuildTarget());
		set('customSubstate', CustomSubstate.instance);
		set('customSubstateName', CustomSubstate.name);

		set('Function_Stop', Function_Stop);
		set('Function_Continue', Function_Continue);
		set('Function_StopLua', Function_StopLua); //doesnt do much cuz HScript has a lower priority than Lua
		set('Function_StopHScript', Function_StopHScript);
		set('Function_StopAll', Function_StopAll);

		set('add', FlxG.state.add);
		set('insert', FlxG.state.insert);
		set('remove', FlxG.state.remove);

		if(PlayState.instance == FlxG.state)
		{
			set('addBehindGF', PlayState.instance.addBehindGF);
			set('addBehindDad', PlayState.instance.addBehindDad);
			set('addBehindBF', PlayState.instance.addBehindBF);
		}
	}

	public function debugPrint(text:String, color:FlxColor = FlxColor.WHITE):Void {
		#if LUA_ALLOWED
		if (parentLua != null)
			return parentLua.debugPrint(text, color);
		#end

		return game.addTextToDebug(text, color);
	}

	#if LUA_ALLOWED
	public function executeCode(?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null):IrisCall {
		if (funcToRun == null) return null;

		if(!exists(funcToRun)) {
			debugPrint('$origin - No function named: $funcToRun', FlxColor.RED);
			return null;
		}

		try
		{
			final callValue:IrisCall = call(funcToRun, funcArgs);
			return callValue.returnValue;
		}
		catch(e:Dynamic)
		{
			trace('ERROR ${funcToRun}: $e');
		}
		return null;
	}

	public function executeFunction(funcToRun:String = null, ?funcArgs:Array<Dynamic>):IrisCall {
		if (funcToRun == null || !exists(funcToRun)) return null;
		return call(funcToRun, funcArgs);
	}

	public static function implementLua(lua:FunkinLua) {
		lua.addLocalCallback("runHaxeCode", function(codeToRun:String, ?varsToBring:Any = null, ?funcToRun:String = null, ?funcArgs:Array<Dynamic> = null):IrisCall {
			initHaxeModuleCode(lua, codeToRun, varsToBring);
			try
			{
				final retVal:IrisCall = lua.hscript.executeCode(funcToRun, funcArgs);
				if (retVal != null)
					return (retVal.returnValue == null || LuaUtils.isOfTypes(retVal.returnValue, [Bool, Int, Float, String, Array])) ? retVal.returnValue : null;
			}
			catch(e:Dynamic)
			{
				lua.debugPrint('ERROR (${lua.hscript.origin}: $funcToRun) - $e', FlxColor.RED);
			}

			return null;
		});
		
		lua.addLocalCallback("runHaxeFunction", function(funcToRun:String, ?funcArgs:Array<Dynamic> = null) {
			try
			{
				final retVal:IrisCall = lua.hscript.executeFunction(funcToRun, funcArgs);
				if (retVal != null)
					return (retVal.returnValue == null || LuaUtils.isOfTypes(retVal.returnValue, [Bool, Int, Float, String, Array])) ? retVal.returnValue : null;
			}
			catch(e:Dynamic)
			{
				lua.debugPrint('ERROR (${lua.hscript.origin}: $funcToRun) - $e', FlxColor.RED);
			}
			return null;
		});
		// This function is unnecessary because import already exists in HScript as a native feature
		lua.addLocalCallback("addHaxeLibrary", function(libName:String, ?libPackage:String = '') {
			var str:String = '';
			if(libPackage.length > 0)
				str = libPackage + '.';
			else
				libName ??= '';

			var c:Dynamic = Type.resolveClass(str + libName);
			c ??= Type.resolveEnum(str + libName);

			if (lua.hscript != null)
			{
				try {
					if (c != null)
						lua.hscript.set(libName, c);
				}
				catch (e:Dynamic) {
					lua.debugPrint('${lua.hscript.origin}: ${lua.lastCalledFunction} - $e', FlxColor.RED);
				}
			}
			lua.debugPrint("addHaxeLibrary is deprecated! Import classes through \"import\" in HScript!", false, true);
		});
	}
	#end

	override public function set(name:String, value:Dynamic, allowOverride:Bool = false):Void {
		// should always override by default
		super.set(name, value, true);
	}

	/*override function irisPrint(v):Void
	{
		FunkinLua.luaTrace('ERROR (${this.origin}:${interp.posInfos().lineNumber}): ${v}');
		trace('[${ruleSet.name}:${interp.posInfos().lineNumber}]: ${v}\n');
	}*/

	override public function destroy()
	{
		origin = null;
		#if LUA_ALLOWED parentLua = null; #end

		super.destroy();
	}

	function set_varsToBring(values:Any) {
		if (varsToBring != null)
			for (key in Reflect.fields(varsToBring))
				if(exists(key.trim()))
					interp.variables.remove(key.trim());

		if (values != null)
		{
			for (key in Reflect.fields(values))
			{
				key = key.trim();
				set(key, Reflect.field(values, key));
			}
		}

		return varsToBring = values;
	}
}

class CustomFlxColor {
	public static var TRANSPARENT(default, null):Int = FlxColor.TRANSPARENT;
	public static var BLACK(default, null):Int = FlxColor.BLACK;
	public static var WHITE(default, null):Int = FlxColor.WHITE;
	public static var GRAY(default, null):Int = FlxColor.GRAY;

	public static var GREEN(default, null):Int = FlxColor.GREEN;
	public static var LIME(default, null):Int = FlxColor.LIME;
	public static var YELLOW(default, null):Int = FlxColor.YELLOW;
	public static var ORANGE(default, null):Int = FlxColor.ORANGE;
	public static var RED(default, null):Int = FlxColor.RED;
	public static var PURPLE(default, null):Int = FlxColor.PURPLE;
	public static var BLUE(default, null):Int = FlxColor.BLUE;
	public static var BROWN(default, null):Int = FlxColor.BROWN;
	public static var PINK(default, null):Int = FlxColor.PINK;
	public static var MAGENTA(default, null):Int = FlxColor.MAGENTA;
	public static var CYAN(default, null):Int = FlxColor.CYAN;

	public static function fromInt(Value:Int):Int 
	{
		return cast FlxColor.fromInt(Value);
	}

	public static function fromRGB(Red:Int, Green:Int, Blue:Int, Alpha:Int = 255):Int
	{
		return cast FlxColor.fromRGB(Red, Green, Blue, Alpha);
	}
	public static function fromRGBFloat(Red:Float, Green:Float, Blue:Float, Alpha:Float = 1):Int
	{	
		return cast FlxColor.fromRGBFloat(Red, Green, Blue, Alpha);
	}

	public static function fromCMYK(Cyan:Float, Magenta:Float, Yellow:Float, Black:Float, Alpha:Float = 1):Int
	{
		return cast FlxColor.fromCMYK(Cyan, Magenta, Yellow, Black, Alpha);
	}

	public static function fromHSB(Hue:Float, Sat:Float, Brt:Float, Alpha:Float = 1):Int
	{	
		return cast FlxColor.fromHSB(Hue, Sat, Brt, Alpha);
	}
	public static function fromHSL(Hue:Float, Sat:Float, Light:Float, Alpha:Float = 1):Int
	{	
		return cast FlxColor.fromHSL(Hue, Sat, Light, Alpha);
	}
	public static function fromString(str:String):Int
	{
		return cast FlxColor.fromString(str);
	}
}
#end