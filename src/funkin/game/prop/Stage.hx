package funkin.game.prop;

import flixel.FlxSprite;
import flixel.group.FlxGroup;

using StringTools;

class Stage extends FlxGroup
{
    public var id:String;

    public var zoom:Float;
    public var props:Map<String, JsonProp> = [];

    public var foreground:FlxGroup = new FlxGroup();

    public function new(id:String):Void
    {
        super();

        this.id = id;
        if (!FunkinAssets.exists(Paths.get('game/stages/$id/data.json')))
            this.id = "stage";

        var data:StageData = haxe.Json.parse(FunkinAssets.getText(Paths.get('game/stages/$id/data.json')));
        
        this.zoom = data.zoom ?? 1;
        
        for (prop in data.props)
        {
            var propObj = JsonProp.create(prop, this.id);
            props.set(prop.id, propObj);
            if (prop.foreground ?? false)
                foreground.add(propObj);
            else
                add(propObj);
        }
    }

    public function getAsset(key:String)
        return Paths.get('game/stages/$id/assets/$key');
}

typedef StageData = {
    var zoom:Float;
    var props:Array<PropData>;
    var characters:CharacterPropAccess;
}

typedef PropData = {
    var id:String;
    var ?path:String;
    var position:Array<Float>;
    var ?scrollFactor:Array<Float>;
    var ?foreground:Bool;
    var ?blend:String;
}

typedef CharacterPropAccess = {
    var player:CharacterPropData;
    var opponent:CharacterPropData;
    var spectator:CharacterPropData;
}

typedef CharacterPropData = {
    var position:Array<Float>;
    var cameraOffset:Array<Float>;
}

class JsonProp extends FlxSprite
{
    public static function create(data:Dynamic, stageID:String):JsonProp
    {
        var prop:JsonProp = new JsonProp();
        prop.setPosition(data.position[0], data.position[1]);

        if (data.path != null)
        {
            // if (FunkinAssets.exists(getAsset(path.replace(".png", ".xml"))))
            trace(getAsset(data.path + ".png", stageID));
            prop.loadGraphic(FunkinAssets.getGraphic(getAsset(data.path + ".png", stageID)));
        }
        prop.updateHitbox();
        if (data.scrollFactor != null) prop.scrollFactor.set(data.scrollFactor[0], data.scrollFactor[1]);

        return prop;
    }

    public static function getAsset(key:String, stageID:String)
        return Paths.get('game/stages/$stageID/assets/$key');
}