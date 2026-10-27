class_name MansionCat
extends Grabbable

## One of Señora Ofelia's five cats (escena-gato.md, "La Duquesa y las otras cuatro gatas"): ginger and fat, all alike,
## loose around the house. Picked up, after a few seconds she jumps out of the cop's arms and runs to hide by a piece
## of furniture for a while; in the transport crate she can't. An open can of tuna calls every cat near it, and only
## Duquesa purrs (hearts and all) close to the piano's music box while it plays. Every number here is (propuesta).

signal escaped(cat: MansionCat)

const MODEL := preload("res://assets/models/cat_michi.glb")
## Fatter than the grandpa's Michi.
const SIZE := 1.3
const WALK_SPEED := 0.8
const RUN_SPEED := 3.5
## How long a cop can hold her before she jumps out, and how long she stays hidden after.
const ESCAPE_SECONDS := 5.0
const HIDE_SECONDS := 8.0
const PURR_RANGE := 3.0
const LURE_RANGE := 10.0
## How long she eats at an open can before wandering off again.
const EAT_SECONDS := 10.0
const TURN_MIN := 2.0
const TURN_MAX := 5.0
const ARRIVED := 0.5

## The real one: Duquesa, the heiress.
var duchess := false
## Her name's text key (DUCHESS for her, CAT_NAME_0... for the others).
var cat_name := "DUCHESS"
## In Señora Ofelia's arms, home at last: she stays there.
var home := false
## Locked away somewhere by the culprit (step 5): she doesn't walk and only meows when called.
var shut_in := false
## Where she runs to hide (world positions), the nearest one each time.
var hide_spots: Array[Vector3] = []
## The crate she is in, if any.
var crate: TransportCrate
var purring := false
var _held_for := 0.0
var _hiding_left := 0.0
var _target := Vector3.INF
var _eat_left := 0.0
var _heading := 0.0
var _turn_left := 0.0
var _rng := RandomNumberGenerator.new()
var _bubble: Label3D


func _ready() -> void:
	add_to_group("mansion_cats")
	collision_layer = 4
	collision_mask = 15
	mass = 4.0
	axis_lock_angular_x = true
	axis_lock_angular_z = true
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.26, 0.3, 0.45) * SIZE
	shape.shape = box
	shape.position.y = 0.15 * SIZE
	add_child(shape)
	var model: Node3D = MODEL.instantiate()
	model.name = "Model"
	model.scale = Vector3.ONE * SIZE
	add_child(model)
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 0.7
	add_child(_bubble)
	_rng.seed = hash(name)
	_heading = _rng.randf() * TAU


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_MANSION_CAT"


func is_hiding() -> bool:
	return _hiding_left > 0.0


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func say(text: String) -> void:
	_bubble.text = text
	_bubble.show()


## Jumps out of every cop's arms and runs to the nearest hiding spot.
func escape() -> void:
	free_from_arms()
	_hiding_left = HIDE_SECONDS
	_target = _nearest_spot()
	say("CAT_HISS")
	escaped.emit(self)


## Locked away at `at` by the culprit: out of sight, still, and only her meow gets out.
func lock_in(at: Vector3) -> void:
	shut_in = true
	_set_out(false)
	global_position = at


## Out of her hiding place at `at`, on the floor: she can walk again.
func let_out(at: Vector3) -> void:
	shut_in = false
	global_position = at
	_set_out(true)


func _set_out(out: bool) -> void:
	(get_node("Model") as Node3D).visible = out
	freeze = not out
	collision_layer = 4 if out else 0
	collision_mask = 15 if out else 0


## Every cop holding her lets go.
func free_from_arms() -> void:
	for id: int in holders.keys():
		var grabber := instance_from_id(id) as Grabber
		if grabber:
			grabber.release()
		else:
			let_go(id)
	_held_for = 0.0


## An open can of tuna at `at`: she goes there and eats, unless she is locked away (then she only meows).
func lure(at: Vector3) -> void:
	if shut_in:
		say("CAT_MEOW")
		return
	if crate or home or is_held() or global_position.distance_to(at) > LURE_RANGE:
		return
	_hiding_left = 0.0
	_target = at
	_eat_left = EAT_SECONDS


func _physics_process(delta: float) -> void:
	super(delta)
	purring = duchess and not shut_in and _music_near()
	if purring:
		say("CAT_PURR")
	elif _bubble.text == "CAT_PURR":
		_bubble.hide()
	if crate or shut_in or home:
		return
	if is_held():
		_held_for += delta
		if _held_for >= ESCAPE_SECONDS:
			escape()
		return
	_held_for = 0.0
	_hiding_left = maxf(_hiding_left - delta, 0.0)
	if _target != Vector3.INF:
		if _flat(_target - global_position).length() > ARRIVED:
			_walk(_target - global_position, RUN_SPEED if is_hiding() else WALK_SPEED * 2.0)
			return
		_eat_left = maxf(_eat_left - delta, 0.0)
		_stop()
		if is_hiding() or _eat_left > 0.0:
			return
		_target = Vector3.INF
		_bubble.hide()
	_turn_left -= delta
	if _turn_left <= 0.0:
		_turn_left = _rng.randf_range(TURN_MIN, TURN_MAX)
		_heading = _rng.randf() * TAU
	_walk(Vector3(sin(_heading), 0, cos(_heading)), WALK_SPEED)


func _music_near() -> bool:
	for box: MusicBox in get_tree().get_nodes_in_group("music_boxes"):
		if box.playing() and box.global_position.distance_to(global_position) <= PURR_RANGE:
			return true
	return false


func _nearest_spot() -> Vector3:
	var best := global_position
	var best_distance := INF
	for spot in hide_spots:
		var d := spot.distance_to(global_position)
		if d < best_distance:
			best = spot
			best_distance = d
	return best


func _walk(direction: Vector3, speed: float) -> void:
	var wish := _flat(direction).normalized() * speed
	linear_velocity.x = wish.x
	linear_velocity.z = wish.z
	rotation.y = atan2(wish.x, wish.z)


func _stop() -> void:
	linear_velocity.x = 0.0
	linear_velocity.z = 0.0


static func _flat(v: Vector3) -> Vector3:
	return Vector3(v.x, 0, v.z)
