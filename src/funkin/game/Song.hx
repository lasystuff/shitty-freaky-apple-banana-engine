package funkin.game;

import haxe.Json;

class Song
{
    public var id:String = "";
    public var name:String = "";

    public var assets:SongAssets;
    public var difficulties:Array<String>;
    public var variations:Array<String>;

    public var charts:Map<String, Chart> = [];

    public function new(){}

    public static function fromId(id:String, ?variation:String):Song
    {
        var postfix:String = variation != null ? "-" + variation : "";
        var dataPath:String = Paths.get('game/songs/$id/data$postfix.json');
        var instance:Song = variation == null || variation == "default" ? new Song() : Song.fromId(id);

        var json = Json.parse(FunkinAssets.getText(dataPath));

        instance.id = id;
        instance.name = json.name != null ? json.name : id;
        instance.assets = json.assets != null ? ReflectUtil.copyToObject(json.assets, new SongAssets()) : new SongAssets();
        instance.difficulties = json.difficulties != null ? json.difficulties : ["easy", "normal", "hard"];
        instance.variations = json.variations != null ? json.variations : [];

        instance.charts.clear(); // for some cases
        for (difficuly in instance.difficulties)
        {
            var targetFile = 'game/songs/$id/charts/$difficuly-$postfix.json'; // hard-pico.json
            if (!FunkinAssets.exists(targetFile))
                targetFile = 'game/songs/$id/charts/$difficuly.json';
            instance.charts.set(difficuly, Chart.fromFile(targetFile, instance));
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