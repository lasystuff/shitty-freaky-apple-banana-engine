package psychlua;

import Type.ValueType;
import haxe.Constraints;
import substates.GameOverSubstate;

//
// Functions that use a high amount of Reflections, which are somewhat CPU intensive
// These functions are held together by duct tape
//

class ReflectionFunctions
{
	static final instanceStr:Dynamic = "##PSYCHLUA_STRINGTOOBJ";
	public static function implementLua(lua:FunkinLua)
	{
		var game = PlayState.instance;
		var variables = MusicBeatState.getVariables();
		lua.set("getProperty", function(variable:String, ?allowMaps:Bool = false) {
			var split:Array<String> = variable.split('.');
			if(split.length > 1)
				return LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split, true, allowMaps), split[split.length-1], allowMaps);
			return LuaUtils.getVarInArray(LuaUtils.getTargetInstance(), variable, allowMaps);
		});
		lua.set("setProperty", function(variable:String, value:Dynamic, ?allowMaps:Bool = false, ?allowInstances:Bool = false) {
			var split:Array<String> = variable.split('.');
			if(split.length > 1) {
				LuaUtils.setVarInArray(LuaUtils.getPropertyLoop(split, true, allowMaps), split[split.length-1], allowInstances ? parseSingleInstance(value) : value, allowMaps);
				return value;
			}
			LuaUtils.setVarInArray(LuaUtils.getTargetInstance(), variable, allowInstances ? parseSingleInstance(value) : value, allowMaps);
			return value;
		});
		lua.set("getPropertyFromClass", function(classVar:String, variable:String, ?allowMaps:Bool = false) {
			var myClass:Dynamic = Type.resolveClass(classVar);
			if(myClass == null)
			{
				lua.debugPrint('getPropertyFromClass: Class $classVar not found', FlxColor.RED);
				return null;
			}

			var split:Array<String> = variable.split('.');
			if(split.length > 1) {
				var obj:Dynamic = LuaUtils.getVarInArray(myClass, split[0], allowMaps);
				for (i in 1...split.length-1)
					obj = LuaUtils.getVarInArray(obj, split[i], allowMaps);

				return LuaUtils.getVarInArray(obj, split[split.length-1], allowMaps);
			}
			return LuaUtils.getVarInArray(myClass, variable, allowMaps);
		});
		lua.set("setPropertyFromClass", function(classVar:String, variable:String, value:Dynamic, ?allowMaps:Bool = false, ?allowInstances:Bool = false) {
			var myClass:Dynamic = Type.resolveClass(classVar);
			if(myClass == null)
			{
				lua.debugPrint('setPropertyFromClass: Class $classVar not found', FlxColor.RED);
				return null;
			}

			var split:Array<String> = variable.split('.');
			if(split.length > 1) {
				var obj:Dynamic = LuaUtils.getVarInArray(myClass, split[0], allowMaps);
				for (i in 1...split.length-1)
					obj = LuaUtils.getVarInArray(obj, split[i], allowMaps);

				LuaUtils.setVarInArray(obj, split[split.length-1], allowInstances ? parseSingleInstance(value) : value, allowMaps);
				return value;
			}
			LuaUtils.setVarInArray(myClass, variable, allowInstances ? parseSingleInstance(value) : value, allowMaps);
			return value;
		});
		lua.set("getPropertyFromGroup", function(group:String, index:Int, variable:Dynamic, ?allowMaps:Bool = false) {
			var split:Array<String> = group.split('.');
			var realObject:Dynamic = null;
			if(split.length > 1)
				realObject = LuaUtils.getPropertyLoop(split, false, allowMaps);
			else
				realObject = Reflect.getProperty(LuaUtils.getTargetInstance(), group);

			var groupOrArray:Dynamic = Reflect.getProperty(LuaUtils.getTargetInstance(), group);
			if(groupOrArray != null)
			{
				switch(Type.typeof(groupOrArray))
				{
					case TClass(Array): //Is Array
						var leArray:Dynamic = realObject[index];
						if(leArray != null) {
							var result:Dynamic = null;
							if(Type.typeof(variable) == ValueType.TInt)
								result = leArray[variable];
							else
								result = LuaUtils.getGroupStuff(leArray, variable, allowMaps);
							return result;
						}
						lua.debugPrint('getPropertyFromGroup: Object #$index from group: $group doesn\'t exist!', FlxColor.RED);

						default: //Is Group
						var result:Dynamic = LuaUtils.getGroupStuff(realObject.members[index], variable, allowMaps);
						return result;
				}
			}
			lua.debugPrint('getPropertyFromGroup: Group/Array $group doesn\'t exist!', FlxColor.RED);
			return null;
		});
		lua.set("setPropertyFromGroup", function(group:String, index:Int, variable:Dynamic, value:Dynamic, ?allowMaps:Bool = false, ?allowInstances:Bool = false) {
			var split:Array<String> = group.split('.');
			var realObject:Dynamic = null;
			if(split.length > 1)
				realObject = LuaUtils.getPropertyLoop(split, false, allowMaps);
			else
				realObject = Reflect.getProperty(LuaUtils.getTargetInstance(), group);

			if(realObject != null)
			{
				switch(Type.typeof(realObject))
				{
					case TClass(Array): //Is Array
						var leArray:Dynamic = realObject[index];
						if(leArray != null)
						{
							if(Type.typeof(variable) == ValueType.TInt)
							{
								leArray[variable] = allowInstances ? parseSingleInstance(value) : value;
								return value;
							}
							LuaUtils.setGroupStuff(leArray, variable, allowInstances ? parseSingleInstance(value) : value, allowMaps);
						}

					default: //Is Group
						LuaUtils.setGroupStuff(realObject.members[index], variable, allowInstances ? parseSingleInstance(value) : value, allowMaps);
				}
			}
			else lua.debugPrint('setPropertyFromGroup: Group/Array $group doesn\'t exist!', FlxColor.RED);
			return value;
		});
		lua.set("addToGroup", function(group:String, tag:String, ?index:Int = -1) {
			var obj:FlxSprite = LuaUtils.getObjectDirectly(tag);
			if(obj == null || obj.destroy == null)
				return lua.debugPrint('addToGroup: Object $tag is not valid!', FlxColor.RED);

			var groupOrArray:Dynamic = Reflect.getProperty(LuaUtils.getTargetInstance(), group);
			if(groupOrArray == null)
				return lua.debugPrint('addToGroup: Group/Array $group is not valid!', FlxColor.RED);
			if(index < 0)
			{
				switch(Type.typeof(groupOrArray))
				{
					case TClass(Array): //Is Array
						groupOrArray.push(obj);
					default: //Is Group
						groupOrArray.add(obj);
				}
			}
			else groupOrArray.insert(index, obj);
		});
		lua.set("removeFromGroup", function(group:String, ?index:Int = -1, ?tag:String = null, ?destroy:Bool = true) {
			var obj:FlxSprite = null;
			if(tag != null)
			{
				obj = LuaUtils.getObjectDirectly(tag);
				if(obj == null || obj.destroy == null)
				{
					lua.debugPrint('removeFromGroup: Object $tag is not valid!', FlxColor.RED);
					return;
				}
			}
			var groupOrArray:Dynamic = Reflect.getProperty(LuaUtils.getTargetInstance(), group);
			if(groupOrArray == null)
			{
				lua.debugPrint('removeFromGroup: Group/Array $group is not valid!', FlxColor.RED);
				return;
			}

			switch(Type.typeof(groupOrArray))
			{
				case TClass(Array): //Is Array
					if(obj != null)
					{
						groupOrArray.remove(obj);
						if(destroy) obj.destroy();
					}
					else groupOrArray.remove(groupOrArray[index]);

				default: //Is Group
					if(obj == null) obj = groupOrArray.members[index];
					groupOrArray.remove(obj, true);
					if(destroy) obj.destroy();
			}
		});
		
		lua.set("callMethod", function(funcToRun:String, ?args:Array<Dynamic> = null) {
			var parent:Dynamic = PlayState.instance;
			var split:Array<String> = funcToRun.split('.');
			var varParent:Dynamic = MusicBeatState.getVariables().get(split[0].trim());
			if(varParent != null)
			{
				split.shift();
				funcToRun = split.join('.').trim();
				parent = varParent;
			}

			if(funcToRun.length > 0)
				return callMethodFromObject(parent, funcToRun, parseInstances(args));
			return Reflect.callMethod(null, parent, parseInstances(args));
		});
		lua.set("callMethodFromClass", function(className:String, funcToRun:String, ?args:Array<Dynamic> = null) {
			return callMethodFromObject(Type.resolveClass(className), funcToRun, parseInstances(args));
		});

		lua.set("createInstance", function(variableToSave:String, className:String, ?args:Array<Dynamic> = null) {
			variableToSave = variableToSave.trim().replace('.', '');
			if(variables.get(variableToSave) == null)
			{
				args ??= [];
				var myType:Dynamic = Type.resolveClass(className);
		
				if(myType == null)
				{
					lua.debugPrint('createInstance: createInstance: Class $className not found', FlxColor.RED);
					return false;
				}

				var obj:Dynamic = Type.createInstance(myType, parseInstances(args));
				if(obj != null)
					variables.set(variableToSave, obj);
				else
					lua.debugPrint('createInstance: Failed to create $variableToSave, arguments are possibly wrong.', FlxColor.RED);

				return (obj != null);
			}
			else lua.debugPrint('createInstance: Variable $variableToSave is already being used and cannot be replaced!', FlxColor.RED);
			return false;
		});
		lua.set("addInstance", function(objectName:String, ?inFront:Bool = false) {
			var savedObj:Dynamic = variables.get(objectName);
			if(savedObj != null)
			{
				var obj:Dynamic = savedObj;
				if (inFront)
					LuaUtils.getTargetInstance().add(obj);
				else
				{
					if(!game.isDead)
						game.insert(game.members.indexOf(LuaUtils.getLowestCharacterGroup()), obj);
					else
						GameOverSubstate.instance.insert(GameOverSubstate.instance.members.indexOf(GameOverSubstate.instance.boyfriend), obj);
				}
			}
			else lua.debugPrint('addInstance: Can\'t add what doesn\'t exist~ ($objectName)', FlxColor.RED);
		});
		lua.set("instanceArg", function(instanceName:String, ?className:String = null) {
			var retStr:String ='$instanceStr::$instanceName';
			if(className != null) retStr += '::$className';
			return retStr;
		});
	}

	static function parseInstances(args:Array<Dynamic>)
	{
		if(args == null) return [];

		for (i in 0...args.length)
		{
			args[i] = parseSingleInstance(args[i]);
		}
		return args;
	}

	public static function parseSingleInstance(arg:Dynamic)
	{
		var argStr:String = cast arg;
		if(argStr != null && argStr.length > instanceStr.length)
		{
			var index:Int = argStr.indexOf('::');
			if(index > -1)
			{
				argStr = argStr.substring(index+2);
				//trace('Op1: $argStr');
				var lastIndex:Int = argStr.lastIndexOf('::');

				var split:Array<String> = (lastIndex > -1) ? argStr.substring(0, lastIndex).split('.') : argStr.split('.');
				arg = (lastIndex > -1) ? Type.resolveClass(argStr.substring(lastIndex+2)) : PlayState.instance;
				for (j in 0...split.length)
				{
					//trace('Op2: ${Type.getClass(args[i])}, ${split[j]}');
					arg = LuaUtils.getVarInArray(arg, split[j].trim());
					//trace('Op3: ${args[i] != null ? Type.getClass(args[i]) : null}');
				}
			}
		}
		return arg;
	}

	static function callMethodFromObject(classObj:Dynamic, funcStr:String, args:Array<Dynamic>)
	{
		var split:Array<String> = funcStr.split('.');
		var funcToRun:Function = null;
		var obj:Dynamic = classObj;
		//trace('start: ' + obj);
		if(obj == null)
		{
			return null;
		}

		for (i in 0...split.length)
		{
			obj = LuaUtils.getVarInArray(obj, split[i].trim());
			//trace(obj, split[i]);
		}

		funcToRun = cast obj;
		//trace('end: $obj');
		return funcToRun != null ? Reflect.callMethod(obj, funcToRun, args) : null;
	}
}