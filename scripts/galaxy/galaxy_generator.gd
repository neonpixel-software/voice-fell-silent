class_name GalaxyGenerator
extends RefCounted
## Builds a galaxy from a seed. The same seed and settings always give the same
## galaxy.
##
## This is a port of prototype 0.1's generator, which covers galaxy doc steps
## 3, 4, 5, 6, 8 and 11 in cut-down form:
##   1. scatter systems with a minimum spacing
##   2. connect each to its nearest neighbours without crossing lanes,
##      then join any separate clusters
##   3. deal system types
##   4. roll each faction's cargo rules
##   5. place faction seats far apart, then grow territories outward
##   6. name systems, set danger, black markets and starting markets
##   7. build each system's local map
## Not ported yet: map templates, terrain, chokepoint rules, power scenarios,
## presence, fronts, starting situations and validation.

const PREFERRED_SEAT_TYPES := {
	Factions.ACCORD: [SystemTypes.HUB, SystemTypes.CAPITAL],
	Factions.SUCCESSION: [SystemTypes.FORTRESS, SystemTypes.INDUSTRIAL],
	Factions.CLANS: [SystemTypes.AGRI, SystemTypes.HUB],
	Factions.COMPACT: [SystemTypes.MINING, SystemTypes.AGRI, SystemTypes.REFUGEE],
	Factions.SEYL: [SystemTypes.CAPITAL, SystemTypes.HUB],
}

## The order factions take turns growing (Succession first: it grabs land).
const GROWTH_ORDER: Array[String] = [
	Factions.SUCCESSION, Factions.SEYL, Factions.ACCORD, Factions.COMPACT, Factions.CLANS,
]

## Type deck from the prototype. Larger galaxies deal it again.
const TYPE_DECK: Array[String] = [
	SystemTypes.HUB, SystemTypes.CAPITAL, SystemTypes.HAVEN, SystemTypes.FORTRESS,
	SystemTypes.MINING, SystemTypes.AGRI, SystemTypes.INDUSTRIAL, SystemTypes.REFUGEE,
	SystemTypes.DERELICT, SystemTypes.HUB, SystemTypes.FORTRESS, SystemTypes.MINING,
	SystemTypes.AGRI, SystemTypes.INDUSTRIAL, SystemTypes.REFUGEE, SystemTypes.DERELICT,
]

const BASE_DANGER := {
	Factions.ACCORD: 0, Factions.COMPACT: 1, Factions.CLANS: 1,
	Factions.SUCCESSION: 1, Factions.SEYL: 1, Factions.NONE: 3,
}

const COMPACT_BAN_POOL: Array[String] = [
	Goods.SPIRITS, Goods.ARMS, Goods.GLINT, Goods.DATACORES, Goods.KNITGEL,
]

## Unreachable marker in hop tables; larger than any real hop count.
const FAR := 999

var _rng := RandomNumberGenerator.new()
var _settings: GalaxySettings
var _galaxy: Galaxy
var _points: Array[Vector2] = []
var _lane_keys := {}


static func generate(galaxy_seed: int, settings: GalaxySettings = null) -> Galaxy:
	var gen := GalaxyGenerator.new(galaxy_seed, settings if settings else GalaxySettings.new())
	return gen._build()


func _init(galaxy_seed: int, settings: GalaxySettings) -> void:
	_rng.seed = galaxy_seed
	_settings = settings
	_galaxy = Galaxy.new()
	_galaxy.galaxy_seed = galaxy_seed
	_galaxy.settings = settings


func _build() -> Galaxy:
	_place_points()
	_connect_lanes()
	var types := _deal_types()
	_roll_rules()
	var owner := _grow_territories(types)
	_galaxy.start = _galaxy.seats[_settings.cast[0]]
	_make_systems(types, owner)
	_ensure_black_market_near_start()
	for s in _galaxy.systems:
		_build_local_map(s)
	return _galaxy


# --- 1. Systems -------------------------------------------------------------

func _place_points() -> void:
	var size := _settings.map_size()
	var margin := _settings.map_margin()
	var inner := size - margin * 2.0
	var tries := 0
	var max_tries := 600 * _settings.system_count
	while _points.size() < _settings.system_count and tries < max_tries:
		tries += 1
		var p := margin + Vector2(_rng.randf() * inner.x, _rng.randf() * inner.y)
		var clear := true
		for q in _points:
			if p.distance_to(q) <= _settings.min_spacing:
				clear = false
				break
		if clear:
			_points.append(p)


# --- 2. Lanes ---------------------------------------------------------------

func _connect_lanes() -> void:
	var n := _points.size()
	for i in n:
		var near: Array[int] = []
		for j in n:
			if j != i:
				near.append(j)
		near.sort_custom(func(p: int, q: int) -> bool:
			return _dist(i, p) < _dist(i, q))
		var got := 0
		for j in near.slice(0, 4):
			if got >= 2:
				break
			if _lane_keys.has(_key(i, j)):
				got += 1
				continue
			if not _crosses_any(i, j):
				_add_lane(i, j)
				got += 1

	# Join separate clusters with the shortest lane out of the first cluster,
	# avoiding crossings where possible.
	var comp := _components()
	var guard := 0
	while _max_of(comp) > 0 and guard < 4 * n:
		guard += 1
		var best_i := -1
		var best_j := -1
		var best_cost := INF
		for i in n:
			if comp[i] != 0:
				continue
			for j in n:
				if comp[j] == 0:
					continue
				var cost := _dist(i, j) + (3000.0 if _crosses_any(i, j) else 0.0)
				if cost < best_cost:
					best_cost = cost
					best_i = i
					best_j = j
		_add_lane(best_i, best_j)
		comp = _components()

	for i in n:
		var s := StarSystem.new()
		s.id = i
		s.position = _points[i]
		_galaxy.systems.append(s)
	_galaxy.rebuild_adjacency()


func _add_lane(a: int, b: int) -> void:
	var k := _key(a, b)
	if _lane_keys.has(k):
		return
	_lane_keys[k] = true
	var d := _dist(a, b)
	var days := 1 if d < _settings.one_day_distance else (2 if d < _settings.two_day_distance else 3)
	_galaxy.lanes.append(Lane.new(a, b, days))


func _crosses_any(a: int, b: int) -> bool:
	for lane in _galaxy.lanes:
		if lane.connects(a) or lane.connects(b):
			continue
		if Geometry2DUtil.segments_cross(_points[a], _points[b], _points[lane.a], _points[lane.b]):
			return true
	return false


## Component index per system; component 0 always contains system 0.
func _components() -> PackedInt32Array:
	var n := _points.size()
	var comp := PackedInt32Array()
	comp.resize(n)
	comp.fill(-1)
	var k := 0
	for i in n:
		if comp[i] >= 0:
			continue
		comp[i] = k
		var stack: Array[int] = [i]
		while not stack.is_empty():
			var u: int = stack.pop_back()
			for lane in _galaxy.lanes:
				var v := lane.other(u)
				if v >= 0 and comp[v] < 0:
					comp[v] = k
					stack.append(v)
		k += 1
	return comp


# --- 3. Types ---------------------------------------------------------------

func _deal_types() -> Array[String]:
	var types: Array[String] = []
	for i in _points.size():
		types.append(TYPE_DECK[i % TYPE_DECK.size()])
	_shuffle(types)
	return types


# --- 4. Cargo rules ---------------------------------------------------------

func _roll_rules() -> void:
	_galaxy.rules[Factions.NONE] = FactionRules.new()
	for f in _settings.cast:
		_galaxy.rules[f] = _roll_faction_rules(f)


func _roll_faction_rules(faction: String) -> FactionRules:
	var r := FactionRules.new()
	match faction:
		Factions.SUCCESSION:
			r.status[Goods.KNITGEL] = Legality.TAXED
			r.status[Goods.SPIRITS] = Legality.CONTRABAND if _rng.randf() < 0.35 else Legality.TAXED
			r.status[Goods.GLINT] = Legality.FORBIDDEN if _rng.randf() < 0.6 else Legality.CONTRABAND
			r.tax[Goods.KNITGEL] = 0.2
			r.tax[Goods.SPIRITS] = snappedf(0.2 + _rng.randf() * 0.2, 0.01)
		Factions.ACCORD:
			r.status[Goods.DATACORES] = Legality.CONTRABAND
			r.status[Goods.GLINT] = Legality.CONTRABAND
			r.status[Goods.ARMS] = Legality.CONTRABAND if _rng.randf() < 0.5 else Legality.TAXED
			r.tax[Goods.ARMS] = 0.15
		Factions.CLANS:
			var feud: String = _pick([Goods.ARMS, Goods.DATACORES, Goods.PARTS])
			r.status[Goods.SPIRITS] = Legality.TAXED
			r.status[Goods.GLINT] = Legality.OPEN if _rng.randf() < 0.5 else Legality.TAXED
			r.status[feud] = Legality.CONTRABAND
			r.tax[Goods.SPIRITS] = 0.25
			r.tax[Goods.GLINT] = 0.15
		Factions.COMPACT:
			pass # Nothing forbidden; each Compact world adds its own local bans.
		_:
			push_warning("No cargo rules ported yet for faction '%s'." % faction)
	return r


# --- 5. Territory -----------------------------------------------------------

func _grow_territories(types: Array[String]) -> Array[String]:
	var n := _points.size()
	var owner: Array[String] = []
	owner.resize(n)
	owner.fill(Factions.NONE)

	# Seats: as far as possible from seats already placed, on preferred types.
	for f in _settings.cast:
		var taken_hops: Array[PackedInt32Array] = []
		for seat in _galaxy.seats.values():
			taken_hops.append(_galaxy.hops_from(seat))
		var preferred: Array = PREFERRED_SEAT_TYPES.get(f, [])
		var best := -1
		var best_score := -INF
		for i in n:
			if owner[i] != Factions.NONE or types[i] == SystemTypes.HAVEN or types[i] == SystemTypes.DERELICT:
				continue
			var spread := 0
			if not taken_hops.is_empty():
				spread = FAR
				for hops in taken_hops:
					spread = mini(spread, hops[i] if hops[i] >= 0 else FAR)
			var score := spread * 10.0 + (15.0 if types[i] in preferred else 0.0) + _rng.randf() * 3.0
			if score > best_score:
				best_score = score
				best = i
		_galaxy.seats[f] = best
		owner[best] = f

	# Grow: each faction in turn claims its cheapest unclaimed neighbour.
	var count := {}
	for f in _settings.cast:
		count[f] = 1
	var grew := true
	while grew:
		grew = false
		for f in GROWTH_ORDER:
			if not count.has(f) or count[f] >= _settings.territory_target(f):
				continue
			var best_v := -1
			var best_cost := INF
			for i in n:
				if owner[i] != f:
					continue
				for nb in _galaxy.neighbors(i):
					var v: int = nb.id
					if owner[v] != Factions.NONE or types[v] == SystemTypes.HAVEN:
						continue
					var cost: float = nb.days + _rng.randf() * 0.9 + (1.5 if types[v] == SystemTypes.DERELICT else 0.0)
					if cost < best_cost:
						best_cost = cost
						best_v = v
			if best_v >= 0:
				owner[best_v] = f
				count[f] += 1
				grew = true
	return owner


# --- 6. Systems -------------------------------------------------------------

func _make_systems(types: Array[String], owner: Array[String]) -> void:
	var names := Names.SYSTEMS.duplicate()
	var havens := Names.HAVENS.duplicate()
	var derelicts := Names.DERELICTS.duplicate()
	_shuffle(names)
	_shuffle(havens)
	_shuffle(derelicts)
	var used_names := {}

	for s in _galaxy.systems:
		var i := s.id
		s.type = types[i]
		s.owner = owner[i]

		var danger: int = BASE_DANGER.get(s.owner, 1)
		if s.owner != Factions.NONE:
			for nb in _galaxy.neighbors(i):
				if owner[nb.id] != s.owner:
					danger += 1
					break
		if s.type == SystemTypes.DERELICT:
			danger += 1
		s.danger = 0 if i == _galaxy.start else clampi(danger, 0, 3)

		var pool := havens if s.type == SystemTypes.HAVEN else (derelicts if s.type == SystemTypes.DERELICT else names)
		s.name = _unique_name(pool, names, used_names)

		if s.type != SystemTypes.HAVEN and i != _galaxy.start:
			s.has_black_market = _rng.randf() < (0.55 if s.owner == Factions.CLANS else 0.3)

		if s.owner == Factions.COMPACT:
			var bans := COMPACT_BAN_POOL.duplicate()
			_shuffle(bans)
			s.local_bans.assign(bans.slice(0, 2))

		var clan_glint_open := _galaxy.rules.has(Factions.CLANS) \
			and _galaxy.rules[Factions.CLANS].status_of(Goods.GLINT) != Legality.CONTRABAND
		for g in Goods.ALL:
			var mod := SystemTypes.price_mod(s.type, g)
			var sup: int
			if g == Goods.GLINT:
				sup = 10 if s.type == SystemTypes.HAVEN else (4 if s.owner == Factions.CLANS and clan_glint_open else 0)
			elif g == Goods.DATACORES:
				sup = 5 if s.type == SystemTypes.DERELICT else (2 if s.type == SystemTypes.HAVEN else 0)
			else:
				sup = 30 if mod < 0.9 else (6 if mod > 1.25 else 14)
			s.stock[g] = 1.0
			s.supply[g] = sup
			s.qty[g] = sup


func _unique_name(pool: Array, fallback: Array, used: Dictionary) -> String:
	var name := ""
	if not pool.is_empty():
		name = pool.pop_back()
	elif not fallback.is_empty():
		name = fallback.pop_back()
	else:
		name = "Waypoint %d" % (used.size() + 1)
	while used.has(name):
		name += " II"
	used[name] = true
	return name


func _ensure_black_market_near_start() -> void:
	var hops := _galaxy.hops_from(_galaxy.start)
	for s in _galaxy.systems:
		if (s.has_black_market or s.type == SystemTypes.HAVEN) and hops[s.id] >= 0 and hops[s.id] <= 3:
			return
	var best: StarSystem = null
	for s in _galaxy.systems:
		if s.id == _galaxy.start or hops[s.id] < 1 or hops[s.id] > 2:
			continue
		if best == null or hops[s.id] < hops[best.id]:
			best = s
	if best:
		best.has_black_market = true


# --- 7. Local maps ----------------------------------------------------------

func _build_local_map(s: StarSystem) -> void:
	var center := Vector2(540, 300)
	var angles: Array[float] = []
	for k in 6:
		angles.append(k * 60.0 + _rng.randf() * 25.0)
	_shuffle(angles)
	var next_angle := [0]
	var place := func(radius: float) -> Vector2:
		var a := deg_to_rad(angles[next_angle[0]] - 90.0)
		next_angle[0] += 1
		return center + Vector2(cos(a) * radius * 1.35, sin(a) * radius)

	s.locations.append(SystemLocation.new(SystemLocation.JUMP, SystemLocation.JUMP, "Jump point", Vector2(95, 300)))

	var station := SystemLocation.new(SystemLocation.STATION, SystemLocation.STATION,
		SystemTypes.DATA[s.type]["dock"], place.call(130.0))
	station.customs = Factions.has_customs(s.owner) \
		and s.type != SystemTypes.HAVEN and s.type != SystemTypes.DERELICT
	s.locations.append(station)

	if s.has_black_market:
		var bm_name: String = Names.BLACK_MARKETS[s.id % Names.BLACK_MARKETS.size()]
		s.locations.append(SystemLocation.new(SystemLocation.BLACK_MARKET, SystemLocation.BLACK_MARKET,
			bm_name, place.call(210.0)))
		for g in Goods.ALL:
			s.bm_qty[g] = 0
		s.bm_qty[Goods.GLINT] = 3 + _rng.randi_range(0, 3)
		s.bm_qty[Goods.ARMS] = 4 + _rng.randi_range(0, 4)
		s.bm_qty[Goods.DATACORES] = _rng.randi_range(0, 2)
		s.bm_max = s.bm_qty.duplicate()

	if s.type == SystemTypes.DERELICT:
		s.locations.append(SystemLocation.new(SystemLocation.SALVAGE, SystemLocation.SALVAGE,
			"Wreck field", place.call(210.0)))

	if s.id != _galaxy.start and _rng.randf() < 0.35:
		s.locations.append(SystemLocation.new(SystemLocation.ANOMALY, SystemLocation.ANOMALY,
			"Unknown signal", place.call(210.0)))


# --- Helpers ----------------------------------------------------------------

func _dist(i: int, j: int) -> float:
	return _points[i].distance_to(_points[j])


func _key(a: int, b: int) -> int:
	return mini(a, b) * 100000 + maxi(a, b)


func _max_of(values: PackedInt32Array) -> int:
	var m := 0
	for v in values:
		m = maxi(m, v)
	return m


## Fisher-Yates shuffle with the galaxy's RNG (Array.shuffle uses the global RNG).
func _shuffle(arr: Array) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp


func _pick(arr: Array) -> Variant:
	return arr[_rng.randi_range(0, arr.size() - 1)]
