class_name TvCamera
extends Grabbable

## One of the studio's 3 cameras (politico-debate.md, step 2, decision 230). It weighs KG on its wheels: one cop
## drags it slowly and two move it fast (it rolls, it doesn't lift: it never tips over). E turns it to where the cop
## looks, the way a cameraman pans it by its handles. The one on air (TvStudio.put_on_air) lights its red tally and
## is what the big screen shows. Every number here is (propuesta).

const MODEL := preload("res://assets/models/tv_camera.glb")
const KG := 80.0
## The wheels: hardly any friction, and the drag that keeps one cop slower than two.
const WHEELS := 0.05
const ROLL_DAMP := 1.5
const SIZE := Vector3(0.8, 1.75, 0.8)
## Just in front of the lens, in its own space (it looks to -Z), and what it takes in.
const LENS := Vector3(0, 1.58, -0.8)
const FOV := 40.0
const TALLY_ON := Color(1.0, 0.1, 0.12)
const TALLY_OFF := Color(0.3, 0.06, 0.07)

var on_air := false:
	set(value):
		on_air = value
		if _tally:
			_tally.material_override = _tally_on if value else _tally_off
var _tally: MeshInstance3D
var _tally_on: StandardMaterial3D
var _tally_off: StandardMaterial3D


func _ready() -> void:
	add_to_group("tv_cameras")
	mass = KG
	linear_damp = ROLL_DAMP
	collision_layer = 4
	collision_mask = 15
	# It rolls and turns on the floor, never tips.
	axis_lock_angular_x = true
	axis_lock_angular_z = true
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.friction = WHEELS
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	var model: Node3D = MODEL.instantiate()
	model.name = "Model"
	# The model's lens points to +Z; the camera looks to -Z like a Camera3D.
	model.rotation.y = PI
	add_child(model)
	_tally_on = _glow(TALLY_ON, 3.0)
	_tally_off = _glow(TALLY_OFF, 0.0)
	_tally = MeshInstance3D.new()
	_tally.name = "Tally"
	var lamp := BoxMesh.new()
	lamp.size = Vector3(0.11, 0.06, 0.07)
	_tally.mesh = lamp
	_tally.position = Vector3(0, 1.78, -0.2)
	add_child(_tally)
	on_air = on_air


func _glow(color: Color, energy: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = energy > 0.0
	material.emission = color
	material.emission_energy_multiplier = energy
	return material


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_AIM_TV_CAMERA"


## E: it turns to face where the cop faces.
func use(cop: Cop) -> void:
	turn_to(cop.global_rotation.y)


## Turns it to this yaw (its -Z along it).
func turn_to(yaw: float) -> void:
	global_basis = Basis(Vector3.UP, yaw)
	angular_velocity = Vector3.ZERO
	sleeping = false


## Turns it to look at a world point.
func aim_at(at: Vector3) -> void:
	var to := at - global_position
	turn_to(atan2(-to.x, -to.z))


## Where the lens is and where it looks, in the world.
func lens() -> Transform3D:
	return global_transform * Transform3D(Basis.IDENTITY, LENS)


## Whether a world point is in its picture: within half its field of view from where the lens looks.
func frames(at: Vector3) -> bool:
	var eye := lens()
	var to := at - eye.origin
	return to.length() > 0.3 and (-eye.basis.z).angle_to(to) < deg_to_rad(FOV / 2)
