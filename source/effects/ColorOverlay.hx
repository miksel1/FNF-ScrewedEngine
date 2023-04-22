package effects;

import lime.math.Vector4;
import flixel.FlxBasic;
import flixel.system.FlxAssets.FlxShader;

/**
 * Replaces the color by the specified values.
 * Made by Wither362
 */
class ColorOverlayShader extends FlxShader {
	@:glFragmentSource('
		#pragma header
		uniform vec4 color;

		void main()
		{
			gl_FragColor = color;
		}')
	public function new() {
		super();
	}
}
/**
 * Replaces the color by the specified values.
 * Made by Wither362
 */
class ColorOverlay extends FlxBasic {
	public var shader(default, null):ColorOverlayShader = new ColorOverlayShader();

	public var color(default, set):Vector4 = new Vector4(0.0, 0.0, 0.0, 1.0);

	function set_color(v:Vector4):Vector4 {
		color = v;
		this.shader.color.value = [v.x, v.y, v.z, v.w];
		return v;
	}
	public function new() {
		super();
	}
}