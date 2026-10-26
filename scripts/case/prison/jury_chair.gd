class_name JuryChair
extends StaticBody3D

## One of the 4 chairs at the jury table of the prison's talent show (carcel-talentos.md, step 2), facing the stage:
## E sits a cop on it (looking at the stage, can look around but not walk) and E again stands them up behind it. Its
## origin is on the floor and its -Z faces the stage. Every number here is (propuesta).

const SEAT := Vector2(0.45, 0.45)
const SEAT_HEIGHT := 0.45
const BACK_HEIGHT := 0.5
const STAND_BEHIND := 0.7
const COLOR := Color(0.3, 0.32, 0.36)

var sitter: Cop


func _ready() -> void:
	add_to_group("jury_chairs")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(SEAT.x, SEAT_HEIGHT, SEAT.y)
	shape.shape = box
	shape.position.y = SEAT_HEIGHT / 2
	add_child(shape)
	add_child(CopTool.piece(CopTool.box(Vector3(SEAT.x, 0.05, SEAT.y)), COLOR, Vector3(0, SEAT_HEIGHT, 0)))
	add_child(CopTool.piece(CopTool.box(Vector3(SEAT.x, BACK_HEIGHT, 0.05)), COLOR,
		Vector3(0, SEAT_HEIGHT + BACK_HEIGHT / 2, SEAT.y / 2)))
	for x: float in [-1.0, 1.0]:
		for z: float in [-1.0, 1.0]:
			add_child(CopTool.piece(CopTool.box(Vector3(0.04, SEAT_HEIGHT, 0.04)), COLOR,
				Vector3(x * (SEAT.x / 2 - 0.03), SEAT_HEIGHT / 2, z * (SEAT.y / 2 - 0.03))))


func prompt_key(cop: Cop) -> String:
	if sitter == cop:
		return "PROMPT_JURY_STAND"
	return "" if sitter else "PROMPT_JURY_SIT"


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


func stand_up() -> void:
	if not sitter:
		return
	var cop := sitter
	sitter = null
	cop.seated_in = null
	cop.remove_collision_exception_with(self)
	cop.global_position = global_position + global_basis.z * STAND_BEHIND + Vector3.UP * 0.1


func _physics_process(_delta: float) -> void:
	if not sitter:
		return
	if not is_instance_valid(sitter):
		sitter = null
		return
	sitter.global_position = global_position + Vector3.UP * 0.05
	sitter.velocity = Vector3.ZERO
