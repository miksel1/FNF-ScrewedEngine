package effects;

import flixel.system.FlxAssets.FlxShader;

class FunkScopShader extends FlxShader {
    @:glFragmentSource("
    #pragma header

    // https://www.shadertoy.com/view/tsfXWj

    uniform vec3 iResolution;

    uniform vec4 iMouse;

    uniform sampler2D iChannel0;

    const vec2 maxResLuminance = vec2(333.0, 480.0);
    const vec2 maxResChroma = vec2(40.0, 480.0);

    vec2 rotate(vec2 v, float a)
    {
        float s = sin(a);
        float c = cos(a);
        mat2 m = mat2(c, -s, s, c);
        return m * v;
    }

    vec4 cubic(float v){
        vec4 n = vec4(1.0, 2.0, 3.0, 4.0) - v;
        vec4 s = n * n * n;
        float x = s.x;
        float y = s.y - 4.0 * s.x;
        float z = s.z - 4.0 * s.y + 6.0 * s.x;
        float w = 6.0 - x - y - z;
        return vec4(x, y, z, w) * (1.0/6.0);
    }

    vec4 textureBicubic(sampler2D sampler, vec2 texCoords){
        vec2 textureSize = openfl_TextureSize;

        vec2 texSize = textureSize(sampler, 0);
        vec2 invTexSize = 1.0 / texSize;
        
        texCoords = texCoords * texSize - 0.5;

        vec2 fxy = fract(texCoords);
        texCoords -= fxy;

        vec4 xcubic = cubic(fxy.x);
        vec4 ycubic = cubic(fxy.y);
    
        vec4 c = texCoords.xxyy + vec2 (-0.5, +1.5).xyxy;
        
        vec4 s = vec4(xcubic.xz + xcubic.yw, ycubic.xz + ycubic.yw);
        vec4 offset = c + vec4 (xcubic.yw, ycubic.yw) / s;
        
        offset *= invTexSize.xxyy;
        
        vec4 sample0 = texture2D(sampler, offset.xz);
        vec4 sample1 = texture2D(sampler, offset.yz);
        vec4 sample2 = texture2D(sampler, offset.xw);
        vec4 sample3 = texture2D(sampler, offset.yw);
    
        float sx = s.x / (s.x + s.y);
        float sy = s.z / (s.z + s.w);
    
        return mix(
        mix(sample3, sample2, sx), mix(sample1, sample0, sx)
        , sy);
    }    

    void main()
    {
        vec2 uv = openfl_TextureCoordv / iResolution.xy;
        vec2 mouseNormalized = iMouse.xy / iResolution.xy;
        
        vec2 resLuminance = min(maxResLuminance, vec2(iResolution));
        vec2 resChroma = min(maxResChroma, vec2(iResolution));
        
        vec2 uvLuminance = uv * (resLuminance / vec2(iResolution));
        vec2 uvChroma = uv * (resChroma / vec2(iResolution));
        
        vec3 result;
        
        if (uv.x > mouseNormalized.x)
        {
            float luminance = textureBicubic(iChannel1, uvLuminance).x;
            vec2 chroma = textureBicubic(iChannel1, uvChroma).yz;
            result = vec3(luminance, chroma) * yiq2rgb;
        }
        else
        {
            result = texture2D(iChannel0, uv).rgb;
        }
        
        fragColor = vec4(result, 1);
    }")

    public function new(){
        super();
    }
}