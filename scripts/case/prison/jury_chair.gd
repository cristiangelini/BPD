class_name JuryChair
extends StaticBody3D

## One of the 4 chairs at the jury table of the prison's talent show (carcel-talentos.md, step 2), facing the stage:
## E sits a cop on it (looking at the stage, can look around but not walk) and E again stands them up behind it. Its
## origin is on the floor and its -Z faces the stage. Step 3: sat down, R changes the score on its card (1 to 10), and
## when the host asks for the scores the card goes up. Every number here is (propuesta).

const SEAT := Vector2(0.45, 0.45)
const SEAT_HEIGHT := 0.45
const BACK_HEIGHT := 0.5
const STAND_BEHIND := 0.7
const COLOR := Color(0.3, 0.32, 0.36)
const MAX_SCORE := 10
const START_SCORE := 7
## The card on the table in front of the chair, and how high it goes up at the vote.
const CARD_AT := Vector3(0, 0.82, -0.75)
const CARD_UP := 0.5
const CARD_SIZE := Vector2(0.3, 0.22)
const CARD := Color(0.97, 0.97, 0.94)

var sitter: Cop
var score := START_SCORE
var raised := false
var _card: Node3D
var _number: Label3D


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
	_card = Node3D.new()
	_card.name = "Card"
	_card.position = CARD_AT
	add_child(_card)
	_card.add_child(CopTool.piece(CopTool.box(Vector3(CARD_SIZE.x, CARD_SIZE.y, 0.01)), CARD,
		Vector3(0, CARD_SIZE.y / 2, 0)))
	_number = Label3D.new()
	_number.name = "Number"
	_number.font_size = 96
	_number.pixel_size = 0.002
	_number.modulate = Color(0.1, 0.1, 0.1)
	_number.outline_size = 0
	_number.double_sided = true
	_number.position = Vector3(0, CARD_SIZE.y / 2, -0.01)
	_card.add_child(_number)
	_card.visible = false
	_show_score()


func prompt_key(cop: Cop) -> String:
	if sitter == cop:
		return "PROMPT_JURY_SEATED"
	return "" if sitter else "PROMPT_JURY_SIT"


func use(cop: Cop) -> void:
	if sitter == cop:
		stand_up()
		return
	if sitter or cop.seated_in:
		return
	sitter = cop
	_card.visible = true
	cop.seated_in = self
	cop.add_collision_exception_with(self)
	cop.global_rotation.y = global_rotation.y
	cop.global_position = global_position + Vector3.UP * 0.05


func stand_up() -> void:
	if not sitter:
		return
	var cop := sitter
	sitter = null
	set_raised(false)
	_card.visible = false
	cop.seated_in = null
	cop.remove_collision_exception_with(self)
	cop.global_position = global_position + global_basis.z * STAND_BEHIND + Vector3.UP * 0.1


## R sat down: the next score on the card (10 goes back to 1).
func ask(cop: Cop) -> bool:
	if sitter != cop:
		return false
	score = score % MAX_SCORE + 1
	_show_score()
	return true


## The card up in the air (the host asked for the scores) or back on the table.
func set_raised(up: bool) -> void:
	raised = up
	_card.position.y = CARD_AT.y + (CARD_UP if up else 0.0)


func _show_score() -> void:
	_number.text = str(score)


func _physics_process(_delta: float) -> void:
	if not sitter:
		return
	if not is_instance_valid(sitter):
		sitter = null
		return
	sitter.global_position = global_position + Vector3.UP * 0.05
	sitter.velocity = Vector3.ZERO
