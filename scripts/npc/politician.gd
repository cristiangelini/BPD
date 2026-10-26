class_name Politician
extends CharacterBody3D

## Deputy Pompeyo Lustre (proteccion-politico.md, step 1, decision 103): the annoying politician the cops guard at
## the plaza. He stands at the stage's lectern and gives his speech (PoliticianSpeech says the lines). Each egg or
## tomato that hits him is a stain on his suit (step 2): he complains into the microphone and, with STAINS_MAX of them,
## leaves furious (`furious`; the case is lost, decision 103). Step 5: his walks off the stage to greet the crowd and
## being led back by the hand (PoliticianWalks, "Walks"). Online the host's decides and a guest's follows it (NpcSync,
## net_state: his stains and where his walk is). Every number here is (propuesta).

signal stained(count: int)
signal furious

const MODEL := preload("res://assets/models/npc_politico.glb")
const SAY_TIME := 6.0
const STAINS_MAX := 10
const STAIN_LINES := 6
## The stain left on him: the splat this small, stuck where it hit.
const STAIN_SCALE := 0.35

var stains := 0
## Each stain as [kind, where on him], so a guest's copy wears them in the same places.
var marks: Array = []

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
	_model.name = "Model"
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


func prompt_key(cop: Cop) -> String:
	var walks := PoliticianWalks.of(self)
	if walks:
		return walks.prompt_key(cop)
	# On the bridge, the cops hold him back by the coat (BridgeCoat).
	var coat := get_node_or_null("Coat")
	return coat.prompt_key(cop) if coat else "PROMPT_TALK_POLITICIAN"


## E: he shakes the cop's hand and asks for their vote; off the stage, the cop takes him by the hand (PoliticianWalks).
func use(cop: Cop) -> void:
	var walks := PoliticianWalks.of(self)
	if walks and walks.use(cop):
		return
	var coat := get_node_or_null("Coat")
	if coat and coat.use(cop):
		return
	say("POLITICIAN_HANDSHAKE")


## Off the stage greeting, or being led back.
func off_stage() -> bool:
	var walks := PoliticianWalks.of(self)
	return walks != null and walks.off_stage()


## An egg or a tomato hit him at `at` (world space).
func stain(kind: String, at: Vector3) -> void:
	if stains >= STAINS_MAX:
		return
	stains += 1
	_wear(kind, to_local(at))
	stained.emit(stains)
	if stains >= STAINS_MAX:
		say("POLITICIAN_FURIOUS")
		furious.emit()
	else:
		say("POLITICIAN_STAIN_%d" % ((stains - 1) % STAIN_LINES + 1))


## Stain number `marks.size() + 1`: `kind`'s splat flat against his body where it hit (`local`), facing out from his
## middle.
func _wear(kind: String, local: Vector3) -> void:
	marks.append([kind, local])
	var mark: Node3D = RallyThrowable.SPLATS[kind].instantiate()
	mark.name = "Stain%d" % marks.size()
	add_child(mark)
	var out := Vector3(local.x, 0, local.z)
	if out.length() < 0.01:
		out = Vector3.BACK
	mark.position = Vector3(0, clampf(local.y, 0.3, 1.5), 0) + out.normalized() * 0.38
	mark.basis = Basis(Quaternion(Vector3.UP, out.normalized())).scaled(Vector3.ONE * STAIN_SCALE)


## What a guest's copy needs besides where he is and what he says (NpcSync): his stains and his walk's state.
func net_state() -> Array:
	var walks := PoliticianWalks.of(self)
	return [marks.duplicate(), walks.state if walks else 0]


func apply_net_state(state: Variant) -> void:
	for i in range(marks.size(), (state[0] as Array).size()):
		_wear(state[0][i][0], state[0][i][1])
	stains = marks.size()
	var walks := PoliticianWalks.of(self)
	if walks:
		walks.state = state[1]
		if walks.state != PoliticianWalks.State.LED:
			walks.led_by = null


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
