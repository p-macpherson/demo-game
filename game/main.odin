// Goblin Gold: walk a mossy clearing as a goblin and open every treasure chest. See docs/design/Overview.md.
// Content (the clearing, the goblin, chests, barrels, boulders) is in assets/scenes and assets/prefabs.
package game

import "core:strconv"
import "engine:engine"
import "engine:input"

Vec3 :: engine.Vec3
Entity :: engine.Entity

// Marks the goblin the player controls.
Player :: struct {
	celebrating: bool, // playing the wave after opening a chest
}

// A treasure chest. `open` turns true once the goblin opens it (the lid plays its "open" clip).
Chest :: struct {
	gold: int,
	open: bool,
}

game: struct {
	player:    Entity,
	gold:      int,
	cam_yaw:   f32, // degrees; 0 looks along +Z
	cam_pitch: f32,
	cam_dist:  f32,
	near:      Entity, // the closed chest the goblin can open right now, if any
}

main :: proc() {
	engine.run({setup = setup, init = init, update = update, draw_ui = draw_ui}, {title = "Goblin Gold", scene = "scenes/clearing.json"})
}

setup :: proc() {
	engine.register_component(Player)
	engine.register_component(Chest)
	input.bind("move_x", input.key(.A, -1), input.key(.D), input.key(.LEFT, -1), input.key(.RIGHT), input.pad_stick(.LEFT_X))
	input.bind("move_y", input.key(.W), input.key(.S, -1), input.key(.UP), input.key(.DOWN, -1), input.pad_stick(.LEFT_Y, -1))
	input.bind("look_x", input.pad_stick(.RIGHT_X))
	input.bind("interact", input.key(.E), input.pad_button(.RIGHT_FACE_DOWN))

	// For tests and agents: move the goblin instantly.
	engine.register_command("teleport", "teleport X Z: put the goblin at (X, 0, Z)", proc(args: []string) -> string {
		if game.player == 0 || len(args) != 2 do return "usage: teleport X Z"
		x, _ := strconv.parse_f32(args[0])
		z, _ := strconv.parse_f32(args[1])
		engine.get(game.player, engine.Transform).position = {x, 0.05, z}
		engine.skip_interpolation(game.player)
		return "ok"
	})
}

init :: proc() {
	game.player = engine.find("Goblin")
	game.cam_pitch = 25
	game.cam_dist = 4.5
}

update :: proc(dt: f32) {
	if game.player == 0 || !engine.alive(game.player) do return
	control_player(dt)
	update_chests()
	update_camera(dt)
}

// The goblin's model is the root's child (the root is the walking capsule).
goblin_model :: proc() -> Entity {
	for child in engine.children(game.player) do if engine.get(child, engine.Animator) != nil do return child
	return 0
}
