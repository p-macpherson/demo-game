// Pond water for a transparent "grid" mesh (square, UVs 0..1). The water is clipped to the ellipse inscribed in the
// grid (so scale the grid to the pond's width and depth), with a pale shallow fringe just inside that edge and
// wherever it touches the bank or rocks. Calm: slow low swells plus faint ripples and a few sparkles.
// @param float wave_height = 0.025 [0, 0.2]
// @param float wave_speed = 0.5 [0, 3]
// @param color deep = #174852
// @param color shallow = #6fb0b0
// @param float clarity = 0.3 [0, 1]
// @param float edge = 0.015 [0.01, 1]
// @param float rim = 0.03 [0, 0.5]
// @param float ripple = 0.5 [0, 2]
// @bounds 0.1

float wave(vec2 p) {
    return sin(p.x * 1.3 + u_time * wave_speed) * 0.6 + sin(p.y * 1.7 - u_time * wave_speed * 1.3 + p.x * 0.5) * 0.4;
}

void vertex(inout Vertex v) {
    vec2 p = v.position.xz;
    v.position.y += wave(p) * wave_height;
    float k = wave_height;
    float dx = (cos(p.x * 1.3 + u_time * wave_speed) * 0.78 + cos(p.y * 1.7 - u_time * wave_speed * 1.3 + p.x * 0.5) * 0.2) * k;
    float dz = cos(p.y * 1.7 - u_time * wave_speed * 1.3 + p.x * 0.5) * 0.68 * k;
    v.normal = normalize(vec3(-dx, 1.0, -dz));
}

void surface(inout Surface s) {
    // elliptical mask: r = 1 at the inscribed ellipse
    vec2 c = (s.uv - 0.5) * 2.0;
    float r = length(c);
    float inside = 1.0 - smoothstep(0.975, 1.0, r);
    // thin soft band just inside the outer edge (0 well inside .. 1 at the edge)
    float rimk = smoothstep(1.0 - max(rim, 0.001), 0.985, r);
    // ripples: two drifting noise layers perturb the normal
    vec2 p = s.position.xz;
    float t = u_time * 0.35;
    float n1 = noise(p * 3.0 + vec2(t, t * 0.6));
    float n2 = noise(p * 4.5 - vec2(t * 0.8, t));
    vec2 g = vec2(n1 - 0.5, n2 - 0.5) * ripple * 0.35;
    s.normal = normalize(s.normal + vec3(g.x, 0.0, g.y));
    float f = fresnel(s, 4.0);
    // thin foam line where the water meets the bank or rocks, broken up a little by noise
    float shore = depth_fade(s, edge);
    float line = (1.0 - shore) * (0.75 + 0.5 * n2);
    float foam = clamp(max(line, rimk * 0.8), 0.0, 1.0);
    // a few small, subtle sparkles on the ripple crests
    float spark = smoothstep(0.93, 0.99, noise(p * 9.0 + vec2(t * 2.0, -t * 1.5))) * 0.5 * ripple;
    // depth tint: the pond is only ~0.1 m deep, so read the bank slope as a gentle teal gradient, not a pale band
    float d = depth_fade(s, 0.1);
    vec3 col = mix(deep, shallow, f * 0.55 + (1.0 - d) * 0.08 + (n1 - 0.5) * 0.1);
    s.albedo = mix(col, vec3(0.8, 0.9, 0.86), foam * 0.5);
    s.roughness = 0.2;
    s.metallic = 0.0;
    s.emission = vec3(0.8, 0.95, 1.0) * spark * (1.0 - foam);
    float a = mix(1.0 - clarity, 0.9, f * f) + (1.0 - d) * 0.0;
    s.alpha = mix(a, 0.55, foam) * inside;
}
