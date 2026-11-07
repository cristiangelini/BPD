class_name MansionVase
extends Grabbable

## One of the eight porcelain vases on their pedestals in the Monedero mansion (escena-gato.md, "Los jarrones"). It
## can be picked up; falling off its pedestal, thrown or dropped hard, it breaks on whatever it hits (`broke`): the
## señora's patience goes down and the vase comes off the salary. Every number here is (propuesta).

signal broke(vase: MansionVase)

const KG := 3.0
const HEIGHT := 0.45
const BLUE := Color(0.3, 0.45, 0.85)
const WHITE := Color(0.96, 0.96, 0.98)
## It breaks hitting something this fast (m/s): falling off its pedestal is enough.
const BREAK_SPEED := 3.0

var broken := false
var _speed := 0.0


func _ready() -> void:
	add_to_group("mansion_vases")
	collision_layer = 4
	collision_mask = 15
	mass = KG
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_hit)
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = 0.13
	cylinder.height = HEIGHT
	shape.shape = cylinder
	shape.position.y = HEIGHT / 2
	add_child(shape)
	var vase := CylinderMesh.new()
	vase.top_radius = 0.1
	vase.bottom_radius = 0.13
	vase.height = HEIGHT
	var builder := PlaceBuilder.new(self)
	builder.mesh(vase, Vector3(0, HEIGHT / 2, 0), BLUE)
	builder.mesh_box(Vector3(0, HEIGHT / 2 + 0.05, 0), Vector3(0.24, 0.08, 0.24), WHITE)


## Smashed: the porcelain on the floor in pieces.
func shatter() -> void:
	if broken:
		return
	broken = true
	release_all()
	for child in get_children():
		if child is MeshInstance3D:
			child.hide()
	collision_layer = 0
	freeze = true
	rotation = Vector3(0, rotation.y, 0)
	# The pieces lie on the floor under where it broke.
	var down := PhysicsRayQueryParameters3D.create(global_position + Vector3.UP * 0.3,
		global_position + Vector3.DOWN * 3.0)
	down.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(down)
	if not hit.is_empty():
		global_position = hit.position
	var shards := PlaceBuilder.new(self)
	var shard := BoxMesh.new()
	shard.size = Vector3(0.08, 0.02, 0.06)
	for i in 6:
		var turn := TAU * i / 6.0
		shards.mesh(shard, Vector3(cos(turn) * 0.2, 0.01, sin(turn) * 0.2), BLUE if i % 2 else WHITE, Vector3(0, turn, 0))
	broke.emit(self)


func _on_hit(_body: Node) -> void:
	if not broken and _speed >= BREAK_SPEED:
		shatter()


func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if not broken:
		_speed = linear_velocity.length()
