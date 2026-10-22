class_name NightGuard
extends StaticBody3D

## The night guard of the jailbreak (fuga.md, "La llave en la dona", step 2): he sits at his desk in front of the
## cells with a box of six donuts, and the key of the cells went into one of them without him noticing. Every
## EAT_EVERY seconds he eats one, from the last in the box to the first; if it's the one with the key, he spits it out
## and hangs it from his belt. The seed draws which donut has it. He only eats from the box while it's within his
## reach on the desk. Every number here is (propuesta).

signal ate(donut: int)
signal found_key

const MODEL := preload("res://assets/models/npc_carcelero.glb")
const EAT_EVERY := 40.0
## How far from him the box can be for him to take a donut.
const REACH := 1.5
const MUNCH_LINES := 5
const BUBBLE_TIME := 4.0

var box: DonutBox
## Which donut of the box (its part donut_<n>) has the key.
var key_donut := 0
var key_on_belt := false
var eat_left := EAT_EVERY
var _bubble: Label3D
var _bubble_left := 0.0
var _rng := RandomNumberGenerator.new()


## The guard for this jailbreak's seed: the same donut has the key every time.
func setup(case_seed: int, donut_box: DonutBox) -> void:
	box = donut_box
	_rng.seed = hash(["night guard", case_seed])
	key_donut = _rng.randi_range(0, box.donuts - 1)


func _ready() -> void:
	add_to_group("night_guard")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.6
	shape.shape = capsule
	shape.position.y = 0.8
	add_child(shape)
	add_child(MODEL.instantiate())
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.0, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 900.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


## The key is still in a donut of the box.
func key_in_box() -> bool:
	return not key_on_belt and box != null and key_donut < box.donuts


func box_in_reach() -> bool:
	return is_instance_valid(box) and box.global_position.distance_to(global_position) <= REACH


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()
	eat_left -= delta
	if eat_left <= 0.0:
		eat_left = EAT_EVERY
		eat()


## Takes the next donut out of the box and eats it, or complains that the box is gone or empty.
func eat() -> void:
	if not box_in_reach() or box.donuts == 0:
		say("GUARD_NO_DONUTS")
		return
	box.eat_one()
	var donut := box.donuts
	ate.emit(donut)
	if donut == key_donut and not key_on_belt:
		key_on_belt = true
		say("GUARD_KEY_FOUND", 6.0)
		found_key.emit()
	else:
		say("GUARD_MUNCH_%d" % _rng.randi_range(0, MUNCH_LINES - 1))


func say(text: String, seconds := BUBBLE_TIME) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


func said() -> String:
	return _bubble.text if _bubble.visible else ""


## Online: what the guests need to show the same box and belt (NpcSync).
func net_state() -> Variant:
	return [box.donuts if is_instance_valid(box) else 0, key_on_belt]


func apply_net_state(state: Variant) -> void:
	key_on_belt = state[1]
	while is_instance_valid(box) and box.donuts > int(state[0]):
		box.eat_one()
