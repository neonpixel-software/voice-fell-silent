class_name FactionRules
extends RefCounted
## One faction's cargo rules for this game: the fixed core plus the part rolled
## at generation (economy doc, "Rolled per game, within personality").

## good id -> Legality status. Goods not listed are Open.
var status: Dictionary[String, String] = {}
## good id -> tariff as a fraction of value, for Taxed goods.
var tax: Dictionary[String, float] = {}


func status_of(good: String) -> String:
	return status.get(good, Legality.OPEN)


func tax_of(good: String) -> float:
	return tax.get(good, 0.0) if status_of(good) == Legality.TAXED else 0.0
