package;

import flixel.util.FlxAxes;
import flixel.FlxObject;
import flixel.util.FlxSave;
import flixel.FlxG;
import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
#if (flixel >= "5.3.0")
import flixel.sound.FlxSound;
#else
import flixel.system.FlxSound;
#end
#if sys
import sys.io.File;
import sys.FileSystem;
#end

using StringTools;

enum SlideCalcMethod
{
	SIN;
	COS;
}

class CoolUtil
{
	public static final defaultDifficulties:Array<String> = ['Easy', 'Normal', 'Hard'];
	public static final defaultDifficulty:String = 'Normal'; // The chart that has no suffix and starting difficulty on Freeplay/Story Mode

	public static var difficulties:Array<String> = [];

	inline public static function quantize(f:Float, snap:Float)
	{
		// changed so this actually works lol
		var m:Float = Math.fround(f * snap);
		return (m / snap);
	}

	public static function checkSongDifficulty(song:String):Null<String>
	{
		var file = Paths.formatToSongPath(song);

		if (file == null)
			return null;

		if (file.endsWith('-null'))
			return file.replace('-null', '');
		else
			return file;

		return null;
	}

	public static function getDifficultyFilePath(num:Null<Int> = null)
	{
		if (num == null)
			num = PlayState.storyDifficulty;

		var fileSuffix:String = difficulties[num];
		if (fileSuffix != defaultDifficulty)
			fileSuffix = '-' + fileSuffix;
		else
			fileSuffix = '';

		return Paths.formatToSongPath(fileSuffix);
	}

	public static function difficultyString():String
		return difficulties[PlayState.storyDifficulty].toUpperCase();

	inline public static function boundTo(value:Float, min:Float, max:Float):Float
		return Math.max(min, Math.min(max, value));

	inline public static function coolTextFile(path:String):Array<String>
	{
		#if sys
		if(FileSystem.exists(path)) 
			return [for (i in File.getContent(path).trim().split('\n')) i.trim()];
		#else
        if(Assets.exists(path)) 
			return [for (i in Assets.getText(path).trim().split('\n')) i.trim()];
		#end

		return [];
	}

	inline public static function listFromString(string:String):Array<String>
		return string.trim().split('\n').map(str -> str.trim());

	public static function dominantColor(sprite:flixel.FlxSprite):Int
	{
		var countByColor:Map<Int, Int> = [];
		for (col in 0...sprite.frameWidth)
		{
			for (row in 0...sprite.frameHeight)
			{
				var colorOfThisPixel:Int = sprite.pixels.getPixel32(col, row);
				if (colorOfThisPixel != 0)
				{
					if (countByColor.exists(colorOfThisPixel))
						countByColor[colorOfThisPixel] = countByColor[colorOfThisPixel] + 1;
					else if (countByColor[colorOfThisPixel] != 13520687 - (2 * 13520687))
						countByColor[colorOfThisPixel] = 1;
				}
			}
		}
		var maxCount = 0;
		var maxKey:Int = 0; // after the loop this will store the max color
		countByColor[flixel.util.FlxColor.BLACK] = 0;
		for (key in countByColor.keys())
		{
			if (countByColor[key] >= maxCount)
			{
				maxCount = countByColor[key];
				maxKey = key;
			}
		}
		return maxKey;
	}

	inline public static function numberArray(max:Int, ?min = 0):Array<Int>
		return [
			for (i in min...max) 
				i
		];

	// uhhhh does this even work at all? i'm starting to doubt
	public static function precacheSound(sound:String, ?library:String = null):Void
		Paths.sound(sound, library);

	public static function precacheMusic(sound:String, ?library:String = null):Void
		Paths.music(sound, library);

	public static function browserLoad(site:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [site]);
		#else
		FlxG.openURL(site);
		#end
	}

	public static function fancyOpenURL(schmancy:String)
	{
		#if linux
		Sys.command('/usr/bin/xdg-open', [schmancy, "&"]);
		#else
		FlxG.openURL(schmancy);
		#end
	}

	/** Quick Function to Fix Save Files for Flixel 5
		if you are making a mod, you are gonna wanna change "ShadowMario" to something else
		so Base Psych saves won't conflict with yours
		@BeastlyGabi
	**/
	public static function getSavePath(folder:String = 'Wither362'):String
	{
		@:privateAccess
		return #if (flixel < "5.0.0") folder #else FlxG.stage.application.meta.get('company')
			+ '/'
			+ FlxSave.validate(FlxG.stage.application.meta.get('file')) #end;
	}

	public static function floorDecimal(value:Float, decimals:Int):Float
	{
		if(decimals < 1)
			return Math.floor(value);

		var tempMult:Float = 1;
		for (i in 0...decimals)
			tempMult *= 10;

		var newValue:Float = Math.floor(value * tempMult);
		return newValue / tempMult;
	}

	/**
	 * Pablooooooo
	 * @param amplitude 
	 * @param calcMethod 
	 * @param slowness 
	 * @param delayIndex 
	 * @param offset 
	 * @return Float
	 */
	public static function slideEffect(amplitude:Float, calcMethod:SlideCalcMethod, slowness:Float = 1, delayIndex:Float = 0, ?offset:Float):Float
	{
		if (slowness < 0)
			slowness = 1;
		var slider:Float = (FlxG.sound.music.time / 1000) * (Conductor.bpm / 60);

		/*
			while (delayIndex >= 2)
			{
				delayIndex -= 2;
			}
		 */

		var slideValue:Float;

		switch (calcMethod)
		{
			case SIN:
				slideValue = offset + amplitude * Math.sin(((slider + delayIndex) / slowness) * Math.PI);
			case COS:
				slideValue = offset + amplitude * Math.cos(((slider + delayIndex) / slowness) * Math.PI);
		}

		return slideValue;
	}

	public static function objectCenter(object:FlxObject, target:FlxObject, axis:FlxAxes = XY)
	{
		if (axis == XY || axis == X)
			object.x = target.x + target.width / 2 - object.width / 2;
		if (axis == XY || axis == Y)
			object.y = target.y + target.height / 2 - object.height / 2;
	}

	public static function debugTrace(...s:Dynamic)
	{
		#if debug
		trace(s);
		#end
	}
}
