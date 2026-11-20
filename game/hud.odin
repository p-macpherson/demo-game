package game

import "core:fmt"
import "engine:ui"

draw_ui :: proc() {
	left, total := chests_left()

	r := ui.anchor(.Top_Left, 230, game.has_map ? 100 : 76, {16, 16})
	ui.panel(r)
	col := ui.column(ui.inset(r, 12), 26, 2)
	ui.label(ui.next(&col), fmt.tprintf("Gold: %d", game.gold), size = 26)
	ui.label(ui.next(&col), fmt.tprintf("Chests: %d / %d opened", total - left, total), color = ui.theme().text_dim)
	if game.has_map do ui.label(ui.next(&col), "Map found", color = ui.theme().text_dim)

	if game.near_map != 0 {
		p := ui.anchor(.Bottom, 260, 44, {0, 60})
		ui.panel(p)
		ui.label(p, "E  Pick up the map", .Center)
	} else if game.near != 0 {
		p := ui.anchor(.Bottom, 260, 44, {0, 60})
		ui.panel(p)
		ui.label(p, "E  Open the chest", .Center)
	}
	if total > 0 && left == 0 {
		b := ui.anchor(.Top, 520, 70, {0, 40})
		ui.panel(b)
		ui.label(b, "The clearing is cleared!", .Center, 34)
	}
	hint := ui.anchor(.Bottom_Right, 330, 30, {16, 12})
	ui.label(hint, "WASD walk   |   right-drag look   |   wheel zoom", .Right, 16, ui.theme().text_dim)
}
