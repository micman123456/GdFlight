shader_type sky;

uniform vec3 skyColor : source_color;
uniform vec3 HColor : source_color;
uniform sampler2D skytexture;

uniform vec3 fogColor : source_color;
uniform float fogDensity : hint_range(0.0, 1.0);

void sky() {
    float col = clamp(EYEDIR.y / 0.05, 0.0, 1.0);
    vec3 finalColor = mix(HColor, skyColor, col);

    // Compute fog factor based on distance
    float fogFactor = 1.0 - exp(-fogDensity * abs(EYEDIR.y) * 10.0);
    finalColor = mix(finalColor, fogColor, fogFactor);

    COLOR = finalColor;
}
