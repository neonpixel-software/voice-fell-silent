extends TestCase
## Galaxy generation invariants, checked over many seeds and a few sizes.

const SEEDS := 200
const SIZES: Array[int] = [16, 30, 45]


func _each_galaxy(callback: Callable) -> void:
	for count in SIZES:
		var settings := GalaxySettings.new()
		settings.system_count = count
		for galaxy_seed in SEEDS:
			callback.call(GalaxyGenerator.generate(galaxy_seed, settings), "size %d seed %d" % [count, galaxy_seed])


func test_same_seed_same_galaxy() -> void:
	for galaxy_seed in [1, 42, 123456789]:
		var a := GalaxyGenerator.generate(galaxy_seed)
		var b := GalaxyGenerator.generate(galaxy_seed)
		check_eq(a.size(), b.size(), "system count differs for seed %d" % galaxy_seed)
		check_eq(a.lanes.size(), b.lanes.size(), "lane count differs for seed %d" % galaxy_seed)
		check_eq(a.start, b.start, "start differs for seed %d" % galaxy_seed)
		for i in a.size():
			var sa := a.system(i)
			var sb := b.system(i)
			check(sa.name == sb.name and sa.owner == sb.owner and sa.type == sb.type
				and sa.position == sb.position and sa.danger == sb.danger,
				"system %d differs for seed %d" % [i, galaxy_seed])


func test_different_seeds_differ() -> void:
	var a := GalaxyGenerator.generate(1)
	var b := GalaxyGenerator.generate(2)
	check(a.system(0).position != b.system(0).position, "seeds 1 and 2 gave the same map")


func test_requested_size_is_reached() -> void:
	_each_galaxy(func(g: Galaxy, label: String) -> void:
		check_eq(g.size(), g.settings.system_count, "wrong system count, " + label))


func test_map_is_connected() -> void:
	_each_galaxy(func(g: Galaxy, label: String) -> void:
		var hops := g.hops_from(g.start)
		for i in g.size():
			if hops[i] < 0:
				failures.append("system %d unreachable, %s" % [i, label])
				return)


func test_lanes_are_valid() -> void:
	_each_galaxy(func(g: Galaxy, label: String) -> void:
		var seen := {}
		for lane in g.lanes:
			var key := Vector2i(mini(lane.a, lane.b), maxi(lane.a, lane.b))
			check(lane.a != lane.b, "self lane, " + label)
			check(not seen.has(key), "duplicate lane %s, %s" % [key, label])
			check(lane.days >= 1 and lane.days <= 3, "lane days out of range, " + label)
			seen[key] = true)


func test_systems_keep_their_spacing() -> void:
	_each_galaxy(func(g: Galaxy, label: String) -> void:
		for i in g.size():
			for j in range(i + 1, g.size()):
				if g.system(i).position.distance_to(g.system(j).position) <= g.settings.min_spacing:
					failures.append("systems %d and %d too close, %s" % [i, j, label])
					return)


func test_every_cast_faction_has_a_seat_it_owns() -> void:
	_each_galaxy(func(g: Galaxy, label: String) -> void:
		for f in g.settings.cast:
			check(g.seats.has(f), "%s has no seat, %s" % [f, label])
			check_eq(g.system(g.seats[f]).owner, f, "%s does not own its seat, %s" % [f, label]))


func test_start_is_a_safe_accord_seat() -> void:
	_each_galaxy(func(g: Galaxy, label: String) -> void:
		var s := g.system(g.start)
		check_eq(s.owner, Factions.ACCORD, "start not Accord, " + label)
		check_eq(s.danger, 0, "start not safe, " + label)
		check(not s.has_black_market, "black market at start, " + label))


func test_black_market_within_three_jumps_of_start() -> void:
	_each_galaxy(func(g: Galaxy, label: String) -> void:
		var hops := g.hops_from(g.start)
		var found := false
		for s in g.systems:
			if (s.has_black_market or s.type == SystemTypes.HAVEN) and hops[s.id] >= 0 and hops[s.id] <= 3:
				found = true
		check(found, "no black market within 3 jumps of start, " + label))


func test_names_are_unique() -> void:
	_each_galaxy(func(g: Galaxy, label: String) -> void:
		var names := {}
		for s in g.systems:
			check(not names.has(s.name), "duplicate name %s, %s" % [s.name, label])
			names[s.name] = true)


func test_havens_stay_unclaimed() -> void:
	_each_galaxy(func(g: Galaxy, label: String) -> void:
		for s in g.systems:
			if s.type == SystemTypes.HAVEN:
				check_eq(s.owner, Factions.NONE, "haven %s is owned, %s" % [s.name, label]))


func test_every_system_has_jump_point_and_station() -> void:
	_each_galaxy(func(g: Galaxy, label: String) -> void:
		for s in g.systems:
			check(s.location(SystemLocation.JUMP) != null, "no jump point at %s, %s" % [s.name, label])
			check(s.location(SystemLocation.STATION) != null, "no station at %s, %s" % [s.name, label])
			check(s.locations.size() <= 6, "too many locations at %s, %s" % [s.name, label])
			check_eq(s.location(SystemLocation.BLACK_MARKET) != null, s.has_black_market,
				"black market location mismatch at %s, %s" % [s.name, label]))


func test_compact_worlds_have_two_local_bans() -> void:
	_each_galaxy(func(g: Galaxy, label: String) -> void:
		for s in g.systems:
			var expected := 2 if s.owner == Factions.COMPACT else 0
			check_eq(s.local_bans.size(), expected, "local bans at %s, %s" % [s.name, label])
			for good in s.local_bans:
				check_eq(g.status_at(s.id, good), Legality.CONTRABAND, "local ban not applied, " + label))


func test_core_cargo_rules_hold() -> void:
	_each_galaxy(func(g: Galaxy, label: String) -> void:
		var accord := g.rules[Factions.ACCORD]
		check_eq(accord.status_of(Goods.DATACORES), Legality.CONTRABAND, "Accord data cores should be contraband, " + label)
		check(Legality.is_illegal(g.rules[Factions.SUCCESSION].status_of(Goods.GLINT)),
			"Succession allows glint, " + label)
		for good in Goods.ALL:
			check(g.rules[Factions.COMPACT].status_of(good) != Legality.FORBIDDEN,
				"Compact forbids %s, %s" % [good, label]))
