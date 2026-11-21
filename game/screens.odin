package game

import "engine:engine"
import "engine:input"

CLEARING_SCENE :: "scenes/clearing.json"
WIN_DELAY :: 2.1 // seconds between opening the last chest and the win screen (the lid, the wave and the victory fountain's main burst play out)

// Mirrors which screen is up, so scripts can assert on it (an entity named "Screens"; see tests/screens.jsonl).
Screen_State :: struct {
	title, hud, pause, win: bool,
	gold:                   int,
	glints:                 int, // gold-glints effects still playing (none after a reset)
}

// Runs every frame as the engine's draw_ui hook (`update` doesn't run while a pausing screen is up, and the pause,
// title and win screens must keep reacting): reads the screens' actions, Esc, and feeds the HUD's bindings.
screens_frame :: proc() {
	for a in engine.ui_actions() {
		switch a.action {
		case "play":
			engine.ui_hide("title")
			engine.ui_show("hud")
		case "quit":
			engine.quit()
		case "resume":
			engine.ui_hide("pause")
		case "volume":
			engine.set_volume(.Master, a.value)
		case "quit_to_title":
			reset_game()
			engine.ui_hide("pause")
			engine.ui_hide("hud")
			engine.ui_show("title")
		case "play_again":
			reset_game()
			engine.ui_hide("win")
			engine.ui_show("hud")
		}
	}

	if input.action_pressed("pause") {
		if engine.ui_shown("pause") do engine.ui_hide("pause")
		else if engine.ui_shown("hud") do engine.ui_show("pause")
	}

	left, total := chests_left()
	engine.ui_set("gold", game.gold)
	engine.ui_set("chests_opened", total - left)
	engine.ui_set("chests_total", total)
	engine.ui_set("has_map", game.has_map)
	engine.ui_set("near_map", game.near_map != 0)
	engine.ui_set("near_chest", game.near != 0 && game.near_map == 0)

	if s := engine.get(game.screens, Screen_State); s != nil {
		glints := 0
		for h in game.glints[:game.glint_count] do if engine.effect_playing(h) do glints += 1
		s^ = {engine.ui_shown("title"), engine.ui_shown("hud"), engine.ui_shown("pause"), engine.ui_shown("win"), game.gold, glints}
	}
}

// The win screen appears a moment after the last chest opens.
update_win :: proc(dt: f32) {
	if game.win_in > 0 {
		game.win_in -= dt
		if game.win_in <= 0 {
			engine.ui_hide("hud")
			engine.ui_show("win")
		}
		return
	}
	left, total := chests_left()
	if total > 0 && left == 0 && engine.ui_shown("hud") {
		game.win_in = WIN_DELAY
		engine.play_effect("effects/victory.json", engine.world_position(game.player))
	}
}

// Back to a fresh game: reloads the scene (chests closed, map on the ground, goblin at the start) and the state.
reset_game :: proc() {
	for h in game.glints[:game.glint_count] do engine.stop_effect(h, clear = true)
	engine.load_scene(CLEARING_SCENE)
	game = {}
	setup_world()
}

// Looks up what the scene holds and (re)creates the screen-state entity.
setup_world :: proc() {
	game.player = engine.find("Goblin")
	game.cam_pitch = 25
	game.last_step = -1
	game.cam_dist = 4.5
	game.screens = engine.spawn("Screens")
	engine.add(game.screens, Screen_State{})
}
