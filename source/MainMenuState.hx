package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;
import flixel.input.keyboard.FlxKey;

import haxe.Json;
#if MODS_ALLOWED
import sys.FileSystem;
import sys.io.File;
#end

using StringTools;

typedef MainMenuData =
{
 storymodeP:Array<Int>,
 freeplayP:Array<Int>,
 creditsP:Array<Int>,
 donateP:Array<Int>,
 optionsP:Array<Int>,
 storymodeS:Array<Float>,
 freeplayS:Array<Float>,
 creditsS:Array<Float>,
 donateS:Array<Float>,
 optionsS:Array<Float>,
 centerX:Bool
}

class MainMenuState extends MusicBeatState
{
	public static var screwedEngineVersion:String = '0.1.0';
	public static var psychEngineVersion:String = '0.6.3'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;

	var terminalKeys:Array<String> = [
		'TERMINAL'
	];
	var allowedKeys:String = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
	var terminalKeysBuffer:String = '';

	var optionShit:Array<String> = [
		'story_mode',
		'freeplay',
		'credits',
		#if !switch 'donate', #end
		'options'
	];

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;
	var char:FlxSprite;
	var debugKeys:Array<FlxKey>;

	var mainMenuJSON:MainMenuData;

	override function create()
	{
		#if MODS_ALLOWED
		Paths.pushGlobalMods();
		#end
		WeekData.loadTheFirstEnabledMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

        #if (desktop && MODS_ALLOWED)
		var path = "mods/" + Paths.currentModDirectory + "/images/mainmenu/mainMenuLayout.json";
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)) {
			path = "mods/images/mainmenu/mainMenuLayout.json";
		}
		//trace(path, FileSystem.exists(path));
		if (!FileSystem.exists(path)) {
			path = "assets/images/mainmenu/mainMenuLayout.json";
		}
		//trace(path, FileSystem.exists(path));
		mainMenuJSON = Json.parse(File.getContent(path));
		#else
		var path = Paths.getPreloadPath("images/mainmenu/mainMenuLayout.json");
		mainMenuJSON = Json.parse(Assets.getText(path));
        #end

		debugKeys = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement, false);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.25 - (0.05 * (optionShit.length - 4)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var scale:Float = 1;
		/*if(optionShit.length > 6) {
			scale = 6 / optionShit.length;
		}*/

		//Story Mode
		var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
		var menuItem:FlxSprite = new FlxSprite(mainMenuJSON.storymodeP[0], mainMenuJSON.storymodeP[1] + offset);
		menuItem.scale.x = mainMenuJSON.storymodeS[0];
		menuItem.scale.y = mainMenuJSON.storymodeS[1];
		menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[0]);
		menuItem.animation.addByPrefix('idle', optionShit[0] + " basic", 24);
		menuItem.animation.addByPrefix('selected', optionShit[0] + " white", 24);
		menuItem.animation.play('idle');
		menuItem.ID = 0;
		if(mainMenuJSON.centerX == true){
			menuItem.screenCenter(X);
		}
		//menuItem.screenCenter(X);
		menuItems.add(menuItem);
		var scr:Float = (optionShit.length - 4) * 0.135;
		if(optionShit.length < 6) scr = 0;
		menuItem.scrollFactor.set(0, scr);
		menuItem.antialiasing = ClientPrefs.globalAntialiasing;
		//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
		menuItem.updateHitbox();

		//Freeplay
		var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
		var menuItem:FlxSprite = new FlxSprite(mainMenuJSON.freeplayP[0], mainMenuJSON.freeplayP[1] + offset);
		menuItem.scale.x = mainMenuJSON.freeplayS[0];
		menuItem.scale.y = mainMenuJSON.freeplayS[1];
		menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[1]);
		menuItem.animation.addByPrefix('idle', optionShit[1] + " basic", 24);
		menuItem.animation.addByPrefix('selected', optionShit[1] + " white", 24);
		menuItem.animation.play('idle');
		menuItem.ID = 1;
		if(mainMenuJSON.centerX == true){
			menuItem.screenCenter(X);
		}
		//menuItem.screenCenter(X);
		menuItems.add(menuItem);
		var scr:Float = (optionShit.length - 4) * 0.135;
		if(optionShit.length < 6) scr = 0;
		menuItem.scrollFactor.set(0, scr);
		menuItem.antialiasing = ClientPrefs.globalAntialiasing;
		//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
		menuItem.updateHitbox();

		//Credits
		var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
		var menuItem:FlxSprite = new FlxSprite(mainMenuJSON.creditsP[0], mainMenuJSON.creditsP[1] + offset);
		menuItem.scale.x = mainMenuJSON.creditsS[0];
		menuItem.scale.y = mainMenuJSON.creditsS[1];
		menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[2]);
		menuItem.animation.addByPrefix('idle', optionShit[2] + " basic", 24);
		menuItem.animation.addByPrefix('selected', optionShit[2] + " white", 24);
		menuItem.animation.play('idle');
		menuItem.ID = 2;
		if(mainMenuJSON.centerX == true){
			menuItem.screenCenter(X);
		}
		//menuItem.screenCenter(X);
		menuItems.add(menuItem);
		var scr:Float = (optionShit.length - 4) * 0.135;
		if(optionShit.length < 6) scr = 0;
		menuItem.scrollFactor.set(0, scr);
		menuItem.antialiasing = ClientPrefs.globalAntialiasing;
		//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
		menuItem.updateHitbox();

		//Donate
		var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
		var menuItem:FlxSprite = new FlxSprite(mainMenuJSON.donateP[0], mainMenuJSON.donateP[1] + offset);
		menuItem.scale.x = mainMenuJSON.donateS[0];
		menuItem.scale.y = mainMenuJSON.donateS[1];
		menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[3]);
		menuItem.animation.addByPrefix('idle', optionShit[3] + " basic", 24);
		menuItem.animation.addByPrefix('selected', optionShit[3] + " white", 24);
		menuItem.animation.play('idle');
		menuItem.ID = 3;
		if(mainMenuJSON.centerX == true){
			menuItem.screenCenter(X);
		}
		//menuItem.screenCenter(X);
		menuItems.add(menuItem);
		var scr:Float = (optionShit.length - 4) * 0.135;
		if(optionShit.length < 6) scr = 0;
		menuItem.scrollFactor.set(0, scr);
		menuItem.antialiasing = ClientPrefs.globalAntialiasing;
		//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
		menuItem.updateHitbox();

		//Options
		var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
		var menuItem:FlxSprite = new FlxSprite(mainMenuJSON.optionsP[0], mainMenuJSON.optionsP[1] + offset);
		menuItem.scale.x = mainMenuJSON.optionsS[0];
		menuItem.scale.y = mainMenuJSON.optionsS[1];
		menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[4]);
		menuItem.animation.addByPrefix('idle', optionShit[4] + " basic", 24);
		menuItem.animation.addByPrefix('selected', optionShit[4] + " white", 24);
		menuItem.animation.play('idle');
		menuItem.ID = 4;
		if(mainMenuJSON.centerX == true){
			menuItem.screenCenter(X);
		}
		//menuItem.screenCenter(X);
		menuItems.add(menuItem);
		var scr:Float = (optionShit.length - 4) * 0.135;
		if(optionShit.length < 6) scr = 0;
		menuItem.scrollFactor.set(0, scr);
		menuItem.antialiasing = ClientPrefs.globalAntialiasing;
		//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
		menuItem.updateHitbox();

		FlxG.camera.follow(camFollowPos, null, 1);

		var versionShit:FlxText = new FlxText(12, FlxG.height - 64, 0, "Screwed Engine v" + screwedEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "Friday Night Funkin' v" + Application.current.meta.get('version'), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18) {
			var achieveID:Int = Achievements.getAchievementIndex('friday_night_play');
			if(!Achievements.isAchievementUnlocked(Achievements.achievementsStuff[achieveID][2])) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
				Achievements.achievementsMap.set(Achievements.achievementsStuff[achieveID][2], true);
				giveAchievement();
				ClientPrefs.saveSettings();
			}
		}
		#end

		super.create();

		switch(FlxG.random.int(1, 7))
		{
			case 1:
			char = new FlxSprite(820, 170).loadGraphic(Paths.image('mainmenu/templeBambi'));//put your cords and image here
            char.frames = Paths.getSparrowAtlas('mainmenu/templeBambi');//here put the name of the xml
            char.animation.addByPrefix('idleA', 'idle', 24, true);//on 'idle' change it to your xml one
            char .animation.play('idleA');//you can rename the anim however you want to
            char.scrollFactor.set();
            FlxG.sound.play(Paths.sound('appear'), 2);
            char.flipX = true; //this is for flipping it to look left instead of right you can make it however you want
            char.antialiasing = ClientPrefs.globalAntialiasing;
            add(char);

			case 2:
			char = new FlxSprite(820, 170).loadGraphic(Paths.image('mainmenu/BOYFRIEND'));//put your cords and image here
            char.frames = Paths.getSparrowAtlas('mainmenu/BOYFRIEND');//here put the name of the xml
            char.animation.addByPrefix('idleB', 'BF idle dance', 24, true);//on 'BF idle dance' change it to your xml one
            char .animation.play('idleB');//you can rename the anim however you want to
            char.scrollFactor.set();
            FlxG.sound.play(Paths.sound('appear'), 2);
            char.flipX = false; //this is for flipping it to look left instead of right you can make it however you want
            char.antialiasing = ClientPrefs.globalAntialiasing;
            add(char);

			case 3:
			char = new FlxSprite(500, -200).loadGraphic(Paths.image('mainmenu/purple_girl'));//put your cords and image here
            char.frames = Paths.getSparrowAtlas('mainmenu/purple_girl');//here put the name of the xml
            char.animation.addByPrefix('idleC', 'purple girl idle', 12, true);//on 'BF idle dance' change it to your xml one
            char .animation.play('idleC');//you can rename the anim however you want to
            char.scrollFactor.set();
            FlxG.sound.play(Paths.sound('appear'), 2);
            char.flipX = true; //this is for flipping it to look left instead of right you can make it however you want
            char.antialiasing = ClientPrefs.globalAntialiasing;
            add(char);

			case 4:
			char = new FlxSprite(500, -200).loadGraphic(Paths.image('mainmenu/blue_dude'));//put your cords and image here
            char.frames = Paths.getSparrowAtlas('mainmenu/blue_dude');//here put the name of the xml
            char.animation.addByPrefix('idleE', 'blue dude idle', 12, true);//on 'BF idle dance' change it to your xml one
            char .animation.play('idleE');//you can rename the anim however you want to
            char.scrollFactor.set();
            FlxG.sound.play(Paths.sound('appear'), 2);
            char.flipX = true; //this is for flipping it to look left instead of right you can make it however you want
            char.antialiasing = ClientPrefs.globalAntialiasing;
            add(char);

			case 5:
			char = new FlxSprite(500, -200).loadGraphic(Paths.image('mainmenu/d.e.b'));//put your cords and image here
            char.frames = Paths.getSparrowAtlas('mainmenu/d.e.b');//here put the name of the xml
            char.animation.addByPrefix('idleF', 'd.e.b idle', 12, true);//on 'BF idle dance' change it to your xml one
            char .animation.play('idleF');//you can rename the anim however you want to
            char.scrollFactor.set();
            FlxG.sound.play(Paths.sound('appear'), 2);
            char.flipX = true; //this is for flipping it to look left instead of right you can make it however you want
            char.antialiasing = ClientPrefs.globalAntialiasing;
            add(char);

			case 6:
			char = new FlxSprite(820, -170).loadGraphic(Paths.image('mainmenu/dave'));//put your cords and image here
            char.frames = Paths.getSparrowAtlas('mainmenu/dave');//here put the name of the xml
            char.animation.addByPrefix('idleG', 'idle', 24, true);//on 'BF idle dance' change it to your xml one
            char .animation.play('idleG');//you can rename the anim however you want to
            char.scrollFactor.set();
            FlxG.sound.play(Paths.sound('appear'), 2);
            char.flipX = true; //this is for flipping it to look left instead of right you can make it however you want
            char.antialiasing = ClientPrefs.globalAntialiasing;
            add(char);

			case 7:
			char = new FlxSprite(500, -200).loadGraphic(Paths.image('mainmenu/worried_shitface'));//put your cords and image here
            char.frames = Paths.getSparrowAtlas('mainmenu/worried_shitface');//here put the name of the xml
            char.animation.addByPrefix('idleH', 'worried shitface idle', 12, true);//on 'BF idle dance' change it to your xml one
            char .animation.play('idleH');//you can rename the anim however you want to
            char.scrollFactor.set();
            FlxG.sound.play(Paths.sound('appear'), 2);
            char.flipX = true; //this is for flipping it to look left instead of right you can make it however you want
            char.antialiasing = ClientPrefs.globalAntialiasing;
            add(char);
		}
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	function giveAchievement() {
		add(new AchievementObject('friday_night_play', camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement "friday_night_play"');
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 7.5, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://www.youtube.com/channel/UCpqxNBH2KzhAqVa4mf7tcBQ');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.4, {
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										/*if(FlxG.keys.pressed.F)
											MusicBeatState.switchState(new FreeplaySelectState());
										else*/
											MusicBeatState.switchState(new FreeplayState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										LoadingState.loadAndSwitchState(new options.states.OptionsState.OptionsStatePage1());
								}
							});
						}
					});
				}
			}
			else if (FlxG.keys.firstJustPressed() != FlxKey.NONE  #if desktop && !FlxG.keys.anyJustPressed(debugKeys) #end)
			{
				var keyPressed:FlxKey = FlxG.keys.firstJustPressed();
				var keyName:String = Std.string(keyPressed);
				if(allowedKeys.contains(keyName)) {
					terminalKeysBuffer += keyName;
					if(terminalKeysBuffer.length >= 32) terminalKeysBuffer = terminalKeysBuffer.substring(1);
					trace('Test! Allowed Key pressed!!! Buffer: ' + terminalKeysBuffer);

					for (wordRaw in terminalKeys)
					{
						var word:String = wordRaw.toUpperCase(); //just for being sure you're doing it right
						if(terminalKeysBuffer.contains(word)) {
							/*#if (!debug && MODS_ALLOWED)
							if(ClientPrefs.modData.exists(Paths.currentModDirectory))
								if(ClientPrefs.modData.get(Paths.currentModDirectory).exists('allowTerminal'))
									if(ClientPrefs.modData.get(Paths.currentModDirectory).get('allowTerminal')) {
							#end*/
										FlxG.sound.music.pause();
										MusicBeatState.switchState(new TerminalState());
									//}
						}
					}
				}
			}
			#if desktop
			else if (FlxG.keys.anyJustPressed(debugKeys))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			if(mainMenuJSON.centerX == true){
				spr.screenCenter(X);
			}
			//spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.updateHitbox();

			if (spr.ID == curSelected)
			{
				spr.animation.play('selected');
				var add:Float = 0;
				if(menuItems.length > 4) {
					add = menuItems.length * 8;
				}
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y - add);
				spr.centerOffsets();
			}
		});
	}
}

