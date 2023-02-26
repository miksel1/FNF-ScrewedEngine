package;

import effects.ColorSwap;
import Alphabet.AlphaCharacter;
import Language.LanguageString;
import flixel.ui.FlxButton.FlxTypedButton;
import effects.GrainEffect;
import flixel.addons.effects.chainable.FlxEffectSprite;
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
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.addons.effects.chainable.FlxGlitchEffect;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end
import lime.utils.Assets;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = -1;

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private var grpTitles:FlxTypedGroup<Alphabet>;
	private var iconArray:Array<AttachedSprite> = [];
	private var creditsStuff:Array<Array<String>> = [];

	var AAHHHG:ColorSwap;

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;
	var titleColorTween:FlxTween;
	var descBox:AttachedSprite;

	var offsetThing:Float = -75;

	var glitchedOnes:Array<String> = ['Wither362', 'MemeHoovy', 'Delta', 'miksel'];
	var grainedOnes:Array<String> = ['Wither362', 'BeastlyGhost']; // time to credit them ;)
	var coolTitleOnes:Array<String> = [
		'Wither362',
		'Delta',
		'Join our Discord!', '¡Únete al Discord!',
		'miksel',
		'MemeHoovy',
		'BeastlyGhost',
		'tposejank',
		'Gamer Pablito']; // yes dude ;D

	var glitchEffect:FlxGlitchEffect;
	var glitchBg:FlxEffectSprite;

	var grainEffect:GrainEffect;

	var theTitle:Alphabet;
	var visibleTitle:Bool = false;
	var theTitleTween:FlxTween;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		AAHHHG = new ColorSwap();

		persistentUpdate = true;
		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);
		bg.screenCenter();
		add(glitchBg = new FlxEffectSprite(bg));
		glitchEffect = new FlxGlitchEffect(10, 2, 0.1);

		if (!ClientPrefs.lowQuality)
			glitchBg.effects = [glitchEffect];

		grpOptions = new FlxTypedGroup<Alphabet>();
		grpTitles = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		grainEffect = new GrainEffect();
		//grainEffect.lumAmount *= 2;

		#if MODS_ALLOWED
		var path:String = 'modsList.txt';
		if(FileSystem.exists(path))
		{
			var leMods:Array<String> = CoolUtil.coolTextFile(path);
			for (i in 0...leMods.length)
			{
				if(leMods.length > 1 && leMods[0].length > 0) {
					var modSplit:Array<String> = leMods[i].split('|');
					if(!Paths.ignoreModFolders.contains(modSplit[0].toLowerCase()) && !modsAdded.contains(modSplit[0]))
					{
						if(modSplit[1] == '1')
							pushModCreditsToList(modSplit[0]);
						else
							modsAdded.push(modSplit[0]);
					}
				}
			}
		}

		var arrayOfFolders:Array<String> = Paths.getModDirectories();
		arrayOfFolders.push('');
		for (folder in arrayOfFolders)
		{
			pushModCreditsToList(folder);
		}
		#end

		var pisspoop:Array<Array<Dynamic>> = [ //Name - Icon name - Description - Link - BG Color
			[{s: 'Screwed Engine Team'}],
			[{s: 'Wither362'},			    'Wither',			{s: 'Main Programmer of this engine', spanish: 'Programador Principal\ny traductor al castellano'},								'https://github.com/Wither362',				'FF5F5F'],
			[{s: 'MemeHoovy'},				'meme',				'Additional Programmer and Deleting-Coder',							'https://twitter.com/meme_hoovy',		'438434'],
			[{s: 'Delta'},				    'delta',			{s: 'Strident Engine'},												'https://www.youtube.com/c/Delta1248',									'0xFF00C6FF'],
			[{s: 'miksel'},				    'miksel',			{s: 'Features and Ideas'},									        'https://www.youtube.com/@miksel_fnf',	                                '371893'],
			[{s: 'Join our Discord!', spanish: '¡Únete al Discord!'},	'discord',			{s: 'Yeah! Join us for features and more!', spanish: '¡Sí! ¡Únete para información y más!'},						'https://discord.gg/ACY3MQgB2A',										'0xFF75D8FF'],
			[''],
			[{s: 'Screwed Engine Helpers', spanish: 'Contribudores/Otros Screwed Engine...'}],
			['BeastlyGhost',		'beast',			'Icons and other help',													'https://twitter.com/Fan_de_RPG',		'b0ceff'],
			['tposejank',			'jank',				'Spanish Alphabet Support',										'https://twitter.com/tpose_jank',		'B9AF27'],
			['Gamer Pablito',		'pablo',			'Gamejolt Support',												'https://twitter.com/GamerPablito1',	'0xFF257FB3'],
			['Vs Dave and Bambi',	'dab',				'Our Gods.',													'https://www.discord.gg/vsdave',		'0xFF135816'],
			['Saturn Orr',			'saturn',			'Lua documentation',											'https://github.com/saturn-volv',		'0xFFA203AE'],
			[''],
			['Original Psych Engine Team'],
			['Shadow Mario',		'shadowmario',		'Main Programmer of Psych Engine',								'https://twitter.com/Shadow_Mario_',	'444444'],
			['RiverOaken',			'river',			'Main Artist/Animator of Psych Engine',							'https://twitter.com/RiverOaken',		'B42F71'],
			['shubs',				'shubs',			'Additional Programmer of Psych Engine',						'https://twitter.com/yoshubs',			'5E99DF'],
			[''],
			['Former Psych Engine Members'],
			['bb-panzu',			'bb',				'Ex-Programmer of Psych Engine',								'https://twitter.com/bbsub3',			'3E813A'],
			[''],
			['Psych Engine Contributors'],
			['iFlicky',				'flicky',			'Composer of Psync and Tea Time\nMade the Dialogue Sounds',		'https://twitter.com/flicky_i',			'9E29CF'],
			['SqirraRNG',			'sqirra',			'Crash Handler and Base code for\nChart Editor\'s Waveform',	'https://twitter.com/gedehari',			'E1843A'],
			['EliteMasterEric',		'mastereric',		'Runtime Shaders support',										'https://twitter.com/EliteMasterEric',	'FFBD40'],
			['PolybiusProxy',		'proxy',			'.MP4 Video Loader Library (hxCodec)',							'https://twitter.com/polybiusproxy',	'DCD294'],
			['KadeDev',				'kade',				'Fixed some cool stuff on Chart Editor\nand other PRs',			'https://twitter.com/kade0912',			'64A250'],
			['Keoiki',				'keoiki',			'Note Splash Animations',										'https://twitter.com/Keoiki_',			'D2D2D2'],
			['Nebula the Zorua',	'nebula',			'LUA JIT Fork and some Lua reworks',							'https://twitter.com/Nebula_Zorua',		'7D40B2'],
			['Smokey',				'smokey',			'Sprite Atlas Support',											'https://twitter.com/Smokey_5_',		'483D92'],
			[''],
			["Funkin' Crew"],
			['ninjamuffin99',		'ninjamuffin99',	"Programmer of Friday Night Funkin'",							'https://twitter.com/ninja_muffin99',	'CF2D2D'],
			['PhantomArcade',		'phantomarcade',	"Animator of Friday Night Funkin'",								'https://twitter.com/PhantomArcade3K',	'FADC45'],
			['evilsk8r',			'evilsk8r',			"Artist of Friday Night Funkin'",								'https://twitter.com/evilsk8r',			'5ABD4B'],
			['kawaisprite',			'kawaisprite',		"Composer of Friday Night Funkin'",								'https://twitter.com/kawaisprite',		'378FC7']
		];

		for (i in pisspoop) {
			var t:Array<String> = [];
			for(j in i) {
				if(j is String)
					t.push(j);
				else
					t.push(Language.getString(j));
			}
			creditsStuff.push(t);
		}

		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var image = 'alphabet';
			if(glitchedOnes.contains(creditsStuff[i][0]))
			image = 'otherAlphabet';
			var optionText:Alphabet = new Alphabet(
				FlxG.width / 2,
				300,
				creditsStuff[i][0],
				!isSelectable,
				image
			);
			if(glitchedOnes.contains(creditsStuff[i][0])) {
				optionText.useColorSwap = true;
			}
			optionText.isMenuItem = true;
			optionText.targetY = i;
			optionText.changeX = false;
			optionText.snapToPosition();
			grpOptions.add(optionText);

			if(isSelectable) {
				if(creditsStuff[i][5] != null)
				{
					Paths.currentModDirectory = creditsStuff[i][5];
				}

				var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;

				if(grainedOnes.contains(creditsStuff[i][0])) {
				//	icon.shader = grainEffect.shader;
				}
				// using a FlxGroup is too much fuss!
				iconArray.push(icon);
				add(icon);
				Paths.currentModDirectory = '';

				if(curSelected == -1) curSelected = i;
			}
			else {
				optionText.alignment = CENTERED;
				grpTitles.add(optionText);
			}
		}
		visibleTitle = (!coolTitleOnes.contains(creditsStuff[curSelected][0]));

		descBox = new AttachedSprite();
		descBox.makeGraphic(1, 1, FlxColor.BLACK);
		descBox.xAdd = -10;
		descBox.yAdd = -10;
		descBox.alphaMult = 0.6;
		descBox.alpha = 0.6;
		add(descBox);

		descText = new FlxText(50, FlxG.height + offsetThing - 25, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER/*, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK*/);
		descText.scrollFactor.set();
		//descText.borderSize = 2.4;
		descBox.sprTracker = descText;
		add(descText);

		bg.color = getCurrentBGColor();
		intendedColor = bg.color;
		theTitle = new Alphabet(
			FlxG.width / 2,
			40,
			'SCREWED ENGINE',
			true,
			'alphabet'
		);
		theTitle.alignment = CENTERED;
		theTitle.setAlpha(0.7);
		theTitle.setVisible(visibleTitle);
		add(theTitle);

		if(coolTitleOnes.contains(creditsStuff[curSelected][0])) {
			grpTitles.forEach(function(tit:Alphabet) {
				if(tit.text.toUpperCase().contains('SCREWED')) {
					titleColorTween = FlxTween.color(tit, 1, tit.color, intendedColor, {
						onComplete: function(twn:FlxTween) {
							titleColorTween = null;
						}
					});
				}
			});
		}
		changeSelection();
		super.create();
	}

	var quitting:Bool = false;
	var holdTime:Float = 0;
	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if(!quitting)
		{
			if(creditsStuff.length > 1)
			{
				var shiftMult:Int = 1;
				if(FlxG.keys.pressed.SHIFT) shiftMult = 3;

				var upP = controls.UI_UP_P;
				var downP = controls.UI_DOWN_P;

				if (upP || FlxG.mouse.wheel > 0)
				{
					changeSelection(-shiftMult);
					holdTime = 0;
				}
				if (downP || FlxG.mouse.wheel < 0)
				{
					changeSelection(shiftMult);
					holdTime = 0;
				}

				if(controls.UI_DOWN || controls.UI_UP)
				{
					var checkLastHold:Int = Math.floor((holdTime - 0.5) * 10);
					holdTime += elapsed;
					var checkNewHold:Int = Math.floor((holdTime - 0.5) * 10);

					if(holdTime > 0.5 && checkNewHold - checkLastHold > 0)
					{
						changeSelection((checkNewHold - checkLastHold) * (controls.UI_UP ? -shiftMult : shiftMult));
					}
				}
			}

			if(controls.ACCEPT && (creditsStuff[curSelected][3] == null || creditsStuff[curSelected][3].length > 4)) {
				CoolUtil.browserLoad(creditsStuff[curSelected][3]);
			}
			if (controls.BACK)
			{
				if(colorTween != null) {
					colorTween.cancel();
				}
				if(titleColorTween != null) {
					titleColorTween.cancel();
				}
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new MainMenuState());
				quitting = true;
			}
		}

		for (item in grpOptions.members)
		{
			if(!item.bold)
			{
				var lerpVal:Float = CoolUtil.boundTo(elapsed * 12, 0, 1);
				if(item.targetY == 0)
				{
					var lastX:Float = item.x;
					item.screenCenter(X);
					item.x = FlxMath.lerp(lastX, item.x - 70, lerpVal);
				}
				else
				{
					item.x = FlxMath.lerp(item.x, 200 + -40 * Math.abs(item.targetY), lerpVal);
				}
			}
		}

		if(AAHHHG != null) {
			AAHHHG.hue += elapsed;
		}
		super.update(elapsed);
	}

	var moveTween:FlxTween = null;
	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		visibleTitle = (!coolTitleOnes.contains(creditsStuff[curSelected][0]));

		var newColor:Int = getCurrentBGColor();
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			if(titleColorTween != null) {
				titleColorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
			if(coolTitleOnes.contains(creditsStuff[curSelected][0])) {
				grpTitles.forEach(function(alp:Alphabet) {
					if(alp.text.toUpperCase().contains('SCREWED')) {
						titleColorTween = FlxTween.color(alp, 1, alp.color, intendedColor, {
							onComplete: function(twn:FlxTween) {
								titleColorTween = null;
							}
						});
					}
				});
			}
		}
		theTitle.setVisible(visibleTitle);

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}

		descText.text = creditsStuff[curSelected][2];
		descText.y = FlxG.height - descText.height + offsetThing - 60;

		if(creditsStuff[curSelected][0].toLowerCase() == 'vs dave and bambi') {
			descText.shader == AAHHHG.shader;
		} else if(descText.shader == AAHHHG.shader) {
			descText.shader = null;
		} 

		if(moveTween != null) moveTween.cancel();
		moveTween = FlxTween.tween(descText, {y : descText.y + 75}, 0.25, {ease: FlxEase.sineOut});

		descBox.setGraphicSize(Std.int(descText.width + 20), Std.int(descText.height + 25));
		descBox.updateHitbox();
		if (glitchEffect != null && !ClientPrefs.lowQuality)
			glitchEffect.active = glitchedOnes.contains(creditsStuff[curSelected][0]);
	}

	#if MODS_ALLOWED
	private var modsAdded:Array<String> = [];
	function pushModCreditsToList(folder:String)
	{
		if(modsAdded.contains(folder)) return;

		var creditsFile:String = null;
		if(folder != null && folder.trim().length > 0) creditsFile = Paths.mods(folder + '/data/credits.txt');
		else creditsFile = Paths.mods('data/credits.txt');

		if (FileSystem.exists(creditsFile))
		{
			var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
			for(i in firstarray)
			{
				var arr:Array<String> = i.replace('\\n', '\n').split("::");
				if(arr.length >= 5) arr.push(folder);
				creditsStuff.push(arr);
			}
			creditsStuff.push(['']);
		}

		for (language in Language.getLanguages())
		{
			if(language == 'English') continue; // skip this item

			var creditsFile:String = null;
			if (folder != null && folder.trim().length > 0)
				creditsFile = Paths.mods(folder + '/data/credits-' + language.toLowerCase() + '.txt');
			else
				creditsFile = Paths.mods('data/credits-' + language.toLowerCase() + '.txt');

			if (FileSystem.exists(creditsFile))
			{
				var firstarray:Array<String> = File.getContent(creditsFile).split('\n');
				for (i in firstarray)
				{
					var arr:Array<String> = i.replace('\\n', '\n').split("::");
					if (arr.length >= 5)
						arr.push(folder);
					creditsStuff.push(arr);
				}
				creditsStuff.push(['']);
			}
		}
		modsAdded.push(folder);
	}
	#end

	function getCurrentBGColor() {
		var bgColor:String = creditsStuff[curSelected][4];
		if(!bgColor.startsWith('0xFF')) {
			bgColor = '0xFF' + bgColor;
		}
		return Std.parseInt(bgColor);
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}
