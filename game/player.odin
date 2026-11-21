package game

import "core:math"
import "core:math/linalg"
import "core:math/rand"
import "engine:engine"
import "engine:input"
import "engine:ui"

WALK_SPEED :: 2.2 // m/s: a jog for a 1.1 m goblin, so it moves with the "run" clip (the library's walk covers about a third of that)
MOVE_CLIP :: "run"
TURN_SHARPNESS :: 10

// WASD moves relative to the camera; the goblin turns to face where it goes and plays idle, run or wave.
control_player :: proc(dt: f32) {
	cc := engine.get(game.player, engine.Character_Controller)
	t := engine.get(game.player, engine.Transform)
	p := engine.get(game.player, Player)
	if cc == nil || t == nil || p == nil do return

	move := input.action_vector("move_x", "move_y") if !ui.wants_keyboard() else {}
	yaw := math.to_radians(game.cam_yaw)
	forward := Vec3{math.sin(yaw), 0, math.cos(yaw)}
	right := Vec3{-math.cos(yaw), 0, math.sin(yaw)}
	wish := right * move.x + forward * move.y
	moving := linalg.length(wish) > 0.1

	cc.velocity.xz = linalg.lerp(cc.velocity.xz, wish.xz * WALK_SPEED, engine.damp(12, dt))
	if moving do t.rotation = linalg.quaternion_slerp(t.rotation, engine.look_rotation(wish), engine.damp(TURN_SHARPNESS, dt))

	model := goblin_model()
	an := engine.get(model, engine.Animator)
	if an == nil do return
	if p.celebrating && (moving || an.finished) do p.celebrating = false
	if p.celebrating {
		game.last_step = -1
		return
	}
	engine.play_animation(model, MOVE_CLIP if moving else "idle")
	update_footsteps(model, an)
}

FOOTSTEPS := [4]string{"sounds/footstep/footstep.ogg", "sounds/footstep/footstep-2.ogg", "sounds/footstep/footstep-3.ogg", "sounds/footstep/footstep-4.ogg"}

// One footstep each time a foot lands: at 0.41 and 0.91 of the run cycle (where each foot is furthest forward in
// the animation library's jog, measured on the goblin). Index -1 is the start of the clip, so no step plays when
// moving begins.
update_footsteps :: proc(model: Entity, an: ^engine.Animator) {
	if an.clip != MOVE_CLIP || an._current != MOVE_CLIP {
		game.last_step = -1
		return
	}
	length := engine.animation_duration(model, MOVE_CLIP)
	if length <= 0 do return
	step := int(math.floor((an.time / length - 0.41) * 2))
	if step != game.last_step {
		game.last_step = step
		engine.play_sound_at(rand.choice(FOOTSTEPS[:]), engine.world_position(game.player), volume = 0.4, pitch = 0.96 + rand.float32() * 0.08)
		// A puff of dust under the landing foot (left/right alternately, a little behind), on cobbles only.
		here := engine.world_position(game.player)
		if on_cobbles(here) {
			t := engine.get(game.player, engine.Transform)
			fwd := linalg.quaternion_mul_vector3(t.rotation, Vec3{0, 0, 1})
			side := linalg.quaternion_mul_vector3(t.rotation, Vec3{1, 0, 0}) * (0.12 if step % 2 == 0 else -0.12)
			engine.play_effect("effects/footstep-dust.json", here + side - fwd * 0.1)
			if p := engine.get(game.player, Player); p != nil do p.dust_puffs += 1
		}
	}
}

// Whether a ground point is on the cobblestone: within half a width of a Path's segments (points are in the
// entity's local space; the curve is approximated by its control polyline), or inside the round hub or a pad.
on_cobbles :: proc(p: Vec3) -> bool {
	ents, paths := engine.view(engine.Path)
	for path, i in paths {
		if len(path.points) < 2 do continue
		origin := engine.world_position(ents[i])
		half := (path.width if path.width > 0 else 1) / 2
		for k in 0 ..< len(path.points) - 1 {
			if dist_to_segment(p.xz, (origin + path.points[k]).xz, (origin + path.points[k + 1]).xz) < half do return true
		}
	}
	in_disc :: proc(name: string, p: Vec3) -> bool {
		e := engine.find(name)
		if e == 0 do return false
		t := engine.get(e, engine.Transform)
		return t != nil && linalg.length((p - engine.world_position(e)).xz) < t.scale.x / 2
	}
	if in_disc("Path Hub", p) do return true
	for n in ([4]string{"Pad Chest 1", "Pad Chest 2", "Pad Chest 3", "Pad Chest 4"}) do if in_disc(n, p) do return true
	return false
}

dist_to_segment :: proc(p, a, b: [2]f32) -> f32 {
	ab := b - a
	len2 := linalg.dot(ab, ab)
	s := clamp(linalg.dot(p - a, ab) / len2, 0, 1) if len2 > 0 else 0
	return linalg.length(p - (a + ab * s))
}

// The goblin waves once (walking cuts it short).
celebrate :: proc() {
	if p := engine.get(game.player, Player); p != nil do p.celebrating = true
	engine.play_animation(goblin_model(), "wave", once = true, restart = true)
}

// A third-person camera behind the goblin: drag with the right mouse button to turn it, wheel to zoom.
update_camera :: proc(dt: f32) {
	cam := engine.find("Camera")
	if cam == 0 do return
	if input.mouse_down(.RIGHT) && !ui.wants_mouse() {
		d := input.mouse_delta()
		game.cam_yaw -= d.x * 0.25
		game.cam_pitch = clamp(game.cam_pitch + d.y * 0.2, 5, 70)
	}
	game.cam_yaw -= input.action_value("look_x") * 120 * dt
	game.cam_dist = clamp(game.cam_dist - input.mouse_wheel() * 0.5, 2, 10)

	target := engine.world_position(game.player) + {0, 0.8, 0}
	yaw, pitch := math.to_radians(game.cam_yaw), math.to_radians(game.cam_pitch)
	dir := Vec3{math.cos(pitch) * math.sin(yaw), -math.sin(pitch), math.cos(pitch) * math.cos(yaw)}
	dist := game.cam_dist
	if hit, ok := engine.raycast(target, -dir, dist, ignore = game.player); ok do dist = max(hit.distance - 0.3, 0.5)
	t := engine.get(cam, engine.Transform)
	t.position = linalg.lerp(t.position, target - dir * dist, engine.damp(20, dt))
	engine.look_at(cam, target)
}
