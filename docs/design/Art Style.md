---
status: draft
---
# Art Style

> Chunky, stylised and hand-painted, in a calm natural palette: readable at a glance, with the goblin always the
> clearest thing on screen.

Written on 2026-11-21 from what was already in the game and its old Overview; Pat hasn't reviewed it as a doc yet, hence draft. It describes the assets the game already has, so new ones match them.

## Style
Chunky, stylised game art with a hand-painted look. Never photoreal.

## Palette
Calm and natural: mossy greens, warm wood browns, grey stone, with gold as the one bright accent.

## Shape and proportion
Thick, simple forms with clear silhouettes. The goblin must read more clearly than any scenery around it.

## Detail and materials
Stylised hand-painted textures (grass with small clover leaves, cobblestone), sized in metres. Wood and stone are worn
and mossy, not clean.

## Lighting and effects
A warm afternoon light; the clearing should feel alive but never busy. Movement and light are small and slow so the
goblin, the chests and the paths stay the clearest things on screen.

- **Light and grade.** Post-processing (`environment.post` in the scene): soft bloom (0.45, threshold 1, so only
  emissive things and glints glow, never the pale cobbles or the sky), a warm white balance (temperature 0.12), a
  touch of contrast and saturation (0.06, 0.08) and a light vignette (0.25). No outlines, no chromatic aberration.
  The sky's horizon and the fog are a warm hazy cream. The HUD is drawn after the grade and stays crisp.
- **Glow.** Only the lanterns and the gold glow. Lantern glass (`shaders/lantern-glow.glsl` on the lantern
  model) burns a warm candle orange with a gentle flicker, each lantern out of step. Gold (`shaders/gold.glsl`)
  keeps its coins' own colours and gems, a faint inner warmth and a few small glints that travel across the pile
  and bloom: it reads as coins, not a light bulb.
- **Water** (`shaders/water.glsl` on a `grid`): slow, few-centimetre waves; deep teal looking down, lighter at
  grazing angles; a thin, soft, broken pale line where it meets the bank and the rocks; a few faint sparkles.
- **Wind** (`shaders/wind.glsl`): grass bends gently from the base (tips move a few centimetres, more than the
  base), gusts drift across the clearing so neighbouring tufts move out of step. Tufts are instanced and cast no
  shadows, to keep the game smooth.
- **Budget.** All of this adds no measurable frame time (about 0.8 ms a frame at 1280×720 on a desktop GPU).

## UI
One carved-wood-and-parchment frame and one mossy plank button for every screen, plus coin, chest and map icons.

## Scale
| Thing | Size |
|---|---|
| Goblin | 1.1 m tall |
| Chest | 0.6 m |
| Barrel | 0.9 m |
| Boulder | 0.7 m |

## To decide
- **Prompt phrases.** Wording to put in every generation prompt so assets match.
- **References.** Games or artists this should sit beside.
