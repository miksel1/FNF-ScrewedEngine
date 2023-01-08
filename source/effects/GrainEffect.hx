package effects;

import openfl.Lib;
import effects.openfl8.GrainShader;

/**
 * IM NEW TO SHADERS OK??????!!!
 */
class GrainEffect {
	public static inline final MAX_GRAIN_SIZE:Float = 2.5;
	public static inline final MIN_GRAIN_SIZE:Float = 1.5;

	/**
	 * The instance of the actual shader class
	 */
	public var shader(default, null):GrainShader;

	public var textelSize(default, set):Float = 256;

	/**
	 * Amount of color this shader has, I recommend it to 0.6 (default)
	 */
	public var colorAmount(default, set):Float = 0.6;

	/**
	 * Defines if the shader has color, defaults to `false`
	 */
	public var colored(default, set):Bool = false;

	/**
	 * The amount of grain in this shader, defaults to `0.05`
	 */
	public var grainAmount(default, set):Float = 0.05;

	/**
	 * Grain particle size (from `1.5` to `2.5`)
	 */
	public var grainSize(default, set):Float = 1.6;

	/**
	 * Luminance of this shader
	 */
	public var lumAmount(default, set):Float = 1.0;

	public function new(textelSize:Float = 256) {
		shader = new GrainShader();
		this.textelSize = textelSize;

		shader.coloramount.value = [colorAmount];
		shader.colored.value = [colored];
		shader.grainamount.value = [grainAmount];
		shader.grainsize.value = [grainSize];
		shader.lumamount.value = [lumAmount];

		shader.uTime.value = [0];
	}

	public function update(?elapsed) {
		shader.uTime.value = [Lib.getTimer() / 1000];
	}

	function set_textelSize(v:Float):Float {
		shader.permTexUnit.value = [1 / textelSize];
		shader.permTexUnitHalf.value = [0.5 / textelSize];
		return textelSize = v;
	}

	function set_colorAmount(v:Float):Float {
		shader.coloramount.value = [v];
		return colorAmount = v;
	}

	function set_colored(v:Bool):Bool {
		shader.colored.value = [v];
		return colored = v;
	}

	function set_grainSize(v:Float):Float {
		if(v < MIN_GRAIN_SIZE)
			v = MIN_GRAIN_SIZE;
		if(v > MAX_GRAIN_SIZE)
			v = MAX_GRAIN_SIZE;
		shader.grainsize.value = [v];
		return grainSize = v;
	}

	function set_grainAmount(v:Float):Float {
		shader.grainamount.value = [v];
		return grainAmount = v;
	}

	function set_lumAmount(v:Float):Float {
		shader.lumamount.value = [v];
		return lumAmount = v;
	}
}