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

class Options {
	public static var max:Int = 2;
}

class OptionsStatePage1 extends MusicBeatState
{
	var defaults:Array<String> = [
		'Note Colors',
		'Controls',
		'Adjust Delay and Combo',
		'Graphics',
		'Visuals and UI',
		'Gameplay',
		'Language'
	];
	var options:LanguageArray = {
		a: [
			'Note Colors',
			'Controls',
			'Graphics',
			'Visuals and UI',
			'Gameplay',
			'Language'
		],
		spanish: [
			'Colores de Notas',
			'Controles',
			'Gráficos',
			'Visualización y UI',
			'Gameplay',
			'Idioma'
		]
	};
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

		selectorLeft = new Alphabet(0, 0, '>', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		add(selectorRight);

		pageText = new Alphabet(0, 0, 'page 1/' + Options.max, false);
		pageText.screenCenter();
		pageText.y += (separation * (0 - (Language.getArray(options).length / 2))) + 50 - offset;
		add(pageText);
		leftArrow = new Alphabet(FlxG.width / (FlxG.width / 4), first + offset, '<', true);
		leftArrow.scaleX = leftArrow.scaleY = 1.25;
		leftArrow.screenCenter();
		leftArrow.y = pageText.y;
		leftArrow.x = pageText.x - 63;
		add(leftArrow);
		rightArrow = new Alphabet(0, 0, '>', true);
		rightArrow.y = pageText.y;
		rightArrow.x = pageText.x + 63;
		add(rightArrow);

		changeSelection();
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
			MusicBeatState.switchState(new OptionsStatePage2());
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
class OptionsStatePage2 extends MusicBeatState
{
	var defaults:Array<String> = [
		'Note Colors',
		'Controls',
		'Adjust Delay and Combo',
		'Graphics',
		'Visuals and UI',
		'Gameplay',
		'Language'
	];
	var options:LanguageArray = {
		a: [
			'Adjust Delay and Combo',
		],
		spanish: [
			'Ajustar Retraso y Combo',
		]
	};
	private var grpOptions:FlxTypedGroup<Alphabet>;
	private static var curSelected:Int = 0;
	public static var menuBG:FlxSprite;

	function openSelectedSubstate(label:String) {
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

		selectorLeft = new Alphabet(0, 0, '>', true);
		add(selectorLeft);
		selectorRight = new Alphabet(0, 0, '<', true);
		add(selectorRight);

		pageText = new Alphabet(0, 0, 'page 2/' + Options.max, false);
		pageText.screenCenter();
		pageText.y += (separation * (0 - (Language.getArray(options).length / 2))) + 50 - offset;
		add(pageText);
		leftArrow = new Alphabet(FlxG.width / (FlxG.width / 4), first + offset, '<', true);
		leftArrow.scaleX = leftArrow.scaleY = 1.25;
		leftArrow.screenCenter();
		leftArrow.y = pageText.y;
		leftArrow.x = pageText.x - 63;
		add(leftArrow);
		rightArrow = new Alphabet(0, 0, '>', true);
		rightArrow.y = pageText.y;
		rightArrow.x = pageText.x + 63;
		add(rightArrow);

		changeSelection();
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

		if(controls.UI_LEFT_P) {
			MusicBeatState.switchState(new OptionsStatePage1());
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