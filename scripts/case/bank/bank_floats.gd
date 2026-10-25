class_name BankFloats
extends StaticBody3D

## The duck floats in the patrol car's trunk for the flooding bank (robo-banco-inundado.md, step 3, decision 125): a
## stack of FLOATS rubber rings with a duck's head. E takes one, worn around the waist (`Cop.duck_float`, one per cop);
## E on a hostage up on the counter puts it on them and they come down to be led out. Built as a child of the car, in
## its frame (the trunk is at -Z). Every number here is (propuesta).

const FLOATS := 4
const YELLOW := Color(1.0, 0.85, 0.15)
const BEAK := Color(1.0, 0.5, 0.1)
## Where the ring sits on whoever wears it, by their height.
const WAIST := 0.78

var left := FLOATS
var _stack: Array[Node3D] = []


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.8, 0.5, 0.8)
	shape.shape = box
	shape.position = Vector3(0, 0.25, 0)
	add_child(shape)
	for i in FLOATS:
		var ring := ring_model(0.32)
		ring.position = Vector3(0, 0.06 + i * 0.11, 0)
		ring.rotation.y = i * 0.7
		add_child(ring)
		_stack.append(ring)


func prompt_key(cop: Cop) -> String:
	if left == 0 or cop.duck_float:
		return ""
	return "PROMPT_TAKE_FLOAT"


## E: one float around this cop's waist (one each).
func use(cop: Cop) -> void:
	if left == 0:
		cop.show_hint("HINT_FLOATS_GONE")
		return
	if cop.duck_float:
		return
	left -= 1
	_stack[left].hide()
	wear(cop, true)
	cop.show_hint("HINT_FLOAT_TAKEN")


## A rubber ring with a duck's head, flat, `radius` across its middle.
static func ring_model(radius: float) -> Node3D:
	var ring := Node3D.new()
	ring.name = "DuckFloat"
	var torus := MeshInstance3D.new()
	var mesh := TorusMesh.new()
	mesh.inner_radius = radius - 0.07
	mesh.outer_radius = radius + 0.07
	torus.mesh = mesh
	torus.material_override = _material(YELLOW)
	ring.add_child(torus)
	var head := MeshInstance3D.new()
	var ball := SphereMesh.new()
	ball.radius = 0.09
	ball.height = 0.18
	head.mesh = ball
	head.material_override = _material(YELLOW)
	head.position = Vector3(0, 0.1, radius)
	ring.add_child(head)
	var beak := MeshInstance3D.new()
	var nose := BoxMesh.new()
	nose.size = Vector3(0.07, 0.03, 0.07)
	beak.mesh = nose
	beak.material_override = _material(BEAK)
	beak.position = Vector3(0, 0.09, radius + 0.1)
	ring.add_child(beak)
	return ring


static func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	return material


## Puts the ring on `who` (a cop or a hostage) around the waist, or takes it off.
static func wear(who: Node3D, on: bool) -> void:
	var worn := who.get_node_or_null("DuckFloat")
	if "duck_float" in who:
		who.set("duck_float", on)
	if on and not worn:
		var ring := ring_model(0.4)
		ring.position = Vector3(0, WAIST, 0)
		who.add_child(ring)
	elif not on and worn:
		worn.queue_free()
		who.remove_child(worn)


func net_state() -> Array:
	return [left]


func apply_net_state(state: Array) -> void:
	left = state[0]
	for i in FLOATS:
		_stack[i].visible = i < left
