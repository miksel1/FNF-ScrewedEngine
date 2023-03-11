package options.substates;

import flixel.text.FlxText;
import flixel.FlxG;
import flixel.FlxSprite;

class CPUSettingsSubState extends BaseOptionsMenu {
	var timeBarOption:Option; // because yes (its just a test)
	var timeBarDivisionsOption:Option;

	public function new() {
		title = Language.getString({s: 'CPU And Performance Settings', spanish: 'Ajustes de CPU y Rendimiento'});
		rpcTitle = 'CPU And Performance Settings Menu'; //for Discord Rich Presence

		var option:Option = new Option({s: 'Low Quality', spanish: 'Baja Calidad'}, //Name
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

		var option:Option = new Option({s: 'Disable "COMBO" sprite.', spanish: 'Desactivar la imagen de "COMBO".'},
			{s: 'If checked, disables the "COMBO" popping.\nIt can cause lag if unchecked', spanish: 'Si está activado, desactiva el "COMBO" en sprite\nPuede causar bastante lag si está desactivado.'},
			'allowComboSprite',
			'bool',
			false);
		addOption(option);

		var option:Option = new Option({s: 'Disable "NUM COMBO" sprite.', spanish: 'Desactivar imagen del Combo.'},
			{s: 'If checked, disables the number of combo popping.\nIt can cause lag if unchecked', spanish: 'Si está activado, desactiva el número de combo en sprite\nPuede causar bastante lag si está desactivado.'},
			'allowNumcomboSprite',
			'bool',
			false);
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

		var option:Option = new Option({s: 'Note Splashes'},
			{s: "If unchecked, hitting \"Sick!\" notes won't show particles.", spanish: 'Si está desactivado, al hacer "Sick!" no saldrán partículas\nde la nota.'},
			'noteSplashes',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option({s: 'Hide HUD', spanish: 'Ocultar HUD'},
			{s: 'If checked, hides most HUD elements.', spanish: 'Si está activado, oculta la mayoría de los elementos del HUD.'},
			'hideHud',
			'bool',
			false);
		addOption(option);

		timeBarOption = new Option({s: 'Time Bar:', spanish: 'Barra de Tiempo:'},
			{s: "What should the Time Bar display?\n(Select Disabled for less lag)", spanish: '¿Qué debería mostrar la Barra de Tiempo?\n(Disabled si no quieres lag)'},
			'timeBarType',
			'string',
			'Time Left',
			['Time Left', 'Time Elapsed', 'Song Name', 'Elapsed / Total', 'Disabled']);
		timeBarOption.onChange = onChangeTimer;
		addOption(timeBarOption);

		timeBarDivisionsOption = new Option({s: 'Time Bar Divisions', spanish: 'Divisiones de la Barra de Tiempo'},
			{s: 'How many divisions the Time Bar has.\n(CAN CAUSE LAG IF TOO HIGH)', spanish: '¿Cuántas divisiones tiene la Barra de Tiempo?\n(PUEDE CAUSAR LAG SI ESTÁ MUY ALTO)'},
			'timeBarDivisions',
			'int',
			800);
		timeBarDivisionsOption.minValue = 100;
		timeBarDivisionsOption.changeValue = 50;
		timeBarDivisionsOption.scrollSpeed = 50;
		timeBarDivisionsOption.changeValueShift = 4;
		addOption(timeBarDivisionsOption);

		var option:Option = new Option({s: 'Flashing Lights', spanish: 'Luces Parpadeantes'},
			{s: "Uncheck this if you're sensitive to flashing lights!\n(Or if you want less lag)", spanish: '¡Desactiva esto si eres sensible a las luces parpadeantes!\n(O si quieres menos lag...)'},
			'flashing',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option({s: 'Camera Zooms', spanish: 'Zoom de Cámara'},
			{s: "If unchecked, the camera won't zoom in on a beat hit.", spanish: 'Si está desactivado, la cámara no hará zoom en un "beat hit".'},
			'camZooms',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option({s: 'Score Text Zoom on Hit', spanish: 'Zoom del Texto de Puntuación'},
			{s: "If unchecked, disables the Score text zooming\neverytime you hit a note.", spanish: 'Si está desactivado, el texto de puntuación no hará zoom\ncuando pulses una nota.'},
			'scoreZoom',
			'bool',
			true);
		addOption(option);

		super();
	}

	function onChangeAntiAliasing()
	{
		for (sprite in members)
		{
			var sprite:Dynamic = sprite; //Make it check for FlxSprite instead of FlxBasic
			var sprite:FlxSprite = sprite; //Don't judge me ok
			if(sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
				sprite.antialiasing = ClientPrefs.data.globalAntialiasing;
			}
		}
	}

	function onChangeFramerate()
	{
		if(ClientPrefs.data.framerate > FlxG.drawFramerate)
		{
			FlxG.updateFramerate = ClientPrefs.data.framerate;
			FlxG.drawFramerate = ClientPrefs.data.framerate;
		}
		else
		{
			FlxG.drawFramerate = ClientPrefs.data.framerate;
			FlxG.updateFramerate = ClientPrefs.data.framerate;
		}
	}

	function onChangeTimer() {
		@:privateAccess {
			if(ClientPrefs.data.timeBarType == 'Disabled') {
				timeBarDivisionsOption.active = false;
			} else if(!timeBarDivisionsOption.active) {
				timeBarDivisionsOption.active = true;
			}
		}
	}
}