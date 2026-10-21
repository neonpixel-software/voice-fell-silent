extends Node
## Makes the UI readable from a desktop monitor down to a phone.
##
## The project renders at a 1280x720 base size with the "canvas_items" stretch
## mode and "expand" aspect, so the UI always fills the window and keeps its
## proportions. That alone makes text too small on phones and small tablets,
## whose screens are physically tiny for their pixel count. This node picks a
## form factor and multiplies the window's content scale factor so a logical
## pixel stays a comfortable physical size, then tells the UI whether to use
## the compact layout.
##
## Preview another form factor on PC by passing a user argument:
##   godot --path . -- --form-factor=phone      (or tablet, desktop)
##   godot --path . -- --ui-scale=1.25          (extra multiplier, accessibility)

signal layout_changed

enum FormFactor { DESKTOP, TABLET, PHONE }

## Extra scale per form factor, on top of the stretch mode's own scaling.
const FORM_FACTOR_SCALE := {
	FormFactor.DESKTOP: 1.0,
	FormFactor.TABLET: 1.15,
	FormFactor.PHONE: 1.6,
}

## Screens with a diagonal under this many inches count as phones.
const PHONE_MAX_DIAGONAL_INCHES := 7.5

## Below this logical width (after scaling), the UI switches to the compact layout.
const COMPACT_WIDTH := 1100.0

## Smallest comfortable touch target, in logical pixels after scaling.
const MIN_TOUCH_TARGET := 44.0

var form_factor: FormFactor = FormFactor.DESKTOP
## Player-chosen multiplier (settings menu later), 0.8 to 1.5.
var user_scale := 1.0
var compact := false


func _ready() -> void:
	form_factor = _detect_form_factor()
	_read_cmdline()
	get_window().size_changed.connect(_apply)
	_apply()


func is_touch() -> bool:
	return DisplayServer.is_touchscreen_available() or form_factor != FormFactor.DESKTOP


## Size of the visible UI area in logical pixels.
func logical_size() -> Vector2:
	return get_viewport().get_visible_rect().size


func _apply() -> void:
	var window := get_window()
	window.content_scale_factor = FORM_FACTOR_SCALE[form_factor] * user_scale
	compact = form_factor == FormFactor.PHONE or logical_size().x < COMPACT_WIDTH
	layout_changed.emit()


func _detect_form_factor() -> FormFactor:
	if not OS.has_feature("mobile"):
		return FormFactor.DESKTOP
	var screen := DisplayServer.screen_get_size()
	var dpi := maxi(DisplayServer.screen_get_dpi(), 1)
	var diagonal_inches := Vector2(screen).length() / dpi
	return FormFactor.PHONE if diagonal_inches < PHONE_MAX_DIAGONAL_INCHES else FormFactor.TABLET


func _read_cmdline() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--form-factor="):
			match arg.get_slice("=", 1):
				"phone":
					form_factor = FormFactor.PHONE
				"tablet":
					form_factor = FormFactor.TABLET
				"desktop":
					form_factor = FormFactor.DESKTOP
		elif arg.begins_with("--ui-scale="):
			user_scale = clampf(arg.get_slice("=", 1).to_float(), 0.8, 1.5)
