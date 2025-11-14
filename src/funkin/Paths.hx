package funkin;

class Paths
{
	public static inline function game(key:String, ?mod:String)
	{
		return get("game/" + key, mod);
	}

	public static inline function menu(key:String, ?mod:String)
	{
		return get("menu/" + key, mod);
	}

	public static inline function get(key:String, mod:String)
	{
		// try get from requested mod
		if (mod != null && Mods.modsLookup.exists(mod))
		{
			if (mod.exists(key))
				return mod.get(key);
		}

		// global mods
		for (d in Mods.globalMods)
		{
			if (d.exists(key))
				return d.get(key);
		}

		// and last assets
		if (FileSystem.exists("res/" + key))
			return "res/" + key;

		return null;
	}
}