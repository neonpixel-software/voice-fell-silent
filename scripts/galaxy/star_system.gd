class_name StarSystem
extends RefCounted
## One star system as generated. Runtime state (what the player knows, current
## market events, prices seen) belongs to the game state, not here.

var id: int
var name: String
## Position on the galaxy map, in map units (see GalaxySettings.map_size).
var position: Vector2
var type: String
var owner: String
## 0 (safe) to 3 (dangerous).
var danger := 0
var has_black_market := false
## Goods made contraband by local custom (Free Worlds Compact systems).
var local_bans: Array[String] = []

## Market state per good id. stock is a price multiplier (1.0 = normal);
## supply is how many units the station restocks to; qty is what is for sale now.
var stock: Dictionary[String, float] = {}
var supply: Dictionary[String, int] = {}
var qty: Dictionary[String, int] = {}
## Black-market stock, only filled when has_black_market.
var bm_qty: Dictionary[String, int] = {}
var bm_max: Dictionary[String, int] = {}

var locations: Array[SystemLocation] = []


func location(loc_id: String) -> SystemLocation:
	for loc in locations:
		if loc.id == loc_id:
			return loc
	return null
