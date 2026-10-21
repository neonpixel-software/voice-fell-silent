class_name Geometry2DUtil
extends RefCounted
## Small geometry helpers for map generation.


## True if segments p1-p2 and p3-p4 properly cross (touching ends do not count).
static func segments_cross(p1: Vector2, p2: Vector2, p3: Vector2, p4: Vector2) -> bool:
	var d1 := _side(p3, p4, p1)
	var d2 := _side(p3, p4, p2)
	var d3 := _side(p1, p2, p3)
	var d4 := _side(p1, p2, p4)
	return ((d1 > 0 and d2 < 0) or (d1 < 0 and d2 > 0)) \
		and ((d3 > 0 and d4 < 0) or (d3 < 0 and d4 > 0))


static func _side(a: Vector2, b: Vector2, c: Vector2) -> float:
	return (c.x - a.x) * (b.y - a.y) - (b.x - a.x) * (c.y - a.y)
