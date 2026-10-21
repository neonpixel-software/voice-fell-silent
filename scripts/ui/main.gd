extends Control
## Galaxy preview screen: generate galaxies by seed and inspect systems.
## This is the first playable slice of the port; trading and travel come next.

const SIDEBAR_WIDTH := 380.0
const SIDEBAR_WIDTH_COMPACT := 300.0

@onready var _margin: MarginContainer = %Margin
@onready var _sidebar: PanelContainer = %Sidebar
@onready var _map: GalaxyMapView = %MapView
@onready var _seed_edit: LineEdit = %SeedEdit
@onready var _size_spin: SpinBox = %SizeSpin
@onready var _info: RichTextLabel = %Info
@onready var _summary: RichTextLabel = %Summary


func _ready() -> void:
	%Generate.pressed.connect(_generate_from_field)
	%NewSeed.pressed.connect(_new_seed)
	_seed_edit.text_submitted.connect(func(_t: String) -> void: _generate_from_field())
	_map.system_selected.connect(_show_system)
	UIScale.layout_changed.connect(_apply_layout)
	_apply_layout()
	_new_seed()


func _apply_layout() -> void:
	var compact := UIScale.compact
	_sidebar.custom_minimum_size.x = SIDEBAR_WIDTH_COMPACT if compact else SIDEBAR_WIDTH
	var m := 8 if compact else 16
	for side in ["left", "right", "top", "bottom"]:
		_margin.add_theme_constant_override("margin_" + side, m)
	for button: Button in [%Generate, %NewSeed]:
		button.custom_minimum_size.y = UIScale.MIN_TOUCH_TARGET if UIScale.is_touch() else 0.0


func _new_seed() -> void:
	_seed_edit.text = str(randi() % 1_000_000_000)
	_generate_from_field()


func _generate_from_field() -> void:
	var settings := GalaxySettings.new()
	settings.system_count = int(_size_spin.value)
	var galaxy := GalaxyGenerator.generate(_seed_edit.text.to_int(), settings)
	_map.galaxy = galaxy
	_summary.text = _summary_text(galaxy)
	_map.selected = galaxy.start
	_show_system(galaxy.start)


func _summary_text(galaxy: Galaxy) -> String:
	var counts := {}
	for s in galaxy.systems:
		counts[s.owner] = counts.get(s.owner, 0) + 1
	var lines: Array[String] = []
	for f in galaxy.settings.cast + [Factions.NONE]:
		lines.append("[color=%s]●[/color] %s  %d" % [
			Factions.color(f).to_html(false), Factions.short_name(f), counts.get(f, 0)])
	return "%d systems, %d lanes\n%s" % [galaxy.size(), galaxy.lanes.size(), "\n".join(lines)]


func _show_system(id: int) -> void:
	var galaxy := _map.galaxy
	var s := galaxy.system(id)
	var t := "[font_size=22][b]%s[/b][/font_size]\n" % s.name
	t += "%s, [color=%s]%s[/color]" % [SystemTypes.display_name(s.type),
		Factions.color(s.owner).to_html(false), Factions.display_name(s.owner)]
	if s.id in galaxy.seats.values():
		t += " (seat)"
	if s.id == galaxy.start:
		t += "\n[i]Your starting system.[/i]"
	t += "\nDanger %s" % ("●".repeat(s.danger) + "○".repeat(3 - s.danger))

	t += "\n\n[b]Locations[/b]"
	for loc in s.locations:
		t += "\n  %s%s" % [loc.name, " (customs)" if loc.customs else ""]

	t += "\n\n[b]Cargo rules here[/b]"
	for g in Goods.ALL:
		var st := galaxy.status_at(id, g)
		var tax := galaxy.rules[s.owner].tax_of(g) if not g in s.local_bans else 0.0
		var extra := " %d%%" % roundi(tax * 100) if tax > 0.0 else ""
		if g in s.local_bans:
			extra = " (local ban)"
		t += "\n  %s  [color=%s]%s%s[/color]" % [Goods.display_name(g),
			Legality.COLORS[st].to_html(false), Legality.label(st), extra]

	t += "\n\n[b]Lanes[/b]"
	for nb in galaxy.neighbors(id):
		var other := galaxy.system(nb.id)
		t += "\n  %s, %d day%s" % [other.name, nb.days, "" if nb.days == 1 else "s"]
	_info.text = t
