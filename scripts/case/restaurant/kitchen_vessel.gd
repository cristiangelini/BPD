class_name KitchenVessel
extends Grabbable

## A pot, a frying pan or a plate in the restaurant's kitchen (infiltracion-restaurante.md, step 3, decision 174). An
## ingredient dropped into it (not held) goes in: each one is {kind, cooked (seconds on the fire), burnt, in (the
## vessel it was cooked in, "" if raw)}. A pot or a pan standing upright on one of the stove's burners cooks what's in it;
## past BURN seconds it burns, turns black and smokes. E with a pot or a pan in hand empties it onto the nearest plate,
## keeping how cooked everything is, to take to the pass (step 4). The host decides all of it and tells the guests.
## Every number here is (propuesta).

## The host saw what's in it burn (the smoke, step 4's suspicion).
signal burnt

const KINDS: Array[String] = ["pot", "pan", "plate"]
const MODELS := {
	"pot": preload("res://assets/models/kitchen_pot.glb"),
	"pan": preload("res://assets/models/kitchen_pan.glb"),
	"plate": preload("res://assets/models/kitchen_plate.glb"),
}
const SIZES := {"pot": Vector3(0.4, 0.3, 0.4), "pan": Vector3(0.4, 0.07, 0.4), "plate": Vector3(0.36, 0.04, 0.36)}
const MASSES := {"pot": 2.0, "pan": 1.2, "plate": 0.4}
## Seconds on the fire until it burns: the pan is quick, the pot holds water.
const BURN := {"pot": 12.0, "pan": 8.0}
## A pot or a pan this close to a plate empties onto it (m).
const POUR_REACH := 1.0
## Upright enough to cook (its up's height).
const UPRIGHT := 0.7
## While cooking, the host tells the guests how it's going this often (s).
const SHARE_EVERY := 1.0
const FOOD_SCALE := 0.55

var kind := "pot"
var items: Array[Dictionary] = []
## Which burner a world position is on, or -1 (RestaurantHall sets it).
var burner_at: Callable = func(_at: Vector3) -> int: return -1
var _catch: Area3D
var _food: Node3D
var _smoke: CPUParticles3D
var _share_left := SHARE_EVERY


func _ready() -> void:
	add_to_group("kitchen_vessels")
	mass = MASSES[kind]
	collision_layer = 4
	collision_mask = 15
	var size: Vector3 = SIZES[kind]
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	add_child(shape)
	add_child((MODELS[kind] as PackedScene).instantiate())
	_catch = Area3D.new()
	_catch.collision_layer = 0
	_catch.collision_mask = 4
	var catch_shape := CollisionShape3D.new()
	var catch_box := BoxShape3D.new()
	catch_box.size = Vector3(size.x, 0.25, size.z)
	catch_shape.shape = catch_box
	catch_shape.position.y = size.y / 2 + 0.05
	_catch.add_child(catch_shape)
	add_child(_catch)
	_food = Node3D.new()
	_food.position.y = -size.y / 2 + 0.06
	add_child(_food)
	_smoke = CPUParticles3D.new()
	_smoke.emitting = false
	_smoke.amount = 16
	_smoke.lifetime = 1.6
	_smoke.direction = Vector3.UP
	_smoke.spread = 15.0
	_smoke.initial_velocity_min = 0.4
	_smoke.initial_velocity_max = 0.8
	_smoke.gravity = Vector3(0, 0.3, 0)
	_smoke.scale_amount_min = 0.15
	_smoke.scale_amount_max = 0.35
	var puff := SphereMesh.new()
	puff.radius = 0.5
	puff.height = 1.0
	var grey := StandardMaterial3D.new()
	grey.albedo_color = Color(0.25, 0.25, 0.25, 0.6)
	grey.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	puff.material = grey
	_smoke.mesh = puff
	add_child(_smoke)
	_show()


func is_cookware() -> bool:
	return kind != "plate"


func is_burnt() -> bool:
	return items.any(func(item: Dictionary) -> bool: return item.burnt)


## The kinds in it, in the order they went in.
func kinds() -> Array[String]:
	var list: Array[String] = []
	for item in items:
		list.append(item.kind)
	return list


func held_prompt_key(_cop: Cop) -> String:
	if not is_cookware():
		return "PROMPT_HOLDING"
	if items.is_empty():
		return "PROMPT_" + kind.to_upper() + "_EMPTY"
	return "PROMPT_POUR" if nearest_plate() else "PROMPT_POUR_NO_PLATE"


## The plate nearest to it within POUR_REACH, or null.
func nearest_plate() -> KitchenVessel:
	var best: KitchenVessel = null
	for other: KitchenVessel in get_tree().get_nodes_in_group("kitchen_vessels"):
		if other.kind == "plate" and other.global_position.distance_to(global_position) <= POUR_REACH:
			if not best or other.global_position.distance_to(global_position) < best.global_position.distance_to(
					global_position):
				best = other
	return best


## E with it in hand: a pot or a pan empties onto the nearest plate (host).
func use(cop: Cop) -> void:
	if not is_cookware() or items.is_empty():
		return
	var plate := nearest_plate()
	if not plate:
		cop.show_hint("HINT_POUR_NO_PLATE")
		return
	if not multiplayer.is_server():
		return
	for item in items:
		var served := item.duplicate()
		served["in"] = kind
		plate.items.append(served)
	items.clear()
	plate._changed()
	_changed()


## Host: takes in the ingredients dropped into it, and cooks on a burner.
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not multiplayer.is_server():
		return
	for body in _catch.get_overlapping_bodies():
		if body is Ingredient and not (body as Ingredient).is_held() and not body.is_queued_for_deletion():
			take(body)
	if is_cookware() and not items.is_empty() and on_fire():
		cook(delta)


## Whether it stands upright on a burner.
func on_fire() -> bool:
	return global_basis.y.y > UPRIGHT and burner_at.call(global_position) != -1


## Host: `ingredient` goes in, raw.
func take(ingredient: Ingredient) -> void:
	items.append({"kind": ingredient.kind, "cooked": 0.0, "burnt": false, "in": ""})
	ingredient.queue_free()
	_changed()


## Host: `delta` more seconds on the fire for everything in it; past BURN it burns.
func cook(delta: float) -> void:
	var was_burnt := is_burnt()
	for item in items:
		item.cooked += delta
		if item.cooked > BURN[kind]:
			item.burnt = true
	if is_burnt() and not was_burnt:
		burnt.emit()
		_changed()
		return
	_share_left -= delta
	if _share_left <= 0.0:
		_share_left = SHARE_EVERY
		_changed()


## Host: shows it and tells the guests.
func _changed() -> void:
	_show()
	var net := _net()
	if multiplayer.is_server() and net.is_online():
		for peer: int in net.scene_peers:
			_items_now.rpc_id(peer, items)


@rpc("authority", "call_remote", "reliable")
func _items_now(now: Array) -> void:
	items.assign(now)
	_show()


## What's in it, as little versions of the ingredients (black when burnt), and the smoke.
func _show() -> void:
	if not _food:
		return
	for child in _food.get_children():
		child.free()
	for i in items.size():
		var food: Node3D = (Ingredient.MODELS[items[i].kind] as PackedScene).instantiate()
		var turn := TAU * i / maxf(items.size(), 1.0)
		food.position = Vector3(cos(turn), 0, sin(turn)) * (0.08 if items.size() > 1 else 0.0)
		food.rotation.y = turn
		food.scale = Vector3.ONE * FOOD_SCALE
		_food.add_child(food)
		if items[i].burnt:
			var black := StandardMaterial3D.new()
			black.albedo_color = Color(0.08, 0.07, 0.06)
			for mesh in food.find_children("*", "MeshInstance3D", true, false):
				(mesh as MeshInstance3D).material_override = black
	_smoke.emitting = is_burnt()


## The Net of this PC's multiplayer branch: the autoload in the game, each test PC's own in the online tests.
func _net() -> Node:
	var branch := multiplayer as SceneMultiplayer
	if branch and not branch.root_path.is_empty():
		var net := get_node_or_null(str(branch.root_path) + "/Net")
		if net:
			return net
	return Net
