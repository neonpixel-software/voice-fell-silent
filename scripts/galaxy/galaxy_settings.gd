class_name GalaxySettings
extends RefCounted
## Inputs to galaxy generation. The defaults reproduce prototype 0.1:
## 16 systems, four factions on the map. The galaxy doc's Standard size (40 to
## 50 systems, rotating cast) is the target once the full pipeline is ported.

## Size of the local (in-system) map, in local-map units.
const LOCAL_MAP_SIZE := Vector2(1000, 600)

## Map size and spacing are tuned for 16 systems; larger galaxies grow the map
## so spacing (about one day of travel) stays the same.
const BASE_SYSTEM_COUNT := 16
const BASE_MAP_SIZE := Vector2(1000, 600)

var system_count := BASE_SYSTEM_COUNT
## Minimum distance between two systems, in map units.
var min_spacing := 122.0
## Lanes shorter than these take 1 or 2 days; longer ones take 3.
var one_day_distance := 165.0
var two_day_distance := 255.0
## Factions placed on the map, in seat-picking order. The first one owns the start.
var cast: Array[String] = [Factions.ACCORD, Factions.SUCCESSION, Factions.CLANS, Factions.COMPACT]
## Share of all systems each faction grows to (seat included).
var territory_share: Dictionary[String, float] = {
	Factions.ACCORD: 0.25,
	Factions.SUCCESSION: 0.25,
	Factions.CLANS: 0.19,
	Factions.COMPACT: 0.19,
}


func map_size() -> Vector2:
	return BASE_MAP_SIZE * sqrt(float(system_count) / BASE_SYSTEM_COUNT)


func map_margin() -> Vector2:
	return Vector2(70, 55)


func territory_target(faction: String) -> int:
	return maxi(1, roundi(system_count * territory_share.get(faction, 0.0)))
