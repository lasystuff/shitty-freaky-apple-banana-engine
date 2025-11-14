package melt.scripting;

import sys.io.File;
import flixel.util.FlxColor;

import rulescript.RuleScript;
import rulescript.interps.RuleScriptInterp;
import rulescript.parsers.HxParser;

using StringTools;

class HScript
{
    private var rule:RuleScript;
	private var mod:String;

    public function new(path:String, ?parentInstance:Dynamic, ?mod:String){
        rule = new RuleScript(new RuleScriptInterp(), new HxParser());
        rule.scriptName = path;
        // rule.errorHandler = onError;

        rule.getParser(HxParser).allowAll();

		this.mod = mod;
        if (parentInstance != null)
            rule.superInstance = parentInstance;

		var scriptToRun:String = File.getContent(path);

        presetVariables();

        rule.tryExecute(scriptToRun);
    }
	
	function presetVariables()
	{
		if (!Mods.modsLookup.exists(mod) || Mods.modsLookup.get(mod).global)
			rule.setVar("Paths", Paths);
		else
			rule.setVar("Paths", new PathsSandboxed(mod));
	}


    public function callFunc(func:String, ?args:Array<Dynamic>):Dynamic
	{
		if (existsVar(func)) 
		{
			if (args == null)
				args = [];
			try
				return Reflect.callMethod(null, rule.variables.get(func), args);
		}
		return null;
	}

	public function existsVar(variable:String):Bool
	{
		return rule.variables.exists(variable);
	}

	public function getVar(variable:String):Dynamic
	{
		if (rule.variables.exists(variable))
			rule.variables.get(variable);
		return null;
	}

	public function setVar(variable:String, data:Dynamic):Void
	{
		rule.variables.set(variable, data);
	}

    public function stop():Void
    {
        //idk how can i stop them please help me please
        rule.interp = null;
        rule.variables.clear();
    }
}