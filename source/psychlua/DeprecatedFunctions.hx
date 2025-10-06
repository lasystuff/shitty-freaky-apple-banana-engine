package psychlua;

//
// This is simply where i store deprecated functions for it to be more organized.
// I would suggest not messing with these, as it could break mods.
//

class DeprecatedFunctions
{
	public static function implementLua(lua:FunkinLua)
	{
		inline function debugPrint(text:String, color:FlxColor = FlxColor.YELLOW) lua.debugPrint(text, color, false, true);

		var game = PlayState.instance;
		var variables = MusicBeatState.getVariables();
		// DEPRECATED, DONT MESS WITH THESE SHITS, ITS JUST THERE FOR BACKWARD COMPATIBILITY
		lua.set("addAnimationByIndicesLoop", function(obj:String, name:String, prefix:String, indices:String, framerate:Int = 24) {
			debugPrint("addAnimationByIndicesLoop is deprecated! Use addAnimationByIndices instead");
			return LuaUtils.addAnimByIndices(obj, name, prefix, indices, framerate, true);
		});

		lua.set("objectPlayAnimation", function(obj:String, name:String, forced:Bool = false, ?startFrame:Int = 0) {
			debugPrint("objectPlayAnimation is deprecated! Use playAnim instead");
			var luaObj = PlayState.instance.getLuaObject(obj);
			if(luaObj != null) {
				luaObj.animation.play(name, forced, false, startFrame);
				return true;
			}

			var spr:FlxSprite = Reflect.getProperty(LuaUtils.getTargetInstance(), obj);
			if(spr != null) {
				spr.animation.play(name, forced, false, startFrame);
				return true;
			}
			return false;
		});
		lua.set("characterPlayAnim", function(character:String, anim:String, ?forced:Bool = false) {
			debugPrint("characterPlayAnim is deprecated! Use playAnim instead");
			switch(character.toLowerCase()) {
				case 'dad':
					if(game.dad.hasAnimation(anim))
						game.dad.playAnim(anim, forced);
				case 'gf' | 'girlfriend':
					if(game.gf != null && game.gf.hasAnimation(anim))
						game.gf.playAnim(anim, forced);
				default:
					if(game.boyfriend.hasAnimation(anim))
						game.boyfriend.playAnim(anim, forced);
			}
		});
		lua.set("luaSpriteMakeGraphic", function(tag:String, width:Int, height:Int, color:String) {
			debugPrint("luaSpriteMakeGraphic is deprecated! Use makeGraphic instead");
			if(variables.exists(tag))
				variables.get(tag).makeGraphic(width, height, CoolUtil.colorFromString(color));
		});
		lua.set("luaSpriteAddAnimationByPrefix", function(tag:String, name:String, prefix:String, framerate:Int = 24, loop:Bool = true) {
			debugPrint("luaSpriteAddAnimationByPrefix is deprecated! Use addAnimationByPrefix instead");
			if(variables.exists(tag)) {
				var cock:ModchartSprite = variables.get(tag);
				cock.animation.addByPrefix(name, prefix, framerate, loop);
				if(cock.animation.curAnim == null) {
					cock.animation.play(name, true);
				}
			}
		});
		lua.set("luaSpriteAddAnimationByIndices", function(tag:String, name:String, prefix:String, indices:String, framerate:Int = 24) {
			debugPrint("luaSpriteAddAnimationByIndices is deprecated! Use addAnimationByIndices instead");
			if(variables.exists(tag)) {
				var strIndices:Array<String> = indices.trim().split(',');
				var die:Array<Int> = [];
				for (i in 0...strIndices.length) {
					die.push(Std.parseInt(strIndices[i]));
				}
				var pussy:ModchartSprite = variables.get(tag);
				pussy.animation.addByIndices(name, prefix, die, '', framerate, false);
				if(pussy.animation.curAnim == null) {
					pussy.animation.play(name, true);
				}
			}
		});
		lua.set("luaSpritePlayAnimation", function(tag:String, name:String, forced:Bool = false) {
			debugPrint("luaSpritePlayAnimation is deprecated! Use playAnim instead");
			if(variables.exists(tag)) {
				variables.get(tag).animation.play(name, forced);
			}
		});
		lua.set("setLuaSpriteCamera", function(tag:String, camera:String = '') {
			lua.debugPrint("setLuaSpriteCamera is deprecated! Use setObjectCamera instead");
			if(variables.exists(tag)) {
				variables.get(tag).cameras = [LuaUtils.cameraFromString(camera)];
				return true;
			}
			debugPrint("Lua sprite with tag: " + tag + " doesn't exist!");
			return false;
		});
		lua.set("setLuaSpriteScrollFactor", function(tag:String, scrollX:Float, scrollY:Float) {
			debugPrint("setLuaSpriteScrollFactor is deprecated! Use setScrollFactor instead");
			if(variables.exists(tag)) {
				variables.get(tag).scrollFactor.set(scrollX, scrollY);
				return true;
			}
			return false;
		});
		lua.set("scaleLuaSprite", function(tag:String, x:Float, y:Float) {
			debugPrint("scaleLuaSprite is deprecated! Use scaleObject instead");
			if(variables.exists(tag)) {
				var shit:ModchartSprite = variables.get(tag);
				shit.scale.set(x, y);
				shit.updateHitbox();
				return true;
			}
			return false;
		});
		lua.set("getPropertyLuaSprite", function(tag:String, variable:String) {
			debugPrint("getPropertyLuaSprite is deprecated! Use getProperty instead");
			if(variables.exists(tag)) {
				var killMe:Array<String> = variable.split('.');
				if(killMe.length > 1) {
					var coverMeInPiss:Dynamic = Reflect.getProperty(variables.get(tag), killMe[0]);
					for (i in 1...killMe.length-1) {
						coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
					}
					return Reflect.getProperty(coverMeInPiss, killMe[killMe.length-1]);
				}
				return Reflect.getProperty(variables.get(tag), variable);
			}
			return null;
		});
		lua.set("setPropertyLuaSprite", function(tag:String, variable:String, value:Dynamic) {
			debugPrint("setPropertyLuaSprite is deprecated! Use setProperty instead");
			if(variables.exists(tag)) {
				var killMe:Array<String> = variable.split('.');
				if(killMe.length > 1) {
					var coverMeInPiss:Dynamic = Reflect.getProperty(variables.get(tag), killMe[0]);
					for (i in 1...killMe.length-1) {
						coverMeInPiss = Reflect.getProperty(coverMeInPiss, killMe[i]);
					}
					Reflect.setProperty(coverMeInPiss, killMe[killMe.length-1], value);
					return true;
				}
				Reflect.setProperty(variables.get(tag), variable, value);
				return true;
			}
			debugPrint("setPropertyLuaSprite: Lua sprite with tag: " + tag + " doesn't exist!");
			return false;
		});
		lua.set("musicFadeIn", function(duration:Float, fromValue:Float = 0, toValue:Float = 1) {
			FlxG.sound.music.fadeIn(duration, fromValue, toValue);
			debugPrint('musicFadeIn is deprecated! Use soundFadeIn instead.');

		});
		lua.set("musicFadeOut", function(duration:Float, toValue:Float = 0) {
			FlxG.sound.music.fadeOut(duration, toValue);
			debugPrint('musicFadeOut is deprecated! Use soundFadeOut instead.');
		});
		lua.set("updateHitboxFromGroup", function(group:String, index:Int) {
			if(Std.isOfType(Reflect.getProperty(LuaUtils.getTargetInstance(), group), FlxTypedGroup)) {
				Reflect.getProperty(LuaUtils.getTargetInstance(), group).members[index].updateHitbox();
				return;
			}
			Reflect.getProperty(LuaUtils.getTargetInstance(), group)[index].updateHitbox();
			debugPrint('updateHitboxFromGroup is deprecated! Use updateHitbox instead.');
		});
	}
}