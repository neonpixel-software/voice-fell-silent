class_name Lane
extends RefCounted
## A jump lane between two systems. Travel time is 1 to 3 days.

var a: int
var b: int
var days: int


func _init(p_a: int, p_b: int, p_days: int) -> void:
	a = p_a
	b = p_b
	days = p_days


func connects(id: int) -> bool:
	return a == id or b == id


## The system at the other end of the lane, or -1 if `id` is not on it.
func other(id: int) -> int:
	if a == id:
		return b
	if b == id:
		return a
	return -1
