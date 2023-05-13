package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.effects.FlxFlicker;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class FlashingState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		warnText = new FlxText(0, 0, FlxG.width,
			"Hey, watch out!\n
			This Mod contains some flashing lights!\n
			Press ENTER to disable them now or go to Options Menu.\n
			Press ESCAPE to ignore this message.\n
			You've been warned!",
			32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);
	}

	override function update(elapsed:Float)
	{
		if(!leftState) {
			var back:Bool = controls.BACK;
			if (controls.ACCEPT || back) {
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				if(!back) {
					ClientPrefs.flashing = false;
					ClientPrefs.saveSettings();
					FlxG.sound.play(Paths.sound('confirmMenu'));
					FlxFlicker.flicker(warnText, 1, 0.1, false, true, function(flk:FlxFlicker) {
						new FlxTimer().start(0.5, function (tmr:FlxTimer) {
							MusicBeatState.switchState(new TitleState());
						});
					});
				} else {
					ClientPrefs.flashing = true;
					ClientPrefs.saveSettings();
					FlxG.sound.play(Paths.sound('cancelMenu'));
					FlxTween.tween(warnText, {alpha: 0}, 1, {
						onComplete: function (twn:FlxTween) {
							MusicBeatState.switchState(new TitleState());
						}
					});
				}
			}
		}
		super.update(elapsed);
	}
}

class LanguageState extends MusicBeatState
{
	public static var leftState:Bool = false;

	var warnText:FlxText;
	var curLanguage:Int = 0;

	override function create()
	{
		super.create();

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		add(bg);

		warnText = new FlxText(0, 0, FlxG.width, getDaText(), 32);
		warnText.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, CENTER);
		warnText.screenCenter(Y);
		add(warnText);
	}

	override function update(elapsed:Float)
	{
		if(leftState) {
			if(FlxG.keys.anyJustPressed([LEFT, RIGHT])) {
				if(FlxG.keys.justPressed.LEFT) curLanguage -= 1;
				else curLanguage += 1;
				if(curLanguage < 0) curLanguage = Language.getLanguages().length - 1;
				if(curLanguage >= Language.getLanguages().length) curLanguage = 0;
				if(warnText != null) {
					warnText.text = getDaText();
				}
			}
		} else {
			if(controls.BACK || controls.ACCEPT) {
				final accept = controls.ACCEPT;
				if(accept)
					ClientPrefs.language = Language.getLanguages()[curLanguage];
				leftState = true;
				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				FlxTween.tween(warnText, {alpha: 0}, 1, {
					onComplete: function (twn:FlxTween) {
						if(accept) TitleState.goToOptions = true;
						MusicBeatState.switchState(new TitleState());
					}
				});
			}
		}
		super.update(elapsed);
	}

	function getDaText():String {
		return Language.getString({
			s: "Hey, looks like you didn't selected language!\n
			Select the one you prefer in the options menu!\n
			Press " + Std.string(Controls.Action.BACK).toUpperCase() + " to select it later.\n
			Press " + Std.string(Controls.Action.ACCEPT).toUpperCase() + " to make the language of this text your language.\n
			\nPress LEFT or RIGHT to change the language of this text.",

			spanish:
			"¡Hey, parece que aún no has elegido idioma!\n
			¡Selecciona el que prefieras en el menú de opciones o aquí!\n
			Pulsa " + Std.string(Controls.Action.BACK).toUpperCase() + " para seleccionarlo luego.\n
			Pulsa " + Std.string(Controls.Action.ACCEPT).toUpperCase() + " para que el idioma de este texto sea el tuyo.\n
			\nPulsa IZQUIERDA o DERECHA para cambiar el idioma de este texto."
		});
	}
}
