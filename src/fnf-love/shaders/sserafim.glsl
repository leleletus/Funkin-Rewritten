// Puerto 1:1 de funkin/graphics/shaders/SserafimShader.hx (real, 322
// líneas) -- incluye AMBAS partes: el oscurecimiento/luz pulsante
// (darkAmt/lightColor/pulseStrength/truckStrength/isChar) Y el filtro
// "Adjust Color" de Animate/Flash (hue/saturation/brightness/contrast).
// CORRECCIÓN sobre una nota anterior: sserafim.hxc NUNCA llama
// setAdjustColor() durante el gameplay normal (onSongEvent) -- ahí los 4
// valores quedan en 0 y el filtro es una identidad matemática -- pero SÍ
// lo usa la cutscene de intro (introCutscene(), tweens de
// baseBrightness/baseHue/baseContrast durante el choque de auto), así
// que no es código muerto en general. shaders/adjustColor.glsl (el
// archivo genérico ya existente) tiene la MISMA lógica reusable, pero se
// duplica acá adentro para no depender de un #include (LÖVE2D/GLSL ES no
// tiene esa directiva).

extern float hue;
extern float saturation;
extern float brightness;
extern float contrast;

extern float darkAmt;
extern vec3 lightColor;
extern float pulseStrength;
extern float truckStrength;
extern bool isChar;

const vec3 grayscaleValues = vec3(0.3098039215686275, 0.607843137254902, 0.0823529411764706);
const float eConst = 2.718281828459045;

vec3 applyHueRotate(vec3 aColor, float aHue) {
	float angle = radians(aHue);
	mat3 m1 = mat3(0.213, 0.213, 0.213, 0.715, 0.715, 0.715, 0.072, 0.072, 0.072);
	mat3 m2 = mat3(0.787, -0.213, -0.213, -0.715, 0.285, -0.715, -0.072, -0.072, 0.928);
	mat3 m3 = mat3(-0.213, 0.143, -0.787, -0.715, 0.140, 0.715, 0.928, -0.283, 0.072);
	mat3 m = m1 + cos(angle) * m2 + sin(angle) * m3;
	return m * aColor;
}

vec3 applySaturationAdjust(vec3 aColor, float value) {
	if (value > 0.0) { value = value * 3.0; }
	value = (1.0 + (value / 100.0));
	vec3 grayscale = vec3(dot(aColor, grayscaleValues));
	return clamp(mix(grayscale, aColor, value), 0.0, 1.0);
}

vec3 applyContrastAdjust(vec3 aColor, float value) {
	value = (1.0 + (value / 100.0));
	if (value > 1.0) {
		value = (((0.00852259 * pow(eConst, 4.76454 * (value - 1.0))) * 1.01) - 0.0086078159) * 10.0;
		value += 1.0;
	}
	return clamp((aColor - 0.25) * value + 0.25, 0.0, 1.0);
}

vec3 applyHSBCEffect(vec3 color) {
	color = color + (brightness / 255.0);
	color = applyHueRotate(color, hue);
	color = applyContrastAdjust(color, contrast);
	color = applySaturationAdjust(color, saturation);
	return color;
}

vec3 rgb2hsl(vec3 c) {
	float cMin = min(min(c.r, c.g), c.b);
	float cMax = max(max(c.r, c.g), c.b);
	float delta = cMax - cMin;
	vec3 hsl = vec3(0.0, 0.0, (cMax + cMin) / 2.0);
	if (delta != 0.0) {
		if (hsl.z < 0.5) {
			hsl.y = delta / (cMax + cMin);
		} else {
			hsl.y = delta / (2.0 - cMax - cMin);
		}
		float deltaR = (((cMax - c.r) / 6.0) + (delta / 2.0)) / delta;
		float deltaG = (((cMax - c.g) / 6.0) + (delta / 2.0)) / delta;
		float deltaB = (((cMax - c.b) / 6.0) + (delta / 2.0)) / delta;
		if (c.r == cMax) {
			hsl.x = deltaB - deltaG;
		} else if (c.g == cMax) {
			hsl.x = (1.0 / 3.0) + deltaR - deltaB;
		} else {
			hsl.x = (2.0 / 3.0) + deltaG - deltaR;
		}
		hsl.x = fract(hsl.x);
	}
	return hsl;
}

vec3 hue2rgb(float hue) {
	hue = fract(hue);
	return clamp(vec3(
		abs(hue * 6.0 - 3.0) - 1.0,
		2.0 - abs(hue * 6.0 - 2.0),
		2.0 - abs(hue * 6.0 - 4.0)
	), 0.0, 1.0);
}

vec3 hsl2rgb(vec3 hsl) {
	if (hsl.y == 0.0) {
		return vec3(hsl.z);
	} else {
		float b;
		if (hsl.z < 0.5) {
			b = hsl.z * (1.0 + hsl.y);
		} else {
			b = hsl.z + hsl.y - hsl.y * hsl.z;
		}
		float a = 2.0 * hsl.z - b;
		return a + hue2rgb(hsl.x) * (b - a);
	}
}

// controla cuánto aclarar/oscurecer según combinedAlpha (igual que el real)
const float lightMultiplier = 0.07;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
	vec4 col = Texel(texture, texture_coords);
	vec3 unpremultipliedColor = col.a > 0.0 ? col.rgb / col.a : col.rgb;

	vec3 outColor = applyHSBCEffect(unpremultipliedColor);

	// truckLight1.alpha + backLightColor.alpha (real: combinedAlpha)
	float combinedAlpha = truckStrength + pulseStrength;

	float darkFactor = (combinedAlpha * lightMultiplier) + darkAmt;
	if (darkAmt > 0.65) darkFactor = (combinedAlpha * (-1.0 * lightMultiplier)) + darkAmt;

	// SIC: el real lee bruhColor.b (alias de .z, no "azul") como el
	// componente de luminancia (L) de HSL -- swizzle reinterpretado a
	// propósito, ver SserafimShader.hx:280-283.
	// clamp defensivo: L fuera de [0,1] hace que hsl2rgb devuelva
	// componentes RGB fuera de [0,1] sin avisar (colores "cortados" raros)
	// -- el real evita esto indirectamente porque Flixel clampea
	// sprite.alpha automático antes de mandarlo como pulseStrength (ver
	// stage.lua/flashBackLight) -- este clamp es la red de seguridad acá.
	vec3 bruhColor = rgb2hsl(lightColor);
	bruhColor.b = clamp(bruhColor.b * pulseStrength, 0.0, 1.0);
	bruhColor = hsl2rgb(bruhColor);

	vec3 multiplyColor;
	if (isChar) {
		multiplyColor = mix(vec3(1.0), vec3(0.0), darkFactor / 5.0);
		multiplyColor = mix(multiplyColor, bruhColor, darkFactor / 3.0);
	} else {
		multiplyColor = mix(vec3(1.0), vec3(0.0), darkFactor);
		multiplyColor = mix(multiplyColor, bruhColor, darkFactor / 2.0);
	}

	outColor *= multiplyColor;
	outColor = clamp(outColor, 0.0, 1.0);

	return vec4(outColor * col.a, col.a);
}
