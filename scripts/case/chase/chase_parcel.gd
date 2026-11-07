class_name ChaseParcel
extends RigidBody3D

## A "Frágil" parcel that falls out of the back of the post office's mail van (escena-correo.md, "El tablero y el
## final"; ChaseDrops): it lands in the street, in the patrol car's way. E (anyone on foot) kicks it out of the way; the
## patrol car going into it fast breaks it, and its envelopes cover the windshield for ENVELOPE_SECONDS. Every number
## here is (propuesta).

const SIZE := Vector3(0.6, 0.45, 0.5)
const MASS := 3.0
const CARDBOARD := Color(0.72, 0.55, 0.35)
const TAPE := Color(0.85, 0.75, 0.5)
const RED := Color(0.8, 0.12, 0.12)
## The patrol car this close to its middle, at this speed or more (m/s), breaks it.
const REACH := 1.8
const HIT_SPEED := 2.0
const ENVELOPE_SECONDS := 1.0
## A kick sends it this hard away from the cop, and a little up.
const KICK := 18.0

## The patrol car that can break it, and the drops that cover its windshield.
var car: Node3D
var drops: ChaseDrops
var broken := false
var kicked := false
var _car_at := Vector3.INF


func _ready() -> void:
	mass = MASS
	add_to_group("chase_parcels")
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	var builder := PlaceBuilder.new(self)
	builder.mesh_box(Vector3(0, SIZE.y / 2, 0), SIZE, CARDBOARD)
	builder.mesh_box(Vector3(0, SIZE.y + 0.003, 0), Vector3(0.1, 0.006, SIZE.z + 0.01), TAPE)
	for side: float in [-1.0, 1.0]:
		var label := Label3D.new()
		label.text = "SIGN_FRAGILE"
		label.modulate = RED
		label.pixel_size = 0.004
		label.font_size = 32
		label.position = Vector3(0, SIZE.y / 2, side * (SIZE.z / 2 + 0.005))
		label.rotation.y = 0.0 if side > 0 else PI
		add_child(label)


func prompt_key(_cop: Cop) -> String:
	return "" if broken else "PROMPT_KICK_PARCEL"


## E: a kick, away from the cop.
func use(cop: Cop) -> void:
	if broken:
		return
	kicked = true
	var away := global_position - cop.global_position if cop else Vector3.FORWARD
	away.y = 0
	apply_central_impulse(away.normalized() * KICK + Vector3.UP * KICK * 0.4)
	if cop:
		cop.show_hint("HINT_PARCEL_KICKED")


## The patrol car went into it: it bursts, and the envelopes fly up onto the windshield.
func break_open() -> void:
	if broken:
		return
	broken = true
	if is_instance_valid(drops):
		drops.envelopes_left = ENVELOPE_SECONDS
	queue_free()


func _physics_process(delta: float) -> void:
	if broken or not is_instance_valid(car):
		return
	var at := car.global_position
	var speed := 0.0 if _car_at == Vector3.INF else (at - _car_at).length() / delta
	_car_at = at
	var off := at - global_position
	if Vector2(off.x, off.z).length() <= REACH and speed >= HIT_SPEED:
		break_open()
