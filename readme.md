# Phase 0 Summary: Foundations

**Project:** Khmer word-maze mobile game for grades 1-3 (working title still open)
**Phase goal:** Remove the biggest technical risk (Khmer text rendering), choose the engine, and set up the project foundation.
**Status:** Desktop tests passed. Real-device tests are still pending.

---

## 1. Game concept

A child is lost in an ancient jungle-temple maze. A tiger enters behind them, and a kind elephant waits at the exit. Matching Khmer letters, syllables, and words reveals the route. The player wins by reaching the elephant before the tiger catches them.

- **Audience:** young kids, grades 1-3
- **Mechanics:** a mix across levels (Pair Match, Build-a-Word, Pick the Word, Fix the Route)
- **Goal:** help students test their Khmer knowledge and enjoy discovering new words
- **Key art:** the supplied illustration (boy with map, tiger entrance, elephant exit) sets the visual style

## 2. Decisions made

| Decision | Outcome | Reason |
|---|---|---|
| Target players | Grades 1-3 | Large touch targets, audio on everything, forgiving tiger |
| Core mechanic | Mix of match, build, and pick across levels | Gradual difficulty ramp |
| Engine | **Godot 4 (running 4.6.1)**, pending device test | Animation is a must for kids; built-in tweens, particles, and animation; lightweight on low-end Android |
| Fallback engine | Flutter + Flame (+ Rive) | Used only if Khmer breaks on device in Godot |
| Platforms | **Android phones and tablets first**; iPad later | iOS export needs a Mac with Xcode and an Apple Developer account |
| iPad options later | Cloud Mac build, web export, or a borrowed Mac | Decide when needed |
| Layout approach | Adaptive: phone and tablet, portrait and landscape | Android may ignore orientation locks on large screens |
| Working title | Not final. Candidates: Khla Run, Rok Phlov, Phlov Peak, Word Trail | Check app-store availability before choosing |

## 3. Deliverables produced

1. **Design System Plan** (`khmer-maze-game-design-system-plan.md`): design principles, color, type, spacing, and motion tokens, characters, challenge types, components, screens, content data format, accessibility, tech notes, testing plan, roadmap, risks, and open decisions.
2. **Godot starter project** (`khmer-maze-godot-starter-tablet.zip`):
    - Khmer render test scene with 11 test words
    - Design token loader (`Tokens` autoload)
    - Responsive layout helper (`Layout` autoload)
    - Word data with explicit tile segmentation
    - Noto Sans Khmer font (SIL OFL license included)
    - README with setup steps and checklists

### Project structure

```
project.godot
data/tokens.json      design tokens (colors, spacing, motion, layout)
data/words.json       word list with explicit tile segmentation
fonts/                Noto Sans Khmer + OFL license
scenes/render_test.tscn
scripts/tokens.gd     autoload: Tokens.c("bg.parchment"), Tokens.get_value("motion.quick")
scripts/layout.gd     autoload: phone/tablet detection, columns, rotation signal
scripts/render_test.gd
README.md
```

## 4. Results so far

**Passed on desktop (Godot 4.6.1):**
- Text server is ICU / HarfBuzz / Graphite, so complex Khmer shaping is active
- Subscripts and vowels render correctly on the words checked (ខ្លា, ដំរី, ផ្កា, ទឹក, ព្រៃ, ផ្លូវ, ក្រមា, ពាក្យ)
- Tile segmentation check passes (tiles join back to the full word)
- Tap bounce animation works
- Layout info line works (view size, orientation, phone/tablet, column count)

**Bugs found and fixed during testing:**
- "Tile size" label wrapped into a vertical column. Fixed by adding a `wrap` option to `_ink_label`.
- Early setup notes listed Android tool versions for Godot 4.3 and a wrong keytool flag. Corrected to the Godot 4.6 requirements (below) and the standard keytool command.

**Android requirements for Godot 4.6:**
- JDK 17
- Android SDK Platform 35, Build-Tools 35.0.1, Platform-Tools 35.0.0 or later, latest Command-line Tools
- CMake 3.10.2.4988404, NDK 28.1.13356709
- Export templates must match the editor version exactly (4.6)
- No Gradle build template is needed for this test

## 5. Still open (not yet verified)

- [ ] **Low-end Android phone test:** run the README checklist at tile sizes 32, 48, and 72
- [ ] **Tablet test:** check 1 to 3 columns, centered content, and live rotation (desktop embedded-window testing could not show the wide layout)
- [ ] **Native Khmer review:** confirm every word, spelling, and tile split in `words.json` (starter data, not reviewed)
- [ ] **Font choice:** confirm Noto Sans Khmer, or pick a school-style Khmer font; confirm the display font license
- [ ] **Title and store availability:** pick the name, then check Google Play, App Store, domain, and social handles
- [ ] **Word list source:** curriculum, teacher partner, or custom
- [ ] **Voice recording:** who records the Khmer audio
- [ ] **Distribution and monetization:** Play Store, school deployment, free vs. paid

## 6. Exit criteria for Phase 0

Phase 0 is complete when:
1. Khmer renders cleanly on the low-end Android phone (no broken clusters, no clipping)
2. The layout behaves on a tablet (or a tablet-sized emulator) and rotates correctly
3. A native reader confirms the starter words look right

If all three pass, Godot 4 is locked in. If Khmer breaks on device, record which words and which phone, then switch to the fallback engine.

## 7. Next: Phase 1, vertical slice

One playable level to test whether the game is fun before investing in final art and audio:

1. Main menu, level scene, result screen, and a game-state manager
2. A winding maze of about 6 segments with placeholder child, tiger entrance, and elephant exit
3. Pair Match challenge; each correct match clears vines and opens the next segment
4. Tiger that advances on a timer and on wrong answers; caught means return to the last checkpoint plus an elephant hint
5. Win screen with stars and a word card (picture, sound button, meaning)
6. Polish: bounces, particles, reactions, placeholder sounds

**Assumption for the slice:** a single winding route. Branching mazes and dead ends come later.