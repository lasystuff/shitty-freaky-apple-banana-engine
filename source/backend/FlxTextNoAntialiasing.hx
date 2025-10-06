package backend;

class FlxTextNoAntialiasing extends flixel.text.FlxText {
	/**
	 * Creates a new `FlxText` object at the specified position.
	 *
	 * @param   X              The x position of the text.
	 * @param   Y              The y position of the text.
	 * @param   FieldWidth     The `width` of the text object. Enables `autoSize` if `<= 0`.
	 *                         (`height` is determined automatically).
	 * @param   Text           The actual text you would like to display initially.
	 * @param   Size           The font size for this text object.
	 * @param   EmbeddedFont   Whether this text field uses embedded fonts or not.
	 */
	public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true) {
		super(X, Y, FieldWidth, Text, Size, EmbeddedFont);
		antialiasing = false;
	}
}