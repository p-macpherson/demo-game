# Content

> What's in Goblin Gold now: its screens, the things in the clearing, its effects and its music, with the files behind each.
> The design itself is in the [Game Brief](Game%20Brief.md) and the docs beside it.

## Screens
Screen files in `assets/ui/`, drawn by the engine; wired up in `game/screens.odin`. One carved-wood-and-parchment
frame and one mossy plank button (`assets/ui/art/`) for all of them, plus coin, chest and map icons.

| Screen | File | When |
|---|---|---|
| Title | `assets/ui/title.json` | At start and after Quit to title; pauses the game |
| HUD | `assets/ui/hud.json` | While playing |
| Pause | `assets/ui/pause.json` | Esc while playing; pauses the game |
| Win | `assets/ui/win.json` | 2.1 s after the last chest opens, once the victory fountain's main burst has played; pauses the game |

## World
| Thing | Model | Notes |
|---|---|---|
| Goblin (player) | `assets/models/goblin` | 1.1 m tall, rigged; clips `idle`, `walk`, `wave` |
| Treasure chest | `assets/models/chest` | 0.6 m; hinge rig with `open`/`close` clips; holds gold |
| Treasure map | `assets/models/treasure-map` | 0.43 m rolled map, not solid; picked up with E, plays `map-pickup` |
| Barrel | `assets/models/barrel` | 0.9 m scenery, solid |
| Boulder | `assets/models/rock` | 0.7 m mossy scenery, solid |
| Lantern | `assets/models/lantern` | Small iron lantern beside each chest's path end; its glass glows and a warm point light pools on the grass |
| Gold pile | `assets/models/gold-pile` | A heap of coins, a goblet and two gems inside each chest (`prefabs/chest.json`, child "Gold Pile"); hidden until the lid lifts (0.2 s after opening) |
| Grass tuft | `assets/models/grass-tuft`, `grass-tuft-tall` | 0.4 m and 0.66 m (with seed heads); decorative, not solid, sway in the wind |

The clearing is `assets/scenes/clearing.json`: a ground tiled with the grass texture (`assets/textures/grass`, 2.5 m tile, tinted a little greener), a winding cobblestone path (`assets/textures/cobblestone`, 1.5 m tile) from the goblin's start with a branch toward each chest that stops short of it, four chests, and barrels and boulders placed
as landmarks. Each kind of thing is a prefab in `assets/prefabs/`.

A small pond (4.4 × 3.4 m of water) lies a few metres from the start, off every path, on the left of the opening view: a
muddy bed, the water a little above it, a low mossy bank, small boulders on the bank and two in the water, and
invisible low colliders so the goblin walks round it. About 330 grass tufts grow in a band round the clearing's
edge, in small clumps between the paths, and tall ones on the pond bank and by rocks and barrels; never on the
paths, the hub, the pads, or next to chests and the map.

Three ambient effects are entities in the scene: "Pond Fireflies" over the pond, "Lantern Embers" (a child of each
lantern) and "Clearing Motes" over the middle of the clearing (see Effects below).

## Effects
Particle effects in `assets/effects/`, with their sprites in `assets/effects/textures/` (star glint, spinning coin
flipbook, cartoon dust puff, firefly, ember, mote). The look is in [Art Style](Art%20Style.md).

| Effect | File | Where and when |
|---|---|---|
| Pond fireflies | `assets/effects/fireflies.json` | Always, in the scene: about 1,400 small yellow-green fireflies wandering and pulsing over and round the pond (8 × 6 m, up to 1.8 m); a GPU field |
| Lantern embers | `assets/effects/lantern-embers.json` | Always, on each of the 4 lanterns: a few tiny orange embers a second rising about 0.5 m from the top |
| Clearing motes | `assets/effects/motes.json` | Always, in the scene: sparse, faint pale-warm motes drifting over the middle of the clearing (14 × 14 m, 0.3–3 m up) |
| Footstep dust | `assets/effects/footstep-dust.json` | Each step on cobblestone (paths, hub, chest pads), never on grass: a small cream puff behind the landing foot, gone in about 0.5 s (`game/player.odin`) |
| Chest open | `assets/effects/chest-open.json` | As a chest's lid starts to lift: about 30 gold star sparkles burst up out of it and a low puff of pale dust kicks out at its sides; about 1 s (`game/chests.odin`) |
| Gold glints | `assets/effects/gold-glints.json` | Once the gold pile shows: 1–3 tiny star glints at a time pop and fade over it, looping until **Play again** resets the clearing |
| Victory | `assets/effects/victory.json` | When the last chest opens: spinning gold coins and sparkles arc up and out from a ring round the goblin and fall back, about 2.5 s (`game/screens.odin`) |

## Music
| Piece | Score | Where it plays |
|---|---|---|
| Goblin Gold | `assets/music/goblin-gold/song.json` | The whole game, looping: D dorian, 104 bpm, flute and clarinet over pizzicato strings, about a minute |
| Treasure Found | `assets/music/treasure-found/song.json` | Once, when a chest opens: a glockenspiel flourish ending on D major |
