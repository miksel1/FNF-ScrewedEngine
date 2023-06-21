package;

import openfl.display.Window;
import computer.CoolSystemStuff;
import flixel.util.FlxColor;
import MenuCharacter.MenuCharacterFile;
import openfl.utils.Assets;
import Language.LanguageStringArray;
import Language.LanguageString;
import flixel.math.FlxMath;
import flixel.group.FlxGroup;
import openfl.display.Application;
import flixel.tweens.FlxTween;
import flixel.math.FlxRandom;
import openfl.filters.ShaderFilter;
import haxe.ds.Map;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxTimer;
import flash.system.System;
#if (flixel >= "5.3.0")
import flixel.sound.FlxSound;
#else
import flixel.system.FlxSound;
#end
import flixel.FlxG;
#if sys
import sys.io.File;
#end

using StringTools;

class TerminalState extends MusicBeatState
{
	// dont just yoink this code and use it in your own mod. this includes you, psych engine porters.
	// if you ingore this message and use it anyway, atleast give credit. // sorry dudes, i give you credit, ok?
	public var curCommand:String = "";
	public var previousText:String = Language.getString({
		s: 'Vs Dave Developer Console[Version 1.2.00001.1235]\nAll Rights Reserved.\n>',
		spanish: 'Consola de Desarrollo de Vs Dave[Version 1.2.00001.1234]:linebreak:Todos los derechos reservados.:linebreak:>'});
	public var displayText:FlxText;

	public var CommandList:Array<TerminalCommand> = new Array<TerminalCommand>();
	public var typeSound:FlxSound;

	function myGod(s:String):String {
		// replace the linebreaks and bruh before returning!
		s = s.replace(':linebreak:', '\n');
		s = s.replace(':addquote:', '\"');
		return s;
	}

	/**
	 * This is easy, first argument is for NAME, second argument is for THING IT DOES, third argument is for ARGUMENTS FOR THE THING IT DOES
	 * @return Array<Array<String>>
	 */
	function getCharactersTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('terminalCharactersList'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
			swagGoodArray.push(i.split('--'));

		return swagGoodArray;
	}

	var languageStrings:Map<String, LanguageString> = [
		'term_help_ins' => {s: 'Displays this menu.', spanish: 'Muestra este menú.'},
		'term_char_ins' => {s: 'Shows the list of characters.', spanish: 'Muestra la lista de personajes.'},
		'term_admin_ins' => {s: 'Shows the admin list, use grant to grant rights.', spanish: 'Muestra la lista de administradores, usa grant para dar permisos.'},
		'term_admlist_ins' =>
		{s: '\nTo add extra users, add the grant parameter and the name.\n(Example: admin grant girlfriend.dat)\nNOTE: ADDING CHARACTERS AS ADMINS CAN CAUSE UNEXPECTED CHANGES.',
		spanish: ':linebreak:Para añadir usuarios extra, usa el parámetro grant y el nombre.:linebreak:(Ejemplo: admin grant girlfriend.dat):linebreak:NOTA: AÑADIENDO PERSONAJES COMO ADMINS PUEDE CAUSAR CAMBIOS INESPERADOS.'},
		'term_vault_ins' => {s: 'Store valuable files here. Takes 3 key parameters seperated by spaces.'},
		'term_clear_ins' => {s: 'Clears the screen.', spanish: 'Limpia la pantalla.'},
		'term_leak_ins' => {s: 'No providing such leaks.', spanish: 'No daremos dichas filtraciones.'},
		'term_texts_ins' => {s: 'Searches for a text file with the specified ID, and if it exists, display it.', spanish: 'Busca un archivo de texto con el ID especificado y si existe, lo muestra.'},
		// Errors and argument outputs //
		'term_loading' => {s: '\nLoading...', spanish: '\nCargando...'},
		'term_unknown' => {s: '\nUnknown command \"', spanish: '\nComando desconocido \"'},
		'term_admin_error1' => {s: '\nNo version of the \"admin\" command takes', spanish: '\nNinguna versión del comando \"admin\" toma'},
		'term_admin_error2' => {s: ' parameter(s).', spanish: ' parámetro(s)'},
		'term_grant_error1' => {s: ' is not a valid user or character.'},
		'term_miksel_error' => {s: "\nyou know what? im gonna close the game so you can watch my channel..."},
		'term_moldy_error' => {s: "\nyou know what? im gonna close the game so you can watch my baldi's basics playthrough..."},
		'term_wither_error' => {s: "Did you just let a hacker into your computer?\nYou'll need some help...\nBUT YOU CAN'T\nHAHAHAHAHAHAHA", spanish: "Acabas de dejar que un hacker entre en tu ordenador?\nNecesitarás algo de ayuda...\nPERO NO PODRÁS\nHAHAHAHAHAHAHA"}
	];

	// [BAD PERSON] was too lazy to finish this lol.
	var unformattedSymbols:Array<String> = [
		"period", "backslash", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "zero", "shift", "semicolon", "alt", "lbracket",
		"rbracket", "comma", "plus"
	];

	var formattedSymbols:Array<String> = [
		".", "/", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "", ";", "", "[", "]", ",", "="
	];

	var witherThings:Map<String, Dynamic> = [];

	override public function create():Void
	{
		ClientPrefs.showFPS = false;
		PlayState.isStoryMode = false;
		displayText = new FlxText(0, 0, FlxG.width, previousText, 32);
		displayText.setFormat(Paths.font("fixedsys.ttf"), 16);
		displayText.size *= 2;
		displayText.antialiasing = false;
		typeSound = FlxG.sound.load(Paths.sound('terminal_space'), 0.6);
		witherThings.set('sound', FlxG.sound.load(Paths.sound('wither_fade_in')));
		witherThings.set('soundLength', witherThings.get('sound').length);

		CommandList.push(new TerminalCommand("help", Language.getString(languageStrings.get("term_help_ins")), function(arguments:Array<String>)
		{
			UpdatePreviousText(false); // resets the text
			var helpText:String = "";
			for (v in CommandList)
			{
				if (v.showInHelp)
					helpText += (v.commandName + " - " + v.commandHelp + "\n");
			}
			UpdateText("\n" + helpText);
		}));

		CommandList.push(new TerminalCommand("characters", Language.getString(languageStrings.get("term_char_ins")), function(arguments:Array<String>)
		{
			UpdatePreviousText(false); // resets the text
			var texts:String = '';
			for (firstArray in getCharactersTextShit()) {
				texts += '\n' + firstArray[0];
			}
			UpdateText('\n' + texts);
		}));
		CommandList.push(new TerminalCommand("admin", Language.getString(languageStrings.get("term_admin_ins")), function(arguments:Array<String>)
		{
			if (arguments.length == 0)
			{
				UpdatePreviousText(false); // resets the text
				UpdateText("\n"
					+ /*(!FlxG.save.data.selfAwareness ? CoolSystemStuff.getUsername() : 'User354378')
						+ */ Language.getString(languageStrings.get("term_admlist_ins")));
				return;
			}
			else if (arguments.length != 2)
			{
				UpdatePreviousText(false); // resets the text
				UpdateText(Language.getString(languageStrings.get("term_admin_error1"))
					+ " "
					+ arguments.length
					+ Language.getString(languageStrings.get("term_admin_error2")));
			}
			else
			{
				if (arguments[0] == "grant")
				{
					function playSong(song:String = 'tutorial', difficulty:Int = 0, ?etc:Void->Void) {
						var score = Highscore.formatSong(song, difficulty);
						PlayState.SONG = Song.loadFromJson(score, song);
						if(etc != null) etc();
						ClientPrefs.showFPS = FlxG.save.data.showFPS;
						LoadingState.loadAndSwitchState(new PlayState());
					}

					var names:Array<String> = [];
					var charactersActions:Map<String, String> = [];
					var charactersArguments:Map<String, Array<String>> = [];

					names.push('moldy.dat');
					names.push('miksel.dat');
					names.push('wither.dat');

					for (firstArray in getCharactersTextShit()) {
						trace('name: ' + firstArray[0]);
						names.push(firstArray[0]);

						trace('thing: ' + firstArray[1]);
						charactersActions.set(firstArray[0], firstArray[1]);

						trace('thing arguments: ' + firstArray[2]);
						charactersArguments.set(firstArray[0], firstArray[2].replace('\n', '').split(','));
					}

					var done:Bool = false;
					for (characterName in names) {
						if(done)
							break;

						if(arguments[1] == characterName) {
							UpdatePreviousText(false); // resets the text
							switch(characterName) {
								case 'moldy.dat':
									done = true;
									UpdateText(Language.getString(languageStrings.get("term_moldy_error")));
									new FlxTimer().start(2, function(timer:FlxTimer)
									{
										CoolUtil.fancyOpenURL("https://www.youtube.com/watch?v=azMGySH8fK8");
										System.exit(0);
									});
									done = true;
									break;
								case 'miksel.dat':
									UpdateText(Language.getString(languageStrings.get("term_miksel_error")));
									new FlxTimer().start(2, function(timer:FlxTimer)
									{
										CoolUtil.fancyOpenURL("https://www.youtube.com/@miksel_fnf");
										System.exit(0);
									});
									done = true;
									break;
								case 'wither.dat':
									trace('wither reign starts...');
									UpdatePreviousText(false); // resets the text
									//UpdateText("\n" + arguments[1] + Language.getString(languageStrings.get("term_grant_error1")));
									new FlxTimer().start(2, function(tmr:FlxTimer)
									{
										var textos = Language.getString(languageStrings.get('term_wither_error')).split('\n');
										UpdateText(textos[0]);
										done = true;
										new FlxTimer().start(3, function(tmr:FlxTimer)
										{
											UpdateText(textos[1]);
											new FlxTimer().start(1.5, function(tmr:FlxTimer)
											{
												UpdateText(textos[2]);
												new FlxTimer().start(0.6, function(tmr:FlxTimer)
												{
													UpdateText(textos[3]);
													new FlxTimer().start(0.3, function(tmr:FlxTimer)
													{
														FlxG.camera.shake(0.01, 2); // , function() {
														var soundLength:Float = witherThings.get('soundLength');
														var timerLength:Float = soundLength * 7;
														{
															FlxG.sound.volume = 1;
															FlxG.camera.fade(FlxColor.WHITE, 1, false, function()
															{
																//FlxG.camera.fade(FlxColor.BLACK, soundLength / 2);
															});
															new FlxTimer().start(timerLength, function(tmr:FlxTimer)
															{
																FlxG.sound.play(Paths.sound('wither_fade_in'), 1, false, null, true);
															});
														}
														// });
													});
												});
											});
										});
									});

								default:
									if(charactersActions.exists(characterName)) {
										var newArguments:Array<String> = [];
										if(charactersArguments.exists(characterName)) { // just in case...
											for(arg in charactersArguments.get(characterName)) {
												newArguments.push(arg);
											}
										}

										UpdateText(Language.getString(languageStrings.get("term_loading")));
										switch(charactersActions.get(characterName).toLowerCase()
											.replace(' moldyIsTheBest ', '')
											.replace('moldyIsTheBest ', '')
											.replace(' moldyIsTheBest', '')
											.replace('moldyIsTheBest', ''))
										{
											case 'song':
												playSong(Paths.formatToSongPath(newArguments[0]), Std.parseInt(newArguments[1]));
											case 'openurl':
												CoolUtil.fancyOpenURL(newArguments[0]);
											case 'openurl and explode':
												new FlxTimer().start(Std.parseFloat(newArguments[1]), function(tmr:FlxTimer) {
													CoolUtil.fancyOpenURL(newArguments[0]);
													System.exit(0);
												});
										}
										trace('to do: (' + charactersActions.get(characterName) + ') arguments: (' + newArguments + ')');
									}
									done = true;
									break;
							}
						}
					}
					if(!done) {
						UpdatePreviousText(false); // resets the text
						UpdateText("\n" + arguments[1] + Language.getString(languageStrings.get("term_grant_error1")));
					}
				}
				else
				{
					UpdateText("\nInvalid Parameter"); // todo: translate.
				}
			}
		}));
		CommandList.push(new TerminalCommand("clear", Language.getString(languageStrings.get("term_clear_ins")), function(arguments:Array<String>)
		{
			previousText = "> ";
			displayText.y = 0;
			UpdateText("");
		}));
		CommandList.push(new TerminalCommand("open", Language.getString(languageStrings.get("term_texts_ins")), function(arguments:Array<String>)
		{
			UpdatePreviousText(false); // resets the text
			var tx = "";
			switch (arguments[0].toLowerCase())
			{
				default:
					tx = "File not found.";
			}
			// case sensitive!!
			switch (arguments[0])
			{
				default:
					tx = "File not found.";
			}
			UpdateText("\n" + tx);
		}));
		/*CommandList.push(new TerminalCommand("secret mod leak", Language.getString(languageStrings.get("term_leak_ins")), function(arguments:Array<String>)
			{
				MathGameState.accessThroughTerminal = true;
				FlxG.switchState(new MathGameState());
		}, false, true));*/

		add(displayText);

		super.create();
	}

	inline public function UpdateText(val:String)
		displayText.text = previousText + val;

	public function UpdatePreviousText(reset:Bool)
	{
		previousText = displayText.text + (reset ? "\n> " : "");
		displayText.text = previousText;
		curCommand = "";
		var finalthing:String = "";
		var splits:Array<String> = displayText.text.split("\n");
		if (splits.length <= 22)
		{
			return;
		}
		var split_end:Int = Math.round(Math.max(splits.length - 22, 0));
		for (i in split_end...splits.length)
		{
			var split:String = splits[i];
			if (split == "")
			{
				finalthing = finalthing + "\n";
			}
			else
			{
				finalthing = finalthing + split + (i < (splits.length - 1) ? "\n" : "");
			}
		}
		previousText = finalthing;
		displayText.text = finalthing;
		if (displayText.height > 720)
			displayText.y = 720 - displayText.height;
	}

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		var keyJustPressed:FlxKey = cast(FlxG.keys.firstJustPressed(), FlxKey);

		if (keyJustPressed == FlxKey.ENTER)
		{
			var calledFunc:Bool = false;
			var arguments:Array<String> = curCommand.split(" ");
			for (v in CommandList)
			{
				if (v.commandName == arguments[0]
					|| (v.commandName == curCommand && v.oneCommand)) // argument 0 should be the actual command at the moment
				{
					arguments.shift();
					calledFunc = true;
					v.funcToCall(arguments);
					break;
				}
			}
			if (!calledFunc)
			{
				UpdatePreviousText(false); // resets the text
				UpdateText(Language.getString(languageStrings.get("term_unknown")) + arguments[0] + "\"");
			}
			UpdatePreviousText(true);
			return;
		}

		if (keyJustPressed != FlxKey.NONE)
		{
			if (keyJustPressed == FlxKey.BACKSPACE)
			{
				curCommand = curCommand.substr(0, curCommand.length - 1);
				typeSound.play();
			}
			else if (keyJustPressed == FlxKey.SPACE)
			{
				curCommand += " ";
				typeSound.play();
			}
			else
			{
				var toShow:String = keyJustPressed.toString().toLowerCase();
				for (i in 0...unformattedSymbols.length)
				{
					if (toShow == unformattedSymbols[i])
					{
						toShow = formattedSymbols[i];
						break;
					}
				}
				if (FlxG.keys.pressed.SHIFT)
				{
					toShow = toShow.toUpperCase();
				}
				curCommand += toShow;
				typeSound.play();
			}
			UpdateText(curCommand);
		}
		if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.BACKSPACE)
			curCommand = "";

		if (FlxG.keys.justPressed.ESCAPE)
		{
			ClientPrefs.showFPS = FlxG.save.data.showFPS;
			FlxG.switchState(new MainMenuState());
		}
	}
}

class TerminalCommand
{
	public var commandName:String = "undefined";
	public var commandHelp:String = "if you see this you are very homosexual and dumb."; // hey im not homosexual. kinda mean ngl
	public var funcToCall:Dynamic;
	public var showInHelp:Bool;
	public var oneCommand:Bool;

	public function new(name:String, help:String, func:Dynamic, showInHelp = true, oneCommand:Bool = false)
	{
		commandName = name;
		commandHelp = help;
		funcToCall = func;
		this.showInHelp = showInHelp;
		this.oneCommand = oneCommand;
	}
}
