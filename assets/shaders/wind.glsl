// Sways grass and foliage in the wind. For models whose base is at local y = 0 and tips at local y = height.
// Bends more toward the tips (h^2); a gust travels across the world so neighbours move a little out of step.
// @param float strength = 0.08 [0, 0.5]
// @param float speed = 1.2 [0, 5]
// @param vec2 direction = 1, 0.3
// @param float height = 0.4 [0.05, 3]
// @bounds 0.3

void vertex(inout Vertex v) {
    float h = clamp(v.local.y / height, 0.0, 1.0);
    vec2 p = v.position.xz;
    float gust = noise(p * 0.35 - direction * u_time * speed * 0.3) - 0.5;   // travels along the wind
    float sway = sin(u_time * speed * 2.0 + p.x * 0.9 + p.y * 0.6) * 0.3 + gust * 1.2;
    v.position.xz += normalize(direction) * sway * strength * (h * h);
}
