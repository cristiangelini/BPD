class_name GymReceptionist
extends StaticBody3D

## Lula (docs/diseno/allanamiento-gimnasio.md, "Lula, la recepcionista"), the gym's receptionist and its gossip. She
## spends her break jogging on treadmill 1 and only talks to whoever runs with her: a cop who runs RUN_TIME seconds in a
## row on the treadmill beside hers hears, out of breath, what she saw the profe hide (`clue`, set by the story). Once
## per cop; stopping starts the count over. E on her only gets an invitation to run. Every number here is (propuesta).

## A cop ran with her and she told what she saw: the checklist line, already translated.
signal told(text: String)

const MODEL := preload("res://assets/models/npc_lula.glb")
const RUN_TIME := 5.0
const IDLE_LINES := ["LULA_IDLE_1", "LULA_IDLE_2", "LULA_IDLE_3"]
const IDLE_EVERY := 9.0
const TALK_RANGE := 6.0
## How high and fast she bobs while she jogs.
const JOG := 0.06
const JOG_SPEED := 9.0

## The checklist line for what she saw, and the longer thing she says (both translated, set by the story).
var clue := ""
var clue_speech := ""
## The cops she already talked to, and how long each one has been running beside her.
var listeners := {}
var has_told := false
var _running := {}
var _since_idle := 0.0
var _idle_line := 0
var _beat := 0.0
var _model: Node3D
var _bubble: Label3D


func _ready() -> void:
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.6
	shape.shape = capsule
	shape.position.y = 0.8
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.0, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 10
	_bubble.font_size = 40
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_LULA"


## E on her: she won't stop jogging to chat.
func use(cop: Cop) -> void:
	_say("LULA_AGAIN" if listeners.has(cop) else "LULA_RUN_WITH_ME", 4.0)


## Called every physics frame for each cop: whether `cop` is running on the treadmill beside hers. RUN_TIME seconds in a
## row and she talks to them, once.
func run_beside(cop: Cop, running: bool, delta: float) -> void:
	if listeners.has(cop):
		return
	if not running:
		_running.erase(cop)
		return
	if not _running.has(cop):
		_say("LULA_START", 2.5)
	_running[cop] = _running.get(cop, 0.0) + delta
	if _running[cop] < RUN_TIME:
		return
	_running.erase(cop)
	listeners[cop] = true
	if clue_speech == "":
		_say("LULA_NOTHING", 5.0)
		return
	_say(clue_speech, 8.0)
	if not has_told:
		has_told = true
		told.emit(clue)


## How long `cop` has been running beside her (0 when not).
func run_time(cop: Cop) -> float:
	return _running.get(cop, 0.0)


func _physics_process(delta: float) -> void:
	_beat += delta
	_model.position.y = absf(sin(_beat * JOG_SPEED)) * JOG
	_since_idle += delta
	if _since_idle < IDLE_EVERY:
		return
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Node3D).global_position.distance_to(global_position) <= TALK_RANGE:
			_since_idle = 0.0
			_say(IDLE_LINES[_idle_line % IDLE_LINES.size()])
			_idle_line += 1
			return


func _say(key: String, seconds := 3.0) -> void:
	_since_idle = 0.0
	_bubble.text = key
	_bubble.show()
	var said := key
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if _bubble.text == said:
			_bubble.hide())
