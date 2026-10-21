class_name Galaxy
extends RefCounted
## A generated galaxy: systems, lanes, this game's faction rules and the start.

var galaxy_seed: int
var settings: GalaxySettings
var systems: Array[StarSystem] = []
var lanes: Array[Lane] = []
## faction id -> FactionRules, including Factions.NONE.
var rules: Dictionary[String, FactionRules] = {}
## faction id -> seat system id.
var seats: Dictionary[String, int] = {}
var start: int = 0

var _adjacency: Array = []


func system(id: int) -> StarSystem:
	return systems[id]


func size() -> int:
	return systems.size()


## Rebuilds the neighbour lists. Call after changing lanes.
func rebuild_adjacency() -> void:
	_adjacency.clear()
	for i in systems.size():
		_adjacency.append([])
	for lane in lanes:
		_adjacency[lane.a].append({"id": lane.b, "days": lane.days})
		_adjacency[lane.b].append({"id": lane.a, "days": lane.days})


## Neighbouring systems as [{id, days}], one entry per lane.
func neighbors(id: int) -> Array:
	return _adjacency[id]


## Jump counts from `source` to every system (breadth-first). Unreachable = -1.
func hops_from(source: int) -> PackedInt32Array:
	var dist := PackedInt32Array()
	dist.resize(systems.size())
	dist.fill(-1)
	dist[source] = 0
	var queue: Array[int] = [source]
	var head := 0
	while head < queue.size():
		var u := queue[head]
		head += 1
		for n in _adjacency[u]:
			if dist[n.id] < 0:
				dist[n.id] = dist[u] + 1
				queue.append(n.id)
	return dist


## Legal status of `good` in system `id`, including local bans.
func status_at(id: int, good: String) -> String:
	var s := systems[id]
	if good in s.local_bans:
		return Legality.CONTRABAND
	return rules[s.owner].status_of(good)
