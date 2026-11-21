// Gold coins: metallic warm gold with a soft inner glow and small travelling glints that exceed 1 and bloom.
// @param color gold = #f2b52e
// @param float glow = 0.35 [0, 3]
// @param float glint = 3 [0, 10]
// @param float glint_speed = 1 [0, 4]
// @param float glint_scale = 14 [2, 40]

void surface(inout Surface s) {
    s.albedo = gold;
    s.metallic = 0.9;
    s.roughness = 0.32;
    float rim = 1.0 - clamp(dot(normalize(s.normal), normalize(s.view)), 0.0, 1.0);
    // soft glow, a bit stronger on crevice-facing/rim areas so coins keep their shape
    vec3 em = gold * glow * (0.35 + 0.65 * rim);
    // glints: sparse cells that light up in turn as a wave passes
    vec3 q3 = s.position * glint_scale;
    vec3 c3 = floor(q3);
    float h = hash12(c3.xy + c3.z * 17.0);
    float tw = pow(max(sin(u_time * glint_speed * 2.5 + h * 6.2832), 0.0), 12.0);
    float shape = smoothstep(0.5, 0.0, length(fract(q3) - 0.5));
    float on = step(0.7, h);
    em += vec3(1.0, 0.9, 0.6) * glint * tw * shape * on;
    s.emission = em;
}
