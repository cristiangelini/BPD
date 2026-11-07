class_name BearLootRig
extends CostumeRig

## The bear of the loot (allanamiento-disfraces.md, "El oso del botín"): a bear costume stuffed with the bank robbery's
## bills stands by the counter, as heavy as a wardrobe (12 kg, the main evidence). Every time a cop grabs it or it
## falls over, a bill slips out of a seam and drops at its feet (at most MAX_BILLS). The rental list of the robbery
## night and a clown mask of the robbery are hidden. Every number here is (propuesta).

const BEAR_SCENE := preload("res://scenes/props/bear_loot.tscn")
## By the counter's west end, facing the shop.
const BEAR_AT := Vector3(4.4, CostumeShop.FLOOR_TOP, 6.9)
const MAX_BILLS := 12
## Tilted more than this from upright counts as fallen over.
const FALLEN_UP_Y := 0.5

var bear: Evidence
var bills: Array[BillWad] = []
var _was_held := false
var _was_down := false


func setup(place: CostumeShop) -> void:
	super.setup(place)
	bear = BEAR_SCENE.instantiate()
	bear.position = BEAR_AT + Vector3.UP * 0.01
	bear.rotation.y = PI
	place.add_child(bear)
	place.main = bear


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(bear) or not bear.is_inside_tree():
		return
	var held := bear.is_held()
	var down := bear.global_basis.y.y < FALLEN_UP_Y
	if (held and not _was_held) or (down and not _was_down):
		drop_bill()
	_was_held = held
	_was_down = down


## A bill slips out of the bear and falls by it, until MAX_BILLS are out.
func drop_bill() -> void:
	if bills.size() >= MAX_BILLS:
		return
	var bill := BillWad.new()
	var side := Vector3(cos(bills.size() * 2.4), 0, sin(bills.size() * 2.4))
	bill.position = shop.to_local(bear.global_position) + side * 0.6 + Vector3.UP * 0.9
	shop.add_child(bill)
	bill.apply_central_impulse(side * 0.3 + Vector3.UP * 0.2)
	bills.append(bill)
