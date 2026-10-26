class_name Ornament
extends Grabbable

## One of the grandpa's ~150 porcelain ornaments (docs/diseno/allanamiento.md, "La casa del abuelo").
## Any real hit breaks it into shards; every broken one is a fine.

signal broken(at: Vector3)

## Hits above this relative speed break it (proposal: a gentle put-down survives, a 10 cm drop doesn't).
const BREAK_SPEED := 1.5
const FINE := 20
const SHARDS := 5
const SHARD_LIFE := 3.0

@export var shard_color := Color(0.96, 0.95, 0.92)
## A fake one (the cake lab's foam cakes, laboratorio.md): it takes any hit and only bounces.
@export var unbreakable := false

var is_broken := false
var _impacts := ImpactTracker.new()


func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4


## Applies a hit at `speed` m/s. Returns true if it broke now.
func hit(speed: float) -> bool:
	if is_broken or unbreakable or speed <= BREAK_SPEED:
		return false
	is_broken = true
	_shatter()
	broken.emit(global_position)
	queue_free()
	return true


func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	var speed := _impacts.hardest(state)
	if speed > 0.0:
		hit.call_deferred(speed)


## Small pieces that fly a bit and vanish. They only touch the world, so nobody trips on them.
func _shatter() -> void:
	var parent := get_parent()
	if parent == null:
		return
	var material := StandardMaterial3D.new()
	material.albedo_color = shard_color
	var mesh := BoxMesh.new()
	mesh.size = Vector3.ONE * 0.04
	for i in SHARDS:
		var shard := RigidBody3D.new()
		shard.collision_layer = 0
		shard.collision_mask = 1
		shard.mass = 0.02
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = mesh.size
		shape.shape = box
		shard.add_child(shape)
		var look := MeshInstance3D.new()
		look.mesh = mesh
		look.material_override = material
		shard.add_child(look)
		parent.add_child(shard)
		shard.global_position = global_position + Vector3(randf_range(-0.05, 0.05), 0.05, randf_range(-0.05, 0.05))
		shard.linear_velocity = Vector3(randf_range(-1.5, 1.5), randf_range(1.0, 2.5), randf_range(-1.5, 1.5))
		shard.get_tree().create_timer(SHARD_LIFE).timeout.connect(shard.queue_free)
