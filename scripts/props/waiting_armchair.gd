class_name WaitingArmchair
extends StaticBody3D

## The waiting armchair of the pet salon (docs/diseno/peluqueria.md, "Su distracción"): a cop with a dog in arms
## sits here with E, and Ramiro tells that dog's whole life while not watching the salon. E again stands up early.

const SEAT_SIZE := Vector3(1.0, 0.2, 0.9)
## The backrest, behind the seat (+Z): the armchair faces -Z.
const BACK_SIZE := Vector3(1.0, 0.6, 0.15)
const BACK_AT := Vector3(0, 0.4, 0.45)
## How far in front of the armchair a cop stands when getting up.
const STAND_AHEAD := 1.0

var groomer: DogGroomer
var sitter: Cop


func _ready() -> void:
	_add_shape(SEAT_SIZE, Vector3.ZERO)
	_add_shape(BACK_SIZE, BACK_AT)


func _add_shape(size: Vector3, at: Vector3) -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = at
	add_child(shape)


func prompt_key(cop: Cop) -> String:
	if sitter == cop:
		return "PROMPT_ARMCHAIR_STAND"
	if sitter:
		return ""
	return "PROMPT_ARMCHAIR_SIT" if _holds_dog(cop) else "PROMPT_ARMCHAIR"


func use(cop: Cop) -> void:
	if sitter == cop:
		stand_up()
		return
	if sitter:
		return
	if not _holds_dog(cop):
		cop.show_hint("HINT_ARMCHAIR_DOG")
		return
	if groomer and groomer.start_dog_story(cop):
		sitter = cop
		cop.seated_in = self
		cop.global_rotation.y = global_rotation.y


## The sitter gets up in front of the armchair, and the story ends.
func stand_up() -> void:
	if not sitter:
		return
	var cop := sitter
	sitter = null
	cop.seated_in = null
	cop.global_position = global_position + global_basis.z * -STAND_AHEAD + Vector3.UP * 0.1
	if groomer:
		groomer.end_dog_story()


func seat_point() -> Vector3:
	return global_position + Vector3.UP * (SEAT_SIZE.y / 2 + 0.05)


func _physics_process(_delta: float) -> void:
	if not sitter:
		return
	if groomer and groomer.listener != sitter:
		stand_up()
		return
	sitter.global_position = seat_point()
	sitter.velocity = Vector3.ZERO


func _holds_dog(cop: Cop) -> bool:
	var held = cop.get_node("Grabber").held
	return is_instance_valid(held) and held.is_in_group("dogs")
