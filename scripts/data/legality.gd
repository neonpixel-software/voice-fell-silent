class_name Legality
extends RefCounted
## The legal status ladder from the economy doc ("Legal status ladder").
## Prototype 0.1 does not use Licensed yet; it is here so rules can grow into it.

const OPEN := "open"
const TAXED := "taxed"
const LICENSED := "licensed"
const CONTRABAND := "contraband"
const FORBIDDEN := "forbidden"

const RANK := {OPEN: 0, TAXED: 1, LICENSED: 2, CONTRABAND: 3, FORBIDDEN: 4}

const COLORS := {
	OPEN: Color("#5fc48a"),
	TAXED: Color("#e7c94f"),
	LICENSED: Color("#7fc7d9"),
	CONTRABAND: Color("#ec8a3c"),
	FORBIDDEN: Color("#e85a4f"),
}


static func is_illegal(status: String) -> bool:
	return status == CONTRABAND or status == FORBIDDEN


static func label(status: String) -> String:
	return status.capitalize()
