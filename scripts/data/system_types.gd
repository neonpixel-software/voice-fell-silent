class_name SystemTypes
extends RefCounted
## System types and their market modifiers (economy doc, galaxy doc step 5).
## mods: price multiplier per good; goods not listed trade at 1.0.
## yard: has a shipyard. dock: name of the main station.

const HUB := "hub"
const CAPITAL := "capital"
const MINING := "mining"
const AGRI := "agri"
const INDUSTRIAL := "industrial"
const FORTRESS := "fortress"
const REFUGEE := "refugee"
const HAVEN := "haven"
const DERELICT := "derelict"

const DATA := {
	HUB: {"name": "Trade hub", "mods": {}, "yard": true, "dock": "Exchange"},
	CAPITAL: {
		"name": "Capital world", "yard": true, "dock": "High Concourse",
		"mods": {"spirits": 1.35, "datacores": 1.45, "glint": 1.3, "knitgel": 0.85},
	},
	MINING: {
		"name": "Mining world", "yard": false, "dock": "Ore Dock",
		"mods": {"rations": 1.45, "parts": 1.35, "knitgel": 1.4, "fuel": 1.15},
	},
	AGRI: {
		"name": "Agri-world", "yard": false, "dock": "Grain Port",
		"mods": {"rations": 0.65, "spirits": 0.7, "parts": 1.35, "fuel": 1.4},
	},
	INDUSTRIAL: {
		"name": "Industrial world", "yard": true, "dock": "Foundry Port",
		"mods": {"parts": 0.65, "arms": 0.75, "fuel": 1.35, "rations": 1.3},
	},
	FORTRESS: {
		"name": "Fortress", "yard": true, "dock": "Garrison Dock",
		"mods": {"arms": 1.5, "fuel": 1.45, "rations": 1.35, "knitgel": 1.2},
	},
	REFUGEE: {
		"name": "Refugee world", "yard": false, "dock": "Relief Station",
		"mods": {"rations": 1.55, "knitgel": 1.6, "spirits": 0.6, "parts": 1.1},
	},
	HAVEN: {
		"name": "Pirate haven", "yard": false, "dock": "Free Dock",
		"mods": {"glint": 0.6, "arms": 1.4, "fuel": 1.3, "knitgel": 1.4},
	},
	DERELICT: {
		"name": "Derelict field", "yard": false, "dock": "Scrapper Camp",
		"mods": {"datacores": 0.6, "fuel": 1.4, "parts": 1.3},
	},
}


static func display_name(type: String) -> String:
	return DATA[type]["name"]


static func price_mod(type: String, good: String) -> float:
	return DATA[type]["mods"].get(good, 1.0)
