class_name CityInspector
extends CharacterBody3D

## The city's inspector, Severina Regla (docs/diseno/inspeccion.md, decision 107): on the campaign's last shift she
## comes into the case and goes everywhere with the cops, writing on her clipboard. On foot she walks behind the
## nearest cop at about FOLLOW meters; when the patrol car has a driver and she's next to it she gets in the back
## (standing, like the owners, a bit behind them, so she takes no cop's seat), and once the car stops with nobody
## driving she gets out behind it. --inspection brings her into any case. Every PC moves its own copy after the same
## cops (like InternalAffairsAgent).

## She got in the patrol car or got out of it.
signal boarded(car: PatrolCar)
signal got_out(car: PatrolCar)

const MODEL := preload("res://assets/models/npc_inspectora.glb")
## How far behind she walks, how fast, and how far a cop can get before she turns up behind them again.
const FOLLOW := 3.0
const WALK_SPEED := 2.4
const LOST := 40.0
## How close to the car's body she gets in, and how slow it must be (with nobody driving) for her to get out.
const BOARD_REACH := 3.0
const STOPPED := 1.0
## Where she stands in the car: behind the owner's spot, so both fit.
const SEAT_SHIFT := Vector3(0, 0, -0.45)
## Where her eyes are, and how long she says things.
const EYES := 1.45
const SAY_TIME := 3.0
## Lines while she follows them, now and then (INSPECTOR_NOTE_<n>).
const NOTE_LINES := 4
const NOTE_EVERY := 15.0

## The patrol car she rides in, or null on foot.
var car: PatrolCar
var _bubble: Label3D
var _bubble_left := 0.0
var _note_left := NOTE_EVERY


## Brings the inspector into `cop`'s level on the inspection's shift, if she isn't there yet: called by the player's
## own cop when the level opens.
static func join(cop: Cop) -> CityInspector:
	if not due() or not cop.get_parent() or of(cop) != null:
		return null
	var inspector := CityInspector.new()
	inspector.name = "CityInspector"
	cop.get_parent().add_child(inspector)
	inspector.global_position = cop.global_position + cop.global_basis.z * FOLLOW
	inspector.say("INSPECTOR_ARRIVES", 5.0)
	return inspector


## This shift is the inspection: the campaign's last one (outside the jailbreak's night), or --inspection.
static func due() -> bool:
	if OS.get_cmdline_user_args().has("--inspection"):
		return true
	if Campaign.current:
		return Campaign.current.shift == Campaign.SHIFTS and not Campaign.current.jailed
	return false


## The inspector in `node`'s level, if any.
static func of(node: Node) -> CityInspector:
	for inspector in node.get_tree().get_nodes_in_group("city_inspector"):
		return inspector as CityInspector
	return null


func _ready() -> void:
	add_to_group("city_inspector")
	# She never offers a bribe (Handcuffs.offer_of).
	set_meta("bribe_offered", true)
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.6
	shape.shape = capsule
	shape.position.y = 0.8
	add_child(shape)
	var model: Node3D = MODEL.instantiate()
	# The models face +Z; she faces -Z like everyone else.
	model.rotation.y = PI
	add_child(model)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.9, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.006
	_bubble.outline_size = 8
	_bubble.font_size = 40
	_bubble.width = 1000.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.modulate = Color(1, 0.95, 0.8)
	_bubble.hide()
	add_child(_bubble)


## The cuffs don't close on her.
func cuffed(_seconds: float) -> void:
	say("INSPECTOR_CUFFED")


func is_cuffed() -> bool:
	return false


func say(key: String, seconds := SAY_TIME) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = seconds


func said() -> String:
	return _bubble.text if _bubble.visible else ""


## She gets in the back of `in_car` and rides there: no bumping into it as it drives.
func board(in_car: PatrolCar) -> void:
	car = in_car
	collision_layer = 0
	collision_mask = 0
	velocity = Vector3.ZERO
	global_transform = car.prisoner_seat().translated_local(SEAT_SHIFT)
	say("INSPECTOR_IN_CAR")
	boarded.emit(car)


## She gets out behind the car.
func get_out() -> void:
	var from := car
	car = null
	var behind := from.to_global(Vector3(0, 0, -from.body_half_size().y - 1.0))
	global_position = Vector3(behind.x, from.global_position.y, behind.z)
	# Solid again once she stands outside, or the car would bump off her.
	await get_tree().physics_frame
	if car == null:
		collision_layer = 1
		collision_mask = 1
	say("INSPECTOR_OUT")
	got_out.emit(from)


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble_left <= 0.0:
		_bubble.hide()
	if car:
		if not is_instance_valid(car):
			car = null
			collision_layer = 1
			collision_mask = 1
		elif car.driver() == null and absf(car.forward_speed()) < STOPPED:
			get_out()
		else:
			global_transform = car.prisoner_seat().translated_local(SEAT_SHIFT)
		return
	var ride := _car_to_ride()
	if ride:
		board(ride)
		return
	var cop := _nearest_cop()
	if not cop:
		return
	var to_cop := cop.global_position - global_position
	to_cop.y = 0.0
	if to_cop.length() > LOST:
		global_position = cop.global_position + cop.global_basis.z * FOLLOW
		velocity = Vector3.ZERO
		return
	if to_cop.length() > 0.1:
		look_at(Vector3(cop.global_position.x, global_position.y, cop.global_position.z), Vector3.UP)
	var wish := to_cop.normalized() * WALK_SPEED if to_cop.length() > FOLLOW else Vector3.ZERO
	velocity.x = wish.x
	velocity.z = wish.z
	velocity.y = 0.0 if is_on_floor() else velocity.y - GameScale.GRAVITY * delta
	move_and_slide()
	_note_left -= delta
	if _note_left <= 0.0:
		_note_left = NOTE_EVERY
		say("INSPECTOR_NOTE_%d" % (randi() % NOTE_LINES + 1))


## A patrol car with someone at the wheel, within BOARD_REACH of its body, seen from above.
func _car_to_ride() -> PatrolCar:
	for node in get_tree().get_nodes_in_group("patrol_cars"):
		var patrol := node as PatrolCar
		if not patrol or patrol.driver() == null:
			continue
		var local := patrol.to_local(global_position)
		var half := patrol.body_half_size()
		var outside := Vector2(maxf(absf(local.x) - half.x, 0.0), maxf(absf(local.z) - half.y, 0.0))
		if outside.length() < BOARD_REACH:
			return patrol
	return null


func _nearest_cop() -> Node3D:
	var best: Node3D
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if not best or global_position.distance_to(cop.global_position) < global_position.distance_to(best.global_position):
			best = cop
	return best
