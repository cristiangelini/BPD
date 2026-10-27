class_name LeashedDog
extends Node3D

## Cuqui, Doña Pepa's poodle (docs/diseno/edificio.md): beside her door until a cop takes the leash, then trotting
## behind that cop with the leash drawn from the cop's hand to the collar. Only a look: it pushes nothing.

const MODEL := preload("res://assets/models/dog_poodle.glb")
## How far behind the cop it trots, and how fast it catches up.
const BEHIND := 1.0
const FOLLOW := 6.0
const LEASH_COLOR := Color(0.82, 0.18, 0.18)

var owner_npc: Node3D
var walker: Cop
var _home := Vector3.ZERO
var _leash: MeshInstance3D


func _ready() -> void:
	_home = position
	add_child(MODEL.instantiate())
	_leash = MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.015, 1.0, 0.015)
	_leash.mesh = box
	var look := StandardMaterial3D.new()
	look.albedo_color = LEASH_COLOR
	_leash.material_override = look
	_leash.top_level = true
	add_child(_leash)


func _physics_process(delta: float) -> void:
	var goal := _home
	var face := position + Vector3.FORWARD
	if walker:
		var back := walker.global_basis.z
		back.y = 0.0
		goal = get_parent_node_3d().to_local(walker.global_position + back.normalized() * BEHIND)
		goal.y = get_parent_node_3d().to_local(walker.global_position).y
		face = get_parent_node_3d().to_local(walker.global_position)
	position = position.lerp(goal, minf(FOLLOW * delta, 1.0))
	if walker and absf(position.y - goal.y) > 0.5:
		position = goal
	var to := face - position
	to.y = 0.0
	if to.length() > 0.2:
		rotation.y = atan2(to.x, to.z)
	_draw_leash()


func _draw_leash() -> void:
	var hand: Node3D = walker if walker else owner_npc
	if not hand or not is_inside_tree():
		_leash.hide()
		return
	_leash.show()
	var low := global_position + Vector3.UP * 0.35
	# A cop holds it at the side, at the hip; Doña Pepa lower, at her front (she faces +z).
	var grip := Vector3(0.3, 0.9, 0.0) if walker else Vector3(0.38, 0.5, 0.15)
	var high := hand.global_position + hand.global_basis * grip
	var length := low.distance_to(high)
	var up := (high - low) / maxf(length, 0.01)
	var side := up.cross(Vector3.FORWARD).normalized() if absf(up.z) < 0.99 else Vector3.RIGHT
	_leash.global_transform = Transform3D(Basis(side, up * length, side.cross(up)), (low + high) / 2)
