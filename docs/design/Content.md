# Content

> What's in Goblin Gold now: its screens, the things in the clearing, and its music, with the files behind each.
> The design itself is in the [Game Brief](Game%20Brief.md) and the docs beside it.

## Screens
Screen files in `assets/ui/`, drawn by the engine; wired up in `game/screens.odin`. One carved-wood-and-parchment
frame and one mossy plank button (`assets/ui/art/`) for all of them, plus coin, chest and map icons.

| Screen | File | When |
|---|---|---|
| Title | `assets/ui/title.json` | At start and after Quit to title; pauses the game |
| HUD | `assets/ui/hud.json` | While playing |
| Pause | `assets/ui/pause.json` | Esc while playing; pauses the game |
| Win | `assets/ui/win.json` | 1.6 s after the last chest opens; pauses the game |

## World
| Thing | Model | Notes |
|---|---|---|
| Goblin (player) | `assets/models/goblin` | 1.1 m tall, rigged; clips `idle`, `walk`, `wave` |
| Treasure chest | `assets/models/chest` | 0.6 m; hinge rig with `open`/`close` clips; holds gold |
| Treasure map | `assets/models/treasure-map` | 0.43 m rolled map, not solid; picked up with E, plays `map-pickup` |
| Barrel | `assets/models/barrel` | 0.9 m scenery, solid |
| Boulder | `assets/models/rock` | 0.7 m mossy scenery, solid |

The clearing is `assets/scenes/clearing.json`: a ground tiled with the grass texture (`assets/textures/grass`, 2.5 m tile, tinted a little greener), a winding cobblestone path (`assets/textures/cobblestone`, 1.5 m tile) from the goblin's start with a branch toward each chest that stops short of it, four chests, and barrels and boulders placed
as landmarks. Each kind of thing is a prefab in `assets/prefabs/`.

## Music
| Piece | Score | Where it plays |
|---|---|---|
| Goblin Gold | `assets/music/goblin-gold/song.json` | The whole game, looping: D dorian, 104 bpm, flute and clarinet over pizzicato strings, about a minute |
| Treasure Found | `assets/music/treasure-found/song.json` | Once, when a chest opens: a glockenspiel flourish ending on D major |
