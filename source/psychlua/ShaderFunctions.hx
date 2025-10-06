package psychlua;

#if (!flash && sys)
import flixel.addons.display.FlxRuntimeShader;
#end

@:access(psychlua.FunkinLua)
class ShaderFunctions
{
	public static function implementLua(lua:FunkinLua)
	{
		// shader shit
		lua.addLocalCallback("initLuaShader", function(name:String) {
			if(!lua.prefs.shaders) return false;

			#if (!flash && sys)
			return lua.initLuaShader(name);
			#else
			lua.debugPrint("initLuaShader: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			#end
			return false;
		});
		
		lua.addLocalCallback("setSpriteShader", function(obj:String, shader:String) {
			if(!lua.prefs.shaders) return false;

			#if (!flash && sys)
			if(!lua.runtimeShaders.exists(shader) && !lua.initLuaShader(shader))
			{
				lua.debugPrint('setSpriteShader: Shader $shader is missing!', FlxColor.RED);
				return false;
			}

			var split:Array<String> = obj.split('.');
			var leObj:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
			if(split.length > 1) {
				leObj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);
			}

			if(leObj != null) {
				var arr:Array<String> = lua.runtimeShaders.get(shader);
				leObj.shader = new FlxRuntimeShader(arr[0], arr[1]);
				return true;
			}
			#else
			lua.debugPrint("setSpriteShader: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			#end
			return false;
		});
		lua.set("removeSpriteShader", function(obj:String) {
			var split:Array<String> = obj.split('.');
			var leObj:FlxSprite = LuaUtils.getObjectDirectly(split[0]);
			if(split.length > 1) {
				leObj = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);
			}

			if(leObj != null) {
				leObj.shader = null;
				return true;
			}
			return false;
		});


		lua.set("getShaderBool", function(obj:String, prop:String) {
			#if (!flash && sys)
			var shader:FlxRuntimeShader = getShader(obj);
			if (shader == null)
			{
				lua.debugPrint("getShaderBool: Shader is not FlxRuntimeShader!", FlxColor.RED);
				return null;
			}
			return shader.getBool(prop);
			#else
			lua.debugPrint("getShaderBool: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			return null;
			#end
		});
		lua.set("getShaderBoolArray", function(obj:String, prop:String) {
			#if (!flash && sys)
			var shader:FlxRuntimeShader = getShader(obj);
			if (shader == null)
			{
				lua.debugPrint("getShaderBoolArray: Shader is not FlxRuntimeShader!", FlxColor.RED);
				return null;
			}
			return shader.getBoolArray(prop);
			#else
			lua.debugPrint("getShaderBoolArray: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			return null;
			#end
		});
		lua.set("getShaderInt", function(obj:String, prop:String) {
			#if (!flash && sys)
			var shader:FlxRuntimeShader = getShader(obj);
			if (shader == null)
			{
				lua.debugPrint("getShaderInt: Shader is not FlxRuntimeShader!", FlxColor.RED);
				return null;
			}
			return shader.getInt(prop);
			#else
			lua.debugPrint("getShaderInt: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			return null;
			#end
		});
		lua.set("getShaderIntArray", function(obj:String, prop:String) {
			#if (!flash && sys)
			var shader:FlxRuntimeShader = getShader(obj);
			if (shader == null)
			{
				lua.debugPrint("getShaderIntArray: Shader is not FlxRuntimeShader!", FlxColor.RED);
				return null;
			}
			return shader.getIntArray(prop);
			#else
			lua.debugPrint("getShaderIntArray: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			return null;
			#end
		});
		lua.set("getShaderFloat", function(obj:String, prop:String) {
			#if (!flash && sys)
			var shader:FlxRuntimeShader = getShader(obj);
			if (shader == null)
			{
				lua.debugPrint("getShaderFloat: Shader is not FlxRuntimeShader!", FlxColor.RED);
				return null;
			}
			return shader.getFloat(prop);
			#else
			lua.debugPrint("getShaderFloat: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			return null;
			#end
		});
		lua.set("getShaderFloatArray", function(obj:String, prop:String) {
			#if (!flash && sys)
			var shader:FlxRuntimeShader = getShader(obj);
			if (shader == null)
			{
				lua.debugPrint("getShaderFloatArray: Shader is not FlxRuntimeShader!", FlxColor.RED);
				return null;
			}
			return shader.getFloatArray(prop);
			#else
			lua.debugPrint("getShaderFloatArray: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			return null;
			#end
		});


		lua.set("setShaderBool", function(obj:String, prop:String, value:Bool) {
			#if (!flash && sys)
			var shader:FlxRuntimeShader = getShader(obj);
			if(shader == null)
			{
				lua.debugPrint("setShaderBool: Shader is not FlxRuntimeShader!", FlxColor.RED);
				return false;
			}
			shader.setBool(prop, value);
			return true;
			#else
			lua.debugPrint("setShaderBool: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			return false;
			#end
		});
		lua.set("setShaderBoolArray", function(obj:String, prop:String, values:Dynamic) {
			#if (!flash && sys)
			var shader:FlxRuntimeShader = getShader(obj);
			if(shader == null)
			{
				lua.debugPrint("setShaderBoolArray: Shader is not FlxRuntimeShader!", FlxColor.RED);
				return false;
			}
			shader.setBoolArray(prop, values);
			return true;
			#else
			lua.debugPrint("setShaderBoolArray: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			return false;
			#end
		});
		lua.set("setShaderInt", function(obj:String, prop:String, value:Int) {
			#if (!flash && sys)
			var shader:FlxRuntimeShader = getShader(obj);
			if(shader == null)
			{
				lua.debugPrint("setShaderInt: Shader is not FlxRuntimeShader!", FlxColor.RED);
				return false;
			}
			shader.setInt(prop, value);
			return true;
			#else
			lua.debugPrint("setShaderInt: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			return false;
			#end
		});
		lua.set("setShaderIntArray", function(obj:String, prop:String, values:Dynamic) {
			#if (!flash && sys)
			var shader:FlxRuntimeShader = getShader(obj);
			if(shader == null)
			{
				lua.debugPrint("setShaderIntArray: Shader is not FlxRuntimeShader!", FlxColor.RED);
				return false;
			}
			shader.setIntArray(prop, values);
			return true;
			#else
			lua.debugPrint("setShaderIntArray: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			return false;
			#end
		});
		lua.set("setShaderFloat", function(obj:String, prop:String, value:Float) {
			#if (!flash && sys)
			var shader:FlxRuntimeShader = getShader(obj);
			if(shader == null)
			{
				lua.debugPrint("setShaderFloat: Shader is not FlxRuntimeShader!", FlxColor.RED);
				return false;
			}
			shader.setFloat(prop, value);
			return true;
			#else
			lua.debugPrint("setShaderFloat: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			return false;
			#end
		});
		lua.set("setShaderFloatArray", function(obj:String, prop:String, values:Dynamic) {
			#if (!flash && sys)
			var shader:FlxRuntimeShader = getShader(obj);
			if(shader == null)
			{
				lua.debugPrint("setShaderFloatArray: Shader is not FlxRuntimeShader!", FlxColor.RED);
				return false;
			}

			shader.setFloatArray(prop, values);
			return true;
			#else
			lua.debugPrint("setShaderFloatArray: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			return true;
			#end
		});

		lua.set("setShaderSampler2D", function(obj:String, prop:String, bitmapdataPath:String) {
			#if (!flash && sys)
			var shader:FlxRuntimeShader = getShader(obj);
			if(shader == null)
			{
				lua.debugPrint("setShaderSampler2D: Shader is not FlxRuntimeShader!", FlxColor.RED);
				return false;
			}

			// trace('bitmapdatapath: $bitmapdataPath');
			var value = Paths.image(bitmapdataPath);
			if(value != null && value.bitmap != null)
			{
				// trace('Found bitmapdata. Width: ${value.bitmap.width} Height: ${value.bitmap.height}');
				shader.setSampler2D(prop, value.bitmap);
				return true;
			}
			return false;
			#else
			lua.debugPrint("setShaderSampler2D: Platform unsupported for Runtime Shaders!", FlxColor.RED);
			return false;
			#end
		});
	}

	#if (!flash && sys)
	public static function getShader(obj:String):FlxRuntimeShader
	{
		var split:Array<String> = obj.split('.');
		var target:FlxSprite = null;
		if(split.length > 1) target = LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1]);
		else target = LuaUtils.getObjectDirectly(split[0]);

		if(target == null)
			return null;
		return cast (target.shader, FlxRuntimeShader);
	}
	#end
}