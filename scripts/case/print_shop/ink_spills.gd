class_name InkSpills
extends Node3D

## The print shop's ink on the floor (docs/diseno/allanamiento-imprenta.md, step 3): the puddles a tipped barrel or a
## broken jar leaves, PUDDLE_RADIUS wide, which dry in PUDDLE_TIME seconds; and the footprints of the cops who step in
## them, of the puddle's color, left every STRIDE meters for INKED_TIME seconds after the last step in ink. Everyone
## sees the footprints (they also tell where a partner went). Every number here is (propuesta).

signal spilled(at: Vector3, ink: int)
## A cop stepped in a puddle and starts leaving footprints (again, if they already were).
signal cop_inked(cop: Cop, ink: int)
signal footprint_left(cop: Cop, at: Vector3)

const PUDDLE_RADIUS := 0.75
const PUDDLE_TIME := 30.0
const INKED_TIME := 20.0
const STRIDE := 0.6
const FOOTPRINT_TIME := 40.0
const MAX_FOOTPRINTS := 160

## The puddles on the floor: {"node": MeshInstance3D, "area": Area3D, "ink": int, "left": float}.
var puddles: Array[Dictionary] = []
## The inked cops: Cop -> {"ink": int, "left": float, "last": Vector3}.
var inked := {}
var footprints: Array[Dictionary] = []
var floor_top := 0.06


## Leaves a puddle of INKS[`ink`] centered at `at` (on the floor).
func spill(at: Vector3, ink: int) -> void:
	var mesh := CylinderMesh.new()
	mesh.top_radius = PUDDLE_RADIUS
	mesh.bottom_radius = PUDDLE_RADIUS
	mesh.height = 0.01
	mesh.radial_segments = 14
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.material_override = _ink_material(ink, 0.85)
	node.position = Vector3(at.x, floor_top + 0.006, at.z)
	add_child(node)
	var area := Area3D.new()
	area.collision_layer = 0
	area.collision_mask = 2
	area.position = node.position + Vector3(0, 0.3, 0)
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = PUDDLE_RADIUS
	cylinder.height = 0.6
	shape.shape = cylinder
	area.add_child(shape)
	add_child(area)
	var puddle := {"node": node, "area": area, "ink": ink, "left": PUDDLE_TIME}
	puddles.append(puddle)
	area.body_entered.connect(func(body: Node3D) -> void:
		if body is Cop and puddles.has(puddle):
			step_in(body, ink))
	spilled.emit(at, ink)


## A cop stepped in ink of INKS[`ink`]: footprints for INKED_TIME from now.
func step_in(cop: Cop, ink: int) -> void:
	inked[cop] = {"ink": ink, "left": INKED_TIME, "last": cop.global_position}
	cop_inked.emit(cop, ink)


func is_inked(cop: Cop) -> bool:
	return inked.has(cop)


func _physics_process(delta: float) -> void:
	for puddle: Dictionary in puddles.duplicate():
		puddle.left -= delta
		if puddle.left <= 0.0:
			puddles.erase(puddle)
			(puddle.node as Node).queue_free()
			(puddle.area as Node).queue_free()
			continue
		# Standing in the ink keeps the soles wet.
		for body: Node3D in (puddle.area as Area3D).get_overlapping_bodies():
			if body is Cop and inked.has(body):
				inked[body].left = INKED_TIME
	for cop: Cop in inked.keys():
		if not is_instance_valid(cop):
			inked.erase(cop)
			continue
		var state: Dictionary = inked[cop]
		state.left -= delta
		var last: Vector3 = state.last
		var here := cop.global_position
		if Vector2(here.x - last.x, here.z - last.z).length() >= STRIDE:
			_footprint(cop, here, last, state.ink)
			state.last = here
		if state.left <= 0.0:
			inked.erase(cop)
	for print_left: Dictionary in footprints.duplicate():
		print_left.left -= delta
		if print_left.left <= 0.0:
			footprints.erase(print_left)
			(print_left.node as Node).queue_free()


## A footprint where the cop stands, pointing the way they walked (left and right in turn).
func _footprint(cop: Cop, here: Vector3, last: Vector3, ink: int) -> void:
	if footprints.size() >= MAX_FOOTPRINTS:
		var oldest: Dictionary = footprints.pop_front()
		(oldest.node as Node).queue_free()
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.12, 0.004, 0.26)
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.material_override = _ink_material(ink, 0.9)
	var way := Vector2(here.x - last.x, here.z - last.z).normalized()
	var side := 0.1 if footprints.size() % 2 == 0 else -0.1
	node.position = Vector3(here.x - way.y * side, floor_top + 0.004, here.z + way.x * side)
	node.rotation.y = atan2(way.x, way.y)
	add_child(node)
	footprints.append({"node": node, "left": FOOTPRINT_TIME})
	footprint_left.emit(cop, node.position)


func _ink_material(ink: int, alpha: float) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(PrintingPress.INKS[ink], alpha)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.roughness = 0.2
	return material
