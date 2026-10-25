class_name Cleaner
extends StaticBody3D

## Clotilde, the cleaner of the cleaning crew's jailbreak (docs/diseno/fuga-limpieza.md, step 2): her cart stands in
## the cells room with the cells' key ring on its top tray (the level's CellKey). Her round goes cell by cell, the
## first one drawn by the seed: at the cart she takes the keys, unlocks the cell's door and leaves it open while she
## mops inside for MOP_TIME seconds, then walks back to the cart for the keys and locks the door again. Then the other
## cell, and a rest at the cart. If the keys aren't on the cart she can't open or lock anything: she stays there
## asking for them (and a door she couldn't lock stays open). She doesn't watch anyone: "Yo limpio, no vigilo."
## Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_limpieza.glb")
## In the station's own space (StationRooms): where she stands beside her cart (facing it, +X), and for each cell where she stands
## outside its door (the door swings out toward +Z, on her left) and where she mops inside.
const CART_STAND := Vector3(12.0, 0, 7.4)
const OUTSIDE := [Vector3(9.9, 0, 5.4), Vector3(11.7, 0, 5.4)]
const INSIDE := [Vector3(8.6, 0, 3.0), Vector3(12.4, 0, 3.0)]
const WALK_SPEED := 1.1
const MOP_TIME := 20.0
const REST_MIN := 20.0
const REST_MAX := 40.0
## How often she asks for her keys while they're missing, and how close to the hook they count as on the cart.
const ASK_EVERY := 6.0
const ON_CART := 0.5
const BUBBLE_TIME := 4.0
const LINES := {"CLEANER_OPEN": 3, "CLEANER_MOP": 4, "CLEANER_LOCK": 2, "CLEANER_NO_KEYS": 3, "CLEANER_REST": 2}

## The station's lot, the two cell doors (as StationRooms.CELL_DOORS) and the key ring on her cart.
var station := Transform3D.IDENTITY
var doors: Array = []
var key: CellKey
## Where the keys hang on the cart, in the world.
var hook := Vector3.ZERO
## Her round: [kind, arg] steps ("walk" to a point, "open"/"lock" a cell, "mop", "keys", "rest" seconds).
var steps: Array = []
var step := 0
## Seconds left in the step that takes time (mopping, resting, waiting to ask again for the keys).
var left := 0.0
## Which cell she cleans first in each round.
var first_cell := 0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _rng := RandomNumberGenerator.new()


## The cleaner for this jailbreak's seed, standing beside her cart about to rest before her first round.
func setup(case_seed: int, station_lot: Transform3D, cell_doors: Array, cart_key: CellKey, key_hook: Vector3) -> void:
	station = station_lot
	doors = cell_doors
	key = cart_key
	hook = key_hook
	_rng.seed = hash(["cleaner", case_seed])
	first_cell = _rng.randi_range(0, 1)
	reset()


func _ready() -> void:
	add_to_group("cleaner")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.5
	shape.shape = capsule
	shape.position.y = 0.75
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.9, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 900.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


## Back beside her cart, starting a new round after a short rest (the comisario put everyone back).
func reset() -> void:
	global_transform = Transform3D(station.basis * Basis(Vector3.UP, PI / 2), station * CART_STAND)
	steps = [["rest", _rng.randf_range(REST_MIN, REST_MAX) / 2]]
	for cell: int in [first_cell, 1 - first_cell]:
		steps.append_array([["keys", 0], ["walk", OUTSIDE[cell]], ["open", cell], ["walk", INSIDE[cell]], ["mop", 0],
			["walk", OUTSIDE[cell]], ["walk", CART_STAND], ["keys", 0], ["walk", OUTSIDE[cell]], ["lock", cell],
			["walk", CART_STAND]])
	steps.append(["rest", _rng.randf_range(REST_MIN, REST_MAX)])
	step = 0
	left = steps[0][1]


func keys_on_cart() -> bool:
	return is_instance_valid(key) and not key.is_held() and key.global_position.distance_to(hook) <= ON_CART


## What she's doing now ("walk", "mop"...).
func doing() -> String:
	return steps[step][0]


## The cell she's mopping now, or -1.
func mopping_cell() -> int:
	if doing() != "mop":
		return -1
	return steps[step - 2][1]


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()
	run(delta)


## One tick of her round.
func run(delta: float) -> void:
	var kind: String = steps[step][0]
	match kind:
		"walk":
			if _walk_to(station * (steps[step][1] as Vector3), delta):
				_next()
		"open":
			var door: CellDoor = doors[steps[step][1]]
			door.unlock()
			door.set_open(true)
			_say("CLEANER_OPEN")
			_next()
		"lock":
			(doors[steps[step][1]] as CellDoor).lock()
			_say("CLEANER_LOCK")
			_next()
		"keys":
			left -= delta
			if keys_on_cart():
				_next()
			elif left <= 0.0:
				left = ASK_EVERY
				_say("CLEANER_NO_KEYS")
		"mop", "rest":
			left -= delta
			if left <= 0.0:
				_next()
			elif kind == "mop" and fmod(left, 7.0) < delta:
				_say("CLEANER_MOP")


func _next() -> void:
	step = (step + 1) % steps.size()
	match steps[step][0]:
		"mop":
			left = MOP_TIME
			_say("CLEANER_MOP")
		"rest":
			left = steps[step][1]
			_say("CLEANER_REST")
		_:
			left = 0.0


## A step toward `goal`, facing it; true once there.
func _walk_to(goal: Vector3, delta: float) -> bool:
	var to := goal - global_position
	to.y = 0.0
	var walk := WALK_SPEED * delta
	if to.length() <= walk:
		global_position = Vector3(goal.x, global_position.y, goal.z)
		return true
	global_position += to.normalized() * walk
	global_rotation.y = atan2(to.x, to.z)
	return false


func _say(line: String) -> void:
	say("%s_%d" % [line, _rng.randi_range(0, LINES[line] - 1)])


func say(text: String, seconds := BUBBLE_TIME) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


func said() -> String:
	return _bubble.text if _bubble.visible else ""


## Online: where she is in her round and the doors she opened and locked (NpcSync); the guests' doors follow.
func net_state() -> Variant:
	var state := [step]
	for door: CellDoor in doors:
		state.append_array([door.locked, door.is_open])
	return state


func apply_net_state(state: Variant) -> void:
	step = state[0]
	for i in doors.size():
		var door: CellDoor = doors[i]
		door.locked = state[1 + i * 2]
		if door.is_open != bool(state[2 + i * 2]):
			door.set_open(state[2 + i * 2])
