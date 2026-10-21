class_name QueueCar
extends CharacterBody3D

## A car that comes to the traffic control (control-transito.md, "Cómo es el caso", step 3): it drives down the lane
## toward the checkpoint, stops at the barrier or behind the car ahead and waits there until the cops let it through
## (TrafficQueue.release_front), or until the queue runs out of patience and it sneaks by along the sidewalk, knocking
## the cones over. It moves in the checkpoint's space, along local -Z, without physics: cars don't push the cops'
## things, they just stop. Stopped, its driver can be checked: the line they say at the barrier, E for the license and
## the trunk, opened by lifting its lid (step 4 of "El orden para hacerlo"). Every number here is (propuesta).

const SPEED := 30.0 / 3.6
## Brakes and speeds up this hard, in m/s².
const ACCEL := 6.0
const LENGTH := 4.6
## Space left to the car ahead when stopped, in meters.
const GAP := 1.5
## Where its middle stops before the checkpoint's box edge.
const STOP_BEFORE := LENGTH / 2 + 0.5
## Sneaking, it moves over this far toward the sidewalk (the checkpoint's +X).
const SNEAK_SIDE := 4.5
## Pulled over, it waits this far toward the curb, with two wheels on the sidewalk.
const CURB_SIDE := 3.2
## Cones this close to it when sneaking get knocked over, with this kick (m/s).
const KNOCK_REACH := 1.6
const KNOCK_SPEED := 4.0
## Gone this far past the checkpoint.
const GONE_AT := -60.0
## The trunk's hinge, in the car's space (forward is +Z, so the trunk is at the back).
const TRUNK_HINGE := Vector3(0, 1.0, -1.35)
## From the hinge to the back bumper.
const TRUNK_LENGTH := LENGTH / 2 + TRUNK_HINGE.z
const TRUNK_INSIDE := Vector3(0, 0.55, -1.8)
const BAG := Color(0.45, 0.3, 0.2)
const CONTRABAND := Color(0.85, 0.75, 0.3)
const GRANDPA := preload("res://assets/models/npc_abuelo.glb")
const SAY_SECONDS := 4.0

## "coming", "waiting", "going" (let through), "sneaking", "pulled_over" (detained, by the curb) or "gone".
var state := "coming"
var checkpoint: TrafficCheckpoint
## The car right in front in the queue, if any.
var ahead: QueueCar
var look := 0
var speed := 0.0
## Its place in the checkpoint's space: x across the lane, z along it.
var at := Vector3.ZERO
## From DriverTraits.draw: name, surname, year, line and trunk.
var driver: Dictionary = {}
var plate := ""
## The car the case is after (WantedPlan).
var wanted := false
var papers_checked := false
var trunk_checked := false
var lid: TrunkLid
var said_line := false
var _bubble: Label3D
var _bubble_left := 0.0
var _trunk: Node3D


func _ready() -> void:
	add_to_group("queue_cars")
	# The body leaves the trunk's top free, so the cops' hands reach the lid: the cabin and hood, and under the trunk.
	_add_box(Vector3(2.1, 1.4, LENGTH - TRUNK_LENGTH), Vector3(0, 0.9, TRUNK_LENGTH / 2))
	var under := TRUNK_HINGE.y - 0.3
	_add_box(Vector3(2.1, under, TRUNK_LENGTH), Vector3(0, 0.2 + under / 2, -LENGTH / 2 + TRUNK_LENGTH / 2))
	add_child(TrafficCar.MODELS[look % TrafficCar.MODELS.size()].instantiate())
	for wheel_at in SuspectCar.SEDAN_WHEELS:
		var wheel: Node3D = TrafficCar.WHEEL.instantiate()
		wheel.position = wheel_at
		add_child(wheel)
	_build_trunk()
	var plate_label := Label3D.new()
	plate_label.name = "Plate"
	plate_label.text = plate
	plate_label.font_size = 48
	plate_label.pixel_size = 0.004
	plate_label.modulate = Color(0.1, 0.1, 0.12)
	plate_label.outline_modulate = Color(0.95, 0.95, 0.9)
	plate_label.outline_size = 18
	plate_label.position = Vector3(0, 0.62, -LENGTH / 2 - 0.03)
	plate_label.rotation.y = PI
	add_child(plate_label)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.6, 0.6)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)
	_place()


func _add_box(size: Vector3, center: Vector3) -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = center
	add_child(shape)


func _build_trunk() -> void:
	lid = TrunkLid.new()
	lid.name = "TrunkLid"
	lid.position = TRUNK_HINGE
	add_child(lid)
	lid.opened.connect(_on_trunk_opened)
	_trunk = Node3D.new()
	_trunk.name = "Trunk"
	_trunk.position = TRUNK_INSIDE
	_trunk.visible = false
	add_child(_trunk)
	var builder := PlaceBuilder.new(_trunk)
	match driver.get("trunk", "bags"):
		"bags":
			builder.mesh_box(Vector3(-0.4, 0.2, 0), Vector3(0.7, 0.4, 0.5), BAG)
			builder.mesh_box(Vector3(0.4, 0.15, 0.05), Vector3(0.6, 0.3, 0.45), BAG.darkened(0.3))
		"contraband":
			for i in 3:
				builder.mesh_box(Vector3(-0.5 + i * 0.5, 0.15, 0), Vector3(0.4, 0.3, 0.4), CONTRABAND)
		"grandpa":
			var grandpa: Node3D = GRANDPA.instantiate()
			grandpa.scale = Vector3.ONE * 0.6
			grandpa.rotation.y = PI
			_trunk.add_child(grandpa)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_PAPERS" if waiting() else ""


## E on a stopped car: the driver hands the license.
func use(_cop: Cop) -> void:
	if not waiting() or driver.is_empty():
		return
	papers_checked = true
	say(DriverTraits.license_text(driver))


func say(text: String) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = SAY_SECONDS


## The bubble's text while it shows, for tests.
func saying() -> String:
	return _bubble.text if _bubble.visible else ""


func _on_trunk_opened() -> void:
	trunk_checked = true
	_trunk.visible = true
	match driver.get("trunk", "bags"):
		"contraband":
			say(tr("TRUNK_CONTRABAND"))
		"grandpa":
			say(tr("TRUNK_GRANDPA"))


func waiting() -> bool:
	return state == "waiting"


## In the queue, stopped or rolling up to it: not let through, not sneaking, not gone.
func in_queue() -> bool:
	return state == "coming" or state == "waiting"


func let_through() -> void:
	if in_queue():
		state = "going"


## The handcuffs (Handcuffs.cuffable) on a stopped car cuff its driver: the case detains them (TrafficCase).
func cuffed(_seconds: float) -> void:
	var case := get_tree().get_first_node_in_group("traffic_case") as TrafficCase
	if case and waiting():
		case.detain(self)


## The cuffs on the car itself come off right away: they're on the driver.
func is_cuffed() -> bool:
	return false


## Detained: it moves over to the curb, out of the lane, and stays there.
func pull_over() -> void:
	if in_queue():
		state = "pulled_over"


func sneak() -> void:
	if in_queue():
		state = "sneaking"


## Where it wants to stop, in the checkpoint's z; INF for no stop.
func _stop_z() -> float:
	if state == "pulled_over":
		return at.z
	if not in_queue():
		return -INF
	var stop := TrafficCheckpoint.ZONE.y / 2 + STOP_BEFORE if checkpoint.barrier_ok() else -INF
	if is_instance_valid(ahead) and ahead.in_queue():
		stop = maxf(stop, ahead.at.z + LENGTH + GAP)
	return stop


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()
	if state == "gone" or not checkpoint:
		return
	var stop := _stop_z()
	var room := at.z - stop
	# Slows down to stop right at `stop`: v² = 2·a·d.
	var top := SPEED if room == INF else minf(SPEED, sqrt(maxf(2.0 * ACCEL * room, 0.0)))
	speed = move_toward(speed, top, ACCEL * delta)
	if room <= 0.05:
		speed = 0.0
	# Never past where it stops, even with a long tick.
	at.z = maxf(at.z - speed * delta, stop)
	if state == "sneaking":
		at.x = move_toward(at.x, SNEAK_SIDE, 2.5 * delta)
	if state == "pulled_over":
		at.x = move_toward(at.x, CURB_SIDE, 1.5 * delta)
	if state == "coming" and speed == 0.0:
		state = "waiting"
		# At the barrier, the driver says their piece.
		if not said_line and not driver.is_empty() and not (is_instance_valid(ahead) and ahead.in_queue()):
			said_line = true
			say(tr(driver.line))
	elif state == "waiting" and speed > 0.0:
		state = "coming"
	if at.z < GONE_AT:
		state = "gone"
		queue_free()
		return
	_place()
	if state == "sneaking":
		_knock_cones()


func _place() -> void:
	if checkpoint:
		global_transform = checkpoint.global_transform * Transform3D(Basis(Vector3.UP, PI), at + Vector3.UP * 0.05)


func _knock_cones() -> void:
	for cone: TrafficCone in get_tree().get_nodes_in_group("traffic_cones"):
		var off := cone.global_position - global_position
		off.y = 0
		if off.length() < KNOCK_REACH and cone.standing():
			cone.linear_velocity = (off.normalized() + Vector3.UP * 0.6) * KNOCK_SPEED
			cone.angular_velocity = Vector3(randf_range(-6, 6), 0, randf_range(-6, 6))
