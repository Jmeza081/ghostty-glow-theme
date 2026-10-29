// Clay glow: bloom only the clay orange (#D97757), never the text.
// Same rule as Til Glow, "one thing glows at rest — glow means live": each pixel
// collects light from nearby pixels whose hue is the orange's, bright and
// saturated enough to be ink. Red and amber sit just outside that hue band.
// Shadertoy format: iChannel0 is the rendered terminal, iResolution its size.

const float RADIUS   = 16.0;   // glow reach, in physical pixels
const float STRENGTH = 2.2;    // how bright the halo gets
const int   SAMPLES  = 40;
const vec3  GLOW     = vec3(0.82, 0.43, 0.30); // between #C4623F and #D97757
const float INTENSITY = 0.45;  // 25% under Til Glow's 0.6

// The orange's hue is 15° as written (sRGB) and 9° as linear light, depending
// on how Ghostty stores its frame; the band 5°–25° holds both. Red is at -8°/-4°
// and amber at 38°/30°, so both stay flat.
float hueDegrees(vec3 c) {
    float mx = max(c.r, max(c.g, c.b));
    float mn = min(c.r, min(c.g, c.b));
    float d = max(mx - mn, 1e-4);
    float h;
    if (mx == c.r)      h = mod((c.g - c.b) / d, 6.0);
    else if (mx == c.g) h = (c.b - c.r) / d + 2.0;
    else                h = (c.r - c.g) / d + 4.0;
    h *= 60.0;
    return h > 180.0 ? h - 360.0 : h;
}

float accentMask(vec3 c) {
    float mx = max(c.r, max(c.g, c.b));
    float mn = min(c.r, min(c.g, c.b));
    float sat = (mx - mn) / max(mx, 1e-4);
    float h = hueDegrees(c);
    float band = smoothstep(3.0, 7.0, h) * (1.0 - smoothstep(23.0, 27.0, h));
    return band
         * smoothstep(0.35, 0.50, sat)    // keeps the warm greys flat
         * smoothstep(0.35, 0.55, mx);    // ink, not the dim selection
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    vec4 base = texture(iChannel0, fragCoord / iResolution.xy);
    float acc = 0.0, wsum = 0.0;
    for (int i = 0; i < SAMPLES; i++) {
        float f = float(i) + 0.5;
        float r = sqrt(f / float(SAMPLES)) * RADIUS;   // even spread over a disc
        float a = f * 2.39996323;                       // golden angle
        vec2 off = vec2(cos(a), sin(a)) * r;
        float w = exp(-(r * r) / (RADIUS * RADIUS * 0.35));
        vec3 s = texture(iChannel0, (fragCoord + off) / iResolution.xy).rgb;
        acc += accentMask(s) * w;
        wsum += w;
    }
    float g = clamp(acc / wsum * STRENGTH, 0.0, 1.0);
    fragColor = vec4(base.rgb + GLOW * g * INTENSITY, base.a);
}
