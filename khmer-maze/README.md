# Khmer Maze Game (working title) - Phase 0: Khmer Render Test

A tiny Godot 4 project to check that Khmer text renders correctly on your target
devices **before** we build the game. It also tests the bounce animation and
design-token loading.

## Requirements
- Godot **4.3 or newer** (standard build, not .NET needed)
- An Android phone (ideally a low-end one) with developer mode on

## Run it
1. Open Godot > Import > select `project.godot`.
2. Press **F5**. You should see a list of Khmer word tiles.
3. Tap a tile to see the bounce. Drag the **Tile size** slider to test 24-96.

## Test on a real phone
1. Follow the Godot 4.6 Android export docs (JDK 17, Android SDK Platform 35, Build-Tools 35.0.1, CMake 3.10.2.4988404, NDK 28.1.13356709). No Gradle build template is needed.
2. Project > Export > Add **Android** preset. Enable USB debugging on the phone.
3. Use the one-click deploy (phone icon) in the top right of the editor.

## Pass / fail checklist
Check every tile at sizes 32, 48, and 72, on the phone (not just the desktop):

- [ ] Top line says **OK: text server = ...HarfBuzz...**
- [ ] No broken clusters (subscripts like ខ្លា, ផ្កា, ស្រី sit under/after the consonant correctly)
- [ ] Vowels and marks (ទឹក, ដំរី, ផ្លូវ) are not overlapping or detached
- [ ] Nothing is clipped at the top or bottom of any tile
- [ ] Every tile shows **[segmentation OK]**
- [ ] Mixed Khmer + numerals line renders correctly
- [ ] Tap bounce stays smooth (no stutter) on the low-end phone
- [ ] Have a native Khmer reader confirm every word looks right

**If it all passes:** Godot 4 is locked in as the engine.
**If Khmer breaks on device:** note which words and which phone, and we switch to the
Flutter + Flame (+ Rive) fallback.

## Tablet + rotation checklist
The info line under the title shows view size, orientation, phone/TABLET, and column count.

- [ ] Phone portrait: 1 column
- [ ] Phone landscape: 2-3 columns, nothing cut off
- [ ] Tablet portrait: tiles centered, readable, not stretched edge to edge
- [ ] Tablet landscape: 3 columns, content centered with a max width
- [ ] Rotating the device re-arranges the layout live (no restart)
- [ ] Touch targets still comfortable on a tablet (tiles are not tiny)

## Troubleshooting
- *Text server says "Fallback":* the advanced text server is not active. Check
  Project Settings > Internationalization > Rendering > Text Driver, and use the
  standard Godot build (not a stripped template).
- *Khmer shows as boxes:* the font did not load. Confirm `fonts/NotoSansKhmer.ttf` exists and imported.
- *Different look on phone vs. desktop:* trust the phone.

## Project structure
```
project.godot
data/tokens.json      design tokens (colors, spacing, motion)
data/words.json       word list with explicit tile segmentation
fonts/                Noto Sans Khmer (SIL OFL license included)
scenes/render_test.tscn
scripts/tokens.gd     autoload: Tokens.c("bg.parchment"), Tokens.get_value("motion.quick")
scripts/layout.gd     autoload: responsive helpers (phone/tablet, columns, rotation signal)
scripts/render_test.gd
```

## Notes
- Tiles are grapheme clusters chosen by the author in `words.json`, never raw code points.
- Word spellings and tile splits in `words.json` are starter data and need native-speaker review.
- Font: Noto Sans Khmer, SIL Open Font License 1.1 (see `fonts/OFL.txt`).

## Next (Phase 1: vertical slice)
Main menu, one maze level, Pair Match challenge, tiger and elephant with animation, basic audio.
