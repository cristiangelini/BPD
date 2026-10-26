class_name BankClerk
extends Grabbable

## Don Plácido, the town bank's only clerk (robo-banco-pueblo.md, step 1, decision 127): asleep on his stool behind
## the wooden counter, slumped forward with his head on the counter, snoring ("Zzz..." over his head). He's the only
## one to get out of the bank, and he's carried asleep: he weighs KG, so one cop drags him and two carry him. He waits
## still on his stool (frozen) until a cop takes hold of him. The back door's key sticks out of his vest pocket.
## Step 2: noise wakes him (heard()): a cop running near him, the patrol car's siren near the bank, something falling
## hard near him or a cop talking to him. Awake, he stands up and shouts "Thieves!" for SHOUT_TIME (`shouted`; El
## Conejo hears it, step 3) and falls asleep again. Waking up in the cops' arms, he slips out of them. A crouching cop
## takes the key out of his pocket with E without waking him. Out of the bank he wakes, yawns and goes home
## (`freed_now`). Every number here is (propuesta).

## He woke up and shouts (`why`: "run", "siren", "fall" or "talk").
signal shouted(clerk: BankClerk, why: String)
signal key_taken(cop: Cop)
## Carried out of the bank.
signal freed_now(clerk: BankClerk)

const KG := 70.0
const MODEL := preload("res://assets/models/npc_empleado.glb")
## His body, upright, seated on his stool; the model leans forward from it onto the counter.
const SIZE := Vector3(0.8, 1.2, 0.7)
const LEAN := 0.45
const SNORE_HEIGHT := 1.75
## How far the snore bobs (m) and how fast (radians a second).
const SNORE_BOB := 0.06
const SNORE_SPEED := 2.5
## What wakes him: a cop running this close (m), the siren this close, something this close falling this fast (m/s).
const WAKE_RUN := 4.0
const WAKE_SIREN := 20.0
const WAKE_FALL := 4.0
const FALL_SPEED := 4.0
## How often he listens for falling things (s).
const LISTEN_EVERY := 0.2
const SHOUT_TIME := 6.0
const SHOUT_LINES := 3
## Out of the bank: he yawns this long and goes home.
const HOME_TIME := 4.0

var asleep := true
## He woke up at least once (step 4 pays +100 if never).
var woke_ever := false
var shout_left := 0.0
## Carried out of the bank, and gone home.
var out := false
var gone := false
## The level's: the patrol car (its siren), and whether a world position is out of the bank.
var car: PatrolCar
var is_out: Callable = func(_at: Vector3) -> bool: return false
var _model: Node3D
var _key: Node3D
var _bubble: Label3D
var _bob := 0.0
var _listen_left := 0.0
var _home_left := 0.0
var _next_shout := 0


func _ready() -> void:
	add_to_group("bank_clerks")
	mass = KG
	collision_layer = 4
	collision_mask = 15
	# Carried or dropped, he stays on his feet.
	axis_lock_angular_x = true
	axis_lock_angular_z = true
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	freeze = true
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	_model = MODEL.instantiate()
	_model.rotation.x = LEAN
	add_child(_model)
	_key = _model.find_child("key", true, false) as Node3D
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.font_size = 48
	_bubble.pixel_size = 0.006
	_bubble.outline_size = 10
	_bubble.position.y = SNORE_HEIGHT
	_bubble.text = "CLERK_SNORE"
	add_child(_bubble)


## A cop takes hold of him: off his stool he goes, carried like anything heavy.
func hold(holder_id: int, point: Vector3) -> void:
	freeze = false
	super.hold(holder_id, point)


func has_key() -> bool:
	return _key != null and _key.visible


func prompt_key(cop: Cop) -> String:
	if out:
		return ""
	if asleep and has_key() and cop.is_crouching:
		return "PROMPT_TAKE_CLERK_KEY"
	return "PROMPT_WAKE_CLERK" if asleep else "PROMPT_GRAB"


## E: crouching, the key out of his pocket without waking him; standing, talking to him wakes him.
func use(cop: Cop) -> void:
	if out or not asleep:
		return
	if has_key() and cop.is_crouching:
		_key.hide()
		cop.has_key = true
		cop.show_hint("HINT_CLERK_KEY")
		key_taken.emit(cop)
		return
	wake("talk")


## Something woke him: he stands up and shouts, and slips out of whoever is carrying him.
func wake(why: String) -> void:
	if not asleep or out:
		return
	asleep = false
	woke_ever = true
	shout_left = SHOUT_TIME
	_bubble.text = "CLERK_THIEVES_%d" % (_next_shout % SHOUT_LINES + 1)
	_next_shout += 1
	_model.rotation.x = 0.0
	for id: int in holders.keys():
		var grabber := instance_from_id(id) as Grabber
		if grabber:
			grabber.release()
	shouted.emit(self, why)


## What he hears now that wakes him ("" if nothing): a cop running near him, the siren near or something falling hard.
func heard(delta: float) -> String:
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if cop is Cop and (cop as Cop).is_running and cop.global_position.distance_to(global_position) <= WAKE_RUN:
			return "run"
	if car and car.siren_on and car.global_position.distance_to(global_position) <= WAKE_SIREN:
		return "siren"
	_listen_left -= delta
	if _listen_left > 0.0:
		return ""
	_listen_left = LISTEN_EVERY
	var sphere := SphereShape3D.new()
	sphere.radius = WAKE_FALL
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = sphere
	query.transform = Transform3D(Basis(), global_position)
	query.collision_mask = 4
	query.exclude = [get_rid()]
	for hit in get_world_3d().direct_space_state.intersect_shape(query, 32):
		var body := hit.collider as RigidBody3D
		if body and not body.freeze and body.linear_velocity.length() >= FALL_SPEED:
			return "fall"
	return ""


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if gone:
		return
	if out:
		_home_left -= delta
		if _home_left <= 0.0:
			_go_home()
		return
	if is_out.call(global_position):
		out = true
		asleep = false
		_model.rotation.x = 0.0
		_bubble.text = "CLERK_YAWN"
		_home_left = HOME_TIME
		freed_now.emit(self)
		return
	if asleep:
		var why := heard(delta)
		if why != "":
			wake(why)
		return
	shout_left -= delta
	if shout_left <= 0.0:
		asleep = true
		_bubble.text = "CLERK_SNORE"
		_model.rotation.x = LEAN


func _go_home() -> void:
	gone = true
	for id: int in holders.keys():
		var grabber := instance_from_id(id) as Grabber
		if grabber:
			grabber.release()
	hide()
	collision_layer = 0
	collision_mask = 0
	freeze = true


func _process(delta: float) -> void:
	if asleep:
		_bob += delta * SNORE_SPEED
		_bubble.position.y = SNORE_HEIGHT + sin(_bob) * SNORE_BOB
