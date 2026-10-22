class_name TrafficCheckpoint
extends Node3D

## Where the cops set up the traffic control (control-transito.md, "Cómo es el caso", step 2): a painted box across
## one lane. It works once a barrier stands in the box across the lane and at least CONES_NEEDED cones stand in the
## lane before it. Cars travel along local -Z, so they arrive from +Z; the lane runs across local X.
## Every number here is (propuesta).

signal set_up

## The box: as wide as the lane, a little deeper than the barrier.
const ZONE := Vector2(6.0, 3.0)
## The barrier may turn this much off straight across and still close the lane.
const MAX_TURN := deg_to_rad(30.0)
const CONES_NEEDED := 2
## Cones count this far before the box, and a little wider than the lane.
const CONES_REACH := 14.0
const CONES_WIDE := 4.0
const PAINT := Color(1.0, 0.85, 0.2)

var ready_now := false


func _ready() -> void:
	add_to_group("traffic_checkpoints")
	var builder := PlaceBuilder.new(self)
	# The box's outline, painted on the asphalt.
	for x in [-1, 1]:
		builder.mesh_box(Vector3(x * ZONE.x / 2, 0.02, 0), Vector3(0.15, 0.02, ZONE.y), PAINT)
	for z in [-1, 1]:
		builder.mesh_box(Vector3(0, 0.02, z * ZONE.y / 2), Vector3(ZONE.x, 0.02, 0.15), PAINT)
	var label := Label3D.new()
	label.text = tr("CHECKPOINT_SIGN")
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 64
	label.outline_size = 12
	label.position = Vector3(0, 2.2, 0)
	add_child(label)


func barrier_ok() -> bool:
	for barrier: RoadBarrier in get_tree().get_nodes_in_group("road_barriers"):
		var at := to_local(barrier.global_position)
		if absf(at.x) > ZONE.x / 2 or absf(at.z) > ZONE.y / 2:
			continue
		# Its board along local X, seen from above, against the checkpoint's own X.
		var board := global_basis.inverse() * barrier.global_basis.x
		board.y = 0
		if board.length() > 0.1 and absf(board.normalized().x) >= cos(MAX_TURN):
			return true
	return false


func cones_ok() -> bool:
	var count := 0
	for cone: TrafficCone in get_tree().get_nodes_in_group("traffic_cones"):
		var at := to_local(cone.global_position)
		if cone.standing() and absf(at.x) <= CONES_WIDE and at.z > ZONE.y / 2 and at.z <= ZONE.y / 2 + CONES_REACH:
			count += 1
	return count >= CONES_NEEDED


func is_set_up() -> bool:
	return barrier_ok() and cones_ok()


func _physics_process(_delta: float) -> void:
	if ready_now or not is_set_up():
		return
	ready_now = true
	set_up.emit()
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		cop.show_hint("HINT_CHECKPOINT_READY")
