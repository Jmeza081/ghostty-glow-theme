// Til glow: bloom only the light-blue accent, never the slate text.
// Til's rule is "one thing glows at rest — glow means live", so instead of
// blooming everything bright, each pixel collects light from nearby pixels
// that are clearly blue or cyan and bright enough to be ink: not slate, green or violet.
// Shadertoy format: iChannel0 is the rendered terminal, iResolution its size.

const float RADIUS   = 16.0;   // glow reach, in physical pixels
const float STRENGTH = 2.2;    // how bright the halo gets
const int   SAMPLES  = 40;
const vec3  GLOW     = vec3(0.30, 0.60, 0.95); // between #1981E3 and #8CC2F5

// A second, fainter warm glow keyed to one amber: Claude Code's `warning`
// colour (#F5B94A in claude-code/til-glow.json), which is what draws
// "auto mode on". The shell's amber (#E0B25C) is far enough away to stay flat.
// Each colour is listed three ways, because what reaches the shader depends on
// how Ghostty stores its frame: as written (sRGB), as linear light, or as macOS
// converted it for the display (measured off a screenshot).
const vec3 WARM_KEYS[6] = vec3[6](
    vec3(0.961, 0.725, 0.290),  // #F5B94A  sRGB
    vec3(1.000, 0.824, 0.478),  // #FFD27A  sRGB, its shimmer
    vec3(0.913, 0.485, 0.068),  // #F5B94A  linear
    vec3(1.000, 0.644, 0.195),  // #FFD27A  linear
    vec3(0.980, 0.718, 0.341),  // #FAB757  #F5B94A as seen on screen
    vec3(0.955, 0.479, 0.095)   // #FAB757  linear
);
const vec3  WARM_GLOW = vec3(0.96, 0.70, 0.30);
const float WARM_STRENGTH = 0.45;                  // "slight": a bit under the blue

float accentMask(vec3 c) {
    float lum = dot(c, vec3(0.2126, 0.7152, 0.0722));
    float blue = smoothstep(0.15, 0.35, c.b - c.r)    // bluer than red
               * smoothstep(0.04, 0.12, c.b - c.g)    // bluer than green (keeps green flat)
               * smoothstep(-0.06, 0.02, c.g - c.r);  // not violet (keeps purple flat)
    return blue * smoothstep(0.22, 0.42, lum);
}

float warmMask(vec3 c) {
    float d = 1.0;
    for (int k = 0; k < 6; k++) d = min(d, distance(c, WARM_KEYS[k]));
    return 1.0 - smoothstep(0.04, 0.08, d);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec4 base = texture(iChannel0, fragCoord / iResolution.xy);
    float acc = 0.0, warm = 0.0, wsum = 0.0;
    for (int i = 0; i < SAMPLES; i++) {
        float f = float(i) + 0.5;
        float r = sqrt(f / float(SAMPLES)) * RADIUS;   // even spread over a disc
        float a = f * 2.39996323;                       // golden angle
        vec2 off = vec2(cos(a), sin(a)) * r;
        float w = exp(-(r * r) / (RADIUS * RADIUS * 0.35));
        vec3 s = texture(iChannel0, (fragCoord + off) / iResolution.xy).rgb;
        acc += accentMask(s) * w;
        warm += warmMask(s) * w;
        wsum += w;
    }
    float g = clamp(acc / wsum * STRENGTH, 0.0, 1.0);
    float gw = clamp(warm / wsum * STRENGTH, 0.0, 1.0);
    fragColor = vec4(base.rgb + GLOW * g * 0.6 + WARM_GLOW * gw * WARM_STRENGTH, base.a);
}
