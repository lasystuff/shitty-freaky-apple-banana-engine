package objects;

typedef MenuCharacterFile = {
	var image:String;
	var scale:Float;
	var position:Array<Int>;
	var idle_anim:String;
	var confirm_anim:String;
	var flipX:Bool;
	var antialiasing:Null<Bool>;
}

class MenuCharacter extends FlxSprite
{
	public var character:String;
	public var hasConfirmAnimation:Bool = false;
	private static var DEFAULT_CHARACTER:String = 'bf';

	public function new(x:Float, character:String = 'bf')
	{
		super(x);

		changeCharacter(character);
	}

	public function changeCharacter(?character:String = 'bf') {
		if(character == null) character = '';
		if(character == this.character) return;

		this.character = character;
		visible = true;

		var dontPlayAnim:Bool = false;
		scale.set(1, 1);
		updateHitbox();
		
		color = FlxColor.WHITE;
		alpha = 1;

		hasConfirmAnimation = false;
		switch(character) {
			case '':
				visible = false;
				dontPlayAnim = true;
			default:
				var rawJson:String = Paths.path('images/menucharacters/$character.json');
				if (rawJson == null) {
					rawJson = Paths.path('images/menucharacters/$DEFAULT_CHARACTER.json'); //If a character couldn't be found, change him to BF just to prevent a crash
					color = FlxColor.BLACK;
					alpha = 0.6;
				}

				var charFile:MenuCharacterFile = cast Json.parse(Paths.text(rawJson));
				frames = Paths.getSparrowAtlas('menucharacters/' + charFile.image);
				animation.addByPrefix('idle', charFile.idle_anim, 24);

				var confirmAnim:String = charFile.confirm_anim;
				if(confirmAnim != null && confirmAnim.length > 0 && confirmAnim != charFile.idle_anim)
				{
					animation.addByPrefix('confirm', confirmAnim, 24, false);
					if (animation.getByName('confirm') != null) //check for invalid animation
						hasConfirmAnimation = true;
				}
				flipX = (charFile.flipX == true);

				if(charFile.scale != 1)
				{
					scale.set(charFile.scale, charFile.scale);
					updateHitbox();
				}
				offset.set(charFile.position[0], charFile.position[1]);
				animation.play('idle');

				if (!charFile.antialiasing) antialiasing = false;
		}
	}
}