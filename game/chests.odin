package game

import "core:math/linalg"
import "engine:engine"
import "engine:input"

OPEN_REACH :: 1.4 // metres from the goblin to a chest's centre

// Finds the nearest closed chest in reach; E opens it, adds its gold and makes the goblin wave.
update_chests :: proc() {
	here := engine.world_position(game.player)
	game.near = 0
	best := f32(OPEN_REACH)
	ents, chests := engine.view(Chest)
	for c, i in chests {
		if c.open do continue
		d := linalg.length((engine.world_position(ents[i]) - here).xz)
		if d < best do best, game.near = d, ents[i]
	}
	if game.near != 0 && input.action_pressed("interact") do open_chest(game.near)
}

open_chest :: proc(e: Entity) {
	c := engine.get(e, Chest)
	if c == nil || c.open do return
	c.open = true
	game.gold += c.gold
	engine.play_animation(e, "open", once = true)
	engine.play_sound_at("sounds/chest-open/chest-open.ogg", engine.world_position(e))
	game.gold_in, game.gold_at = 0.5, engine.world_position(e)
	engine.play_sound(JINGLE_TREASURE, volume = 0.9, bus = .Music)
	// Face the chest while celebrating.
	if t := engine.get(game.player, engine.Transform); t != nil {
		to := engine.world_position(e) - engine.world_position(game.player)
		to.y = 0
		if linalg.length(to) > 0.01 do t.rotation = engine.look_rotation(to)
	}
	celebrate()
}

chests_left :: proc() -> (left, total: int) {
	_, chests := engine.view(Chest)
	for c in chests {
		total += 1
		if !c.open do left += 1
	}
	return
}

// The coins jingle half a second after the lid starts to open.
update_gold_sound :: proc(dt: f32) {
	if game.gold_in <= 0 do return
	game.gold_in -= dt
	if game.gold_in <= 0 do engine.play_sound_at("sounds/gold/gold.ogg", game.gold_at, volume = 0.7)
}
