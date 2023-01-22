package options.substates;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.FlxSubState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxSave;
import haxe.Json;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Controls;

using StringTools;

class GameplaySettingsSubState extends BaseOptionsMenu
{
	public function new()
	{
		title = 'Gameplay Settings';
		rpcTitle = 'Gameplay Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option({s: 'Controller Mode', spanish: 'Mando'},
			{s: 'Check this if you want to play with\na controller instead of using your Keyboard.', spanish: 'Si está activado, podrás jugar con un mando\nen vez de con tu Teclado.'},
			'controllerMode',
			'bool',
			false);
		addOption(option);

		//I'd suggest using "Downscroll" as an example for making your own option since it is the simplest here
		var option:Option = new Option({s: 'Downscroll'}, //Name
			{s: 'If checked, notes go Down instead of Up, simple enough.', spanish: 'Si está activado, las notas irán Hacia Abajo\nen vez de Hacia Arriba.'}, //Description
			'downScroll', //Save data variable name
			'bool', //Variable type
			false); //Default value
		addOption(option);

		var option:Option = new Option({s: 'Middlescroll'},
			{s: 'If checked, your notes get centered.', spanish: 'Si está activado, tus notas estarán centradas.'},
			'middleScroll',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option({s: 'Opponent Notes', spanish: 'Notas del Oponente'},
			{s: 'If unchecked, Opponent notes get hidden.', spanish: 'Si está desactivado, no podrás ver las notas del Oponente.'},
			'opponentStrums',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option({s: 'Ghost Tapping'},
			{s: "If checked, you won't get misses from pressing keys\nwhile there are no notes able to be hit.", spanish: 'Si está desactivado, no podrás "spamear".'},
			'ghostTapping',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option({s: 'Show Health Percent', spanish: 'Enseñar Porcentaje de "Vida"'},
			{s: 'If unchecked, you will not be able to see\nhow many Health you have.', spanish: 'Si está desactivado, no podrás ver tu porcentaje de Vida.'},
			'showHealth',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option({s: 'Disable Reset Button', spanish: 'Desactivar Botón de RESET'},
			{s: "If checked, pressing Reset won't do anything.", spanish: 'Si está activado, cuando pulses el botón de\nRESET no morirás instantáneamente.'},
			'noReset',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option({s: 'Hitsound Volume', spanish: 'Volumen de Hitsounds'},
			{s: 'Funny notes does \"Tick!\" when you hit them.', spanish: 'Divertidas notas hacen "¡Tick!" cuando las tocas.'},
			'hitsoundVolume',
			'percent',
			0);
		addOption(option);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		option.onChange = onChangeHitsoundVolume;

		var option:Option = new Option({s: 'Rating Offset', spanish: 'Offset de "Rating"'},
			{s: 'Changes how late/early you have to hit for a "Sick!"\nHigher values mean you have to hit later.', spanish: 'Cuánto pronto/tarde tienes que pulsar una nota para un "Sick!"\nValores mayores significan TARDE.'},
			'ratingOffset',
			'int',
			0);
		option.displayFormat = '%vms';
		option.scrollSpeed = 20;
		option.minValue = -30;
		option.maxValue = 30;
		addOption(option);

		var option:Option = new Option({s: 'Sick! Hit Window'},
			{s: 'Changes the amount of time you have\nfor hitting a "Sick!" in milliseconds.', spanish: 'Cambia la cantidad de milisegundos que tienen que pasar\npara obtener un "Sick!" al tocar una nota.'},
			'sickWindow',
			'int',
			45);
		option.displayFormat = '%vms';
		option.scrollSpeed = 15;
		option.minValue = 15;
		option.maxValue = 45;
		addOption(option);

		var option:Option = new Option({s: 'Good Hit Window'},
			{s: 'Changes the amount of time you have\nfor hitting a "Good" in milliseconds.', spanish: 'Cambia la cantidad de milisegundos que tienen que pasar\npara obtener un "Good" al tocar una nota.'},
			'goodWindow',
			'int',
			90);
		option.displayFormat = '%vms';
		option.scrollSpeed = 30;
		option.minValue = 15;
		option.maxValue = 90;
		addOption(option);

		var option:Option = new Option({s: 'Bad Hit Window'},
			{s: 'Changes the amount of time you have\nfor hitting a "Bad" in milliseconds.', spanish: 'Cambia la cantidad de milisegundos que tienen que pasar\npara obtener un "Bad" al tocar una nota.'},
			'badWindow',
			'int',
			135);
		option.displayFormat = '%vms';
		option.scrollSpeed = 60;
		option.minValue = 15;
		option.maxValue = 135;
		addOption(option);

		var option:Option = new Option({s: 'Safe Frames'},
			{s: 'Changes how many frames you have for\nhitting a note earlier or late.', spanish: 'Cuántos "frames" tienes para pulsar una nota\npronto o tarde.'},
			'safeFrames',
			'float',
			10);
		option.scrollSpeed = 5;
		option.minValue = 2;
		option.maxValue = 10;
		option.changeValue = 0.1;
		addOption(option);

		super();
	}

	function onChangeHitsoundVolume()
	{
		FlxG.sound.play(Paths.sound('hitsound'), ClientPrefs.hitsoundVolume);
	}
}