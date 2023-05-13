package options.substates;

import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class GraphicsSettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Graphics';
		rpcTitle = 'Graphics Settings Menu'; //for Discord Rich Presence

		//I'd suggest using "Low Quality" as an example for making your own option since it is the simplest here
		var option:Option = new Option({s: 'Low Quality', spanish: 'Mala Calidad'}, //Name
			{s: 'If checked, disables some background details,\ndecreases loading times and improves performance.', spanish: 'Si está activado, desactiva algunos efectos\nincrementa el rendimiento del juego, haciéndolo más estable.'}, //Description
			'lowQuality', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

		var option:Option = new Option({s: 'Anti-Aliasing'},
			{s: 'If unchecked, disables anti-aliasing, increases performance\nat the cost of sharper visuals.', spanish: 'Si está desactivado, desactiva el "anti-aliasing", incrementa el rendimiento\npor el costo the peores imágenes.'},
			'globalAntialiasing',
			'bool',
			true);
		option.showBoyfriend = true;
		option.onChange = onChangeAntiAliasing; //Changing onChange is only needed if you want to make a special interaction after it changes the value
		addOption(option);

		var option:Option = new Option({s: 'Shaders', spanish: 'Shaders o Efectos de Cámara'}, //Name
			{s: 'If unchecked, disables shaders.\nIt\'s used for some visual effects, and also CPU intensive for weaker PCs.', spanish: 'Si está activado, desactiva efectos de cámara o shaders.\nSon usados para algunos efectos, pero requiere más CPU.'}, //Description
			'shaders', //Save data variable name
			'bool', //Variable type
			true); //Default value
		addOption(option);

		#if !html5 //Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		var option:Option = new Option({s: 'Framerate', spanish: 'FPS'},
			{s: "Pretty self explanatory, isn't it?", spanish: 'Muy explicativo, ¿verdad?'},
			'framerate',
			'int',
			60);
		addOption(option);
		option.minValue = 60;
		option.maxValue = 240;
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;
		#end

		super();
	}

	function onChangeAntiAliasing()
	{
		for (sprite in members)
		{
			var sprite:Dynamic = sprite; //Make it check for FlxSprite instead of FlxBasic
			var sprite:FlxSprite = sprite; //Don't judge me ok
			if(sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
				sprite.antialiasing = ClientPrefs.globalAntialiasing;
			}
		}
	}

	function onChangeFramerate()
	{
		if(ClientPrefs.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = ClientPrefs.framerate;
			FlxG.drawFramerate = ClientPrefs.framerate;
		}
		else
		{
			FlxG.drawFramerate = ClientPrefs.framerate;
			FlxG.updateFramerate = ClientPrefs.framerate;
		}
	}
}