package funkin.game.song;

import haxe.Json;

class Song
{
    public var id:String;
    public var name:String;

    public var assets:SongAssets;
    public var difficulties:Array<String>;
    public var variations:Array<String>;

    public var meta:SongMeta;

    public var charts:Map<String, Chart> = [];

    // idk
    public var _path:String;
    public var _postfix:String;

    public function new(){}

    public static function fromId(id:String, ?variation:String):Song
    {
        var instance:Song = variation == null || variation == "default" ? new Song() : Song.fromId(id);
        instance._postfix = variation != null ? "-" + variation : "";
        instance._path = Paths.get('game/songs/$id/data${instance._postfix}.json');

        var json = Json.parse(FunkinAssets.getText(instance._path));

        instance.id = id;
        instance.name = json.name ?? id;
        instance.assets = json.assets != null ? ReflectUtil.copyToObject(json.assets, new SongAssets()) : new SongAssets();
        instance.difficulties = json.difficulties ?? ["easy", "normal", "hard"];
        instance.variations = json.variations ?? [];
        instance.meta = json.meta != null ? ReflectUtil.copyToObject(json.meta, new SongMeta()) : new SongMeta();

        instance.charts.clear(); // for some cases
        for (difficulty in instance.difficulties)
        {
            var targetFile = Paths.get('game/songs/$id/charts/$difficulty-${instance._postfix}.json'); // hard-pico.json
            if (!FunkinAssets.exists(targetFile))
                targetFile = Paths.get('game/songs/$id/charts/$difficulty.json');
            instance.charts.set(difficulty, Chart.fromFile(targetFile, instance, difficulty));
        }

        return instance;
    }
}

class SongAssets
{
    public var player:String = "bf";
    public var opponent:String = "dad";
    public var spectator:String = "gf";

    public var stage:String = "stage";
    public var ui:String = "default";

    public function new(){}
}

class SongMeta
{
    public var artists:String = "Unknown";
    public var charter:String = "Unknown";

    public function new(){}
}