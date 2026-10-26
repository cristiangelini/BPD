class_name FoodBucket
extends Grabbable

## One of the patrol car's food buckets (control-circo.md, step 2): bananas, fish, meat or carrots
## (CircusTruck.FOODS). E with it in hand by a circus truck's cage and the animal in it is offered the food
## (QueueCar.feed): it eats its own, gets angry at any other, and El Peludo eats nothing. Then it needs COOLDOWN
## seconds. Every PC offers it (ActionSync). Every number here is (propuesta).

const MODEL := preload("res://assets/models/food_bucket.glb")
const KG := 2.0
const COOLDOWN := 1.5

## One of CircusTruck.FOODS.
var food := "bananas"
var cooldown_left := 0.0


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = KG
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.34, 0.4, 0.34)
	shape.shape = box
	shape.position = Vector3(0, 0.2, 0)
	add_child(shape)


func _ready() -> void:
	add_to_group("food_buckets")
	var model: Node3D = MODEL.instantiate()
	model.name = "Model"
	add_child(model)
	for kind in CircusTruck.FOODS:
		var heap := model.find_child("food_" + kind, true, false) as Node3D
		if heap:
			heap.visible = kind == food


## Online (PropSync): a guest makes its copy from this script, with the same food.
func net_setup() -> Dictionary:
	return {"food": food}


func held_prompt_key(_cop: Cop) -> String:
	return "PROMPT_FEED_" + food.to_upper()


func use(_cop: Cop = null) -> void:
	offer()


## The circus truck whose cage is closest within CircusTruck.FEED_REACH, or null.
func cage_near() -> QueueCar:
	var best: QueueCar
	var best_away := INF
	for car: QueueCar in get_tree().get_nodes_in_group("queue_cars"):
		if car.circus.is_empty() or car.state == "gone" or not CircusTruck.near_cage(car, global_position):
			continue
		var away := car.global_position.distance_to(global_position)
		if away < best_away:
			best = car
			best_away = away
	return best


## Offers the food to the animal in the nearest cage: what it did (QueueCar.feed), or "" if there's none or the
## bucket isn't ready yet.
func offer() -> String:
	if cooldown_left > 0.0:
		return ""
	var car := cage_near()
	if not car:
		return ""
	cooldown_left = COOLDOWN
	return car.feed(food)


## In _process: a guest's copy has no physics of its own (PropSync), and its cooldown runs too.
func _process(delta: float) -> void:
	cooldown_left = maxf(cooldown_left - delta, 0.0)
