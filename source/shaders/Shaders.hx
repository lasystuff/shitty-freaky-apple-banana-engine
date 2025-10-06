package shaders;

import flixel.FlxBasic;
import flixel.addons.display.FlxRuntimeShader;

import openfl.display3D.Context3DWrapMode;

#if !flash
import openfl.display.Shader;
import openfl.filters.ShaderFilter;

// "using" thingy is so cool!!!!!!!!!!!!!!!!! - Leer
@:access(flixel.FlxCamera)
class Shaders {
	public static function getFilters(camera:FlxCamera):Array<openfl.filters.BitmapFilter>
		return camera.filters;
	public static function addShader(camera:FlxCamera, shader:Shader):ShaderFilter {
		var filter = new ShaderFilter(shader);
		camera.filters.push(filter);
		return filter;
	}
	public static function addFilter(camera:FlxCamera, filter:ShaderFilter):ShaderFilter {
		camera.filters.push(filter);
		return filter;
	}
	public static function removeFilter(camera:FlxCamera, filter:ShaderFilter)
		camera.filters.remove(filter);
	public static function clearFilters(camera:FlxCamera)
		camera.filters.clearArray();
}
#end

/**
 * btw u will get null object reference if you try to create instance from this class, to avoid it make your class like this:
 * ```haxe
 class YourShader extends BaseEffect {
	public function new() {
		super("
			<put_shader_content_here>
		");
	}
}
 * ```
 * Psych Engine 0.6.3 / 0.7.X compatible btw
 * @author TheLeerName
 */
class BaseEffect extends FlxBasic {
	public var shader(default, null):FlxRuntimeShader;
	public function new(glsl:String) {
		shader = new FlxRuntimeShader(glsl.replace('\t', ''));
		super();
		if (shader.data.iTime != null) {
			shader.data.iTime.value = [0];
			FlxG.state.add(this);
		}
		shaderCoordsFix();
	}
	override function update(elapsed:Float) {
		super.update(elapsed);
		shader.data.iTime.value[0] += elapsed;
	}

	function shaderCoordsFix() {
		if (Type.getClassFields(Main).contains('resetSpriteCache')) // it already in engine in 0.7 and later lol
			return;

		var func = (w, h) -> {
			if (FlxG.cameras != null) for (cam in FlxG.cameras.list)
				@:privateAccess if (cam != null && cam.filters != null) {
					cam.flashSprite.__cacheBitmap = null;
					cam.flashSprite.__cacheBitmapData = null;
				}

			@:privateAccess if (FlxG.game != null) {
				FlxG.game.__cacheBitmap = null;
				FlxG.game.__cacheBitmapData = null;
			}
		}
		if (!FlxG.signals.gameResized.has(func))
			FlxG.signals.gameResized.add(func);
	}
}