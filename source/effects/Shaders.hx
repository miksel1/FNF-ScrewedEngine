package effects;

import flixel.system.FlxAssets.FlxShader;

/*  VS DAVE AND BAMBI SHADERS IMPLEMENTATION
    ALL OF THIS CODE WAS WROTE BY MTM101, ERIZUR AND T5MPLER (BUGFIXES)

    If you see a SHADERS_ENABLED flag here is because of the following reason:
        Apple deprecated OpenGL support back in 2018, leaving it on version 4.1
        Most shaders here don't support this OpenGL version,
        We would fix the errors and make it cross-compatible with ALL platforms,
        but this would take a lot of time and investigation as support for macOS barely exists.

        We are not trying to bully macOS users to "download other os" with this.
        These are things we are can't fix.
        Sorry for any inconvenience.
*/

class GlitchEffect
{
    public var shader(default, null):GlitchShader = new GlitchShader();

    #if SHADERS_ENABLED
    public var waveSpeed(default, set):Float = 0;
	public var waveFrequency(default, set):Float = 0;
	public var waveAmplitude(default, set):Float = 0;
    public var Enabled(default, set):Bool = true;

	public function new():Void
	{
		shader.uTime.value = [0];
	}

    public function update(elapsed:Float):Void
    {
        shader.uTime.value[0] += elapsed;
    }

    function set_waveSpeed(v:Float):Float
    {
        waveSpeed = v;
        shader.uSpeed.value = [waveSpeed];
        return v;
    }
    function set_Enabled(v:Bool):Bool
    {
        Enabled = v;
        shader.uEnabled.value = [Enabled];
        return v;
    }

    function set_waveFrequency(v:Float):Float
    {
        waveFrequency = v;
        shader.uFrequency.value = [waveFrequency];
        return v;
    }

    function set_waveAmplitude(v:Float):Float
    {
        waveAmplitude = v;
        shader.uWaveAmplitude.value = [waveAmplitude];
        return v;
    }
    #end
}
class GlitchShader extends FlxShader
{
    #if SHADERS_ENABLED
    @:glFragmentSource('
    #pragma header
    //uniform float tx, ty; // x,y waves phase

    //modified version of the wave shader to create weird garbled corruption like messes
    uniform float uTime;

    /**
     * How fast the waves move over time
     */
    uniform float uSpeed;

    /**
     * Number of waves over time
     */
    uniform float uFrequency;

    uniform bool uEnabled;

    /**
     * How much the pixels are going to stretch over the waves
     */
    uniform float uWaveAmplitude;

    vec2 sineWave(vec2 pt)
    {
        float x = 0.0;
        float y = 0.0;

        float offsetX = sin(pt.y * uFrequency + uTime * uSpeed) * (uWaveAmplitude / pt.x * pt.y);
        float offsetY = sin(pt.x * uFrequency - uTime * uSpeed) * (uWaveAmplitude / pt.y * pt.x);
        pt.x += offsetX; // * (pt.y - 1.0); // <- Uncomment to stop bottom part of the screen from moving
        pt.y += offsetY;

        return vec2(pt.x + x, pt.y + y);
    }

    void main()
    {
        vec2 uv = sineWave(openfl_TextureCoordv);
        gl_FragColor = texture2D(bitmap, uv);
    }')
    #end

    public function new()
    {
       super();
    }
}

class DistortBGEffect
{
    public var shader(default,null):DistortBGShader = new DistortBGShader();

    #if SHADERS_ENABLED
    public var waveSpeed(default, set):Float = 0;
	public var waveFrequency(default, set):Float = 0;
	public var waveAmplitude(default, set):Float = 0;

	public function new():Void
	{
		shader.uTime.value = [0];
	}

    public function update(elapsed:Float):Void
    {
        shader.uTime.value[0] += elapsed;
    }


    function set_waveSpeed(v:Float):Float
    {
        waveSpeed = v;
        shader.uSpeed.value = [waveSpeed];
        return v;
    }

    function set_waveFrequency(v:Float):Float
    {
        waveFrequency = v;
        shader.uFrequency.value = [waveFrequency];
        return v;
    }

    function set_waveAmplitude(v:Float):Float
    {
        waveAmplitude = v;
        shader.uWaveAmplitude.value = [waveAmplitude];
        return v;
    }
    #end
}
class DistortBGShader extends FlxShader
{
    #if SHADERS_ENABLED
    @:glFragmentSource('
    #pragma header
    //uniform float tx, ty; // x,y waves phase

    //gives the character a glitchy, distorted outline
    uniform float uTime;

    /**
     * How fast the waves move over time
     */
    uniform float uSpeed;

    /**
     * Number of waves over time
     */
    uniform float uFrequency;

    /**
     * How much the pixels are going to stretch over the waves
     */
    uniform float uWaveAmplitude;

    vec2 sineWave(vec2 pt)
    {
        float x = 0.0;
        float y = 0.0;

        float offsetX = sin(pt.x * uFrequency + uTime * uSpeed) * (uWaveAmplitude / pt.x * pt.y);
        float offsetY = sin(pt.y * uFrequency - uTime * uSpeed) * (uWaveAmplitude);
        pt.x += offsetX; // * (pt.y - 1.0); // <- Uncomment to stop bottom part of the screen from moving
        pt.y += offsetY;

        return vec2(pt.x + x, pt.y + y);
    }

    vec4 makeBlack(vec4 pt)
    {
        return vec4(0, 0, 0, pt.w);
    }

    void main()
    {
        vec2 uv = sineWave(openfl_TextureCoordv);
        gl_FragColor = makeBlack(texture2D(bitmap, uv)) + texture2D(bitmap,openfl_TextureCoordv);
    }')
    #end

    public function new()
    {
       super();
    }
}

class PulseEffect
{
    public var shader(default,null):PulseShader = new PulseShader();

    #if SHADERS_ENABLED
    public var waveSpeed(default, set):Float = 0;
	public var waveFrequency(default, set):Float = 0;
	public var waveAmplitude(default, set):Float = 0;
    public var Enabled(default, set):Bool = false;

	public function new():Void
	{
		shader.uTime.value = [0];
        shader.uampmul.value = [0];
        shader.uEnabled.value = [false];
	}

    public function update(elapsed:Float):Void
    {
        shader.uTime.value[0] += elapsed;
    }


    function set_waveSpeed(v:Float):Float
    {
        waveSpeed = v;
        shader.uSpeed.value = [waveSpeed];
        return v;
    }

    function set_Enabled(v:Bool):Bool
    {
        Enabled = v;
        shader.uEnabled.value = [Enabled];
        return v;
    }
    
    function set_waveFrequency(v:Float):Float
    {
        waveFrequency = v;
        shader.uFrequency.value = [waveFrequency];
        return v;
    }
    
    function set_waveAmplitude(v:Float):Float
    {
        waveAmplitude = v;
        shader.uWaveAmplitude.value = [waveAmplitude];
        return v;
    }
    #end
}
class PulseShader extends FlxShader
{
    #if SHADERS_ENABLED
    @:glFragmentSource('
    #pragma header
    uniform float uampmul;

    //modified version of the wave shader to create weird garbled corruption like messes
    uniform float uTime;

    /**
     * How fast the waves move over time
     */
    uniform float uSpeed;

    /**
     * Number of waves over time
     */
    uniform float uFrequency;

    uniform bool uEnabled;

    /**
     * How much the pixels are going to stretch over the waves
     */
    uniform float uWaveAmplitude;

    vec4 sineWave(vec4 pt, vec2 pos)
    {
        if (uampmul > 0.0)
        {
            float offsetX = sin(pt.y * uFrequency + uTime * uSpeed);
            float offsetY = sin(pt.x * (uFrequency * 2.0) - (uTime / 2.0) * uSpeed);
            float offsetZ = sin(pt.z * (uFrequency / 2.0) + (uTime / 3.0) * uSpeed);
            pt.x = mix(pt.x,sin(pt.x / 2.0 * pt.y + (5.0 * offsetX) * pt.z),uWaveAmplitude * uampmul);
            pt.y = mix(pt.y,sin(pt.y / 3.0 * pt.z + (2.0 * offsetZ) - pt.x),uWaveAmplitude * uampmul);
            pt.z = mix(pt.z,sin(pt.z / 6.0 * (pt.x * offsetY) - (50.0 * offsetZ) * (pt.z * offsetX)),uWaveAmplitude * uampmul);
        }
        return vec4(pt.x, pt.y, pt.z, pt.w);
    }

    void main()
    {
        vec2 uv = openfl_TextureCoordv;
        gl_FragColor = sineWave(texture2D(bitmap, uv),uv);
    }')
    #end

    public function new()
    {
       super();
    }
}

class InvertColorsEffect
{
    public var shader(default,null):InvertShader = new InvertShader();

	public function new() {}
}
class InvertShader extends FlxShader
{
    #if SHADERS_ENABLED
    @:glFragmentSource('
    #pragma header

    vec4 sineWave(vec4 pt)
    {
        return vec4(1.0 - pt.x, 1.0 - pt.y, 1.0 - pt.z, pt.w);
    }

    void main()
    {
        vec2 uv = openfl_TextureCoordv;
        gl_FragColor = sineWave(texture2D(bitmap, uv));
    }')
    #end

    public function new()
    {
       super();
    }
}

class BlockedGlitchEffect
{
    public var shader(default, null):BlockedGlitchShader = new BlockedGlitchShader();

    #if SHADERS_ENABLED
    public var time(default, set):Float = 0;
    public var resolution(default, set):Float = 0;
    public var colorMultiplier(default, set):Float = 0;
    public var hasColorTransform(default, set):Bool = false;

    public function new(res:Float, time:Float, colorMultiplier:Float, colorTransform:Bool):Void
    {
        set_time(time);
        set_resolution(res);
        set_colorMultiplier(colorMultiplier);
        set_hasColorTransform(colorTransform);
    }
    public function update(elapsed:Float):Void
    {
        shader.time.value[0] += elapsed;
    }
    public function set_resolution(v:Float):Float
    {
        resolution = v;
        shader.screenSize.value = [resolution];
        return this.resolution;
    }
	function set_hasColorTransform(value:Bool):Bool {
		this.hasColorTransform = value;
        shader.hasColorTransform.value = [hasColorTransform];
        return hasColorTransform;
	}

	function set_colorMultiplier(value:Float):Float {
        this.colorMultiplier = value;
        shader.colorMultiplier.value = [value];
        return this.colorMultiplier;
    }

	function set_time(value:Float):Float {
        this.time = value;
        shader.time.value = [value];
        return this.time;
    }
    #end
}
class BlockedGlitchShader extends FlxShader
{
    // https://www.shadertoy.com/view/MlVSD3
    #if SHADERS_ENABLED
    @:glFragmentSource('
    #pragma header

    // ---- gllock required fields -----------------------------------------------------------------------------------------
    #define RATE 0.75

    uniform float time;
    uniform float end;
    uniform sampler2D imageData;
    uniform vec2 screenSize;
    // ---------------------------------------------------------------------------------------------------------------------

    float rand(vec2 co){
      return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453) * 2.0 - 1.0;
    }

    float offset(float blocks, vec2 uv) {
      float shaderTime = time*RATE;
      return rand(vec2(shaderTime, floor(uv.y * blocks)));
    }

    void main(void) {
      vec2 uv = openfl_TextureCoordv;
      gl_FragColor = texture(bitmap, uv);
      gl_FragColor.r = texture(bitmap, uv + vec2(offset(64.0, uv) * 0.03, 0.0)).r;
      gl_FragColor.g = texture(bitmap, uv + vec2(offset(64.0, uv) * 0.03 * 0.16666666, 0.0)).g;
      gl_FragColor.b = texture(bitmap, uv + vec2(offset(64.0, uv) * 0.03, 0.0)).b;
    }
    ')
    #end

    public function new()
    {
        super();
    }
}

class DitherEffect
{
    public var shader(default,null):DitherShader = new DitherShader();

    public function new():Void
    {

    }
}

class DitherShader extends FlxShader
{
    // couldn't find a shadertoy link srry http://devlog-martinsh.blogspot.com/2011/03/glsl-8x8-bayer-matrix-dithering.html
    #if SHADERS_ENABLED
    @:glFragmentSource('
        #pragma header
        #extension GL_ARB_arrays_of_arrays : require
        // Ordered dithering aka Bayer matrix dithering

        float Scale = 1.0;

        float find_closest(int x, int y, float c0)
        {

        int dither[8][8] = {
        { 0, 32, 8, 40, 2, 34, 10, 42}, /* 8x8 Bayer ordered dithering */
        {48, 16, 56, 24, 50, 18, 58, 26}, /* pattern. Each input pixel */
        {12, 44, 4, 36, 14, 46, 6, 38}, /* is scaled to the 0..63 range */
        {60, 28, 52, 20, 62, 30, 54, 22}, /* before looking in this table */
        { 3, 35, 11, 43, 1, 33, 9, 41}, /* to determine the action. */
        {51, 19, 59, 27, 49, 17, 57, 25},
        {15, 47, 7, 39, 13, 45, 5, 37},
        {63, 31, 55, 23, 61, 29, 53, 21} };

        float limit = 0.0;
        if(x < 8)
        {
            limit = (dither[x][y] + 1) / 64.0;
        }


        if(c0 < limit)
            return 0.0;
            return 1.0;
        }

        void main(void)
        {
            vec4 lum = vec4(0.299, 0.587, 0.114, 0);
            float grayscale = dot(texture2D(bitmap, openfl_TextureCoordv), lum);
            vec4 rgba = texture2D(bitmap, openfl_TextureCoordv).rgba;

            vec2 xy = gl_FragCoord.xy * Scale;
            int x = int(mod(xy.x, 8.0));
            int y = int(mod(xy.y, 8.0));

            vec4 finalRGB;
            finalRGB.r = find_closest(x, y, rgba.r);
            finalRGB.g = find_closest(x, y, rgba.g);
            finalRGB.b = find_closest(x, y, rgba.b);
            finalRGB.a = find_closest(x, y, rgba.a);

            float final = find_closest(x, y, grayscale);
            gl_FragColor = finalRGB;
        }
    ')
    #end

    public function new()
    {
        super();
    }
}
