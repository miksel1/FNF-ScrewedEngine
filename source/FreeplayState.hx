package;

import haxe.Json;
import openfl.events.SampleDataEvent;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
import flixel.FlxObject;
import discord_rpc.DiscordRpc.SecretCallback;
import flixel.tweens.FlxEase;
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

typedef FreeplaySectionData =
{
	name:String,
	image:String,
	songs:Array<String>,
	position:Int
}

class FreeplayState extends MusicBeatState
{
	/**
	 * CATHEGORIES IS NOT THE SAME 
	 */
	var maxCathegories:Int = 1;

	var curCathegory:Int = -1;

	/**
	 * Ehem, this will be the method to separate songs...
	 */
	var cathegories:Map<String, Array<SongMetadata>> = ['MAIN' => []];

	var cathegoriesInt:Map<Int, String> = [0 => 'MAIN'];
	@:isVar
	var currentCathegory(default, set):String = 'MAIN';
	function set_currentCathegory(v:String):String {
		return currentCathegory = v.replace('--', '').toUpperCase();
	}

	var songs:Array<SongMetadata> = [];
	var fakeSongs:Array<SongMetadata> = [];

	var icons:Array<String> = [];
	var notSongs:Array<Int> = [];

	var sections:Array<String> = [];

	/**
	 * The same, but with "--"
	 */
	var rawSections:Array<String> = [];

	var curFreeplaySection(get, null):String;

	inline function get_curFreeplaySection():String
	{
		return (curSelected < 0) ? 'MAIN' : sections[curSelected];
	}

	private static var curSelected:Int = 0;

	var curDifficulty:Int = -1;

	private static var lastDifficultyName:String = '';

	var searcher:FlxUIInputText;

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

	private var iconArray:FlxSpriteGroup = new FlxSpriteGroup();

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	var normalCamera:FlxCamera;

	var bg:FlxSprite;
	var intendedColor:Int;
	var colorTween:FlxTween;

	var ahg:Bool = true;

	var originalTitlePosition:Null<Float> = null;

	var coolSongs:Array<String> = ['dad-battle', 'blammed'];

	/**
	 * a fake bg for the user to select a section
	 */
	var fakeBg:FlxSprite;

	var infoText:FlxText;

	/**
	 * If its true, it means that the player its still selecting the category
	 */
	var selectingSection:Bool = true;

	var canSmash:Bool = true;
	var fakeBgTween:FlxTween;
	var sectionImages:Array<FlxSprite> = [];
	var sectionAlphabets:Array<Alphabet> = [];
	var curSelectingSection:Int = 0;
	var sectionsToSelect:Array<String> = [];
	var cameraSection:FlxCamera;

	var ALLTHEFUCKINGSECTIONS:Array<String> = [];

	var sortedSectionJSOns:Array<FreeplaySectionData> = [];
	var sectionJSONs:Array<FreeplaySectionData> = [];

	var informationAboutThings:FlxText;
	var informationAboutSections:FlxText;
	var informationAboutSectionsBg:FlxSprite;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		/*songs.whenPushed = function(element:SongMetadata) {
				if(cathegories.exists(currentCathegory)) {
					var oldArray = cathegories.get(currentCathegory); // i dont even know what im doing.
					oldArray.push(element);
					cathegories.set(currentCathegory, oldArray);
				} else {
					cathegories.set(currentCathegory, [element]);
				}
				return false;
			};
			songs.whenWannaIterate = function() {
				var arraauu:Array<SongMetadata> = [];
				if(cathegories.exists(currentCathegory)) {
					arraauu = cathegories.get(currentCathegory);
				} else {
					arraauu = cathegories.get('MAIN');
				}
				return arraauu;
			}
			songs.whenWannaGet = function() {
				var arraauu:Array<SongMetadata> = [];
				if(cathegories.exists(currentCathegory)) {
					arraauu = cathegories.get(currentCathegory);
				} else {
					arraauu = cathegories.get('MAIN');
				}
				return arraauu;
			};
			songs.whenWannaLength = function() {
				var arraauu:Array<SongMetadata> = [];
				if(cathegories.exists(currentCathegory)) {
					arraauu = cathegories.get(currentCathegory);
				} else {
					arraauu = cathegories.get('MAIN');
				}
				return arraauu;
		};*/
		// FlxG.mouse.visible = true;

		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		normalCamera = new FlxCamera();
		cameraSection = new FlxCamera();
		normalCamera.bgColor.alpha = cameraSection.bgColor.alpha = 0;

		FlxG.cameras.add(normalCamera, true);
		FlxG.cameras.add(cameraSection, false);
		CustomFadeTransition.nextCamera = cameraSection;

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.screenCenter();
		camFollow.setPosition(0, 0);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		camFollow.cameras = [cameraSection];
		add(camFollow);

		cameraSection.follow(camFollow, LOCKON, 0.04);
		cameraSection.focusOn(camFollow.getPosition());

		currentCathegory = 'MAIN';
		var currentThingInCathegory:Int = 0;
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
				// if(Song.isValidSong(song[0])) {
				addSong(song[0], i, song[1], FlxColor.fromRGB(colors[0], colors[1], colors[2]));
				// } else {
				/*
					currentCathegory = song[0];
					cathegoriesInt.set(currentThingInCathegory, currentCathegory);
					currentThingInCathegory++;
				}*/
			}
		}
		maxCathegories = currentThingInCathegory; // shouldnt i have done it since the beginning????
		currentCathegory = cathegoriesInt.get(maxCathegories);

		WeekData.loadTheFirstEnabledMod();

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		bg.scrollFactor.set();
		add(bg);
		bg.cameras = [normalCamera];
		bg.screenCenter();
		fakeBg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		fakeBg.antialiasing = ClientPrefs.globalAntialiasing;
		fakeBg.screenCenter();
		fakeBg.scrollFactor.set();
		fakeBg.cameras = [cameraSection];

		grpSongs = new FlxTypedGroup<Alphabet>();
		grpSongs.cameras = [normalCamera];
		add(grpSongs);
		iconArray.cameras = [normalCamera];
		add(iconArray);

		curCathegory = 0;

		WeekData.setDirectoryFromWeek();

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		scoreText.cameras = [normalCamera];

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		scoreBG.cameras = [normalCamera];
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		diffText.cameras = [normalCamera];
		add(diffText);

		add(scoreText);

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
		searcher.cameras = [normalCamera];
		searcher.callback = function(text, action)
		{
			ahg = false;
			if (action == FlxInputText.INPUT_ACTION)
			{
				for (i in 0...fakeSongs.length)
				{
					var i:Null<Int> = fakeSongs.length;
					try { // this is prone to crashes so we use try and catch
						if (i != null && fakeSongs[i].songName.toLowerCase().trim().contains(text.toLowerCase().trim()))
						{
							curSelected = i;
							holdTime = 0;
							changeSelection(0, FlxG.random.bool(30.4));
							changeDiff();
							return; // fucking fuck it
						}
						else if (i != null && fakeSongs[i].folder.toLowerCase().trim().contains(text.toLowerCase().trim()))
						{
							curSelected = i;
							holdTime = 0;
							changeSelection(0, FlxG.random.bool(30.4));
							changeDiff();
							return; // fucking fuck it
						}
					}
					catch (e){
						if (i == null)
							throw "Invalid Section or songs are missing/null, full error: " + e.message;
						else
							throw "Error: " + e.message;
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
		textBG.cameras = [normalCamera];
		add(textBG);
		informationAboutSectionsBg = new FlxSprite(0, FlxG.height - 26).makeGraphic(FlxG.width, 26, 0xFF000000);
		informationAboutSectionsBg.alpha = 0.6;
		informationAboutSectionsBg.scrollFactor.set();
		informationAboutSectionsBg.cameras = [cameraSection];

		#if PRELOAD_ALL
		var leText:String = "Press SPACE to listen to the Song / Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 16;
		#else
		var leText:String = "Press CTRL to open the Gameplay Changers Menu / Press RESET to Reset your Score and Accuracy.";
		var size:Int = 18;
		#end
		informationAboutThings = new FlxText(textBG.x, textBG.y + 4, FlxG.width, leText, size);
		informationAboutThings.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, RIGHT);
		informationAboutThings.scrollFactor.set();
		informationAboutThings.cameras = [normalCamera];
		add(informationAboutThings);

		informationAboutSections = new FlxText(textBG.x, textBG.y + 4, FlxG.width, '', size);
		informationAboutSections.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, RIGHT);
		informationAboutSections.scrollFactor.set();
		informationAboutSections.cameras = [cameraSection];

		add(fakeBg);
		addSections();
		changeSection();

		infoText = new FlxText(20, 50, 0, 'Press enter\nFreeplay sections are still WIP', size);
		infoText.setFormat(Paths.font("vcr.ttf"), size, FlxColor.WHITE, CENTER);
		infoText.scrollFactor.set();
		// add(infoText);

		super.create();
	}

	function addTheSpecificSongs()
	{
		for (i in 0...songs.length)
		{
			var song = songs[i];
			var songName = song.songName;
			var isValid = Song.isValidSong(songName);

			/*
				/**
				* 0 is false, 1 is for sections, 2 is for folder
				*
				var canType:Int = 0;

				if (!sections.contains(songName.toUpperCase().replace('--', '')) && !isValid)
					canType = 1;

				if (i > 0 && canType == 0)
				{
					if (song.folder != songs.get(i - 1).folder)
					{
						canType = 2;
					}
				}
				if (canType == 2)
				{
					for (j in i...songs.length)
					{
						sections[j] = rawSections[j] = song.folder.toUpperCase();
					}
				}
				else if (canType == 1)
				{
					for (j in i...songs.length)
					{
						sections[j] = songName.toUpperCase().replace('--', '');
						rawSections[j] = songName.toUpperCase();
					}
			}*/

			var image:String = coolSongs.contains(Paths.formatToSongPath(songName)) ? 'otherAlphabet' : 'alphabet';

			var songText:Alphabet = new Alphabet(isValid ? 90 : 160, 320, songName, true, image);
			if (coolSongs.contains(Paths.formatToSongPath(songName)))
			{
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

			Paths.currentModDirectory = song.folder;
			/*if (!notSongs.contains(i))
				{
					if (icons[i] != 'you this is strange')
					{ */
			var icon:HealthIcon = new HealthIcon(song.songCharacter);
			icon.sprTracker = songText;
			icon.cameras = [normalCamera];
			iconArray.add(icon);
			/*}
				else
				{
					var nothing:FlxSprite = new FlxSprite();
					nothing.cameras = [normalCamera];
					iconArray.add(nothing);
				}
			}*/
		}
	}

	function addTheSongs()
	{
		/*for (i in 0...songs.length)
			{
				sections[i] = 'MAIN';
				rawSections[i] = '--MAIN--';
			}
			if (sections.length != songs.length)
			{
				for (_ in sections)
				{
					sections.pop();
				}
				for (_ in rawSections)
				{
					rawSections.pop();
				}
				for (_ in songs)
				{
					sections.push('MAIN');
					rawSections.push('--MAIN--');
				}
		}*/
		for (i in 0...fakeSongs.length)
		{
			var song = fakeSongs[i];
			var songName = song.songName;
			var isValid = Song.isValidSong(songName);
			/*
				/**
				* 0 is false, 1 is for sections, 2 is for folder
				*
				var canType:Int = 0;

				if (!sections.contains(songName.toUpperCase().replace('--', '')) && !isValid)
					canType = 1;

				if (i > 0 && canType == 0)
				{
					if (song.folder != songs[i - 1].folder)
					{
						canType = 2;
					}
				}
				if (canType == 2)
				{
					for (j in i...songs.length)
					{
						sections[j] = rawSections[j] = song.folder.toUpperCase();
					}
				}
				else if (canType == 1)
				{
					for (j in i...songs.length)
					{
						sections[j] = songName.toUpperCase().replace('--', '');
						rawSections[j] = songName.toUpperCase();
						if(!ALLTHEFUCKINGSECTIONS.contains(songName.toUpperCase())) {
							ALLTHEFUCKINGSECTIONS.push(songName.toUpperCase());
						}
					}
			}*/

			var image:String = coolSongs.contains(Paths.formatToSongPath(songName)) ? 'otherAlphabet' : 'alphabet';

			var songText:Alphabet = new Alphabet(isValid ? 90 : 160, 320, songName, true, image);
			if (coolSongs.contains(Paths.formatToSongPath(songName)))
			{
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

			Paths.currentModDirectory = song.folder;
			/*if (!notSongs.contains(i))
				{
					if (icons[i] != 'you this is strange')
					{ */
			var icon:HealthIcon = new HealthIcon(song.songCharacter);
			icon.sprTracker = songText;
			icon.cameras = [normalCamera];
			iconArray.add(icon);
			/*}
				else
				{
					var nothing:FlxSprite = new FlxSprite();
					nothing.cameras = [normalCamera];
					iconArray.add(nothing);
				}
			}*/
		}
	}

	function resetTheSongs()
	{
		grpSongs.clear();
		iconArray.clear();
		curSelected = 0;
	}

	/**
	 * Changes 
	 * @param change 
	 */
	function changeCathegory(change:Int = 0)
	{
		curCathegory += change;
		if (curCathegory < 0)
			curCathegory = maxCathegories - 1;
		if (curCathegory > maxCathegories)
			curCathegory = 0;

		// currentCathegory = cathegoriesInt.get(curCathegory);

		/*resetTheSongs();
			addTheSongs();
			changeSelection();
			changeDiff(); */
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

		if (!selectingSection)
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

				if (fakeSongs.length > 1)
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

				if (FlxG.keys.pressed.SHIFT)
				{
					if (leftP)
						changeCathegory(-1);
					else if (rightP)
						changeCathegory(1);
					else if (upP || downP)
						changeDiff();
				}
				else
				{
					if (leftP)
						changeDiff(-1);
					else if (rightP)
						changeDiff(1);
					else if (upP || downP) // i dont care at all
						changeDiff();
				}

				if (back)
				{
					persistentUpdate = false;
					if (colorTween != null)
					{
						colorTween.cancel();
					}

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
					if (instPlaying != curSelected /*&& !notSongs.contains(curSelected) && Song.isValidSong(songs[curSelected].songName)*/)
					{
						#if PRELOAD_ALL
						destroyFreeplayVocals();
						FlxG.sound.music.volume = 0;
						Paths.currentModDirectory = fakeSongs[curSelected].folder;
						var poop:String = Highscore.formatSong(fakeSongs[curSelected].songName.toLowerCase(), curDifficulty);
						PlayState.SONG = Song.loadFromJson(poop, fakeSongs[curSelected].songName.toLowerCase());
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
				else if (accepted /*&& !notSongs.contains(curSelected) && Song.isValidSong(songs[curSelected].songName) */)
				{
					var cannn:Bool = true;
					persistentUpdate = false;
					var songLowercase:String = Paths.formatToSongPath(fakeSongs[curSelected].songName);
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
							max += section.sectionNotes.length;
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
				else if (reset /*&& Song.isValidSong(songs[curSelected].songName)*/)
				{
					persistentUpdate = false;
					openSubState(new ResetScoreSubState(fakeSongs[curSelected].songName, curDifficulty, fakeSongs[curSelected].songCharacter));
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
			if (FlxG.mouse.justPressed)
				ahg = true;
		}
		else
		{
			if (FlxG.keys.justPressed.SHIFT && canSmash)
			{
				if (sectionImages.length == 0)
				{
					curSelectingSection = 1;
				}
				else
				{
					curSelectingSection = sectionImages.length;
				}
				selectSection();
			}
			else if (controls.ACCEPT && canSmash)
			{
				selectSection();
			}
			else if (controls.UI_LEFT_P)
			{
				changeSection(-1);
			}
			else if (controls.UI_RIGHT_P)
			{
				changeSection(1);
			}
		}

		super.update(elapsed);
	}

	public function fadeOutSections()
	{
		fakeBgTween = FlxTween.tween(fakeBg, {y: fakeBg.height}, 1, {
			ease: FlxEase.bounceOut,
			onComplete: function(twn:FlxTween)
			{
				FlxG.mouse.visible = true;
				selectingSection = false;
				fakeBgTween = null;
				canSmash = true;
				infoText.visible = false;
				informationAboutSections.visible = false;
				informationAboutSectionsBg.visible = false;
			}
		});
		if (sectionImages.length > 0)
		{
			for (i in 0...sectionImages.length)
			{
				FlxTween.tween(sectionImages[i], {y: fakeBg.height}, 1 + (i / 10), {
					ease: FlxEase.bounceOut,
					onComplete: function(twn:FlxTween)
					{
						FlxTween.tween(sectionAlphabets[i], {y: fakeBg.height}, 0.5 + (1 / 10), {
							ease: FlxEase.bounceOut,
							onComplete: function(twn:FlxTween)
							{
								if (i == sectionImages.length - 1)
								{
									// FlxG.cameras.add(normalCamera, true);
									// FlxG.cameras.remove(cameraSection, false);
								}
							}
						});
					}
				});
			}
		}

		canSmash = false;
	}

	/**
	 * DO NOT START WITH THIS
	 */
	public function fadeInSections()
	{
		fakeBgTween = FlxTween.tween(fakeBg, {y: 0}, 1, {
			ease: FlxEase.bounceOut,
			onComplete: function(twn:FlxTween)
			{
				FlxG.mouse.visible = false;
				selectingSection = true;
				fakeBgTween = null;
				canSmash = true;
			}
		});
		canSmash = false;
	}

	public function addSections()
	{
		#if MODS_ALLOWED
		var modExists = FileSystem.exists(Paths.modFolders('data/sections-data/'));
		#else
		var modExists = false;
		#end
		if (FileSystem.exists('assets/data/sections-data/') || modExists)
		{
			#if MODS_ALLOWED
			if (modExists)
			{
				var files = FileSystem.readDirectory(Paths.modFolders('data/sections-data/'));
				for (modJson in files)
				{
					var sectionData:Dynamic = Json.parse(Paths.getTextFromFile('data/sections-data/' + modJson));
					if (sectionData.position == null)
						sectionData.position = -1;

					if (sectionData != null)
					{
						var data:FreeplaySectionData = cast sectionData;
						if (data != null)
						{
							sectionJSONs.push(data);
						}
					}
				}
			}
			#end

			var files = FileSystem.readDirectory('assets/data/sections-data/');
			for (json in files)
			{
				trace(json);
				var sectionData:Dynamic = Json.parse(Paths.getTextFromFile('data/sections-data/' + json));
				if (sectionData.position == null)
					sectionData.position = -1;

				if (sectionData != null)
				{
					var data:FreeplaySectionData = cast sectionData;
					if (data != null)
					{
						sectionJSONs.push(data);
					}
				}
			}
		}

		/*ALLTHEFUCKINGSECTIONS = [];
			for(key => value in cathegories) {
				ALLTHEFUCKINGSECTIONS.push(key);
			}
			/**
			* contains the information of each section but its simplificated
			*
			var trueSections:Map<String, Int> = [];
			for (i in 0...ALLTHEFUCKINGSECTIONS.length) {
				if(!trueSections.exists(ALLTHEFUCKINGSECTIONS[i]) /*&& (!Song.isValidSong(rawSections[i]) || rawSections[i].replace('--', '').toUpperCase() == 'MAIN') */ /*) {
				trueSections.set(ALLTHEFUCKINGSECTIONS[i], i);
				sectionsToSelect.push(ALLTHEFUCKINGSECTIONS[i]);
			}
		}*/
		var lastInt:Int = 0;
		for (i in 0...sectionJSONs.length)
		{
			var name:String = sectionJSONs[i].name;
			var image:String = sectionJSONs[i].image;
			var position:Int = sectionJSONs[i].position;

			var file = Paths.image('freeplaysections/' + image);
			var sectionImage:FlxSprite = new FlxSprite(0, 0).loadGraphic(file);
			sectionImage.centerOffsets(false);
			if (position == -1)
			{
				sectionImage.x = (1000 * lastInt + 1) + (512 - sectionImage.width);
			}
			else
			{
				sectionImage.x = (1000 * position + 1) + (512 - sectionImage.width);
				lastInt = position;
			}

			sectionImage.y = (FlxG.height / 2) - 256;
			sectionImage.antialiasing = ClientPrefs.globalAntialiasing;
			sectionImage.cameras = [cameraSection];

			var sectionAlphabet:Alphabet = new Alphabet(40 /*???*/, 20, name.toUpperCase());
			sectionAlphabet.cameras = [cameraSection];
			sectionAlphabet.x = sectionImage.x;

			add(sectionImage);
			add(sectionAlphabet);
			if (position == -1)
			{
				sectionImages.insert(lastInt + 1, sectionImage);
				sectionAlphabets.insert(lastInt + 1, sectionAlphabet);
			}
			else
			{
				sectionImages.insert(position, sectionImage);
				sectionAlphabets.insert(position, sectionAlphabet);
			}
		}
		/*for (sectionInt in 0...sectionsToSelect.length)
			{ // done?
				trace('section: ' + sectionsToSelect[sectionInt]);
				var path = 'freeplaysections/' + Paths.formatToSongPath(sectionsToSelect[sectionInt].toLowerCase().replace('--', ''));
				if (Paths.fileExists('images/' + path + '.png', IMAGE)) // FUCKING GOD
				{
					var file = Paths.image(path);
					var sectionImage:FlxSprite = new FlxSprite(0, 0).loadGraphic(file);
					sectionImage.centerOffsets(false);
					sectionImage.x = (1000 * sectionInt + 1) + (512 - sectionImage.width);
					sectionImage.y = (FlxG.height / 2) - 256;
					sectionImage.antialiasing = ClientPrefs.globalAntialiasing;
					sectionImage.cameras = [cameraSection];

					var sectionAlphabet:Alphabet = new Alphabet(40, 20, sectionsToSelect[sectionInt].replace('--', ''));
					sectionAlphabet.cameras = [cameraSection];
					sectionAlphabet.x = sectionImage.x;

					add(sectionImage);
					sectionImages.push(sectionImage);
					add(sectionAlphabet);
					sectionAlphabets.push(sectionAlphabet);
				}
		}*/

		if (sectionImages[0] != null)
			camFollow.setPosition(sectionImages[0].x + 256, sectionImages[0].y + 256);

		if (informationAboutSections != null)
		{
			informationAboutSections.text = 'Press SHIFT to have all the songs at the same time.';
			add(informationAboutSectionsBg);
			add(informationAboutSections);
		}
	}

	public function changeSection(change:Int = 0)
	{
		curSelectingSection += change;
		if (curSelectingSection < 0)
			curSelectingSection = sectionImages.length - 1;
		if (curSelectingSection >= sectionImages.length)
			curSelectingSection = 0;

		if (camFollow != null)
		{
			if (sectionImages[curSelectingSection] != null)
				camFollow.x = sectionImages[curSelectingSection].x + 256;
		}
	}

	public function selectSection()
	{
		if (camFollow != null)
			camFollow.setPosition(0, 0);

		resetTheSongs();

		var pushedOnce:Bool = false;

		fakeSongs = [];

		if (sectionImages.length > 0)
		{
			if (sectionJSONs.length > curSelectingSection)
			{
				var THEsection:Null<FreeplaySectionData> = null;
				for (sect in sectionJSONs)
				{
					if (sect.name.toLowerCase() == sectionAlphabets[curSelectingSection].text.toLowerCase())
					{
						THEsection = sect;
						break;
					}
				}
				if (THEsection != null)
				{
					for (songName in THEsection.songs)
					{
						for (realSong in songs)
						{
							if (Paths.formatToSongPath(realSong.songName) == Paths.formatToSongPath(songName))
							{
								fakeSongs.push(realSong);
							}
						}
					}
				}
				else
				{
					trace('upps! something got wrong!');
					for (realSong in songs)
					{
						fakeSongs.push(realSong);
					}
				}
			}
			else
			{
				trace('upps! something got REALLY wrong!');
				for (realSong in songs)
				{
					fakeSongs.push(realSong);
				}
			}
		}
		else
		{
			for (realSong in songs)
			{
				fakeSongs.push(realSong);
			}
		}
		addTheSongs();
		changeSelection();
		changeDiff();
		fadeOutSections();
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
		if (fakeSongs.length > 1)
		{
			var songName = fakeSongs[curSelected].songName;
			if (songName.replace('--', '').toUpperCase() == sections[curSelected])
				return;

			curDifficulty += change;

			if (curDifficulty < 0)
				curDifficulty = CoolUtil.difficulties.length - 1;
			if (curDifficulty >= CoolUtil.difficulties.length)
				curDifficulty = 0;

			lastDifficultyName = CoolUtil.difficulties[curDifficulty];

			#if !switch
			intendedScore = Highscore.getScore(songName, curDifficulty);
			intendedRating = Highscore.getRating(songName, curDifficulty);
			#end

			PlayState.storyDifficulty = curDifficulty;
			diffText.text = '< ' + CoolUtil.difficultyString() + ' >';
			positionHighscore();
		}
	}

	var resetVisibility:Bool = false; // less lag

	function changeSelection(change:Int = 0, playSound:Bool = true)
	{
		if (playSound)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (grpSongs != null && grpSongs.members != null)
		{
			if (curSelected < 0)
				curSelected = grpSongs.members.length - 1;
			if (curSelected >= grpSongs.members.length)
				curSelected = 0;
		}
		else
		{
			if (curSelected < 0)
				curSelected = fakeSongs.length - 1;
			if (curSelected >= fakeSongs.length)
				curSelected = 0;
		}

		if (fakeSongs.length > 1)
		{
			var song = fakeSongs[curSelected];

			var newColor:Int = song.color;
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

			if (Song.isValidSong(fakeSongs[curSelected].songName))
			{
				intendedScore = Highscore.getScore(song.songName, curDifficulty);
				intendedRating = Highscore.getRating(song.songName, curDifficulty);
			}

			var bullShit:Int = 0;

			for (i in 0...iconArray.length)
			{
				iconArray.members[i].alpha = 0.6;
			}

			if (iconArray.members[curSelected] != null)
			{
				iconArray.members[curSelected].alpha = 1;
			}

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

			Paths.currentModDirectory = song.folder;
			PlayState.storyWeek = song.week;

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
			if (!Song.isValidSong(song.songName))
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
		if (fakeBgTween != null)
		{
			fakeBgTween.cancel();
		}
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
