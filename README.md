# When the Voice Fell Silent

A top-down space trading and smuggling game. The Voice, who ruled by decree, is
dead. His empire, the Edict, lost the war to the Accord, and his regional
governors, the Echoes, now fight over what is left of the Reach. You fly a
small freighter through it, trading, smuggling and fighting to make a living.

Every game builds a new galaxy with different factions in charge. Death is
permanent, but some upgrades carry over to the next game.

- Engine: **Godot 4.7.2**, GDScript
- Platforms: PC first, then iPad, then iOS and Android phones

## Status

Early port of the browser prototype (0.1). What's in so far:

- Game data: goods, factions, system types, legality ladder, market events
- Galaxy generation: systems, jump lanes, system types, faction seats and
  territory, rolled cargo rules, black markets, local system maps
- A galaxy preview screen: generate by seed, pick a size, tap a system to see
  its owner, danger, locations, cargo rules and lanes

Next: game state and markets, travel and fog of war, customs checks, contracts,
then combat.

## Running it

1. Install [Godot 4.7.2](https://godotengine.org/download/archive/4.7.2-stable/)
   (the standard build, not .NET).
2. Open `project.godot` in the editor and press Play, or from a terminal:

   ```sh
   godot --path .
   ```

Preview the phone or tablet layout on a PC:

```sh
godot --path . -- --form-factor=phone
godot --path . -- --form-factor=tablet
godot --path . -- --ui-scale=1.25   # extra UI scale
```

## Tests

Tests run headless with no add-ons:

```sh
godot --headless --path . --import
godot --headless --path . -s res://tests/run_tests.gd
```

They also run on every pull request (`.github/workflows/tests.yml`).

## Layout

```
scenes/            Scenes (.tscn). main.tscn is the entry point.
scripts/
  autoload/        Global singletons (UIScale)
  data/            Static game data: goods, factions, system types, names
  galaxy/          Galaxy model and the generator
  ui/              Scripts for UI scenes
assets/            Fonts, sprites, audio
tests/             Headless test runner and test suites
tools/             Developer scripts (screenshots)
```

## License

MIT, see [LICENSE](LICENSE).
