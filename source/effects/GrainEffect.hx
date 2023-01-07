package effects;

import openfl.Lib;
import effects.openfl8.GrainShader;

class GrainEffect {
	/**
	 * The instance of the actual shader class
	 */
	public var shader(default, null):GrainShader;

	public function new() {
		shader = new GrainShader();
	}

	public function update(?elapsed) {
		shader.uTime.value = [Lib.getTimer() / 1000];
	}
}