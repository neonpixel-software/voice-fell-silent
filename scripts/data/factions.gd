class_name Factions
extends RefCounted
## The factions of the Reach.
##
## All seven factions from the design docs are defined here. Prototype 0.1 only
## puts four of them on the map (see GalaxySettings.cast); the
## numbers for Seyl, the Embers and the Ninefold are first guesses from the
## economy doc's descriptions and have not been played yet.
##
## scan:    base chance a customs sweep happens on arrival (0..1)
## bribe:   how open officers are to a bribe (0..1)
## fee:     docking fee in credits
## customs: whether the faction runs sweeps and inspections at all

const SUCCESSION := "succession"
const SEYL := "seyl"
const ACCORD := "accord"
const EMBERS := "embers"
const CLANS := "clans"
const NINEFOLD := "ninefold"
const COMPACT := "compact"
const NONE := "none"

const DATA := {
	SUCCESSION: {
		"name": "Iron Succession", "short": "Succession", "color": Color("#d9604f"),
		"scan": 0.45, "bribe": 0.25, "fee": 30, "customs": true, "echo": true,
		"blurb": "Echo Dovran's militarists. Checkpoints everywhere, few bribes taken.",
	},
	SEYL: {
		"name": "Seyl Protectorate", "short": "Seyl", "color": Color("#e0a84f"),
		"scan": 0.55, "bribe": 0.1, "fee": 25, "customs": true, "echo": true,
		"blurb": "The other Echo. Paperwork, permits and a very long memory.",
	},
	ACCORD: {
		"name": "The Accord", "short": "Accord", "color": Color("#5aa9e6"),
		"scan": 0.3, "bribe": 0.45, "fee": 10, "customs": true, "echo": false,
		"blurb": "The former rebellion, now trying to govern. Seizes Edict tech.",
	},
	EMBERS: {
		"name": "The Embers", "short": "Embers", "color": Color("#e2763f"),
		"scan": 0.1, "bribe": 0.5, "fee": 0, "customs": false, "echo": false,
		"blurb": "Rebels who never stopped. Arms always welcome, Echoes never.",
	},
	CLANS: {
		"name": "Vashti Clans", "short": "Clans", "color": Color("#c58be0"),
		"scan": 0.15, "bribe": 0.75, "fee": 15, "customs": true, "echo": false,
		"blurb": "Old crime families. Luxury is taxed as tribute; glint flows freely.",
	},
	NINEFOLD: {
		"name": "The Ninefold", "short": "Ninefold", "color": Color("#9fd36a"),
		"scan": 0.1, "bribe": 0.9, "fee": 0, "customs": false, "echo": false,
		"blurb": "The glint syndicate. Everything has a price, and they keep the ledger.",
	},
	COMPACT: {
		"name": "Free Worlds Compact", "short": "Compact", "color": Color("#63c08a"),
		"scan": 0.12, "bribe": 0.55, "fee": 5, "customs": true, "echo": false,
		"blurb": "Independents and guilds. Light scans, local customs, nothing forbidden.",
	},
	NONE: {
		"name": "Unclaimed", "short": "Unclaimed", "color": Color("#8a9196"),
		"scan": 0.0, "bribe": 1.0, "fee": 0, "customs": false, "echo": false,
		"blurb": "No owner, no customs, no protection.",
	},
}


static func display_name(faction: String) -> String:
	return DATA[faction]["name"]


static func short_name(faction: String) -> String:
	return DATA[faction]["short"]


static func color(faction: String) -> Color:
	return DATA[faction]["color"]


static func has_customs(faction: String) -> bool:
	return DATA[faction]["customs"]
