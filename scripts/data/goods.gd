class_name Goods
extends RefCounted
## Trade goods catalogue.
##
## Ported from prototype 0.1, which uses 8 of the 18 goods in the economy doc
## (space-trader-economy-v1.md, "Cargo catalogue"). Prices are base credits per
## cargo unit (CU); systems multiply them by their type modifier and stock level.

const RATIONS := "rations"
const FUEL := "fuel"
const PARTS := "parts"
const KNITGEL := "knitgel"
const SPIRITS := "spirits"
const ARMS := "arms"
const GLINT := "glint"
const DATACORES := "datacores"

const DATA := {
	RATIONS: {"name": "Ration packs", "base": 20, "volume": 1, "tags": ["Food"]},
	FUEL: {"name": "Fuel cells", "base": 40, "volume": 1, "tags": ["Fuel", "Strategic"]},
	PARTS: {"name": "Machine parts", "base": 80, "volume": 1, "tags": ["Industrial"]},
	KNITGEL: {"name": "Knitgel", "base": 150, "volume": 1, "tags": ["Medical", "Strategic"]},
	SPIRITS: {"name": "Fine spirits", "base": 200, "volume": 1, "tags": ["Luxury"]},
	ARMS: {"name": "Small arms", "base": 250, "volume": 1, "tags": ["Military", "Arms"]},
	GLINT: {"name": "Glint", "base": 600, "volume": 1, "tags": ["Narcotic"]},
	DATACORES: {"name": "Edict data cores", "base": 1500, "volume": 1, "tags": ["Edict", "Intel"]},
}

## Goods in catalogue order (cheapest first), for stable iteration and UI rows.
const ALL: Array[String] = [RATIONS, FUEL, PARTS, KNITGEL, SPIRITS, ARMS, GLINT, DATACORES]


static func display_name(good: String) -> String:
	return DATA[good]["name"]


static func base_price(good: String) -> int:
	return DATA[good]["base"]
