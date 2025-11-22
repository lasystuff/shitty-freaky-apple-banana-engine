package funkin.game.song;

import haxe.Json;
import moonchart.backend.FormatDetector;
import moonchart.formats.fnf.FNFVSlice;

using StringTools;

class Chart
{
    public var bpm:Float;
    public var speed:Float;

    public var player:Array<ChartNote>;
    public var opponent:Array<ChartNote>;
    
    public var events:Array<ChartEvent>;

    // for moonchart maybe
    private var __SHITTYFREAKY_CHART__:Bool = true;

    public function new(){}

    public static function fromFile(file:String, meta:Song, difficulty:String = "normal"):Chart
    {
        var chart:Chart = new Chart();
        var json = Json.parse(FunkinAssets.getText(file));

        if (json.__SHITTYFREAKY_CHART__ != null)
        {
            chart.bpm = json.bpm;
            chart.speed = json.speed ?? 1;
            chart.player = json.player ?? [];
            chart.opponent = json.opponent ?? [];

            chart.events = json.events ?? [];
        }
        else
        {
            // first we convert chart to v-slice chart, then convert it to our own format cuz im too lazy to write format class
            // but it maybe missing some notetypes or event type converts
            var format = FormatDetector.findFromContents(FunkinAssets.getText(file));
            // sorry but fuck you FormatDetector
            if (FunkinAssets.getText(file).contains('"generatedBy":'))
                format = FNF_VSLICE;

            trace("Converting chart from " + format + " format!");

            var vslice:Dynamic;

            switch(format)
            {
                case FNF_VSLICE:
                    vslice = new FNFVSlice().fromFile(file, file.replace(".json", "-metadata.json"), difficulty);
                default:
                    var base = FormatDetector.createFormatInstance(format).fromFile(file, meta._path, difficulty);
                    vslice = new FNFVSlice().fromFormat(base);
            }
            
            chart.bpm = vslice.meta.timeChanges[0].bpm;
            chart.speed = Reflect.field(vslice.data.scrollSpeed, difficulty);

            chart.player = [];
            chart.opponent = [];
            var notes:Array<VSliceNote> = Reflect.field(vslice.data.notes, difficulty);
            for (note in notes)
            {
                var shittyNote:ChartNote = {
                    time: note.t,
                    id: note.d % 4,
                    length: note.l ?? 0,
                    type: note.k ?? ""
                }
                if (note.d > 3)
                    chart.opponent.push(shittyNote);
                else
                    chart.player.push(shittyNote);
            }

            chart.events = [];

            var events:Array<VSliceEvent> = vslice.data.events;
            for (event in events)
            {
                chart.events.push({
                    time: event.t,
                    name: resolveVSliceEvent(event.e, event.v)[0],
                    data: resolveVSliceEvent(event.e, event.v)[1],
                });
            }

            // converting bpm changes
            var timeChanges:Array<VSliceTimeChange> = vslice.meta.timeChanges;
            for (change in timeChanges)
            {
                if (timeChanges.indexOf(change) < 1)
                    continue;
                chart.events.push({
                    time: change.t,
                    name: "Change BPM",
                    data: {bpm: change.bpm},
                });
            }
            
        }

        return chart;
    }

    private static function resolveVSliceEvent(event:String, data:Dynamic):Array<Dynamic>
    {
        switch(event)
        {
            case "FocusCamera":
                return ["Focus Camera", {target: ["bf", "dad", "gf"][data.char]}];
        }
        return [event, data];
    }
}

typedef ChartNote = {
    var time:Float;
    var id:Int;
    var length:Float;
    var type:String;
}

typedef ChartEvent = {
    var time:Float;
    var name:String;
    var data:Dynamic;
}

typedef VSliceNote = {
    var t:Float;
    var d:Int;
    var ?l:Float;
    var ?k:String;
}

typedef VSliceEvent = {
    var t:Float;
    var e:String;
    var ?v:Dynamic;
}

typedef VSliceTimeChange = {
    var t:Float;
    var b:Int;
    var bpm:Float;
}