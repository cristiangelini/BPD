class_name Armory
extends RefCounted

## The station's armory (docs/diseno/comisaria.md, "La armería"): what the armero hands out, what it costs and who owns
## it. Buying spends the wallet's money and keeps the item for good; taking hands it to one cop. The wallet is any
## object with `money: int` and `items: Array[String]`: the campaign once it reaches the station, a StationWallet
## until then. Every number here is (propuesta).

## Every item: its name and line on the armero's list and its price (0 = free, always there). A "stock" item gets used
## up: each purchase is one in the wallet's items, and taking it hands that one out.
const ITEMS := {
	"ram": {"name": "ARMORY_RAM", "about": "ARMORY_RAM_ABOUT", "price": 0},
	"donuts": {"name": "ARMORY_DONUTS", "about": "ARMORY_DONUTS_ABOUT", "price": 30, "stock": true},
}
const DONUT_BOX_SCENE := preload("res://scenes/props/donut_box.tscn")

var wallet: Object
var items: Dictionary


func _init(with_wallet: Object, catalog: Dictionary = ITEMS) -> void:
	wallet = with_wallet
	items = catalog


func ids() -> Array:
	return items.keys()


## Free items are always there; the rest once bought.
func owns(id: String) -> bool:
	return items[id].price == 0 or wallet.items.has(id)


func is_stock(id: String) -> bool:
	return items[id].get("stock", false)


## How many the station has of a stock item.
func count(id: String) -> int:
	return wallet.items.count(id)


## Buys `id` with the wallet's money. Returns "" or the hint key for why not.
func buy(id: String) -> String:
	if owns(id) and not is_stock(id):
		return "ARMORY_ALREADY_OWNED"
	if wallet.money < items[id].price:
		return "ARMORY_NO_MONEY"
	wallet.money -= items[id].price
	wallet.items.append(id)
	return ""


## Hands `id` to `cop`. Returns "" or the hint key for why not.
func take(id: String, cop: Cop) -> String:
	if not owns(id):
		return "ARMORY_NOT_OWNED"
	match id:
		"ram":
			if cop.ram:
				return "ARMORY_HAS_RAM"
			cop.equip_ram()
		"donuts":
			if cop.ram or cop.get_node("Grabber").held:
				return "ARMORY_HANDS_FULL"
			var box: DonutBox = DONUT_BOX_SCENE.instantiate()
			cop.get_parent().add_child(box)
			cop.get_node("Grabber").grab(box)
			box.global_position = cop.get_node("Grabber").hold_point()
	if is_stock(id):
		wallet.items.erase(id)
	return ""


## E on a row: takes what the station owns, buys what it doesn't (a second E takes it).
func choose(id: String, cop: Cop) -> String:
	return take(id, cop) if owns(id) else buy(id)
