package funkin.util;

import sys.FileSystem;
import sys.io.File;

import openfl.display.BitmapData;
import openfl.utils.Assets;
import openfl.media.Sound;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;

@:access(openfl.display.BitmapData)
@:access(flixel.system.frontEnds.BitmapFrontEnd)
@:access(flixel.FlxG)
class FunkinAssets
{
	public static final graphicCache:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();
	public static final soundCache:Map<String, Sound> = new Map<String, Sound>();

	public static inline function exists(id:String)
		return FileSystem.exists(id);

	public static inline function getGraphic(id:String):FlxGraphic
	{
		if (!exists(id))
			return null;
		if (graphicCache.exists(id))
			return graphicCache.get(id);

		var bitmap = BitmapData.fromFile(id);
		if (bitmap.image != null)
		{
			bitmap.lock();
			if (bitmap.__texture == null)
			{
				bitmap.image.premultiplied = true;
				bitmap.getTexture(flixel.FlxG.stage.context3D);
			}
			bitmap.getSurface();
			bitmap.disposeImage();
			bitmap.image.data = null;
			bitmap.image = null;
			bitmap.readable = true;
		}
		var graphic = FlxGraphic.fromBitmapData(bitmap);
		graphic.persist = true;

		graphicCache.set(id, graphic);
		return graphic;
	}

	public static inline function getSound(id:String):Sound
	{
		if (!exists(id))
			return null;
		if (soundCache.exists(id))
			return soundCache.get(id);

		var sound = Sound.fromFile(id);
		soundCache.set(id, sound);
		return sound;
	}

	public static inline function getText(id:String):String
	{
		if (!exists(id))
			return null;
		return File.getContent(id);
	}

	public static inline function getSparrow(id:String):FlxAtlasFrames
	{
		if (!exists(id + ".png"))
			return null;
		return FlxAtlasFrames.fromSparrow(getGraphic(id + ".png"), Xml.parse(getText(id + ".xml")));
	}

	public static inline function clearCache():Void
	{
		for (key => graphic in graphicCache)
		{
			var graph:FlxGraphic = FlxG.bitmap._cache.get(key);
			if (FlxG.bitmap._cache.exists(key))
			{
				if (graph.bitmap?.__texture != null)
					graph.bitmap.__texture.dispose();
				Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
			}
		}
		
		graphicCache.clear();
		soundCache.clear();
	}
}