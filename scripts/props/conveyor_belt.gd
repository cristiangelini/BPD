class_name ConveyorBelt
extends Node3D

## The doll factory's belt that never stops (fabrica.md, "La cinta que no para"): runs from corner to corner, each a
## surface moving at SPEED that carries whatever lies on it, cops included (a StaticBody3D's constant velocity moves
## rigid bodies by friction and is a CharacterBody3D's platform). Its machines mark what goes under them: the eyes
## machine sticks two googly eyes on anything, the hair machine pink hair, the paint machine paints it pink and the
## heads machine bonks cops. Something heavy that reaches a machine jams the belt until someone clears it, and the
## red button stops it. Every number here is (propuesta).

signal stopped(cop: Cop)
signal started
signal jammed(body: Node3D)
signal marked(body: Node3D, machine: String)

const SPEED := 1.0
## Rigid bodies this heavy or more jam a machine.
const JAM_MASS := 8.0
## How long a cop keeps the googly eyes or the pink hair.
const COP_MARK_TIME := 20.0
const RAIL_HEIGHT := 0.06
const MACHINE_DEPTH := 0.6
const MACHINE_HEIGHT := 1.0
const BELT_COLOR := Color(0.18, 0.18, 0.2)
const RAIL_COLOR := Color(0.75, 0.6, 0.2)
const PINK := Color(1.0, 0.45, 0.7)
const MARK_NAMES := {"eyes": "BeltEyes", "hair": "BeltHair", "heads": "BeltHead"}

var running := true
var jammed_by: Node3D
## The runs: each one {"body": StaticBody3D, "dir": Vector3, "riders": Area3D}.
var runs: Array[Dictionary] = []
var top := 0.8
var width := 0.8
var _build: PlaceBuilder
var _paint: StandardMaterial3D


## Builds the runs from corner to corner (on the floor at y = 0 under them), their top at `belt_top`. Each run owns
## the square at its first corner, so things turn there; the last one also covers its end.
func build(corners: Array[Vector3], belt_top: float, belt_width: float) -> void:
	top = belt_top
	width = belt_width
	_build = PlaceBuilder.new(self)
	for i in corners.size() - 1:
		var dir := (corners[i + 1] - corners[i]).normalized()
		var from := corners[i] - dir * width / 2
		var to := corners[i + 1] - dir * width / 2
		if i == corners.size() - 2:
			to = corners[i + 1] + dir * width / 2
		var middle := (from + to) / 2
		var length := from.distance_to(to)
		var along_x := absf(dir.x) > 0.5
		var size := Vector3(length, 0.1, width) if along_x else Vector3(width, 0.1, length)
		var surface := _build.body(Vector3(middle.x, top - 0.05, middle.z))
		_build.shape(surface, size)
		_build.mesh_box(surface.position, size, BELT_COLOR)
		# What lies on the run, to wake it up when the belt starts again (a still body falls asleep).
		var riders := Area3D.new()
		riders.collision_layer = 0
		riders.collision_mask = 4 | 8
		riders.position = Vector3(middle.x, top + 0.25, middle.z)
		var riders_shape := CollisionShape3D.new()
		var riders_box := BoxShape3D.new()
		riders_box.size = Vector3(size.x, 0.5, size.z)
		riders_shape.shape = riders_box
		riders.add_child(riders_shape)
		add_child(riders)
		runs.append({"body": surface, "dir": dir, "riders": riders})
		var side := Vector3(-dir.z, 0, dir.x)
		for s: float in [-1.0, 1.0]:
			var rail_at := Vector3(middle.x, top + RAIL_HEIGHT / 2, middle.z) + side * s * (width / 2 + 0.03)
			var rail_size := Vector3(length, RAIL_HEIGHT, 0.06) if along_x else Vector3(0.06, RAIL_HEIGHT, length)
			_build.mesh_box(rail_at, rail_size, RAIL_COLOR)
		for t: float in [0.0, 0.5, 1.0]:
			var leg := corners[i].lerp(corners[i + 1], t)
			_build.box(Vector3(leg.x, (top - 0.1) / 2, leg.z), Vector3(0.1, top - 0.1, 0.1), Color(0.55, 0.58, 0.62))
	_apply()


## A machine over the belt at `at` (on the floor): what goes under it gets its mark.
func add_machine(id: String, at: Vector3) -> Area3D:
	var area := Area3D.new()
	area.name = "Machine_" + id
	area.collision_layer = 0
	area.collision_mask = 2 | 4 | 8
	area.position = Vector3(at.x, top + MACHINE_HEIGHT / 2, at.z)
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(width, MACHINE_HEIGHT, width)
	shape.shape = box
	area.add_child(shape)
	add_child(area)
	area.body_entered.connect(func(body: Node3D) -> void: _on_machine(id, body))
	return area


func is_moving() -> bool:
	return running and jammed_by == null


## The red button: stops the belt, and a second press starts it again.
func stop(cop: Cop = null) -> void:
	if not running:
		start()
		return
	running = false
	_apply()
	stopped.emit(cop)


func start() -> void:
	if running:
		return
	running = true
	_apply()
	started.emit()


## Clears a jam: whatever got stuck is pushed off the belt and it moves again.
func unjam() -> void:
	if jammed_by == null:
		return
	if is_instance_valid(jammed_by) and jammed_by is RigidBody3D:
		(jammed_by as RigidBody3D).apply_central_impulse(Vector3.UP * 20.0)
	jammed_by = null
	_apply()


func _apply() -> void:
	for run: Dictionary in runs:
		(run.body as StaticBody3D).constant_linear_velocity = run.dir * SPEED if is_moving() else Vector3.ZERO
		if is_moving():
			for body: Node3D in (run.riders as Area3D).get_overlapping_bodies():
				if body is RigidBody3D:
					(body as RigidBody3D).sleeping = false


func _on_machine(id: String, body: Node3D) -> void:
	if body is RigidBody3D and (body as RigidBody3D).mass >= JAM_MASS:
		if jammed_by == null:
			jammed_by = body
			_apply()
			jammed.emit(body)
		return
	if not is_moving():
		return
	if body is Cop:
		_mark_cop(id, body)
	else:
		mark(body, id)


## Leaves the machine's mark on a thing that rode under it (once each).
func mark(body: Node3D, id: String) -> void:
	if id == "paint":
		if body.has_meta("belt_paint"):
			return
		body.set_meta("belt_paint", true)
		for mesh: Node in body.find_children("*", "MeshInstance3D", true, false):
			(mesh as MeshInstance3D).material_overlay = _paint_material()
	else:
		if body.has_node(MARK_NAMES[id]):
			return
		body.add_child(_mark_node(id, Vector3(0, 0.12, 0)))
	marked.emit(body, id)


func _mark_cop(id: String, cop: Cop) -> void:
	if id == "heads":
		cop.stagger(0.6)
		cop.show_hint("HINT_BELT_BONK")
		marked.emit(cop, id)
		return
	if id == "paint":
		cop.show_hint("HINT_BELT_PAINT")
		marked.emit(cop, id)
		return
	if cop.model.has_node(MARK_NAMES[id]):
		return
	var node := _mark_node(id, Vector3(0, 1.42, -0.16) if id == "eyes" else Vector3(0, 1.62, 0))
	cop.model.add_child(node)
	cop.show_hint("HINT_BELT_EYES" if id == "eyes" else "HINT_BELT_HAIR")
	get_tree().create_timer(COP_MARK_TIME).timeout.connect(func() -> void:
		if is_instance_valid(node):
			node.queue_free())
	marked.emit(cop, id)


func _mark_node(id: String, at: Vector3) -> Node3D:
	var node := Node3D.new()
	node.name = MARK_NAMES[id]
	node.position = at
	match id:
		"eyes":
			for s: float in [-1.0, 1.0]:
				_ball(node, Vector3(s * 0.045, 0, 0), 0.035, Color.WHITE)
				_ball(node, Vector3(s * 0.045, -0.01, -0.03), 0.015, Color.BLACK)
		"hair":
			_ball(node, Vector3.ZERO, 0.09, PINK).scale = Vector3(1.2, 0.6, 1.2)
		"heads":
			_ball(node, Vector3(0, 0.05, 0), 0.06, Color(0.98, 0.85, 0.75))
	return node


func _ball(parent: Node3D, at: Vector3, radius: float, color: Color) -> MeshInstance3D:
	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2
	mesh.radial_segments = 8
	mesh.rings = 4
	var instance := MeshInstance3D.new()
	instance.mesh = mesh
	instance.position = at
	instance.material_override = _build.material(color)
	parent.add_child(instance)
	return instance


func _paint_material() -> StandardMaterial3D:
	if _paint == null:
		_paint = StandardMaterial3D.new()
		_paint.albedo_color = Color(PINK, 0.55)
		_paint.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return _paint
