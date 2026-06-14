// RAIN SHADER - Ported from FNF Weekend 1 (RainShader.hx)
// Original shader by @shr_id on Twitter
// Adapted for Love2D: works in pixel coordinates like the Haxe original

vec3 mod289(vec3 x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289(vec4 x) {
	return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x) {
	return mod289(((x*34.0)+10.0)*x);
}

vec4 taylorInvSqrt(vec4 r) {
	return 1.79284291400159 - 0.85373472095314 * r;
}

float snoise(vec3 v) {
	const vec2  C = vec2(1.0/6.0, 1.0/3.0);
	const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

	vec3 i  = floor(v + dot(v, C.yyy));
	vec3 x0 =   v - i + dot(i, C.xxx);

	vec3 g = step(x0.yzx, x0.xyz);
	vec3 l = 1.0 - g;
	vec3 i1 = min(g.xyz, l.zxy);
	vec3 i2 = max(g.xyz, l.zxy);

	vec3 x1 = x0 - i1 + C.xxx;
	vec3 x2 = x0 - i2 + C.yyy;
	vec3 x3 = x0 - D.yyy;

	i = mod289(i);
	vec4 p = permute(permute(permute(
				i.z + vec4(0.0, i1.z, i2.z, 1.0))
			+ i.y + vec4(0.0, i1.y, i2.y, 1.0))
			+ i.x + vec4(0.0, i1.x, i2.x, 1.0));

	float n_ = 0.142857142857;
	vec3  ns = n_ * D.wyz - D.xzx;

	vec4 j = p - 49.0 * floor(p * ns.z * ns.z);

	vec4 x_ = floor(j * ns.z);
	vec4 y_ = floor(j - 7.0 * x_);

	vec4 x = x_ * ns.x + ns.yyyy;
	vec4 y = y_ * ns.x + ns.yyyy;
	vec4 h = 1.0 - abs(x) - abs(y);

	vec4 b0 = vec4(x.xy, y.xy);
	vec4 b1 = vec4(x.zw, y.zw);

	vec4 s0 = floor(b0) * 2.0 + 1.0;
	vec4 s1 = floor(b1) * 2.0 + 1.0;
	vec4 sh = -step(h, vec4(0.0));

	vec4 a0 = b0.xzyw + s0.xzyw * sh.xxyy;
	vec4 a1 = b1.xzyw + s1.xzyw * sh.zzww;

	vec3 p0 = vec3(a0.xy, h.x);
	vec3 p1 = vec3(a0.zw, h.y);
	vec3 p2 = vec3(a1.xy, h.z);
	vec3 p3 = vec3(a1.zw, h.w);

	vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2,p2), dot(p3,p3)));
	p0 *= norm.x;
	p1 *= norm.y;
	p2 *= norm.z;
	p3 *= norm.w;

	vec4 m = max(0.5 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
	m = m * m;
	return 105.0 * dot(m*m, vec4(dot(p0,x0), dot(p1,x1),
								  dot(p2,x2), dot(p3,x3)));
}

extern float uScale;
extern float uIntensity;
extern float uTime;

float rand(vec2 a) {
	return fract(sin(dot(mod(a, vec2(1000.0)).xy, vec2(12.9898, 78.233))) * 43758.5453);
}

float rainDist(vec2 p, float scale, float intensity) {
	p *= 0.1;
	p.x += p.y * 0.1;
	p.y -= uTime * 500.0 / scale;
	p.y *= 0.03;
	float ix = floor(p.x);
	p.y += mod(ix, 2.0) * 0.5 + (rand(vec2(ix)) - 0.5) * 0.3;
	float iy = floor(p.y);
	vec2 index = vec2(ix, iy);
	p -= index;
	p.x += (rand(index.yx) * 2.0 - 1.0) * 0.35;
	vec2 a = abs(p - 0.5);
	float res = max(a.x * 0.8, a.y * 0.5) - 0.1;
	bool empty = rand(index) < mix(1.0, 0.1, intensity);
	return empty ? 1.0 : res;
}

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
    // =====================================================================
    // En el Haxe original: wpos = screenToWorld(screenCoord)
    // screenToWorld convierte [0,1] → coordenadas de mundo en pixeles.
    // En Love2D, screen_coords YA viene en pixeles, así que es equivalente.
    // =====================================================================
    vec2 wpos = screen_coords;
    float intensity = uIntensity;

    vec3 add = vec3(0);
    float rainSum = 0.0;

    const int numLayers = 4;
    float scales[numLayers];
    scales[0] = 1.0;
    scales[1] = 1.8;
    scales[2] = 2.6;
    scales[3] = 4.8;

    for (int i = 0; i < numLayers; i++) {
        float scale = scales[i];
        float r = rainDist(wpos * scale / uScale + 500.0 * float(i), scale, intensity);
        if (r < 0.0) {
            float v = (1.0 - exp(r * 5.0)) / scale * 2.0;
            wpos.x += v * 10.0 * uScale;
            wpos.y -= v * 2.0 * uScale;
            add += vec3(0.1, 0.15, 0.2) * v;
            rainSum += (1.0 - rainSum) * 0.75;
        }
    }

    // Convertir pixeles distorsionados → UV [0,1] para samplear la textura
    // Equivale a sampleBitmapWorld(wpos) del original
    vec2 uv = wpos / love_ScreenSize.xy;
    vec4 color_ = Texel(texture, uv);

    vec3 rainColor = vec3(0.4, 0.5, 0.8);
    color_ += vec4(add, 0.0);
    color_ = mix(color_, vec4(rainColor, 0.0), 0.1 * rainSum);

    return vec4(color_.rgb, 1.0);
}
