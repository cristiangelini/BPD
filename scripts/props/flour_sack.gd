class_name FlourSack
extends Grabbable

## A 25 kg sack of flour in the cake lab's storeroom (docs/diseno/laboratorio.md, "Las bolsas de harina"): dropped
## from carrying height, or hit by something thrown, it bursts in a white cloud and leaves a patch of flour on the
## floor; the cop who walks through it leaves white footprints for a while (FlourPrints). Once. Every number here is
## (propuesta).

## `at` is the floor under the sack, where the flour lands.
signal burst(at: Vector3)

## Hits above this relative speed burst it: a drop from about half a metre, or a thrown thing.
const BURST_SPEED := 3.0
const CLOUD_RADIUS := 1.4
const CLOUD_TIME := 3.0
const FLOUR := Color(0.97, 0.96, 0.92)

var is_burst := false
var _impacts := ImpactTracker.new()


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4


## Applies a hit at `speed` m/s. Returns true if it burst now.
func hit(speed: float) -> bool:
	if is_burst or speed <= BURST_SPEED:
		return false
	is_burst = true
	var floor_at := Vector3(global_position.x, global_position.y - 0.18, global_position.z)
	_cloud()
	burst.emit(floor_at)
	queue_free()
	return true


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var speed := _impacts.hardest(state)
	if speed > 0.0:
		hit.call_deferred(speed)


## A white ball that swells and fades where the sack was.
func _cloud() -> void:
	var parent := get_parent()
	if parent == null:
		return
	var mesh := SphereMesh.new()
	mesh.radius = CLOUD_RADIUS
	mesh.height = CLOUD_RADIUS * 2
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(FLOUR, 0.85)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mesh.material = material
	var cloud := MeshInstance3D.new()
	cloud.mesh = mesh
	parent.add_child(cloud)
	cloud.global_position = global_position
	cloud.scale = Vector3.ONE * 0.4
	var tween := cloud.create_tween().set_parallel()
	tween.tween_property(cloud, "scale", Vector3.ONE, CLOUD_TIME * 0.4)
	tween.tween_property(material, "albedo_color:a", 0.0, CLOUD_TIME)
	tween.chain().tween_callback(cloud.queue_free)
