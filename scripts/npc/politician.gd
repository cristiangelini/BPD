class_name Politician
extends CharacterBody3D

## Deputy Pompeyo Lustre (proteccion-politico.md, step 1, decision 103): the annoying politician the cops guard at
## the plaza. He stands at the stage's lectern and gives his speech (PoliticianSpeech says the lines). Each egg or
## tomato that hits him is a stain on his suit (step 2): he complains into the microphone and, with STAINS_MAX of them,
## leaves furious (`furious`; the case is lost, decision 103). Later steps add his walks off the stage. Every number
## here is (propuesta).

signal stained(count: int)
signal furious

const MODEL := preload("res://assets/models/npc_politico.glb")
const SAY_TIME := 6.0
const STAINS_MAX := 10
const STAIN_LINES := 6
## The stain left on him: the splat this small, stuck where it hit.
const STAIN_SCALE := 0.35

var stains := 0

var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("politicians")
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.6
	shape.shape = capsule
	shape.position.y = 0.8
	add_child(shape)
	_model = MODEL.instantiate()
	# The models face +Z; he faces -Z like everyone else.
	_model.rotation.y = PI
	add_child(_model)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.9, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.006
	_bubble.outline_size = 8
	_bubble.font_size = 40
	_bubble.width = 1000.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.modulate = Color(1, 0.95, 0.7)
	_bubble.hide()
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TALK_POLITICIAN"


## E: he shakes the cop's hand and asks for their vote.
func use(_cop: Cop) -> void:
	say("POLITICIAN_HANDSHAKE")


## An egg or a tomato hit him at `at` (world space).
func stain(kind: String, at: Vector3) -> void:
	if stains >= STAINS_MAX:
		return
	stains += 1
	var mark: Node3D = RallyThrowable.SPLATS[kind].instantiate()
	mark.name = "Stain%d" % stains
	add_child(mark)
	# Flat against his body where it hit, facing out from his middle.
	var local := to_local(at)
	var out := Vector3(local.x, 0, local.z)
	if out.length() < 0.01:
		out = Vector3.BACK
	mark.position = Vector3(0, clampf(local.y, 0.3, 1.5), 0) + out.normalized() * 0.38
	mark.basis = Basis(Quaternion(Vector3.UP, out.normalized())).scaled(Vector3.ONE * STAIN_SCALE)
	stained.emit(stains)
	if stains >= STAINS_MAX:
		say("POLITICIAN_FURIOUS")
		furious.emit()
	else:
		say("POLITICIAN_STAIN_%d" % ((stains - 1) % STAIN_LINES + 1))


func say(key: String, seconds := SAY_TIME) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = seconds


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
