package funkin.game;

import haxe.Json;

class Chart
{
    public var notes:Array<Dynamic> = [];
    public var events:Array<Dynamic> = [];

    public var bpm:Float = 0;

    public function new(){}

    public static function fromFile(file:String, ?meta:Song):Chart
    {
        var chart:Chart = new Chart();

        return chart;
    }
}