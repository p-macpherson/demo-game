package game

import "core:math"
import "core:math/linalg"
import "core:math/rand"
import "engine:engine"
import "engine:input"
import "engine:ui"

WALK_SPEED :: 2.2 // m/s; matches the walk clip's stride at a 1.1 m goblin
TURN_SHARPNESS :: 10

// WASD moves relative to the camera; the goblin turns to face where it walks and plays idle, walk or wave.
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
	engine.play_animation(model, "walk" if moving else "idle")
	update_footsteps(model, an)
}

FOOTSTEPS := [4]string{"sounds/footstep/footstep.ogg", "sounds/footstep/footstep-2.ogg", "sounds/footstep/footstep-3.ogg", "sounds/footstep/footstep-4.ogg"}

// One footstep each time a foot lands: twice per walk cycle, timed from the walk clip's time.
update_footsteps :: proc(model: Entity, an: ^engine.Animator) {
	if an.clip != "walk" || an._current != "walk" {
		game.last_step = -1
		return
	}
	length := engine.animation_duration(model, "walk")
	if length <= 0 do return
	step := int(math.floor(an.time / length * 2))
	if step != game.last_step {
		game.last_step = step
		engine.play_sound_at(rand.choice(FOOTSTEPS[:]), engine.world_position(game.player), volume = 0.4, pitch = 0.96 + rand.float32() * 0.08)
	}
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
