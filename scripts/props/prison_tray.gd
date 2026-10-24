class_name PrisonTray
extends Grabbable

## A canteen's steel tray (carcel-motin.md, step 3, decision 104), from the stack by the counter. Held, it turns to
## face the way the cop looks, a shield in front of the chest: food that bursts on it (hit_by_food) leaves a blob on it
## instead of a stain on the cop, and counts toward the shift report (tray_blocks). Every number here is (propuesta).

const MODEL := preload("res://assets/models/prison_tray.glb")
const SIZE := Vector3(0.45, 0.03, 0.35)
const KG := 0.8
## How hard it turns to face where the holder looks.
const TURN := 12.0
const BLOBS := 4
const BLOB_SCALE := 0.35


func _ready() -> void:
	add_to_group("prison_trays")
	mass = KG
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	add_child(MODEL.instantiate())


## Food burst on it: a blob on its face (the first few) and one more block for the cop holding it.
func hit_by_food(food: RallyThrowable) -> void:
	for cop in handling_cops(0.0):
		cop.stats["tray_blocks"] = cop.stats.get("tray_blocks", 0) + 1
	var blobs := get_children().filter(func(child: Node) -> bool: return child.is_in_group("tray_blobs"))
	if not food or blobs.size() >= BLOBS:
		return
	var blob: Node3D = RallyThrowable.SPLATS[food.kind].instantiate()
	blob.add_to_group("tray_blobs")
	add_child(blob)
	blob.position = Vector3(randf_range(-0.12, 0.12), SIZE.y / 2, randf_range(-0.1, 0.1))
	blob.scale = Vector3.ONE * BLOB_SCALE


func _physics_process(delta: float) -> void:
	super(delta)
	var cops := handling_cops(0.0)
	if cops.is_empty():
		return
	# Its face (+Y) toward where the holder looks, its long side level.
	var view := cops[0].camera.global_transform.basis
	angular_velocity = (global_transform.basis.y.cross(-view.z) + global_transform.basis.x.cross(view.x)) * TURN
