extends SceneTree
## Headless test runner. No add-ons needed:
##   godot --headless --path . --import
##   godot --headless --path . -s res://tests/run_tests.gd
## Runs every test_* method on every script in TEST_SCRIPTS and exits non-zero
## on any failure.
##
## Only failed check() calls count as failures. A runtime error inside a test
## (bad index, null access) is printed but does NOT fail the run, because
## GDScript errors don't propagate out of call(). Assert with check() rather
## than relying on a crash.

const TEST_SCRIPTS: Array[String] = [
	"res://tests/test_galaxy_generator.gd",
]


func _initialize() -> void:
	var failed := 0
	var passed := 0
	for path in TEST_SCRIPTS:
		var suite: Object = load(path).new()
		for method in suite.get_method_list():
			var test_name: String = method.name
			if not test_name.begins_with("test_"):
				continue
			suite.failures.clear()
			suite.call(test_name)
			if suite.failures.is_empty():
				passed += 1
				print("  PASS %s" % test_name)
			else:
				failed += 1
				print("  FAIL %s" % test_name)
				for f in suite.failures:
					print("       %s" % f)
	print("\n%d passed, %d failed" % [passed, failed])
	quit(1 if failed > 0 else 0)
