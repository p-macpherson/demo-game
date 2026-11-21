// Glowing glass for the lantern model: the model's own texture has pale glass panes and a dark iron frame, so the
// emission is masked by the albedo's brightness (panes glow warm above 1 and bloom, the frame stays dark) and
// flickers like a candle, each lantern out of step (phase from its world position).
// Put it on the lantern's Mesh_Renderer material; it keeps the model's texture.
// @param color flame = #ff9a2e
// @param float strength = 2.2 [0, 20]
// @param float flicker = 0.2 [0, 1]
// @param float speed = 1 [0, 4]

void surface(inout Surface s) {
    // phase differs between lanterns, nearly constant across one small model
    float ph = s.position.x * 3.7 + s.position.z * 5.3;
    float t = u_time * speed;
    float f = noise(vec2(t * 7.0 + ph, ph)) * 0.6 + noise(vec2(t * 2.3 + ph * 1.7, 3.1)) * 0.4;
    float k = 1.0 - flicker + flicker * 2.0 * f;
    float lum = dot(s.albedo, vec3(0.299, 0.587, 0.114));
    float glass = smoothstep(0.35, 0.6, lum); // linear space: pale panes ~0.7+, brass ~0.1
    // warmer towards the middle of a pane's brightness, paler at the brightest
    vec3 col = mix(flame, vec3(1.0, 0.85, 0.5), smoothstep(0.5, 0.9, lum));
    s.emission = col * strength * k * glass;
    s.albedo = mix(s.albedo, s.albedo * flame * 1.5, glass);
}
