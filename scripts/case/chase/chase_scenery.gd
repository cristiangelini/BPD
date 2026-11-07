class_name ChaseScenery
extends RigidBody3D

## A cardboard flat that falls off the back of the theater's scenery truck (escena-teatro.md, "El tablero y el final";
## ChaseDrops): a painted tree or a cloud, standing in the patrol car's way. E (anyone on foot) kicks it over; the
## patrol car going into it fast takes it on the hood, and it covers the windshield for STUCK_SECONDS before it falls
## off. Every number here is (propuesta).

const SIZE := Vector3(1.4, 1.8, 0.08)
const MASS := 2.0
const CARD := Color(0.78, 0.63, 0.44)
## The looks: [part center, part size, color] in the flat's space, painted on its front.
const LOOKS := {
	"tree": [[Vector3(0, 0.55, 0.045), Vector3(0.3, 1.1, 0.01), Color(0.42, 0.29, 0.16)],
		[Vector3(0, 1.3, 0.045), Vector3(1.3, 0.9, 0.01), Color(0.23, 0.55, 0.23)]],
	"cloud": [[Vector3(0, 1.2, 0.045), Vector3(1.3, 0.7, 0.01), Color(0.97, 0.97, 0.99)],
		[Vector3(0, 0.6, 0.045), Vector3(0.1, 1.2, 0.01), Color(0.5, 0.5, 0.55)]],
}
## The patrol car this close to its middle, at this speed or more (m/s), takes it on the hood.
const REACH := 1.8
const HIT_SPEED := 2.0
const STUCK_SECONDS := 1.0
## A kick sends it this hard away from the cop, and a little up.
const KICK := 10.0

## "tree" or "cloud".
var look := "tree"
## The patrol car that can hit it, and the drops that cover its windshield.
var car: Node3D
var drops: ChaseDrops
var stuck := false
var kicked := false
var _car_at := Vector3.INF


func _ready() -> void:
	mass = MASS
	add_to_group("chase_scenery")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	var builder := PlaceBuilder.new(self)
	builder.mesh_box(Vector3(0, SIZE.y / 2, 0), SIZE, CARD)
	for part: Array in LOOKS[look]:
		builder.mesh_box(part[0], part[1], part[2])


func prompt_key(_cop: Cop) -> String:
	return "" if stuck else "PROMPT_KICK_SCENERY"


## E: a kick, away from the cop.
func use(cop: Cop) -> void:
	if stuck:
		return
	kicked = true
	var away := global_position - cop.global_position if cop else Vector3.FORWARD
	away.y = 0
	apply_central_impulse(away.normalized() * KICK + Vector3.UP * KICK * 0.4)
	if cop:
		cop.show_hint("HINT_SCENERY_KICKED")


## The patrol car went into it: on the hood it goes, over the windshield, and a second later it falls off.
func stick() -> void:
	if stuck:
		return
	stuck = true
	freeze = true
	collision_layer = 0
	collision_mask = 0
	if is_instance_valid(drops):
		drops.scenery_left = STUCK_SECONDS
	if is_instance_valid(car):
		reparent(car)
		position = Vector3(0, 0.9, 1.4)
		rotation = Vector3(-0.5, 0, 0)
	get_tree().create_timer(STUCK_SECONDS).timeout.connect(queue_free)


func _physics_process(delta: float) -> void:
	if stuck or not is_instance_valid(car):
		return
	var at := car.global_position
	var speed := 0.0 if _car_at == Vector3.INF else (at - _car_at).length() / delta
	_car_at = at
	var off := at - global_position
	if Vector2(off.x, off.z).length() <= REACH and speed >= HIT_SPEED:
		stick()
