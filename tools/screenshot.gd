extends SceneTree
## Renders the main scene and saves a PNG, for checking layouts without a device:
##   godot --path . --resolution 2532x1170 -s res://tools/screenshot.gd -- --form-factor=phone --out=/tmp/phone.png
## Needs a display (use xvfb-run on a headless machine).

var frames := 0
func _initialize() -> void:
	change_scene_to_file("res://scenes/main.tscn")
func _process(_d: float) -> bool:
	frames += 1
	if frames == 20:
		var out := "/tmp/shot.png"
		for a in OS.get_cmdline_user_args():
			if a.begins_with("--out="): out = a.get_slice("=", 1)
		root.get_texture().get_image().save_png(out)
		return true
	return false
