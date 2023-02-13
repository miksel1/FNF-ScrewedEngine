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
import flixel.*;
import flixel.util.FlxTimer;
import flash.system.System;
import flixel.system.FlxSound;
#if sys
import sys.io.File;
#end

using StringTools;

import PlayState; // why the hell did this work LMAO.

class TerminalState extends MusicBeatState
{
	// dont just yoink this code and use it in your own mod. this includes you, psych engine porters.
	// if you ingore this message and use it anyway, atleast give credit. // sorry dudes, i give you credit, ok?
	public var curCommand:String = "";
	public var previousText:String = Language.getString({
		s: 'Vs Dave Developer Console[Version 1.2.00001.1235]\nAll Rights Reserved.\n>',
		spanish: 'Consola de Desarrollo de Vs Dave[Version 1.2.00001.1234]:linebreak:Todos los derechos reservados.:linebreak:>'});
	public var displayText:FlxText;

	var expungedActivated:Bool = false;

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
		{
			swagGoodArray.push(i.split('--'));
		}

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

	public var fakeDisplayGroup:FlxTypedGroup<FlxText> = new FlxTypedGroup<FlxText>();
	public var expungedTimer:FlxTimer;

	var curExpungedAlpha:Float = 0;

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
		//FlxG.sound.playMusic(Paths.music('TheAmbience'), 0.7);

		CommandList.push(new TerminalCommand("help", Language.getString(languageStrings.get("term_help_ins")), function(arguments:Array<String>)
		{
			UpdatePreviousText(false); // resets the text
			var helpText:String = "";
			for (v in CommandList)
			{
				if (v.showInHelp)
				{
					helpText += (v.commandName + " - " + v.commandHelp + "\n");
				}
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
						var score:String = Highscore.formatSong(song, difficulty);
						PlayState.SONG = Song.loadFromJson(song, score);
						PlayState.SONG.validScore = false;
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
																FlxG.sound.play(Paths.sound('wither_fade_in'), 1, false, null, true, function()
																{
																});
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
												playSong(newArguments[0], Std.parseInt(newArguments[1]));
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
					/*
					switch (arguments[1])
					{
						default:
							UpdatePreviousText(false); // resets the text
							UpdateText("\n" + arguments[1] + Language.getString(languageStrings.get("term_grant_error1")));
						case "dave.dat":
							UpdatePreviousText(false); // resets the text
							UpdateText(Language.getString(languageStrings.get("term_loading")));
							//PlayState.globalFunny = CharacterFunnyEffect.Dave;
							play('house');
						case "tristan.dat":
							UpdatePreviousText(false); // resets the text
							UpdateText(Language.getString(languageStrings.get("term_loading")));
							//PlayState.globalFunny = CharacterFunnyEffect.Tristan;
							play('house');
						case "exbungo.dat":
							UpdatePreviousText(false); // resets the text
							UpdateText(Language.getString(languageStrings.get("term_loading")));
							//PlayState.globalFunny = CharacterFunnyEffect.Exbungo;
							var funny:Array<String> = ["house", "insanity", "polygonized", "five-nights", "splitathon", "shredder"];
							var funnylol:Int = FlxG.random.int(0, funny.length - 1);
							play(funny[funnylol], function() {
								PlayState.SONG.player2 = 'exbungo';
							});
						case "bambi.dat":
							UpdatePreviousText(false); // resets the text
							UpdateText(Language.getString(languageStrings.get("term_loading")));
							//PlayState.globalFunny = CharacterFunnyEffect.Bambi;
							play('shredder');
						case "recurser.dat":
							UpdatePreviousText(false); // resets the text
							UpdateText(Language.getString(languageStrings.get("term_loading")));
							//PlayState.globalFunny = CharacterFunnyEffect.Recurser;
							play('polygonized', function() {
								PlayState.SONG.stage = "house-night";
								PlayState.SONG.player2 = 'dave-annoyed';
							});
						case "expunged.dat":
							UpdatePreviousText(false); // resets the text
							UpdateText(Language.getString(languageStrings.get("term_loading")));
							expungedActivated = true;
							new FlxTimer().start(3, function(timer:FlxTimer)
							{
								expungedReignStarts();
							});
						case "moldy.dat":
							UpdatePreviousText(false); // resets the text
							UpdateText(Language.getString(languageStrings.get("term_moldy_error")));
							new FlxTimer().start(2, function(timer:FlxTimer)
							{
								CoolUtil.fancyOpenURL("https://www.youtube.com/watch?v=azMGySH8fK8");
								System.exit(0);
							});
					}
					*/
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
				case "dave":
					tx = "Forever lost and adrift.\nTrying to change his destiny.\nDespite this, it pulls him by a lead.\nIt doesn't matter to him though.\nHe has a child to feed.";
				case "bambi":
					tx = "A forgotten GOD.\nThe truth will never be known.\nThe extent of his POWERs won't ever unfold.";
				case "god" | "artifact1":
					tx = "Artifact 1:\nA stone with symbols and writing carved into it.\nDescription:Its a figure that has hundreds of EYEs all across its body.\nNotes: Why does it look so much like Bambi?";
				case "eye":
					tx = "Our LORD told us that he would remove one of his eyes everyday.\nHe tells me that he's doing this to save us.\nThat he might one day become unreasonable and we need to have faith in ourselves.\n...\nPlease, I promise you that's what he said. I-I'm not lying.\nDon't hurt me.";
				case "lord":
					tx = "A being of many eyes. A being so wise. He gives it all up to ensure, that the golden one will have a bright future.";
				case "artifact2":
					tx = "Artifact 2:\nAn almost entirely destroyed red robe.\nDescription: A red robe. \nIt has a symbol that resembles Bambi's hat, etched on it.";
				case "artifact3":
					tx = "Artifact 3:\nA notebook, found on the floor of the 3D realm.\nNotes: I haven't bothered with the cypher yet.\nI have more important matters.";
				case "artifact4":
					tx = "\"Artifact\" 4:\nA weird email, with attached images that use the same cypher as Artifact 3.\nNotes: Who sent this?";
				case "tristan":
					tx = "The key to defeating the one whose name shall not be stated.\nA heart of gold that will never become faded.";
				case "expunged":
					tx = "[FILE DELETED]\n[FUCK YOU!]"; // [THIS AND EXBUNGOS FILE ARE THE ONLY ONES I HAVE ACCESS TO UNFORTUNATELY. I HATE IT]
				case "deleted":
					tx = "The unnamable never was a god and never will be. Just an accident.";
				case "exbungo":
					tx = "[FAT AND UGLY.]";
				case "recurser":
					tx = "A being of chaos that wants to spread ORDER.\nDespite this, his sanity is at the border.";
				case "moldy":
					tx = "Let me show you my DS family!";
				case "1":
					tx = "LOG 1\nHello. I'm currently writing this from in my lab.\nThis entry will probably be short.\nTristan is only 3 and will wake up soon.\nBut this is mostly just to test things. Bye.";
				case "2":
					tx = "LOG 2\nI randomly turned 3-Dimensional again, but things were different this time...\nI appeared in a void with\nrandom red geometric shapes scattered everywhere and an unknown light source.\nWhat is that place?\nCan I visit it again?";
				case "3":
					tx = "LOG 3\nI'm currently working on studying interdimensional dislocation.\nThere has to be a root cause. Some trigger.\nI hope there aren't any long term side effects.";
				case "4":
					tx = "LOG 4\nI'm doing various tests on myself, trying to figure out what causes the POLYGONization.\nIt hurts a lot, \nBut I must keep a smile. For Tristan's sake.";
				case "5":
					tx = "[FILE DELETED]";
				case "6":
					tx = "LOG 6\nNot infront of Tristan. I almost lost him in that void. I- [DATA DELETED]";
				case "7":
					tx = "LOG 7\nMy interdimensional dislocation appears to be caused by mass amount of stress.\nHow strange.\nMaybe I could isolate this effect somehow?";
				case "8":
					tx = "LOG 8\nHey, Muko here. Dave recently called me to assist with the PROTOTYPE. \nIt's been kind of fun. He won't tell me what it does though.";
				case "9" | "11" | "13":
					tx = "[FILE DELETED]";
				case "12":
					tx = "LOG 12\nThe prototype going pretty well.\nDave still won't tell me what this thing does.\nI can't figure it out even with the\nblueprints.\nI managed to convince him to take a break and\ngo to Cicis Pizza with me and Maldo.\nHe brought Tristan long as well. It was fun.\n-Maldo";
				case "10":
					tx = "LOG 10\nWorking on the prototype.";
				case "14":
					tx = "LOG 14\nI need to stop naming these numerically its getting confusing.";
				case "prototype":
					tx = "Project <P.R.A.E.M>\nNotes: The SOLUTION.\nEstimated Build Time: 2 years.";
				case "solution":
					tx = "I feel every ounce of my being torn to shreds and reconstructed with some parts removed.\nI can hear the electronical hissing of the machine.\nEvery fiber in my being is begging me to STOP.\nI don't.";
				case "stop":
					tx = "A reflection that is always wrong now has appeared in his dreams.\nIt's a part thats now missing.\nA chunk out of his soul.";
				case "boyfriend":
					tx = "LOG [REDACTED]\nA multiversal constant, for some reason. Must dive into further research.";
				case "order":
					tx = "What is order? There are many definitions. Recurser doesn't use any of these though.\nThey want to keep everything the way they love it.\nTo them, that's order.";
				case "power":
					tx = "[I HATE THEM.] [THEY COULD'VE HAD SO MUCH POWER, BUT THEY THREW IT AWAY.]\n[AND IN THAT HEAP OF UNWANTED POWER, I WAS CREATED.]";
				case "birthday":
					tx = "Sent back to the void, a shattered soul encounters his broken <reflection>.";
				case "polygonized" | "polygon" | "3D":
					tx = "He will never be <free>.";
				case "p.r.a.e.m":
					tx = "Name: Power Removal And Extraction Machine\nProgress: Complete\nNotes: Took longer than expected. Tristans 7th BIRTHDAY is in a month.";
			}
			// case sensitive!!
			switch (arguments[0])
			{
				case "cGVyZmVjdGlvbg":
					tx = "[BLADE WOULD'VE BEEN PERFECT. BUT DAVE HAD TO REFUSE.]";
				case "bGlhcg":
					tx = "LOG 331\nI refuse to put Tristan through the torture that is P.R.A.E.M. Especially for [DATA EXPUNGED]. Not now. Not ever.";
				case "YmVkdGltZSBzb25n":
					tx = "Even when you're feeling blue.\nAnd the world feels like its crumbling around you.\nJust know that I'll always be there.\nI wish I knew, everything that will happen to you.\nBut I don't, and that's okay.\nAs long as I'm here you'll always see a sunny day.";
				case "Y29udmVyc2F0aW9u":
					tx = "Log 336\nI encountered some entity in the void today.\nCalled me \"Out of Order\".\nIt mentioned [DATA EXPUNGED] and I asked it for help.\nI don't know if I can trust it but I don't really have\nany other options.";
				case "YXJ0aWZhY3QzLWE=":
					tx = "http://gg.gg/davetabase-artifact3";
				case "YmlydGhkYXk=":
					tx = "http://gg.gg/davetabase-birthday";
				case "ZW1haWw=":
					tx = "http://gg.gg/davetabase-mysterious-email";
			}
			UpdateText("\n" + tx);
		}));
		CommandList.push(new TerminalCommand("vault", Language.getString(languageStrings.get("term_vault_ins")), function(arguments:Array<String>)
		{
			UpdatePreviousText(false); // resets the text
			var funnyRequiredKeys:Array<String> = ['free', 'reflection', 'p.r.a.e.m'];
			var amountofkeys:Int = (arguments.contains(funnyRequiredKeys[0]) ? 1 : 0);
			amountofkeys += (arguments.contains(funnyRequiredKeys[1]) ? 1 : 0);
			amountofkeys += (arguments.contains(funnyRequiredKeys[2]) ? 1 : 0);
			if (arguments.contains(funnyRequiredKeys[0])
				&& arguments.contains(funnyRequiredKeys[1])
				&& arguments.contains(funnyRequiredKeys[2]))
			{
				UpdateText("\nVault unlocked.\ncGVyZmVjdGlvbg\nbGlhcg\nYmVkdGltZSBzb25n\ndGhlIG1lZXRpbmcgcDE=\ndGhlIG1lZXRpbmcgcDI=\nYmlydGhkYXk=\nZW1haWw=\nYXJ0aWZhY3QzLWE=");
			}
			else
			{
				UpdateText("\n" + "Invalid keys. Valid keys: " + amountofkeys);
			}
		}));
		/*CommandList.push(new TerminalCommand("secret mod leak", Language.getString(languageStrings.get("term_leak_ins")), function(arguments:Array<String>)
			{
				MathGameState.accessThroughTerminal = true;
				FlxG.switchState(new MathGameState());
		}, false, true));*/

		add(displayText);

		super.create();
	}

	public function UpdateText(val:String)
	{
		displayText.text = previousText + val;
	}

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

		if (expungedActivated)
		{
			curExpungedAlpha = Math.min(curExpungedAlpha + elapsed, 1);
			if (fakeDisplayGroup.exists && fakeDisplayGroup != null)
			{
				for (text in fakeDisplayGroup.members)
				{
					text.alpha = curExpungedAlpha;
				}
			}
			return;
		}
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
					v.FuncToCall(arguments);
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
		{
			curCommand = "";
		}
		if (FlxG.keys.justPressed.ESCAPE)
		{
			ClientPrefs.showFPS = FlxG.save.data.showFPS;
			FlxG.switchState(new MainMenuState());
		}
	}

	function expungedReignStarts()
	{
		var glitch = new FlxSprite(0, 0);
		glitch.frames = Paths.getSparrowAtlas('ui/glitch/glitch');
		glitch.animation.addByPrefix('glitchScreen', 'glitch', 40);
		glitch.animation.play('glitchScreen');
		glitch.setGraphicSize(FlxG.width, FlxG.height);
		glitch.updateHitbox();
		glitch.screenCenter();
		glitch.scrollFactor.set();
		glitch.antialiasing = false;
		if (FlxG.save.data.eyesores)
		{
			add(glitch);
		}

		add(fakeDisplayGroup);

		var expungedLines:Array<String> = [
			'TAKING OVER....',
			'ATTEMPTING TO HIJACK ADMIN OVERRIDE...',
			'THIS REALM IS MINE',
			"DON'T YOU UNDERSTAND? THIS IS MY WORLD NOW.",
			"I WIN, YOU LOSE.",
			"GAME OVER.",
			"THIS IS IT.",
			"FUCK YOU!",
			"I HAVE THE PLOT ARMOR NOW!!",
			"AHHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAH",
			"EXPUNGED'S REIGN SHALL START",
			'[DATA EXPUNGED]'
		];
		var i:Int = 0;
		var camFollow = new FlxObject(FlxG.width / 2, -FlxG.height / 2, 1, 1);

		FlxG.camera.follow(camFollow, 1);

		expungedActivated = true;
		expungedTimer = new FlxTimer().start(FlxG.elapsed * 2, function(timer:FlxTimer)
		{
			var lastFakeDisplay = fakeDisplayGroup.members[i - 1];
			var fakeDisplay:FlxText = new FlxText(0, 0, FlxG.width, "> " + expungedLines[new FlxRandom().int(0, expungedLines.length - 1)], 19);
			fakeDisplay.setFormat(Paths.font("fixedsys.ttf"), 16);
			fakeDisplay.size *= 2;
			fakeDisplay.antialiasing = false;

			var yValue:Float = lastFakeDisplay == null ? displayText.y + displayText.textField.textHeight : lastFakeDisplay.y
				+ lastFakeDisplay.textField.textHeight;
			fakeDisplay.y = yValue;
			fakeDisplayGroup.add(fakeDisplay);
			if (fakeDisplay.y > FlxG.height)
			{
				camFollow.y = fakeDisplay.y - FlxG.height / 2;
			}
			i++;
		}, FlxMath.MAX_VALUE_INT);

		FlxG.sound.music.stop();
		FlxG.sound.play(Paths.sound("expungedGrantedAccess"), function()
		{
			FlxTween.tween(glitch, {alpha: 0}, 1);
			expungedTimer.cancel();
			fakeDisplayGroup.clear();

			var eye = new FlxSprite(0, 0).loadGraphic(Paths.image('mainMenu/eye'));
			eye.screenCenter();
			eye.antialiasing = false;
			eye.alpha = 0;
			add(eye);

			FlxTween.tween(eye, {alpha: 1}, 1, {
				onComplete: function(tween:FlxTween)
				{
					FlxTween.tween(eye, {alpha: 0}, 1);
				}
			});
			FlxG.sound.play(Paths.sound('iTrollYou'), function()
			{
				new FlxTimer().start(1, function(timer:FlxTimer)
				{
					FlxG.save.data.exploitationState = 'awaiting';
					FlxG.save.data.exploitationFound = true;
					FlxG.save.flush();

					var programPath:String = Sys.programPath();
					var textPath = programPath.substr(0, programPath.length - CoolSystemStuff.executableFileName().length) + "help me.txt";

					File.saveContent(textPath, "you don't know what you're getting yourself into\n don't open the game for your own risk");
					System.exit(0);
				});
			});
		});
	}
}

class TerminalCommand
{
	public var commandName:String = "undefined";
	public var commandHelp:String = "if you see this you are very homosexual and dumb."; // hey im not homosexual. kinda mean ngl
	public var FuncToCall:Dynamic;
	public var showInHelp:Bool;
	public var oneCommand:Bool;

	public function new(name:String, help:String, func:Dynamic, showInHelp = true, oneCommand:Bool = false)
	{
		commandName = name;
		commandHelp = help;
		FuncToCall = func;
		this.showInHelp = showInHelp;
		this.oneCommand = oneCommand;
	}
}
