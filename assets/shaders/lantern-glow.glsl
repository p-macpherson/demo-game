// Candle flame core for a small sphere inside a lantern's glass: warm emission above 1 (blooms) with an irregular
// flicker, each lantern out of step (phase from its world position).
// @param color flame = #ff9a2e
// @param float strength = 2.5 [0, 20]
// @param float flicker = 0.25 [0, 1]
// @param float speed = 1 [0, 4]

void surface(inout Surface s) {
    // smooth world-position phase: differs between lanterns, nearly constant across one small sphere
    float ph = s.position.x * 3.7 + s.position.z * 5.3;
    float t = u_time * speed;
    float f = noise(vec2(t * 7.0 + ph, ph)) * 0.6 + noise(vec2(t * 2.3 + ph * 1.7, 3.1)) * 0.4;
    float k = 1.0 - flicker + flicker * 2.0 * f;
    float rim = 1.0 - clamp(dot(normalize(s.normal), normalize(s.view)), 0.0, 1.0);
    s.emission = mix(flame, vec3(1.0, 0.8, 0.45), 0.2 * (1.0 - rim)) * strength * k;
    s.albedo = flame * 0.15;
    s.roughness = 0.9;
    s.metallic = 0.0;
}
