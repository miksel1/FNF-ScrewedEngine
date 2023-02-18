package;

import flixel.util.FlxTimer;
import flixel.input.FlxInput;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUIInputText;
#if desktop
import Discord.DiscordClient;
#end
import editors.ChartingState;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import WeekData;
#if MODS_ALLOWED
import sys.FileSystem;
#end

using StringTools;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];
	var icons:Array<String> = [];
	var notSongs:Array<Int> = [];

	var sections:Array<String> = [];
	var curFreeplaySection(get, null):String;

	inline function get_curFreeplaySection():String {
		return (curSelected < 0) ? 'MAIN' : sections[curSelected];
	}

	private static var curSelected:Int = 0;

	var curDifficulty:Int = -1;

	private static var lastDifficultyName:String = '';

	var searcher:FlxUIInputText;
	var titleTxt:Alphabet; // trying to do like creditsState

	var blockPressWhileTypingOn:Array<FlxUIInputText> = [];

	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var lerpRating:Float = 0;
	var intendedScore:Int = 0;
	var intendedRating:Float = 0;

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<FlxSprite> = [];

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var ahg:Bool = true;

	var originalTitlePosition:Null<Float> = null;

	var coolSongs:Array<String> = [
		'dad-battle',
		'blammed'
	];

	var fakeBg:FlxSprite;
	var selectingGrid:Bool = true;
	var sectionsGrid:FlxSprite;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		//FlxG.mouse.visible = true;

		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		for (i in 0...WeekData.weeksList.length)
		{
			if (weekIsLocked(WeekData.weeksList[i]))
				continue;

			var leWeek:WeekData = WeekData.weeksLoaded.get(WeekData.weeksList[i]);
			var leSongs:Array<String> = [];
			var leChars:Array<String> = [];

			for (j in 0...leWeek.songs.length) // THIS IS NOT FOR ICONS WITHER!!!!! IS NOT FOR ICONS!!
			{
				leSongs.push(leWeek.songs[j][0]);
				if (leWeek.songs[j][1] != 'nothing' && leWeek.songs[j][1] != '')
				{
					leChars.push(leWeek.songs[j][1]);
					icons.push(leWeek.songs[j][1]);
				}
				else
				{
					icons.push('you this is strange');
					// notSongs.push(j);
				}
			}

			WeekData.setDirectoryFromWeek(leWeek);
			for (song in leWeek.songs)
			{
				var colors:Array<Int> = song[2];
				if (colors == null || colors.length < 3)
				{
					colors = [146, 113, 253];
				}
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
			}
		}
		WeekData.loadTheFirstEnabledMod();

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);
		bg.screenCenter();
		fakeBg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		fakeBg.antialiasing = ClientPrefs.globalAntialiasing;
		fakeBg.screenCenter();

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (_ in songs)
		{
			sections.push('MAIN');
		}
		if (sections.length != songs.length)
		{
			for (s in sections)
			{
				sections.remove(s);
			}
			for (_ in songs)
			{
				sections.push('MAIN');
			}
		}
		for (i in 0...songs.length)
		{
			var songName = songs[i].songName;
			var isValid = Song.isValidSong(songName);
			/**
			 * 0 is false, 1 is for sections, 2 is for folder
			 */
			var canType:Int = 0;
			if(!sections.contains(songName.toUpperCase().replace('--', '')) && !isValid) canType = 1;

			if(i > 0) {
				if(songs[i].folder != songs[i - 1].folder) {
					canType = 2;
				}
			}
			if(canType == 2) {
				for (j in i...songs.length)
				{
					sections[j] = songs[i].folder.toUpperCase();
				}
			}
			else if (canType == 1)
			{
				for (j in i...songs.length)
				{
					sections[j] = songName.toUpperCase().replace('--', '');
				}
			}

			var image:String = coolSongs.contains(Paths.formatToSongPath(songName)) ? 'otherAlphabet' : 'alphabet';

			var songText:Alphabet = new Alphabet(
				isValid ? 90 : 120,
				320,
				songName,
				true,
				image);
			if(coolSongs.contains(Paths.formatToSongPath(songName))) {
				songText.useColorSwap = true;
				songText.colorEffect = 0.5;
			}
			songText.isMenuItem = true;
			songText.targetY = i - curSelected;
			grpSongs.add(songText);

			var maxWidth = 980;
			if (songText.width > maxWidth)
			{
				songText.scaleX = maxWidth / songText.width;
			}
			songText.snapToPosition();

			Paths.currentModDirectory = songs[i].folder;
			if (!notSongs.contains(i))
			{
				if (icons[i] != 'you this is strange')
				{
					var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
					icon.sprTracker = songText;

					// using a FlxGroup is too much fuss!
					iconArray.push(icon);
					add(icon);
				}
				else
				{
					var nothing:FlxSprite = new FlxSprite();
					iconArray.push(nothing);
					add(nothing);
				}
			}
		}
		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		add(scoreText);

		if (curSelected >= songs.length)
			curSelected = 0;
		bg.color = songs[curSelected].color;
		intendedColor = bg.color;

		if (lastDifficultyName == '')
		{
			lastDifficultyName = CoolUtil.defaultDifficulty;
		}
		curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(lastDifficultyName)));

		changeSelection();
		changeDiff();

		searcher = new FlxUIInputText(90, 30);
		searcher.scrollFactor.set();
		searcher.resize(searcher.width *= 1.3, searcher.height *= 1.3);
		searcher.screenCenter(X);
		searcher.x -= 10;
		searcher.callback = function(text, action)
		{
			ahg = false;
			if (action == FlxInputText.INPUT_ACTION)
			{
				for (i in 0...songs.length)
				{
					if (songs[i].songName.toLowerCase().trim().contains(text.toLowerCase().trim()))
					{
						curSelected = i;
						holdTime = 0;
						changeSelection(0, FlxG.random.bool(30.4));
						changeDiff();
						return; // fucking fuck it
					} else if (songs[i].folder.toLowerCase().trim().contains(text.toLowerCase().trim()))
					{
						curSelected = i;
						holdTime = 0;
						changeSelection(0, FlxG.random.bool(30.4));
						changeDiff();
						return; // fucking fuck it
					}
				}
			}
			else if (action == FlxInputText.ENTER_ACTION)
			{
				searcher.hasFocus = false;
				new FlxTimer().start(0.003, function(tmr:FlxTimer)
				{
					ahg = true;
				});
			}
		};
		add(searcher);
		blockPressWhileTypingOn.push(searcher);

		var textBG:FlxSprite = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		textBG.alpha = 0.6;
		add(textBG);

		titleTxt = new Alphabet(FlxG.height - 10, 320, "MAIN");
		titleTxt.scrollFactor.set();
		titleTxt.snapToPosition();
		originalTitlePosition = titleTxt.x;
		add(titleTxt);

		#if PRELOAD_ALL
		var leText:String = "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 16;
		#else
		var leText:String = "Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 18;
		#end
		var text:FlxText = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		text.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, RIGHT);
		text.scrollFactor.set();
		add(text);


		//add(fakeBg);

		/*var widthsection:Int = 20;
		var heightsection:Int = 20;
		sectionsGrid = FlxGridOverlay.create();
		sectionsGrid.*/
		super.create();
	}

	override function closeSubState()
	{
		changeSelection(0, false);
		persistentUpdate = true;
		super.closeSubState();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String, color:Int, ?folder:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter, color));
	}

	function weekIsLocked(name:String):Bool
	{
		var leWeek:WeekData = WeekData.weeksLoaded.get(name);
		return (!leWeek.startUnlocked
			&& leWeek.weekBefore.length > 0
			&& (!StoryMenuState.weekCompleted.exists(leWeek.weekBefore) || !StoryMenuState.weekCompleted.get(leWeek.weekBefore)));
	}

	var canWrite:Bool = true;

	var instPlaying:Int = -1;

	public static var vocals:FlxSound = null;

	var holdTime:Float = 0;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, CoolUtil.boundTo(elapsed * 24, 0, 1)));
		lerpRating = FlxMath.lerp(lerpRating, intendedRating, CoolUtil.boundTo(elapsed * 12, 0, 1));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;
		if (Math.abs(lerpRating - intendedRating) <= 0.01)
			lerpRating = intendedRating;

		var ratingSplit:Array<String> = Std.string(Highscore.floorDecimal(lerpRating * 100, 2)).split('.');
		if (ratingSplit.length < 2)
		{ // No decimals, add an empty space
			ratingSplit.push('');
		}

		while (ratingSplit[1].length < 2)
		{ // Less than 2 decimals in it, add decimals then
			ratingSplit[1] += '0';
		}

		var blockInput:Bool = false;
		for (inputText in blockPressWhileTypingOn)
		{
			if (inputText.hasFocus)
			{
				FlxG.sound.muteKeys = [];
				FlxG.sound.volumeDownKeys = [];
				FlxG.sound.volumeUpKeys = [];
				blockInput = true;
				break;
			}
		}
		if (!blockInput)
		{
			FlxG.sound.muteKeys = TitleState.muteKeys;
			FlxG.sound.volumeDownKeys = TitleState.volumeDownKeys;
			FlxG.sound.volumeUpKeys = TitleState.volumeUpKeys;
		}

		scoreText.text = 'PERSONAL BEST: ' + lerpScore + ' (' + ratingSplit.join('.') + '%)';
		positionHighscore();

		if (!selectingGrid)
		{
			if (!blockInput)
			{
				var up = controls.UI_UP;
				var down = controls.UI_DOWN;
				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;
				var accepted = controls.ACCEPT && ahg;
				var leftP = controls.UI_LEFT_P;
				var rightP = controls.UI_RIGHT_P;
				var space = FlxG.keys.justPressed.SPACE;
				var ctrl = FlxG.keys.justPressed.CONTROL;
				var back = controls.BACK;
				var reset = controls.RESET;

				var shiftMult:Int = 1;
				if (FlxG.keys.pressed.SHIFT)
					shiftMult = 3;

				if (songs.length > 1)
				{
					if (upP)
					{
						changeSelection(-shiftMult);
						holdTime = 0;
					}
					if (downP)
					{
						changeSelection(shiftMult);
						holdTime = 0;
					}

					if (down || up)
					{
						var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
						holdTime += elapsed;
						var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

						if (holdTime > 0.5 && checkNewHold - checkLastHold > 0)
						{
							changeSelection((checkNewHold - checkLastHold) * (up ? -shiftMult : shiftMult));
							changeDiff();
						}
					}

					if (FlxG.mouse.wheel != 0)
					{
						FlxG.sound.play(Paths.sound('scrollMenu'), 0.2);
						changeSelection(-shiftMult * FlxG.mouse.wheel, false);
						changeDiff();
					}
				}

				if (leftP)
					changeDiff(-1);
				else if (rightP)
					changeDiff(1);
				else if (upP || downP)
					changeDiff();

				if (back)
				{
					persistentUpdate = false;
					if (colorTween != null)
					{
						colorTween.cancel();
					}
					if (titleTxtTween != null)
						titleTxtTween.cancel();

					FlxG.sound.play(Paths.sound('cancelMenu'));
					MusicBeatState.switchState(new MainMenuState());
				}

				if (ctrl)
				{
					persistentUpdate = false;
					openSubState(new GameplayChangersSubstate());
				}
				else if (space)
				{
					if (instPlaying != curSelected /*&& !notSongs.contains(curSelected)*/ && Song.isValidSong(songs[curSelected].songName))
					{
						#if PRELOAD_ALL
						destroyFreeplayVocals();
						FlxG.sound.music.volume = 0;
						Paths.currentModDirectory = songs[curSelected].folder;
						var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
						PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
						if (PlayState.SONG.needsVoices)
							vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
						else
							vocals = new FlxSound();

						FlxG.sound.list.add(vocals);
						FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0.7);
						vocals.play();
						vocals.persist = true;
						vocals.looped = true;
						vocals.volume = 0.7;
						instPlaying = curSelected;
						#end
					}
				}
				else if (accepted /*&& !notSongs.contains(curSelected)*/ && Song.isValidSong(songs[curSelected].songName))
				{
					var cannn:Bool = true;
					persistentUpdate = false;
					var songLowercase:String = Paths.formatToSongPath(songs[curSelected].songName);
					var poop:String = Highscore.formatSong(songLowercase, curDifficulty);
					var freeplaySection:String = '';

					function works(song:String, asas:String):Bool
					{
						#if MODS_ALLOWED
						if (!FileSystem.exists(Paths.modsJson(song + '/' + asas)) && !FileSystem.exists(Paths.json(song + '/' + asas)))
						#else
						if (!OpenFlAssets.exists(Paths.json(song + '/' + asas)))
						#end
						{
							return false;
						}
						return true;
					}
					if (!works(songLowercase, poop) && works(curFreeplaySection.toLowerCase() + '/' + songLowercase, poop))
					{
						freeplaySection = curFreeplaySection.toLowerCase();
						trace('yeiii');
					}
					else if (!works(songLowercase, poop))
					{
						trace('nonononononoooooo');
						cannn = false;
					}
					if (cannn)
					{
						trace(poop);

						var songnsn = Song.loadFromJson(poop, songLowercase);

						var max = 0;
						for (section in songnsn.notes)
						{
							if (section.sectionNotes.length > max)
								max = section.sectionNotes.length;
						}
						function play()
						{
							PlayState.SONG = songnsn;
							PlayState.isStoryMode = false;
							PlayState.storyDifficulty = curDifficulty;

							trace('CURRENT WEEK: ' + WeekData.getWeekFileName());
							if (colorTween != null)
							{
								colorTween.cancel();
							}
							if (titleTxtTween != null)
								titleTxtTween.cancel();

							if (FlxG.keys.pressed.SHIFT)
							{
								LoadingState.loadAndSwitchState(new ChartingState());
							}
							else
							{
								LoadingState.loadAndSwitchState(new PlayState());
							}

							FlxG.sound.music.volume = 0;

							destroyFreeplayVocals();
						}
						if (max > ClientPrefs.maxNotes)
						{
							openSubState(new Prompt("The actual song has more than " + ClientPrefs.maxNotes + " notes\n\nProceed?", 0, function()
							{
								play();
							}, function()
							{
								FlxG.sound.play(Paths.sound('cancelMenu'));
							}));
						}
						else
						{
							play();
						}
					}
				}
				else if (reset && Song.isValidSong(songs[curSelected].songName))
				{
					persistentUpdate = false;
					openSubState(new ResetScoreSubState(songs[curSelected].songName, curDifficulty, songs[curSelected].songCharacter));
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
			}
			else if (FlxG.keys.justPressed.ENTER)
			{
				for (i in 0...blockPressWhileTypingOn.length)
				{
					if (blockPressWhileTypingOn[i].hasFocus)
					{
						blockPressWhileTypingOn[i].hasFocus = false;
					}
				}
				ahg = true;
			}
		} else {
			if(controls.ACCEPT) {
				fakeBg.visible = false;
			}
		}

		if(FlxG.mouse.justPressed)
			ahg = true;

		super.update(elapsed);
	}

	public static function destroyFreeplayVocals()
	{
		if (vocals != null)
		{
			vocals.stop();
			vocals.destroy();
		}
		vocals = null;
	}

	function changeDiff(change:Int = 0)
	{
		if (songs[curSelected].songName.replace('--', '').toUpperCase() == sections[curSelected])
			return;

		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = CoolUtil.difficulties.length - 1;
		if (curDifficulty >= CoolUtil.difficulties.length)
			curDifficulty = 0;

		lastDifficultyName = CoolUtil.difficulties[curDifficulty];

		#if !switch
		intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
		intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		#end

		PlayState.storyDifficulty = curDifficulty;
		diffText.text = '< ' + CoolUtil.difficultyString() + ' >';
		positionHighscore();
	}

	var resetVisibility:Bool = false; // less lag

	var titleTxtTween:FlxTween;
	/**
	 * 0 for nothing, 1 for reseting, 2 for moving
	 */
	var titleTweenSite:Int = 0;

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if (playSound)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		var newColor:Int = songs[curSelected].color;
		if (newColor != intendedColor)
		{
			if (colorTween != null)
			{
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween)
				{
					colorTween = null;
				}
			});
		}

		if (Song.isValidSong(songs[curSelected].songName))
		{
			intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty);
			intendedRating = Highscore.getRating(songs[curSelected].songName, curDifficulty);
		}

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}

		Paths.currentModDirectory = songs[curSelected].folder;
		PlayState.storyWeek = songs[curSelected].week;

		CoolUtil.difficulties = CoolUtil.defaultDifficulties.copy();
		var diffStr:String = WeekData.getCurrentWeek().difficulties;
		if (diffStr != null)
			diffStr = diffStr.trim(); // Fuck you HTML5

		if (diffStr != null && diffStr.length > 0)
		{
			var diffs:Array<String> = diffStr.split(',');
			var i:Int = diffs.length - 1;
			while (i > 0)
			{
				if (diffs[i] != null)
				{
					diffs[i] = diffs[i].trim();
					if (diffs[i].length < 1)
						diffs.remove(diffs[i]);
				}
				--i;
			}

			if (diffs.length > 0 && diffs[0].length > 0)
			{
				CoolUtil.difficulties = diffs;
			}
		}

		if (CoolUtil.difficulties.contains(CoolUtil.defaultDifficulty))
		{
			curDifficulty = Math.round(Math.max(0, CoolUtil.defaultDifficulties.indexOf(CoolUtil.defaultDifficulty)));
		}
		else
		{
			curDifficulty = 0;
		}

		var newPos:Int = CoolUtil.difficulties.indexOf(lastDifficultyName);
		// trace('Pos of ' + lastDifficultyName + ' is ' + newPos);
		if (newPos > -1)
		{
			curDifficulty = newPos;
		}
		if (!Song.isValidSong(songs[curSelected].songName))
		{
			scoreBG.visible = false;
			scoreText.visible = false;
			diffText.visible = false;
			resetVisibility = true;
		}
		else if (resetVisibility)
		{
			scoreBG.visible = true;
			scoreText.visible = true;
			diffText.visible = true;
			resetVisibility = false;
		}

		if (curSelected > -1 && titleTxt != null)
		{
			if (songs[curSelected].songName.length > 11)
			{
				var num = songs[curSelected].songName.length > 16 ? 15 + songs[curSelected].songName.length / 4 : 10;
				if (titleTxtTween != null)
					titleTxtTween.cancel();

				titleTxtTween = FlxTween.tween(titleTxt, {x: originalTitlePosition + songs[curSelected].songName.length * num}, 1, {
					onComplete: function(twn:FlxTween)
					{
						titleTxtTween = null;
					}
				});
				// titleTxt.x += songs[curSelected].songName.length * 10;
			}
			else if (titleTxt.x != originalTitlePosition)
			{
				if (titleTxtTween != null)
					titleTxtTween.cancel();

				titleTxtTween = FlxTween.tween(titleTxt, {x: originalTitlePosition}, 1, {
					onComplete: function(twn:FlxTween)
					{
						titleTxtTween = null;
					}
				});
			}
		}
		changeTitleText();
	}

	var movedTitleTxt:Bool = false;
	function changeTitleText()
	{
		if (curSelected == -1 || titleTxt == null)
			return; // fuck it
		/*function trr()
		{
			if (/*songs[curSelected].songName.length >= 13 || iconArray[curSelected].overlaps(titleTxt))
			{
				while (iconArray[curSelected].overlaps(titleTxt, true))
				{
					titleTxt.x++;
					movedTitleTxt = true;
				}
			} else if(movedTitleTxt) {
				if(originalTitlePosition == null)
					titleTxt.x = FlxG.height - 10;
				else
					titleTxt.x = originalTitlePosition;
				movedTitleTxt = false;
				trr();
			}
		}*/
		if (curSelected >= 0)
		{
			titleTxt.text = sections[curSelected].toUpperCase().replace('--', '');
			//trr();
		}
	}

	private function positionHighscore()
	{
		scoreText.x = FlxG.width - scoreText.width - 6;

		scoreBG.scale.x = FlxG.width - scoreText.x + 6;
		scoreBG.x = FlxG.width - (scoreBG.scale.x / 2);
		diffText.x = Std.int(scoreBG.x + (scoreBG.width / 2));
		diffText.x -= diffText.width / 2;
	}

	override function destroy()
	{
		FlxG.mouse.visible = false;
		super.destroy();
	}
}

class SongMetadata
{
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var color:Int = -7179779;
	public var folder:String = "";

	public function new(song:String, week:Int, songCharacter:String, color:Int)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.color = color;
		this.folder = Paths.currentModDirectory;
		if (this.folder == null)
			this.folder = '';
	}
}
