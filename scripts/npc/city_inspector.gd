class_name CityInspector
extends CharacterBody3D

## The city's inspector, Severina Regla (docs/diseno/inspeccion.md, decision 107): on the campaign's last shift she
## comes into the case and goes everywhere with the cops, writing on her clipboard. On foot she walks behind the
## nearest cop at about FOLLOW meters; when the patrol car has a driver and she's next to it she gets in the back
## (standing, like the owners, a bit behind them, so she takes no cop's seat), and once the car stops with nobody
## driving she gets out behind it. --inspection brings her into any case. Every PC moves its own copy after the same
## cops (like InternalAffairsAgent).
## What she sees within SEEN_REACH, with nothing in between, goes in her report (InspectionReport): the cops cuffing
## someone or a partner, taking a bribe or eating a donut, evidence put in the car, things broken, the car she rides in
## crashing, something hitting her and being left behind.

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
## How far she sees what goes in the report, like the internal affairs agent (Bribes.SEEN_REACH).
const SEEN_REACH := 15.0
## The car she rides losing this much speed at once (m/s, like ChaseDamages) is a crash; one per CRASH_COOLDOWN.
const CRASH_DROP := 15.0 / 3.6
const CRASH_COOLDOWN := 1.0
const SPEED_FRAMES := 8
## Something flying into her this fast (m/s) is a hit; one per HIT_COOLDOWN.
const HIT_SPEED := 4.0
const HIT_COOLDOWN := 2.0

## The patrol car she rides in, or null on foot.
var car: PatrolCar
var _bubble: Label3D
var _bubble_left := 0.0
var _note_left := NOTE_EVERY
var report: InspectionReport
var _speeds: Array[float] = []
var _crash_wait := 0.0
var _hit_wait := 0.0


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
	report = InspectionReport.new()
	report.name = "Report"
	add_child(report)
	report.changed.connect(_show_score)
	var feel := Area3D.new()
	feel.name = "Feel"
	feel.collision_layer = 0
	var sphere := CollisionShape3D.new()
	var ball := SphereShape3D.new()
	ball.radius = 0.6
	sphere.shape = ball
	sphere.position.y = 0.9
	feel.add_child(sphere)
	add_child(feel)
	feel.body_entered.connect(_on_felt)
	_watch.call_deferred()
	_show_score.call_deferred(report.score)


## What she keeps an eye on in the level: the patrol cars' evidence, and every ornament and piece of evidence breaking.
func _watch() -> void:
	for node in get_tree().get_nodes_in_group("patrol_cars"):
		(node as PatrolCar).evidence_delivered.connect(func(item: Evidence) -> void: saw("evidence", item.global_position))
	for ornament in get_parent().find_children("*", "Ornament", true, false):
		(ornament as Ornament).broken.connect(func(at: Vector3) -> void: saw("broken", at))
	for node in get_tree().get_nodes_in_group("evidence"):
		var item := node as Evidence
		item.broken.connect(func() -> void: saw("broken", item.global_position))


func _show_score(score: int) -> void:
	get_tree().call_group("checklist", "show_report", score)
	# On the campaign's last shift her report decides the end (Campaign.finish_shift).
	if Campaign.current and Campaign.current.shift == Campaign.SHIFTS:
		Campaign.current.inspection = report.summary()


## She sees `at` (where `target`, if any, is): close enough and nothing in between. Riding, she sees out of the car.
func sees(at: Vector3, target: Node = null) -> bool:
	var eyes := global_position + Vector3.UP * EYES
	var to := at + Vector3.UP * 0.8
	if eyes.distance_to(to) > SEEN_REACH:
		return false
	var exclude := [get_rid()]
	if car:
		exclude.append(car.get_rid())
	if target is CollisionObject3D:
		exclude.append((target as CollisionObject3D).get_rid())
	var query := PhysicsRayQueryParameters3D.create(eyes, to)
	query.exclude = exclude
	return get_world_3d().direct_space_state.intersect_ray(query).is_empty()


## Writes down `kind` (InspectionReport.KINDS) if she sees `at`, and says so. Returns whether it went in.
func saw(kind: String, at: Vector3, target: Node = null) -> bool:
	if not sees(at, target):
		return false
	report.note(kind)
	say("INSPECTOR_SAW_" + kind.to_upper())
	return true


## `cop` cuffed `target`: a suspect is good procedure, a partner isn't. Nobody else counts (she or the agent).
func saw_cuffed(_cop: Cop, target: Object) -> void:
	if target is Cop:
		saw("partner", (target as Cop).global_position, target as Node)
	elif target and target != self and not target is InternalAffairsAgent and target is Node3D:
		saw("cuffed", (target as Node3D).global_position, target as Node)


func saw_bribe(cop: Cop) -> void:
	saw("bribe", cop.global_position, cop)


func saw_donut(cop: Cop) -> void:
	saw("donut", cop.global_position, cop)


func _on_felt(body: Node3D) -> void:
	if car or _hit_wait > 0.0 or not body is RigidBody3D:
		return
	if (body as RigidBody3D).linear_velocity.length() < HIT_SPEED:
		return
	_hit_wait = HIT_COOLDOWN
	report.note("hit")
	say("INSPECTOR_SAW_HIT")


## The car she rides slowed down too fast: a crash, felt from inside.
func _check_crash(delta: float) -> void:
	_crash_wait -= delta
	var speed := absf(car.forward_speed())
	_speeds.append(speed)
	if _speeds.size() > SPEED_FRAMES:
		_speeds.pop_front()
	if _crash_wait <= 0.0 and _speeds.max() - speed > CRASH_DROP:
		_crash_wait = CRASH_COOLDOWN
		_speeds.clear()
		report.note("crash")
		say("INSPECTOR_SAW_CRASH")


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
	_speeds.clear()
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
	_hit_wait -= delta
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
			_check_crash(delta)
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
		report.note("behind")
		say("INSPECTOR_SAW_BEHIND")
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
