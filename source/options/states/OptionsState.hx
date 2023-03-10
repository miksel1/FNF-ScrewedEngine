package options.states;

import flixel.FlxState;
import Language.LanguageArray;
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

class OptionsState extends MusicBeatState
{
	public static var max:Int = 2;

	var pageOptions:Map<Int, LanguageArray> = [
		1 => {
			a: [
				'Note Colors',
				'Controls',
				'Gameplay',
				'Language',
				#if GAMEJOLT_ALLOWED
				'Gamejolt'
				#end
			],
			spanish: [
				'Colores de Notas',
				'Controles',
				'Gameplay',
				'Idioma',
				#if GAMEJOLT_ALLOWED
				'Gamejolt'
				#end
			]
		},
		2 => {
			a: [
				'Graphics',
				'Adjust Delay and Combo',
				'Visuals and UI',
			],
			spanish: [
				'Gráficos',
				'Ajustar Retraso y Combo',
				'Visualización y UI',
			]
		}
	];
	var curPage:Int = 1;

	var options(get, null):LanguageArray;

	inline function get_options():LanguageArray {
		return pageOptions.get(curPage);
	}

	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

	function openSelectedSubstate(label:String) {
		//Options.page = this;
		switch(label) {
			case 'Note Colors' | 'Colores de Notas':
				openSubState(new options.substates.NotesSubState());
			case 'Controls' | 'Controles':
				openSubState(new options.substates.ControlsSubState());
			case 'Graphics' | 'Gráficos':
				openSubState(new options.substates.GraphicsSettingsSubState());
			case 'Visuals and UI' | 'Visualización y UI':
				openSubState(new options.substates.VisualsUISubState());
			case 'Gameplay':
				openSubState(new options.substates.GameplaySettingsSubState());
			case 'Adjust Delay and Combo' | 'Ajustar Retraso y Combo':
				LoadingState.loadAndSwitchState(new options.states.NoteOffsetState());
			case 'Language' | 'Idioma':
				openSubState(new options.substates.LanguageSettingsSubState());
			#if GAMEJOLT_ALLOWED
			case 'Gamejolt':
				LoadingState.loadAndSwitchState(new gamejolt.menus.GJOptionsState());
			#end
		}
	}

	var selectorLeft:Alphabet;
	var selectorRight:Alphabet;
	var leftArrow:Alphabet;
	var rightArrow:Alphabet;
	var pageText:Alphabet;

	override function create() {
		#if desktop
		DiscordClient.changePresence("Options Menu", null);
		#end

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		bg.color = 0xFFea71fd;
		bg.updateHitbox();

		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		grpOptions = new FlxTypedGroup<Alphabet>();
		add(grpOptions);

		selectorLeft = new Alphabet(0, 0, '>', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		add(selectorRight);

		pageText = new Alphabet(0, 10, 'Page 1/' + max, false);
		pageText.screenCenter(X);
		add(pageText);
		leftArrow = new Alphabet(20, 0, '<', true);
		leftArrow.screenCenter(Y);
		add(leftArrow);
		rightArrow = new Alphabet(FlxG.width - 60, 0, '>', true);
		rightArrow.screenCenter(Y);
		add(rightArrow);

		changeSelection();
		changePage();
		ClientPrefs.saveSettings();

		super.create();
	}

	override function closeSubState() {
		super.closeSubState();
		ClientPrefs.saveSettings();
	}

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (controls.UI_UP_P) {
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P) {
			changeSelection(1);
		}

		if(controls.UI_RIGHT_P) {
			changePage(1);
		}
		if(controls.UI_LEFT_P) {
			changePage(-1);
		}

		if (controls.BACK) {
			FlxG.sound.play(Paths.sound('cancelMenu'));
			if(PauseSubState.toPlayState) {
				MusicBeatState.switchState(new PlayState());
				PauseSubState.toPlayState = false;
			} else
				MusicBeatState.switchState(new MainMenuState());
		}

		if (controls.ACCEPT) {
			openSelectedSubstate(Language.getArray(options)[curSelected]);
		}
	}

	function changePage(change:Int = 0) {
		curPage += change;
		if (curPage <= 0)
			curPage = max;
		if (curPage > max)
			curPage = 1;

		if(grpOptions.length != 0) {
			grpOptions.clear();
		}
		var offset:Float = 70;
		var separation:Float = 100; // i dont really know...
		var first:Null<Float> = null;
		for (i in 0...Language.getArray(options).length)
		{
			var option = Language.getArray(options)[i];

			var optionText:Alphabet = new Alphabet(0, 0, option, true);
			optionText.screenCenter();
			optionText.y += (separation * (i - (Language.getArray(options).length / 2))) + 50 + offset;
			if(first == null)
				first = optionText.y;

			grpOptions.add(optionText);
		}
		pageText.text = 'Page ' + curPage + '/' + max;
		changeSelection();
	}
	function changeSelection(change:Int = 0) {
		curSelected += change;
		if (curSelected < 0)
			curSelected = Language.getArray(options).length - 1;
		if (curSelected >= Language.getArray(options).length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpOptions.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			if (item.targetY == 0) {
				item.alpha = 1;
				selectorLeft.x = item.x - 63;
				selectorLeft.y = item.y;
				selectorRight.x = item.x + item.width + 15;
				selectorRight.y = item.y;
			}
		}
		FlxG.sound.play(Paths.sound('scrollMenu'));
	}
}