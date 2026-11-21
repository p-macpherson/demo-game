package game

import "core:math/linalg"
import "engine:engine"
import "engine:input"

// Finds the nearest treasure map in reach; E picks it up (it disappears, the goblin waves).
update_map :: proc() {
	here := engine.world_position(game.player)
	game.near_map = 0
	best := f32(OPEN_REACH)
	ents, _ := engine.view(Treasure_Map)
	for e in ents {
		d := linalg.length((engine.world_position(e) - here).xz)
		if d < best do best, game.near_map = d, e
	}
	if game.near_map != 0 && input.action_pressed("interact") do pick_up_map(game.near_map)
}

pick_up_map :: proc(e: Entity) {
	pos := engine.world_position(e)
	game.has_map = true
	game.near_map = 0
	engine.play_sound_at("sounds/map-pickup/map-pickup.ogg", pos, volume = 0.8)
	if t := engine.get(game.player, engine.Transform); t != nil {
		to := pos - engine.world_position(game.player)
		to.y = 0
		if linalg.length(to) > 0.01 do t.rotation = engine.look_rotation(to)
	}
	engine.destroy(e)
	celebrate()
}
