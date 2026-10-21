class_name SystemLocation
extends RefCounted
## A place on a system's local map: the jump point, a station, a black market,
## a wreck field or an anomaly (galaxy doc, "Inside a system").

const JUMP := "jump"
const STATION := "station"
const BLACK_MARKET := "bm"
const SALVAGE := "salvage"
const ANOMALY := "anomaly"

var id: String
var kind: String
var name: String
## Position on the local map, in local-map units (see GalaxySettings.LOCAL_MAP_SIZE).
var position: Vector2
## Whether docking here goes through customs.
var customs := false


func _init(p_id: String, p_kind: String, p_name: String, p_position: Vector2) -> void:
	id = p_id
	kind = p_kind
	name = p_name
	position = p_position
