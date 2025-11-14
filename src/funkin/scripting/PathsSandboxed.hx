package funkin;
// just forces mods variable on get function, that it
class PathsSandboxed
{
    public var modId:String;

    public function new(mod:String)
    {
        this.modId = mod;
    }

    public function game(key:String)
	{
		return Paths.game(key, modId);
	}

	public function menu(key:String)
	{
		return Paths.menu(key, modId);
	}
}