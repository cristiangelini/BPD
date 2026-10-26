class_name DoubleTells
extends RefCounted

## The ten small things that tell deputy Lustre from his double (politico-doble.md, step 1, decision 220): each one
## has the real deputy's look and the double's. The seed draws COUNT of them for the double; on the rest he looks just
## like the real one. They're built bigger than life (SCALE), like the hecklers' dirty hands, so they can be told apart
## from 3 or 4 m. The planilla's file lists how each one is on the real deputy. Every number here is (propuesta).

const TELLS: Array[String] = ["watch", "socks", "pin", "mustache", "bandaid", "tie", "part", "shoes", "glasses",
	"coffee"]
const COUNT := 3
const SCALE := 1.5

const GOLD := Color(0.92, 0.75, 0.25)
const GREY := Color(0.55, 0.55, 0.58)
const RED := Color(0.85, 0.15, 0.15)
const GREEN := Color(0.16, 0.55, 0.3)
const BLOND := Color(0.85, 0.66, 0.3)
const DARK := Color(0.15, 0.12, 0.1)
const WHITE := Color(0.97, 0.97, 0.95)
const SKIN_PINK := Color(0.95, 0.75, 0.62)
const BROWN := Color(0.45, 0.28, 0.14)
const COFFEE := Color(0.4, 0.25, 0.12)


## The COUNT tells the double gets with this seed.
static func draw(case_seed: int) -> Array[String]:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["double tells", case_seed])
	var left := TELLS.duplicate()
	var drawn: Array[String] = []
	for i in COUNT:
		drawn.append(left.pop_at(rng.randi_range(0, left.size() - 1)))
	return drawn


## The planilla's line for `tell`: how it is on the real deputy.
static func file_key(tell: String) -> String:
	return "DOUBLE_FILE_%s" % tell.to_upper()


## Puts the ten tells on `model` (the politician's model, facing +Z): the double's look for the ones in `fakes`, the
## real deputy's for the rest. Each one is a node named after it, under "Tells".
static func dress(model: Node3D, fakes: Array[String]) -> Node3D:
	var tells := Node3D.new()
	tells.name = "Tells"
	model.add_child(tells)
	for tell in TELLS:
		var node := Node3D.new()
		node.name = tell
		tells.add_child(node)
		_build(node, tell, fakes.has(tell))
	return tells


static func _build(node: Node3D, tell: String, fake: bool) -> void:
	match tell:
		"watch":
			# On his left wrist (+X); the double wears it on the right.
			var side := -1.0 if fake else 1.0
			_add(node, _cylinder(0.085, 0.03), Vector3(side * 0.46, 0.7, 0.08), GOLD, Vector3(0, 0, PI / 2))
		"socks":
			for side: float in [-1.0, 1.0]:
				_add(node, _cylinder(0.09, 0.08), Vector3(side * 0.2, 0.16, 0.1), RED if fake else GREY)
		"pin":
			# The party's star on his left lapel; the double's points down.
			_add(node, _cone(0.05, 0.08), Vector3(0.14, 0.98, 0.29), GREEN, Vector3(PI if fake else 0.0, 0, 0))
		"mustache":
			_add(node, _box(Vector3(0.16, 0.03, 0.03)), Vector3(0, 1.21, 0.21), BLOND,
				Vector3(0, 0, 0.35 if fake else 0.0))
		"bandaid":
			if fake:
				_add(node, _box(Vector3(0.09, 0.03, 0.05)), Vector3(-0.49, 0.67, 0.15), SKIN_PINK.lightened(0.2))
		"tie":
			# Stripes down the tie; the double's has dots.
			for i in 3:
				var at := Vector3(0, 0.98 - i * 0.07, 0.315 + i * 0.025)
				if fake:
					_add(node, _sphere(0.018), at, WHITE)
				else:
					_add(node, _box(Vector3(0.06, 0.012, 0.01)), at, WHITE, Vector3(0.35, 0, 0.5))
		"part":
			# The parting on his left; the double's on the right.
			_add(node, _box(Vector3(0.02, 0.02, 0.22)), Vector3(-0.08 if fake else 0.08, 1.52, 0.03), DARK)
		"shoes":
			if fake:
				_add(node, _sphere(0.1), Vector3(-0.2, 0.08, 0.13), BROWN, Vector3.ZERO, Vector3(1.5, 0.85, 2.0))
		"glasses":
			if fake:
				_add(node, _box(Vector3(0.14, 0.05, 0.02)), Vector3(-0.15, 0.97, 0.27), DARK)
			else:
				for side: float in [-1.0, 1.0]:
					_add(node, _torus(0.05), Vector3(side * 0.08, 1.33, 0.22), DARK, Vector3(PI / 2, 0, 0))
				_add(node, _box(Vector3(0.06, 0.012, 0.012)), Vector3(0, 1.34, 0.22), DARK)
		"coffee":
			if fake:
				_add(node, _cylinder(0.07, 0.01), Vector3(-0.12, 0.84, 0.33), COFFEE, Vector3(PI / 2 - 0.4, 0, 0))


static func _add(node: Node3D, mesh: Mesh, at: Vector3, color: Color, rot := Vector3.ZERO,
		scale := Vector3.ONE) -> void:
	var part := MeshInstance3D.new()
	part.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	part.material_override = material
	part.position = at
	part.rotation = rot
	part.scale = scale * SCALE
	node.add_child(part)


static func _cylinder(radius: float, height: float) -> CylinderMesh:
	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 10
	return mesh


static func _cone(radius: float, height: float) -> CylinderMesh:
	var mesh := _cylinder(radius, height)
	mesh.top_radius = 0.0
	mesh.radial_segments = 5
	return mesh


static func _box(size: Vector3) -> BoxMesh:
	var mesh := BoxMesh.new()
	mesh.size = size
	return mesh


static func _sphere(radius: float) -> SphereMesh:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = 2 * radius
	mesh.radial_segments = 8
	mesh.rings = 4
	return mesh


static func _torus(radius: float) -> TorusMesh:
	var mesh := TorusMesh.new()
	mesh.inner_radius = (radius - 0.012)
	mesh.outer_radius = radius
	mesh.rings = 10
	mesh.ring_segments = 4
	return mesh
