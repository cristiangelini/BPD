class_name MansionParrot
extends StaticBody3D

## Don Plumas, the parrot of the drawing room (escena-gato.md, "Las pistas"), on the stand of his cage: the witness.
## He saw who took Duquesa and heard him talk. Given one of his crackers (ParrotCrackers, by the cage), E on him
## repeats the culprit's catchphrase twice, if the witness is one of the case's clues. Shouted at close by, or with
## something thrown near him, he's scared for the whole case and only says "¡Lorito bonito!". Every number here is
## (propuesta).

const MODEL := preload("res://assets/models/parrot.glb")
const SHOUT_REACH := 5.0
## Something flying faster than this, this close to him, scares him.
const THROW_SPEED := 3.0
const THROW_REACH := 0.9

var case: CrimeSceneCase
## He heard the culprit (the witness is one of the case's clues).
var knows := false
var fed := false
var scared := false
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("mansion_parrot")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.3, 0.4, 0.3)
	shape.shape = box
	shape.position.y = 0.2
	add_child(shape)
	add_child(MODEL.instantiate())
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 0.7
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_PARROT"


func use(_cop: Cop) -> void:
	if scared:
		say("PARROT_SCARED")
	elif not fed:
		say("PARROT_PRETTY")
	elif knows and case:
		var tic := tr("NEPHEW_TIC_%d" % case.culprit().tic)
		say("%s %s" % [tic, tic], 5.0)
		case.found("witness")
	else:
		say("PARROT_NOTHING")


## A cracker from the tin: he's happy to talk now.
func feed() -> void:
	fed = true
	say("PARROT_CRACKER")


## A cop shouted: if he was close, it scares him.
func shouted_by(cop: Cop) -> void:
	if cop.global_position.distance_to(global_position) <= SHOUT_REACH:
		scare()


func scare() -> void:
	if scared:
		return
	scared = true
	say("PARROT_SCARED")
	if knows and case:
		case.ruin("witness")


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func say(text: String, seconds := 3.0) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()
	if scared or not case or case.follower:
		return
	if _something_thrown_near():
		scare()


## Something loose (layer 4: props, cats) flying fast close to him.
func _something_thrown_near() -> bool:
	var query := PhysicsShapeQueryParameters3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = THROW_REACH
	query.shape = sphere
	query.transform = global_transform
	query.collision_mask = 4
	for hit in get_world_3d().direct_space_state.intersect_shape(query, 8):
		var body := hit.collider as RigidBody3D
		if body and not (body is Grabbable and (body as Grabbable).is_held()) \
				and body.linear_velocity.length() > THROW_SPEED:
			return true
	return false
