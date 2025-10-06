package psychlua;

class TextFunctions
{
	public static function implementLua(lua:FunkinLua)
	{
		var variables = MusicBeatState.getVariables();
		lua.set("makeLuaText", function(tag:String, ?text:String = '', ?width:Int = 0, ?x:Float = 0, ?y:Float = 0) {
			tag = tag.replace('.', '');

			LuaUtils.destroyObject(tag);
			var leText:FlxText = new FlxText(x, y, width, text, 16);
			leText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			if(PlayState.instance != null) leText.cameras = [PlayState.instance.camHUD];
			leText.scrollFactor.set();
			leText.borderSize = 2;
			variables.set(tag, leText);
		});

		lua.set("setTextString", function(tag:String, text:String) {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null)
			{
				obj.text = text;
				return true;
			}
			lua.debugPrint("setTextString: Object " + tag + " doesn't exist!", FlxColor.RED);
			return false;
		});
		lua.set("setTextSize", function(tag:String, size:Int) {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null)
			{
				obj.size = size;
				return true;
			}
			lua.debugPrint("setTextSize: Object " + tag + " doesn't exist!", FlxColor.RED);
			return false;
		});
		lua.set("setTextWidth", function(tag:String, width:Float) {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null)
			{
				obj.fieldWidth = width;
				return true;
			}
			lua.debugPrint("setTextWidth: Object " + tag + " doesn't exist!", FlxColor.RED);
			return false;
		});
		lua.set("setTextHeight", function(tag:String, height:Float) {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null)
			{
				obj.fieldHeight = height;
				return true;
			}
			lua.debugPrint("setTextHeight: Object " + tag + " doesn't exist!", FlxColor.RED);
			return false;
		});
		lua.set("setTextAutoSize", function(tag:String, value:Bool) {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null)
			{
				obj.autoSize = value;
				return true;
			}
			lua.debugPrint("setTextAutoSize: Object " + tag + " doesn't exist!", FlxColor.RED);
			return false;
		});
		lua.set("setTextBorder", function(tag:String, size:Float, color:String, ?style:String = 'outline') {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null)
			{
				CoolUtil.setTextBorderFromString(obj, (size > 0 ? style : 'none'));
				if(size > 0)
					obj.borderSize = size;
				
				obj.borderColor = CoolUtil.colorFromString(color);
				return true;
			}
			lua.debugPrint("setTextBorder: Object " + tag + " doesn't exist!", FlxColor.RED);
			return false;
		});
		lua.set("setTextColor", function(tag:String, color:String) {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null)
			{
				obj.color = CoolUtil.colorFromString(color);
				return true;
			}
			lua.debugPrint("setTextColor: Object " + tag + " doesn't exist!", FlxColor.RED);
			return false;
		});
		lua.set("setTextFont", function(tag:String, newFont:String) {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null)
			{
				obj.font = Paths.font(newFont);
				return true;
			}
			lua.debugPrint("setTextFont: Object " + tag + " doesn't exist!", FlxColor.RED);
			return false;
		});
		lua.set("setTextItalic", function(tag:String, italic:Bool) {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null)
			{
				obj.italic = italic;
				return true;
			}
			lua.debugPrint("setTextItalic: Object " + tag + " doesn't exist!", FlxColor.RED);
			return false;
		});
		lua.set("setTextAlignment", function(tag:String, alignment:String = 'left') {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null)
			{
				obj.alignment = LEFT;
				switch(alignment.trim().toLowerCase())
				{
					case 'right':
						obj.alignment = RIGHT;
					case 'center':
						obj.alignment = CENTER;
					case 'justify':
						obj.alignment = JUSTIFY;
				}
				return true;
			}
			lua.debugPrint("setTextAlignment: Object " + tag + " doesn't exist!", FlxColor.RED);
			return false;
		});

		lua.set("getTextString", function(tag:String) {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null && obj.text != null)
			{
				return obj.text;
			}
			lua.debugPrint("getTextString: Object " + tag + " doesn't exist!", FlxColor.RED);
			return null;
		});
		lua.set("getTextSize", function(tag:String) {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null)
			{
				return obj.size;
			}
			lua.debugPrint("getTextSize: Object " + tag + " doesn't exist!", FlxColor.RED);
			return -1;
		});
		lua.set("getTextFont", function(tag:String) {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null)
			{
				return obj.font;
			}
			lua.debugPrint("getTextFont: Object " + tag + " doesn't exist!", FlxColor.RED);
			return null;
		});
		lua.set("getTextWidth", function(tag:String) {
			var split:Array<String> = tag.split('.');
			var obj:FlxText = split.length > 1 ? (LuaUtils.getVarInArray(LuaUtils.getPropertyLoop(split), split[split.length-1])) : LuaUtils.getObjectDirectly(split[0]);
			if(obj != null)
			{
				return obj.fieldWidth;
			}
			lua.debugPrint("getTextWidth: Object " + tag + " doesn't exist!", FlxColor.RED);
			return 0;
		});

		lua.set("addLuaText", function(tag:String) {
			var text:FlxText = MusicBeatState.getVariables().get(tag);
			if(text != null) LuaUtils.getTargetInstance().add(text);
		});
		lua.set("removeLuaText", function(tag:String, destroy:Bool = true) {
			var variables = MusicBeatState.getVariables();
			var text:FlxText = variables.get(tag);
			if(text == null) return;

			LuaUtils.getTargetInstance().remove(text, true);
			if(destroy)
			{
				text.destroy();
				variables.remove(tag);
			}
		});
	}
}
