class_name BillWad
extends Grabbable

## A wad of the bribes' bills in the bribe jailbreak (docs/diseno/fuga-soborno.md): the campaign's bribe money, split
## among four of them on the bunks. In hand, E on the cell's bars pays it to the guard waiting there (BribeGuard).

const MODEL := preload("res://assets/models/bill_wad.glb")
const SIZE := Vector3(0.16, 0.05, 0.09)

## How much money it holds.
@export var amount := 0


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = 0.2
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	add_child(MODEL.instantiate())


func _ready() -> void:
	add_to_group("bill_wads")


## What a guest's copy needs (PropSync: the host makes new ones after a catch).
func net_setup() -> Dictionary:
	return {"amount": amount}


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_HOLDING_WAD"


## The money split into `wads` wads in steps of `step`, at least one step each, the rest drawn by `rng`: [] if there
## isn't enough for every wad.
static func split(money: int, wads: int, step: int, rng: RandomNumberGenerator) -> Array[int]:
	var steps := money / step
	var split_up: Array[int] = []
	if steps < wads:
		return split_up
	split_up.resize(wads)
	split_up.fill(step)
	for i in steps - wads:
		split_up[rng.randi_range(0, wads - 1)] += step
	return split_up
