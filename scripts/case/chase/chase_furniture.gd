class_name ChaseFurniture
extends RigidBody3D

## A piece of furniture the moving truck loses in a curve, a veggie off the market's trike or a pizza off the Chef's
## scooter (persecucion.md, ChaseDrops): loose, it slows the patrol car down but isn't a fine. Online the host's falls and the guests' copies follow it (NpcSync).

## Which one of ChaseDrops.FURNITURE, of ChaseDrops.VEGGIES when it's a veggie or of ChaseDrops.PIZZAS when it's a
## pizza (set before it's added).
var piece := 0
var veggie := false
var pizza := false
## One of ChaseDrops.CAR_PARTS instead (the station's old patrol car's).
var car_part := false


func _ready() -> void:
	var data: Dictionary = pieces(veggie, pizza, car_part)[piece]
	mass = data.mass
	add_to_group("chase_furniture")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = data.size
	shape.shape = box
	shape.position.y = box.size.y / 2
	add_child(shape)
	add_child((data.model as PackedScene).instantiate())


## Online (NpcSync): what a guest's copy needs before it's added.
func net_setup() -> Dictionary:
	return {"piece": piece, "veggie": veggie, "pizza": pizza, "car_part": car_part}


## The list a piece comes from.
static func pieces(is_veggie: bool, is_pizza: bool, is_car_part: bool) -> Array:
	if is_car_part:
		return ChaseDrops.CAR_PARTS
	return ChaseDrops.PIZZAS if is_pizza else ChaseDrops.VEGGIES if is_veggie else ChaseDrops.FURNITURE
