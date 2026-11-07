class_name WateringCan
extends Grabbable

## Brotecito's watering can (docs/diseno/allanamiento-vivero.md, "Brotecito"): filled at the greenhouse's tap, it
## spills if it tips past TIP (its up's height), if the cop carrying it falls (is staggered: a slip, a push, a bite) or
## if it hits something hard after a throw. Every number here is (propuesta).

## It was full and spilled.
signal spilled

const MODEL := preload("res://assets/models/watering_can.glb")
const SIZE := Vector3(0.3, 0.28, 0.3)
const KG := 1.5
const TIP := 0.5
## Landing faster than this after flying spills it too (m/s).
const CRASH_SPEED := 4.0
const WATER := Color(0.45, 0.7, 1.0, 0.8)

var full := false
var spills := 0
var _water: MeshInstance3D
var _was_fast := false


func _ready() -> void:
	add_to_group("watering_cans")
	mass = KG
	collision_layer = 4
	collision_mask = 15
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	var look: Node3D = MODEL.instantiate()
	look.position.y = -SIZE.y / 2
	add_child(look)
	_water = MeshInstance3D.new()
	var disc := CylinderMesh.new()
	disc.top_radius = 0.12
	disc.bottom_radius = 0.12
	disc.height = 0.02
	_water.mesh = disc
	var look_water := StandardMaterial3D.new()
	look_water.albedo_color = WATER
	look_water.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_water.material_override = look_water
	_water.position.y = SIZE.y / 2 - 0.04
	_water.hide()
	add_child(_water)


func fill() -> void:
	full = true
	_water.show()


## Brotecito waters the plants with it: empty again, nothing spilled.
func pour() -> void:
	full = false
	_water.hide()


## The water goes: on the floor, on the cop, on the plants.
func spill() -> void:
	if not full:
		return
	full = false
	spills += 1
	_water.hide()
	spilled.emit()


## It's tipped too far to keep the water in.
func is_tipped() -> bool:
	return global_basis.y.normalized().y < TIP


func _physics_process(delta: float) -> void:
	super(delta)
	# Online the host's can spills, and the guests' copy empties when it says (Nursery.net_state).
	if not full or not multiplayer.is_server():
		return
	if is_tipped():
		spill()
		return
	for cop in handling_cops(0.0):
		if cop.is_staggered():
			spill()
			return
	var fast := not is_held() and linear_velocity.length() > CRASH_SPEED
	if _was_fast and not fast and linear_velocity.length() < CRASH_SPEED / 2:
		spill()
	_was_fast = fast
