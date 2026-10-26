class_name CityYards
extends Node3D

## The houses' backyards (ciudad-viva.md, step 4): behind each house of the west side, a lawn closed by wooden fences
## between neighbors, against the yards of the next street and beside the house, with a board gate in the side fence.
## Each yard has a grill, a paddling pool, a doghouse or a clothesline. Every fence climbs (Climbable), so a chase on
## foot can cross yard after yard. Only in blocks of houses with no place in them. Every number here is (propuesta).

const FENCE_HEIGHT := 1.8
const FENCE_THICK := 0.1
const GATE_WIDTH := 1.2
const PLANK := Color(0.72, 0.55, 0.36)
const POST := Color(0.5, 0.36, 0.22)
const LAWN := Color(0.4, 0.68, 0.28)
const POOL := Color(0.35, 0.65, 0.95)
const PROPS: Array[String] = ["grill", "pool", "doghouse", "clothesline"]

var _materials := {}
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = 11
	for block in blocks():
		_block(block)


## The blocks that get yards: houses, no plaza, no place.
static func blocks() -> Array[Vector2i]:
	var list: Array[Vector2i] = []
	for row in CityLayout.ROWS:
		for col in CityLayout.COLUMNS:
			var block := Vector2i(col, row)
			if block == CityLayout.PLAZA or CityLayout.barrio_kind(block) != "house":
				continue
			if CityLayout.PLACES.any(func(p: Dictionary) -> bool: return p.block == block):
				continue
			list.append(block)
	return list


## How deep a yard runs behind its house, from the house's back to the middle of the block.
static func yard_depth() -> float:
	return CityLayout.BLOCK / 2 - CityLayout.SIDEWALK - CityLayout.FILLER_SIZE.house.z


## Every fence of a block as [from, to] on the ground, in the world: the middle line, the dividers between yards,
## the two ends, and the stretches beside each house (with the gate's gap).
static func fences(block: Vector2i) -> Array[PackedVector3Array]:
	var c := CityLayout.block_center(block)
	var back := yard_depth()
	var spacing := CityLayout.FILLER_ALONG[1] - CityLayout.FILLER_ALONG[0]
	var reach := CityLayout.FILLER_ALONG[-1] + spacing / 2
	var half_house: float = CityLayout.FILLER_SIZE.house.x / 2
	var lines: Array[PackedVector3Array] = [PackedVector3Array([c + Vector3(-reach, 0, 0), c + Vector3(reach, 0, 0)])]
	for k in CityLayout.FILLER_ALONG.size() + 1:
		var x := CityLayout.FILLER_ALONG[0] - spacing / 2 + k * spacing
		lines.append(PackedVector3Array([c + Vector3(x, 0, -back), c + Vector3(x, 0, back)]))
	for z: float in [-back, back]:
		for along: float in CityLayout.FILLER_ALONG:
			lines.append(PackedVector3Array([c + Vector3(along - spacing / 2, 0, z),
				c + Vector3(along - half_house, 0, z)]))
			lines.append(PackedVector3Array([c + Vector3(along + half_house + GATE_WIDTH, 0, z),
				c + Vector3(along + spacing / 2, 0, z)]))
	return lines


func _block(block: Vector2i) -> void:
	var c := CityLayout.block_center(block)
	var back := yard_depth()
	var spacing := CityLayout.FILLER_ALONG[1] - CityLayout.FILLER_ALONG[0]
	_mesh_box(c + Vector3(0, 0.04, 0), Vector3(spacing * CityLayout.FILLER_ALONG.size(), 0.01, back * 2), LAWN)
	for line in fences(block):
		_fence(line[0], line[1])
	for z: float in [-back / 2, back / 2]:
		for along: float in CityLayout.FILLER_ALONG:
			_prop(PROPS[_rng.randi() % PROPS.size()], c + Vector3(along + _rng.randf_range(-3, 3), 0, z),
				_rng.randf() * TAU)


## A wooden fence from `a` to `b`: one climbable body, planks and posts every 2 m.
func _fence(a: Vector3, b: Vector3) -> void:
	var length := a.distance_to(b)
	var root := Climbable.new()
	root.top = FENCE_HEIGHT
	root.position = (a + b) / 2 + Vector3.UP * FENCE_HEIGHT / 2
	root.rotation.y = atan2(b.x - a.x, b.z - a.z) + PI / 2
	add_child(root)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(length, FENCE_HEIGHT, FENCE_THICK)
	shape.shape = box
	root.add_child(shape)
	_mesh_box(Vector3.ZERO, box.size, PLANK, root)
	for k in floori(length / 2.0) + 1:
		_mesh_box(Vector3(-length / 2 + minf(k * 2.0, length), 0.1, 0), Vector3(0.14, FENCE_HEIGHT + 0.2, 0.16), POST,
			root)


func _prop(kind: String, at: Vector3, turn: float) -> void:
	var root := Node3D.new()
	root.position = at
	root.rotation.y = turn
	add_child(root)
	match kind:
		"grill":
			_mesh_box(Vector3(0, 0.85, 0), Vector3(1.0, 0.25, 0.6), CityLife.IRON, root)
			for x: float in [-0.4, 0.4]:
				_mesh_box(Vector3(x, 0.4, 0), Vector3(0.06, 0.8, 0.5), CityLife.IRON, root)
		"pool":
			var tub := CylinderMesh.new()
			tub.top_radius = 1.6
			tub.bottom_radius = 1.6
			tub.height = 0.5
			_mesh(tub, Vector3(0, 0.25, 0), POOL.darkened(0.3), root)
			var water := CylinderMesh.new()
			water.top_radius = 1.5
			water.bottom_radius = 1.5
			water.height = 0.02
			_mesh(water, Vector3(0, 0.45, 0), POOL, root)
		"doghouse":
			_mesh_box(Vector3(0, 0.45, 0), Vector3(1.0, 0.9, 1.2), Color(0.85, 0.3, 0.25), root)
			var roof := PrismMesh.new()
			roof.size = Vector3(1.2, 0.5, 1.3)
			_mesh(roof, Vector3(0, 1.15, 0), POST, root)
			_mesh_box(Vector3(0, 0.3, 0.61), Vector3(0.45, 0.55, 0.02), Color(0.1, 0.08, 0.06), root)
		"clothesline":
			for x: float in [-2.0, 2.0]:
				_mesh_box(Vector3(x, 0.9, 0), Vector3(0.08, 1.8, 0.08), CityLife.IRON, root)
			_mesh_box(Vector3(0, 1.75, 0), Vector3(4.0, 0.02, 0.02), Color(0.9, 0.9, 0.9), root)
			for k in 4:
				var cloth: Color = [Color(0.9, 0.3, 0.3), Color(0.3, 0.5, 0.9), Color(0.95, 0.85, 0.3),
					Color(0.95, 0.95, 0.95)][k]
				_mesh_box(Vector3(-1.4 + k * 0.9, 1.4, 0), Vector3(0.6, 0.7, 0.02), cloth, root)


func _material(color: Color) -> StandardMaterial3D:
	if not _materials.has(color):
		var material := StandardMaterial3D.new()
		material.albedo_color = color
		material.roughness = 0.9
		_materials[color] = material
	return _materials[color]


func _mesh_box(center: Vector3, size: Vector3, color: Color, parent: Node3D = null) -> void:
	var box := BoxMesh.new()
	box.size = size
	_mesh(box, center, color, parent)


func _mesh(mesh: Mesh, at: Vector3, color: Color, parent: Node3D = null) -> void:
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.material_override = _material(color)
	instance.position = at
	(parent if parent else self).add_child(instance)
