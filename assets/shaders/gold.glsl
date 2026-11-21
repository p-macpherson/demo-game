// Gold coins and gems: uses the model's palette texture (per-coin golds, red and teal gems), a low warm glow that
// keeps coins distinct, and sparse small glints that travel across the pile, exceed 1 and bloom softly.
// @param color gold = #ffd070
// @param float glow = 0.12 [0, 3]
// @param float glint = 2.5 [0, 10]
// @param float glint_speed = 0.8 [0, 4]
// @param float glint_scale = 16 [2, 40]

void surface(inout Surface s) {
    vec3 base = s.albedo * mix(vec3(1.0), gold, 0.35);
    s.albedo = base;
    s.metallic = 0.6;
    s.roughness = 0.4;
    float rim = 1.0 - clamp(dot(normalize(s.normal), normalize(s.view)), 0.0, 1.0);
    // gentle self-glow in the coin's own colour, a little more at the rims so edges separate the coins
    vec3 em = base * glow * (0.3 + 0.7 * rim);
    // glints: sparse cells that light up in turn as a wave passes over the pile
    vec3 q3 = s.position * glint_scale;
    vec3 c3 = floor(q3);
    float h = hash12(c3.xy + c3.z * 17.0);
    float phase = h * 6.2832 + dot(c3, vec3(0.35, 0.2, 0.3));
    float tw = pow(max(sin(u_time * glint_speed * 2.5 + phase), 0.0), 16.0);
    float shape = smoothstep(0.45, 0.0, length(fract(q3) - 0.5));
    float on = step(0.82, h);
    em += vec3(1.0, 0.85, 0.55) * glint * tw * shape * on;
    s.emission = em;
}
