# CLAUDE.md

Guidance for Claude (and other contributors) working in this repo.

## The game

"When the Voice Fell Silent": a top-down space trading, smuggling and combat
game. Roguelike: a new procedural galaxy every game, permadeath, some
permanent upgrades between games. Ship view and fights are inspired by FTL's
top-down cutaway, but NOT its run structure: no chasing fleet, no time pressure.

Design docs live in the project's shared files, not in this repo:
`concept/space-trader-concept-v2.md`, `economy/space-trader-economy-v1.md`,
`galaxy/space-trader-galaxy-v1.md`, `ships/space-trader-ships-v2.md`, and the
browser prototype `prototype/index.html` (the reference for what is being ported).

## Hard rules

- **Engine is pinned to Godot 4.7.2** (standard build, GDScript, no C#). Don't
  bump the version or use features from later versions without the owner's OK.
  CI downloads exactly this version.
- **No Star Wars names, terms or references anywhere** in code, data, comments
  or text, for copyright reasons. Also avoid names that clash with other
  franchises or books. Use only the original setting below. When adding new
  names, check them against games and books first.
- Open a pull request for review; don't push to `main`.

## Setting glossary

- **The Voice**: the dead absolute ruler; whatever he spoke became law. Died at
  the Battle of **Ostrel**.
- **The Edict**: his empire, named for his decrees. Defeated, not gone.
- **The Accord**: the former rebellion, now a government.
- **Echoes**: the Edict's regional governors, fighting over the remains.
- **The Reach**: the region the game takes place in.
- Factions (ids in `scripts/data/factions.gd`): Iron Succession (`succession`,
  led by Echo Dovran), Seyl Protectorate (`seyl`), the Accord (`accord`), the
  Embers (`embers`), Vashti Clans (`clans`), the Ninefold (`ninefold`), Free
  Worlds Compact (`compact`). `none` = Unclaimed.
- Goods of note: **glint** (narcotic), **knitgel** (medicine).
- Old names that must NOT be used: Sovereign, Dominion, Concord, Prefect(s),
  Kessrin, Iron Remnant, Varrick, medgel.

## Code conventions

- GDScript with static typing everywhere (`var x: int`, `:=`, typed arrays and
  dictionaries, return types). Tabs for indentation.
- Game data are `class_name` scripts with `const` dictionaries keyed by string
  ids (`Goods.KNITGEL`, `Factions.ACCORD`). Use the id constants, not literals.
- Simulation code (`scripts/galaxy/`, future `scripts/game/`) is plain
  `RefCounted` classes with no nodes or rendering, so it runs in headless tests.
  UI scripts read from it; they don't hold game rules.
- Generation must be deterministic per seed: use the generator's own
  `RandomNumberGenerator`, never the global `randf()`/`Array.shuffle()`.
- Commit the `.gd.uid` and `.import` files Godot creates; never commit `.godot/`.

## UI scaling (PC, then iPad, then phones)

- Base viewport 1280x720, stretch mode `canvas_items`, aspect `expand`,
  landscape on handhelds, Compatibility renderer.
- The `UIScale` autoload picks a form factor (desktop, tablet, phone) and sets
  the window's content scale factor so text and buttons stay a usable physical
  size. Listen to `UIScale.layout_changed` and read `UIScale.compact` to adapt
  layouts; don't hard-code pixel sizes for a single screen.
- Touch targets are at least `UIScale.MIN_TOUCH_TARGET` (44 logical px) on touch
  devices. Every action must work with a tap: no hover-only info, no
  right-click-only actions, no keyboard-only shortcuts.
- Use containers and anchors, not absolute positions. Custom-drawn views (like
  the galaxy map) must fit themselves to their rect.
- Check layouts at desktop, tablet and phone sizes, e.g. with
  `tools/screenshot.gd` (see the header of that file) or
  `godot --path . -- --form-factor=phone`.

## Tests

```sh
godot --headless --path . --import
godot --headless --path . -s res://tests/run_tests.gd
```

Add suites to `TEST_SCRIPTS` in `tests/run_tests.gd`; suites extend `TestCase`
and every `test_*` method runs. Galaxy tests check invariants over many seeds
and sizes; add one for every new generation rule.
