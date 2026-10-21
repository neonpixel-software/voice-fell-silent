class_name GalaxyMapView
extends Control
## Draws a Galaxy and lets the player pick a system by click or tap.
## The whole map is fitted into the control, so it works at any screen size.

signal system_selected(id: int)

const LANE_COLOR := Color("#3d5361")
const LANE_LABEL_COLOR := Color("#7d93a1")
const NAME_COLOR := Color("#d4dde3")
const SELECT_COLOR := Color("#ffffff")
const START_COLOR := Color("#e8edf0")
const BLACK_MARKET_COLOR := Color("#ec8a3c")
const SYSTEM_RADIUS := 9.0
const SEAT_RADIUS := 12.0

var galaxy: Galaxy:
	set(value):
		galaxy = value
		selected = -1
		hovered = -1
		queue_redraw()
var selected := -1:
	set(value):
		selected = value
		queue_redraw()
var hovered := -1

var _scale := 1.0
var _offset := Vector2.ZERO


func _ready() -> void:
	resized.connect(queue_redraw)
	mouse_exited.connect(func() -> void:
		hovered = -1
		queue_redraw())


func _draw() -> void:
	if galaxy == null:
		return
	_update_transform()
	var font := get_theme_default_font()
	var font_size := get_theme_default_font_size()
	var small_size := maxi(10, font_size - 4)

	var seat_ids := galaxy.seats.values()
	for lane in galaxy.lanes:
		var a := to_screen(galaxy.system(lane.a).position)
		var b := to_screen(galaxy.system(lane.b).position)
		if lane.days >= 3:
			draw_dashed_line(a, b, LANE_COLOR, 2.0, 8.0, true, true)
		else:
			draw_line(a, b, LANE_COLOR, 2.0, true)
		if lane.days > 1:
			# Offset the label sideways from the lane so it doesn't sit on names.
			var normal := (b - a).orthogonal().normalized()
			if normal.y > 0.0:
				normal = -normal
			var mid := (a + b) * 0.5 + normal * 10.0
			draw_string(font, mid + Vector2(-8, 4), "%dd" % lane.days, HORIZONTAL_ALIGNMENT_LEFT, -1, small_size, LANE_LABEL_COLOR)

	for s in galaxy.systems:
		var p := to_screen(s.position)
		var r := SEAT_RADIUS if s.id in seat_ids else SYSTEM_RADIUS
		draw_circle(p, r, Factions.color(s.owner), true, -1.0, true)
		if s.id in seat_ids:
			draw_circle(p, r - 4.0, Color(0, 0, 0, 0.35), true, -1.0, true)
		if s.has_black_market or s.type == SystemTypes.HAVEN:
			draw_circle(p + Vector2(r, -r) * 0.8, 3.5, BLACK_MARKET_COLOR, true, -1.0, true)
		if s.id == galaxy.start:
			draw_arc(p, r + 6.0, 0.0, TAU, 32, START_COLOR, 1.5, true)
		if s.id == selected:
			draw_arc(p, r + 4.0, 0.0, TAU, 32, SELECT_COLOR, 2.5, true)
		elif s.id == hovered:
			draw_arc(p, r + 4.0, 0.0, TAU, 32, Color(SELECT_COLOR, 0.5), 2.0, true)
		var label_pos := p + Vector2(-60, r + font_size + 2)
		draw_string(font, label_pos, s.name, HORIZONTAL_ALIGNMENT_CENTER, 120, small_size + 1, NAME_COLOR)


func _gui_input(event: InputEvent) -> void:
	if galaxy == null:
		return
	if event is InputEventMouseMotion:
		var id := system_at(event.position)
		if id != hovered:
			hovered = id
			queue_redraw()
	elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var id := system_at(event.position)
		if id >= 0:
			selected = id
			system_selected.emit(id)
			accept_event()


## Map units -> local control pixels.
func to_screen(map_pos: Vector2) -> Vector2:
	return _offset + map_pos * _scale


## The system under a point in local pixels, or -1. Uses a finger-sized radius.
func system_at(local_pos: Vector2) -> int:
	_update_transform()
	var reach := maxf(SEAT_RADIUS + 6.0, UIScale.MIN_TOUCH_TARGET * 0.5)
	var best := -1
	var best_d := reach
	for s in galaxy.systems:
		var d := to_screen(s.position).distance_to(local_pos)
		if d <= best_d:
			best_d = d
			best = s.id
	return best


func _update_transform() -> void:
	var map_size := galaxy.settings.map_size()
	var pad := Vector2(16, 16)
	var avail := size - pad * 2.0
	_scale = minf(avail.x / map_size.x, avail.y / map_size.y)
	_offset = pad + (avail - map_size * _scale) * 0.5
