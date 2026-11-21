# Goblin Gold

> The design overview: what the game is and what it's trying to be. Demo Game is the sandbox Game Studio is
> developed against, so this game stays deliberately small: big enough to show every studio module working
> together, small enough to change in an afternoon.

## Pitch
A small goblin wanders a mossy clearing looking for treasure. Walk up to a chest, open it, and celebrate the
gold inside. Find every chest to win.

## Pillars
- **Readable at a glance.** Chunky, stylised models and a calm palette; the goblin is always the clearest thing on screen.
- **Every action has a reaction.** Walking animates, chests creak open, the goblin waves when it finds gold.
- **Made in the studio.** Every asset comes from a Game Studio module (models from 3D Models, code from Game
  Code sessions), so the game doubles as a showcase of the pipeline.

## Core loop
0. The game opens on the title screen over the clearing: **Play** starts, **Quit** exits.
1. Explore the clearing with **WASD** (hold the right mouse button and drag to turn the camera, wheel to zoom).
2. Near a closed chest, press **E** to open it: the lid swings open, gold is added to the counter and the goblin waves.
3. A treasure map lies in the clearing: press **E** next to it to pick it up (a paper rustle) and the HUD shows "Map found".
4. When every chest is open, the clearing is cleared: the win screen shows the gold total and **Play again** resets the clearing.

**Esc** pauses (Resume, master volume, Quit to title). The HUD shows gold, chests opened out of the total, "Map found", and the E prompt near a chest or the map.

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

## Art direction
Stylised and chunky, a calm green-and-stone palette under a warm afternoon light; the clearing should feel alive
but never busy. Movement and light are small and slow so the goblin, the chests and the paths stay the clearest
things on screen.

- **Light and grade.** Post-processing (`environment.post` in the scene): soft bloom (0.45, threshold 1, so only
  emissive things and glints glow, never the pale cobbles or the sky), a warm white balance (temperature 0.12), a
  touch of contrast and saturation (0.06, 0.08) and a light vignette (0.25). No outlines, no chromatic aberration.
  The sky's horizon and the fog are a warm hazy cream. The HUD is drawn after the grade and stays crisp.
- **Glow.** Only the lanterns and the gold glow. Lantern glass (`shaders/lantern-glow.glsl` on the lantern
  model) burns a warm candle orange with a gentle flicker, each lantern out of step. Gold
  (`shaders/gold.glsl`) keeps its coins' own colours and gems, a faint inner warmth and a few small glints that
  travel across the pile and bloom: it reads as coins, not a light bulb.
- **Water** (`shaders/water.glsl` on a `grid`): slow, few-centimetre waves; deep teal looking down, lighter
  at grazing angles; a thin, soft, broken pale line where it meets the bank and the rocks; a few faint sparkles.
- **Wind** (`shaders/wind.glsl`): grass bends gently from the base (tips move a few centimetres, more than the
  base), gusts drift across the clearing so neighbouring tufts move out of step. Tufts are instanced and cast
  no shadows, to keep the game smooth.
- **Budget.** All of this adds no measurable frame time (about 0.8 ms a frame at 1280×720 on a desktop GPU).

## Music
| Piece | Score | Where it plays |
|---|---|---|
| Goblin Gold | `assets/music/goblin-gold/song.json` | The whole game, looping: D dorian, 104 bpm, flute and clarinet over pizzicato strings, about a minute |
| Treasure Found | `assets/music/treasure-found/song.json` | Once, when a chest opens: a glockenspiel flourish ending on D major |

## Scope
Single player, one scene, a few minutes of play. Deliberately left out: enemies, inventory, saving, sound effects (until the SFX module exists), menus beyond the title, pause and win screens.
