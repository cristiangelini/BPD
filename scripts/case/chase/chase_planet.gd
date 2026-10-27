class_name ChasePlanet
extends RigidBody3D

## An inflatable planet that bounces out of the back of the planetarium's van (escena-planetario.md, "El tablero y el
## final"; ChaseDrops): it rolls and bounces along the street, in the patrol car's way. E (anyone on foot) pops it; the
## patrol car going into it fast sends it flying and is held back for a moment (ChaseDrops.planet_hit). Tinted to its
## planet; Saturn keeps its ring. Every number here is (propuesta).

const MODEL := preload("res://assets/models/chase_planet.glb")
const RADIUS := 0.45
const MASS := 2.0
const BOUNCE := 0.8
## The patrol car this close to its middle, at this speed or more (m/s), hits it.
const REACH := 1.6
const HIT_SPEED := 2.0
## A hit sends it flying this hard, the way the car goes and up.
const KICK := 25.0

## The patrol car that can hit it, and the chase that holds it back.
var car: Node3D
var drops: ChaseDrops
## Its planet (a key of Planetarium.PLANET_COLORS).
var planet := "mars"
var hit := false
var popped := false
var _model: Node3D
var _car_at := Vector3.INF


func _ready() -> void:
	mass = MASS
	add_to_group("chase_planets")
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.bounce = BOUNCE
	var shape := CollisionShape3D.new()
	var ball := SphereShape3D.new()
	ball.radius = RADIUS
	shape.shape = ball
	shape.position.y = RADIUS
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	var paint := StandardMaterial3D.new()
	paint.albedo_color = Planetarium.PLANET_COLORS[planet]
	paint.roughness = 0.35
	for mesh in part("ball").find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = paint
	part("ring").visible = planet == "saturn"


func prompt_key(_cop: Cop) -> String:
	return "" if popped else "PROMPT_POP_PLANET"


## E: popped, it's out of the way.
func use(cop: Cop) -> void:
	if popped:
		return
	popped = true
	if cop:
		cop.show_hint("HINT_PLANET_POPPED")
	queue_free()


## The patrol car went into it: off it flies, and the car is held back.
func knocked(direction: Vector3) -> void:
	if hit:
		return
	hit = true
	direction.y = 0
	apply_central_impulse(direction.normalized() * KICK + Vector3.UP * KICK)
	if is_instance_valid(drops):
		drops.planet_hit()


func _physics_process(delta: float) -> void:
	if hit or popped or not is_instance_valid(car):
		return
	var at := car.global_position
	var moved := Vector3.ZERO if _car_at == Vector3.INF else at - _car_at
	_car_at = at
	var off := at - global_position
	if Vector2(off.x, off.z).length() <= REACH and moved.length() / delta >= HIT_SPEED:
		knocked(moved)


## A part of its model by name (ball, ring, valve).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D
