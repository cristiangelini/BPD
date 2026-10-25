class_name BankValve
extends StaticBody3D

## The flooding bank's valve (robo-banco-inundado.md, step 2, decision 125): a red wheel on a pipe out of the back
## wall, by the back door. Holding E on it turns it; it takes TURN_TIME seconds for one cop and half for two at once
## (more hands don't fit). Letting go keeps how far it went. Turned all the way, the water stops pouring (`shut`).
## Every number here is (propuesta).

signal shut

const TURN_TIME := 8.0
const HANDS := 2
## A cop turning it walks off past this (m) and lets go.
const REACH := 2.2
## The wheel turns this many times from open to shut.
const TURNS := 3.0
const RED := Color(0.8, 0.12, 0.1)
const PIPE := Color(0.5, 0.52, 0.55)

## The water it stops.
var water: BankWater
## How far it went (0 open, 1 shut).
var turned := 0.0
var is_shut := false
## The cops holding E on it.
var turners: Array[Cop] = []
## A guest's: only shows the host's (apply_net_state).
var follower := false
var _wheel: Node3D


func _ready() -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.7, 0.7, 0.5)
	shape.shape = box
	shape.position = Vector3(0, 1.0, 0.25)
	add_child(shape)
	# The pipe: down the wall from the roof to the wheel, and into the ground.
	var pipe := MeshInstance3D.new()
	var tube := CylinderMesh.new()
	tube.top_radius = 0.08
	tube.bottom_radius = 0.08
	tube.height = 2.6
	pipe.mesh = tube
	pipe.material_override = _material(PIPE)
	pipe.position = Vector3(0, 1.3, 0.1)
	add_child(pipe)
	var stem := MeshInstance3D.new()
	var stem_tube := CylinderMesh.new()
	stem_tube.top_radius = 0.035
	stem_tube.bottom_radius = 0.035
	stem_tube.height = 0.3
	stem.mesh = stem_tube
	stem.material_override = _material(PIPE)
	stem.rotation.x = PI / 2
	stem.position = Vector3(0, 1.0, 0.25)
	add_child(stem)
	_wheel = Node3D.new()
	_wheel.name = "Wheel"
	_wheel.position = Vector3(0, 1.0, 0.4)
	add_child(_wheel)
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 0.22
	torus.outer_radius = 0.28
	ring.mesh = torus
	ring.material_override = _material(RED)
	ring.rotation.x = PI / 2
	_wheel.add_child(ring)
	for i in 2:
		var spoke := MeshInstance3D.new()
		var bar := BoxMesh.new()
		bar.size = Vector3(0.5, 0.04, 0.04)
		spoke.mesh = bar
		spoke.material_override = _material(RED)
		spoke.rotation.z = i * PI / 2
		_wheel.add_child(spoke)


func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	return material


func prompt_key(_cop: Cop) -> String:
	return "" if is_shut else "PROMPT_TURN_VALVE"


## E pressed: this cop puts their hands on the wheel until they let go of E (end_turn).
func use(cop: Cop) -> void:
	if is_shut:
		cop.show_hint("HINT_VALVE_SHUT")
		return
	if turners.has(cop):
		return
	if turners.size() >= HANDS:
		cop.show_hint("HINT_VALVE_FULL")
		return
	turners.append(cop)
	cop.turning = self
	cop.show_hint("HINT_VALVE_TURN")


## E let go (or walked off): this cop's hands are off the wheel.
func end_turn(cop: Cop) -> void:
	turners.erase(cop)
	if is_instance_valid(cop) and cop.turning == self:
		cop.turning = null


func _physics_process(delta: float) -> void:
	if follower or is_shut:
		return
	for cop in turners.duplicate():
		if not is_instance_valid(cop) or cop.turning != self \
				or cop.global_position.distance_to(_wheel.global_position) > REACH:
			end_turn(cop)
	if turners.is_empty():
		return
	turned = minf(turned + delta * turners.size() / TURN_TIME, 1.0)
	_show()
	if turned >= 1.0:
		_shut()


func _shut() -> void:
	is_shut = true
	for cop in turners.duplicate():
		end_turn(cop)
		cop.show_hint("HINT_VALVE_SHUT")
	if water:
		water.shut_off()
	shut.emit()


func _show() -> void:
	if _wheel:
		_wheel.rotation.z = -turned * TURNS * TAU


func net_state() -> Array:
	return [turned, is_shut]


func apply_net_state(state: Array) -> void:
	turned = state[0]
	is_shut = state[1]
	_show()
