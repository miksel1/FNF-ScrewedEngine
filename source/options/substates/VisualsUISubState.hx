package options.substates;

import flixel.FlxG;

using StringTools;

class VisualsUISubState extends BaseOptionsMenu
{
	var timeBarOption:Option; // because yes (its just a test)
	var timeBarDivisionsOption:Option;

	public function new()
	{
		title = 'Visuals and UI';
		rpcTitle = 'Visuals & UI Settings Menu'; //for Discord Rich Presence

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
			{s: "What should the Time Bar display?", spanish: '¿Qué debería mostrar la Barra de Tiempo?'},
			'timeBarType',
			'string',
			'Time Left',
			['Time Left', 'Time Elapsed', 'Song Name', 'Elapsed / Total', 'Disabled']);
		timeBarOption.onChange = onChangeTimer;
		addOption(timeBarOption);

		timeBarDivisionsOption = new Option({s: 'Time Bar Divisions', spanish: 'Divisiones de la Barra de Tiempo'},
			{s: 'How many divisions the Time Bar has.\n(CAN CAUSE LAG IF TOO HIGH)', spanish: '¿Cuántas divisiones puede tener la Barra de Tiempo?\n(PUEDE CAUSAR LAG SI ESTÁ MUY ALTO)'},
			'timeBarDivisions',
			'int',
			800);
		timeBarDivisionsOption.minValue = 100;
		timeBarDivisionsOption.changeValue = 50;
		timeBarDivisionsOption.scrollSpeed = 50;
		timeBarDivisionsOption.changeValueShift = 4;
		addOption(timeBarDivisionsOption);

		var option:Option = new Option({s: 'Flashing Lights', spanish: 'Luces Parpadeantes'},
			{s: "Uncheck this if you're sensitive to flashing lights!", spanish: '¡Desactiva esto si eres sensible a las luces parpadeantes!'},
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

		var option:Option = new Option({s: 'Health Bar Transparency', spanish: 'Transparencia de la Barra de Vida'},
			{s: 'How much transparent should the health bar and icons be.', spanish: 'Cuánta transparencia la barra de vida y los iconos deberían tener.'},
			'healthBarAlpha',
			'percent',
			1);
		option.scrollSpeed = 1.6;
		option.minValue = 0.0;
		option.maxValue = 1;
		option.changeValue = 0.1;
		option.decimals = 1;
		addOption(option);

		var option:Option = new Option({s: 'Max Notes in Freeplay', spanish: 'Máximo de notas en Freeplay'},
			{s: 'How much notes can you play?\nThis will determinate the maximum notes a song could have in\nfreeplay selection', spanish: '¿Cuánto es el máximo de notas que puedes tocar?\nEsto determinará un aviso en el menú de "Freeplay" cuando\nla cantidad de notas de la canción exceda este valor.'},
			'maxNotes',
			'int',
			5000);
		option.minValue = 100;
		option.changeValue = 1;
		option.scrollSpeed = 100;
		option.changeValueShift = 4;
		addOption(option);

		#if !mobile
		var option:Option = new Option({s: 'FPS Counter', spanish: 'Mostrar FPS'},
			{s: 'If unchecked, hides FPS Counter.', spanish: 'Si está activado, muestra cuántos FPS hay.'},
			'showFPS',
			'bool',
			true);
		addOption(option);
		option.onChange = onChangeFPSCounter;
		#end

		var option:Option = new Option({s: 'Judgement Counter', spanish: 'Contador de Notas'},
			{s: 'If checked, a counter will apear at the left side with each rating.', spanish: 'Si está activado, un contador con cada puntuación general\naparecerá a la izquierda.'},
			'crazyCounter',
			'bool',
			true);
		addOption(option);

		var option:Option = new Option({s: 'Pause Screen Song:', spanish: 'Música del Menú de Pausa:'},
			{s: "What song do you prefer for the Pause Screen?", spanish: '¿Qué canción prefieres para el Menú de Pausa?'},
			'pauseMusic',
			'string',
			'Tea Time',
			['None', 'Breakfast', 'Tea Time']);
		addOption(option);
		option.onChange = onChangePauseMusic;

		#if CHECK_FOR_UPDATES
		var option:Option = new Option({s: 'Check for Updates', spanish: 'Buscar Actualizaciones'},
			{s: 'On Release builds, turn this ON to check for updates when you start the game.', spanish: 'Si está activado, buscará actualizaciones más recientes\ncuando inicias el juego.'},
			'checkForUpdates',
			'bool',
			true);
		addOption(option);
		#end

		var option:Option = new Option({s: 'Combo Stacking'},
			{s: "If unchecked, Ratings and Combo won't stack, saving on System Memory and making them easier to read", spanish: 'Si está desactivado, el "Rating" y el Combo no se quedarán atascados\nguardándolos en el sistema de memoria y haciéndolos más fácil de leer.'},
			'comboStacking',
			'bool',
			true);
		addOption(option);

		super();
	}

	function onChangeTimer() {
		@:privateAccess {
			if(ClientPrefs.timeBarType == 'Disabled') {
				timeBarDivisionsOption.child.alpha = 0.7;
			} else if(timeBarDivisionsOption.child.alpha == 0.7) {
				timeBarDivisionsOption.child.alpha = 1;
			}
		}
	}

	var changedMusic:Bool = false;
	function onChangePauseMusic()
	{
		if(ClientPrefs.pauseMusic == 'None')
			FlxG.sound.music.volume = 0;
		else
			FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.pauseMusic)));

		changedMusic = true;
	}

	override function destroy()
	{
		if(changedMusic) FlxG.sound.playMusic(Paths.music('freakyMenu'));
		super.destroy();
	}

	#if !mobile
	function onChangeFPSCounter()
	{
		if(Main.fpsVar != null)
			Main.fpsVar.visible = ClientPrefs.showFPS;
	}
	#end
}
