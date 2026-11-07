class_name CinemaSideSeat
extends StaticBody3D

## The seat next to Chicho in the "Cine Butaca Floja" (docs/diseno/allanamiento-cine.md, "Chicho"): E sits a cop in it,
## looking at the screen (can look around but not walk), and E again stands them up in the row behind. It takes the
## place of that seat's own body, with the same shape. Its origin is on the floor and its -Z faces the screen. Every
## number here is (propuesta).

signal sat(cop: Cop)
signal stood(cop: Cop)

const STAND_BEHIND := 0.7

var sitter: Cop


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(Cinema.SEAT_SIZE.x, Cinema.SEAT_SIZE.y - Cinema.SEAT_UNDER, Cinema.SEAT_SIZE.z)
	shape.shape = box
	shape.position.y = Cinema.SEAT_UNDER + box.size.y / 2
	add_child(shape)


func prompt_key(cop: Cop) -> String:
	if sitter == cop:
		return "PROMPT_JURY_STAND"
	return "" if sitter else "PROMPT_CINEMA_SIT"


func use(cop: Cop) -> void:
	if sitter == cop:
		stand_up()
		return
	if sitter or cop.seated_in:
		return
	sitter = cop
	cop.seated_in = self
	cop.add_collision_exception_with(self)
	cop.global_rotation.y = global_rotation.y
	cop.global_position = global_position + Vector3.UP * 0.05
	sat.emit(cop)


func stand_up() -> void:
	if not sitter:
		return
	var cop := sitter
	sitter = null
	cop.seated_in = null
	cop.remove_collision_exception_with(self)
	cop.global_position = global_position + global_basis.z * STAND_BEHIND + Vector3.UP * 0.3
	stood.emit(cop)


func _physics_process(_delta: float) -> void:
	if not sitter:
		return
	if not is_instance_valid(sitter):
		sitter = null
		return
	sitter.global_position = global_position + Vector3.UP * 0.05
	sitter.velocity = Vector3.ZERO
