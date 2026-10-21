class_name MarketEvents
extends RefCounted
## Local events that bend a system's prices for a while (prototype 0.1 set).
## goods: price multipliers. scan: extra customs sweep chance. {s} = system name.

const DATA: Array[Dictionary] = [
	{"name": "Famine", "goods": {"rations": 2.4}, "scan": 0.0,
		"news": "Famine on {s}. Ration packs are fetching more than double."},
	{"name": "War scare", "goods": {"arms": 1.8, "fuel": 1.6, "knitgel": 1.4}, "scan": 0.0,
		"news": "War scare at {s}: arms, fuel and knitgel in demand."},
	{"name": "Plague", "goods": {"knitgel": 2.3}, "scan": 0.0,
		"news": "Plague outbreak on {s}. Knitgel desperately needed."},
	{"name": "Boom", "goods": {"parts": 1.6, "rations": 1.3}, "scan": 0.0,
		"news": "Boom on {s}: machine parts and rations selling high."},
	{"name": "Crackdown", "goods": {}, "scan": 0.2,
		"news": "Crackdown at {s}: patrols doubled, black market paying more."},
	{"name": "Glut", "goods": {"spirits": 0.6}, "scan": 0.0,
		"news": "A spirits glut at {s}. Prices are on the floor."},
]
