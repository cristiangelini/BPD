class_name SeaLion
extends AnimatableBody3D

## Bigotes, the loose sea lion (escena-acuario.md, "Bigotes"): he waddles round and round the aquarium's hall along
## `route`, turning to face where he goes. E on him, he barks and claps. He steals: something a cop left on the floor
## within STEAL_REACH, or what a cop holds standing still that close for STILL_SECONDS, goes on his nose, and nobody
## can take it off; he gives it back only for a fish (AquariumFish, feed), and then he rests a while before stealing
## again. A fish he steals he just eats. Every number here is (propuesta).

const MODEL := preload("res://assets/models/sea_lion_bigotes.glb")
const SPEED := 1.2
const LINES := 3
const STEAL_REACH := 2.0
const STILL_SECONDS := 3.0
## A cop slower than this, in m/s, is standing still.
const STILL_SPEED := 0.3
## He takes things of at most this many kg, lying this close to the floor.
const MAX_KG := 5.0
const FLOOR_BAND := 0.3
## After a fish he rests this long before stealing again.
const REST := 15.0
const LOOK_EVERY := 0.25

## The points he waddles through in a loop, in his parent's space. Empty, he stays put.
var route: Array[Vector3] = []
## Whether he is waddling (false: he stays where he is).
var waddling := true
var _next := 0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0
## What he has on his nose, and the collision layer it had.
var carried: Grabbable
var _carried_layer := 0
var rest_left := 0.0
var thefts := 0
var _look_left := 0.0
## Cop -> seconds standing still near him with something in hand.
var _still := {}


func _ready() -> void:
	add_to_group("sea_lion")
	collision_layer = 8
	sync_to_physics = false
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.2
	shape.shape = capsule
	shape.position.y = 0.6
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 1.6
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_SEA_LION"


func use(_cop: Cop) -> void:
	say("SEA_LION_LINE_%d" % (_lines_said % LINES))
	_lines_said += 1


## Takes `item` out of whoever holds it and balances it on his nose (a fish he eats instead).
func steal(item: Grabbable) -> void:
	for holder_id: int in item.holders.keys():
		var grabber := instance_from_id(holder_id) as Grabber
		if grabber:
			grabber.release()
	_still.clear()
	if item is AquariumFish:
		item.queue_free()
		say("SEA_LION_YUM")
		_ate()
		return
	carried = item
	_carried_layer = item.collision_layer
	item.collision_layer = 0
	item.freeze = true
	thefts += 1
	say("SEA_LION_STOLE")
	_hold_carried()


## A fish for him: he tosses back what he has on his nose and eats it.
func feed(_cop: Cop) -> void:
	if carried:
		var item := carried
		carried = null
		item.collision_layer = _carried_layer
		item.freeze = false
		item.global_position = global_position + global_transform.basis.z * 0.8 + Vector3.UP * 0.6
		item.linear_velocity = Vector3.UP * 2.0
		say("SEA_LION_GIVES_BACK")
	else:
		say("SEA_LION_YUM")
	_ate()


func _ate() -> void:
	rest_left = REST
	get_tree().call_group("aquarium_keeper", "saw_fish_given", self)


## Where he balances what he steals: the tip of his nose.
func nose() -> Node3D:
	return _model.find_child("nose", true, false) as Node3D


## The tip of his nose in the world (the nose mesh's middle; its node sits at his feet).
func nose_tip() -> Vector3:
	var tip := nose()
	var mesh := tip as MeshInstance3D
	if not mesh and tip:
		var found := tip.find_children("*", "MeshInstance3D", true, false)
		mesh = found[0] as MeshInstance3D if not found.is_empty() else null
	if not mesh:
		return global_position + Vector3.UP * 1.05
	return mesh.global_transform * mesh.get_aabb().get_center()


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func say(text: String, seconds := 3.0) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()
	if waddling and not route.is_empty():
		_waddle(delta)
	if carried:
		if is_instance_valid(carried):
			_hold_carried()
		else:
			carried = null
		return
	if rest_left > 0.0:
		rest_left -= delta
		return
	_watch_hands(delta)
	_look_left -= delta
	if _look_left <= 0.0 and not carried:
		_look_left = LOOK_EVERY
		var item := _floor_item()
		if item:
			steal(item)


func _hold_carried() -> void:
	carried.global_position = nose_tip() + Vector3.UP * 0.12
	carried.linear_velocity = Vector3.ZERO


## Counts how long each cop near him stands still with something in hand, and takes it at STILL_SECONDS.
func _watch_hands(delta: float) -> void:
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		var grabber := cop.get_node_or_null("Grabber") as Grabber if cop else null
		if not grabber or not grabber.held or cop.global_position.distance_to(global_position) > STEAL_REACH \
				or Vector2(cop.velocity.x, cop.velocity.z).length() > STILL_SPEED:
			_still.erase(cop)
			continue
		_still[cop] = _still.get(cop, 0.0) + delta
		if _still[cop] >= STILL_SECONDS:
			steal(grabber.held)
			return


## Something a cop left on the floor within his reach, if any.
func _floor_item() -> Grabbable:
	var query := PhysicsShapeQueryParameters3D.new()
	var ball := SphereShape3D.new()
	ball.radius = STEAL_REACH
	query.shape = ball
	query.transform = Transform3D(Basis(), global_position)
	for hit in get_world_3d().direct_space_state.intersect_shape(query, 32):
		var item := hit.collider as Grabbable
		if item and item.was_held and not item.is_held() and not item.freeze and item.mass <= MAX_KG \
				and item.global_position.y - global_position.y < FLOOR_BAND:
			return item
	return null


func _waddle(delta: float) -> void:
	var target := route[_next % route.size()]
	var to := target - position
	to.y = 0.0
	if to.length() <= SPEED * delta:
		position = Vector3(target.x, position.y, target.z)
		_next = (_next + 1) % route.size()
		return
	position += to.normalized() * SPEED * delta
	rotation.y = atan2(to.x, to.z)
