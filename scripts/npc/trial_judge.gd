class_name TrialJudge
extends StaticBody3D

## Judge Bermúdez of the fast trial jailbreak (docs/diseno/fuga-juicio.md, step 2): at her bench in the guard room once
## the court sits (TrialGuard.phase "court"). She calls the witnesses, every cop but the lawyer, one at a time in the
## seed's order; the one called takes the stand (TrialStand) and she asks QUESTIONS questions, one for each detail of
## the alibi (TrialAlibi), in the seed's order. On the stand there are three signs (TrialSign) with lookalike answers;
## the witness answers with one. A wrong one is a contradiction, and CONTRADICTIONS of them in a trial is guilty: the
## guard's catch. She runs on the host; the guests follow her (NpcSync). Every number here is (propuesta).

signal guilty

const MODEL := preload("res://assets/models/npc_carcelero.glb")
const QUESTIONS := 3
const CONTRADICTIONS := 3
const BUBBLE_TIME := 5.0
const OK_LINES := 3
const WRONG_LINES := 3
const CALL_LINES := 2
## Seconds she takes to react to an answer before the next question.
const REACT_TIME := 2.0

## The alibi and the cops being judged (the level sets them).
var alibi := {}
var case_seed := 0
## "" (not in court yet), "calling" (a witness to the stand), "asking", "reacting" (to an answer) or "done" (every
## witness heard).
var state := ""
## The witnesses' net ids in the order she calls them, which one she's on and which question.
var witnesses: Array[String] = []
var witness := 0
var question := 0
## The details she asks about, in order, for the witness on the stand.
var order: Array[String] = []
var contradictions := 0
var _react_left := 0.0
## Where the witness stands, facing the signs, in the world (the level sets it).
var stand_spot := Transform3D.IDENTITY
## The last thing she said (a text key) and the answer it's about, if any.
var line := ""
var _bubble: Label3D
var _bubble_left := 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	add_to_group("trial_judges")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.6
	shape.shape = capsule
	shape.position.y = 0.8
	add_child(shape)
	add_child(MODEL.instantiate())
	# A judge's black robe over the guard's model (placeholder).
	var robe := MeshInstance3D.new()
	robe.name = "Robe"
	var cloth := CylinderMesh.new()
	cloth.top_radius = 0.3
	cloth.bottom_radius = 0.4
	cloth.height = 1.25
	robe.mesh = cloth
	var black := StandardMaterial3D.new()
	black.albedo_color = Color(0.08, 0.08, 0.1)
	robe.material_override = black
	robe.position.y = 0.63
	add_child(robe)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.1, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 900.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


## The court sits: she calls the first witness, every cop in `cops` but `lawyer`, in the seed's order.
func open_court(cops: Array, lawyer: Cop) -> void:
	_rng.seed = hash(["trial judge", case_seed, alibi])
	witnesses.clear()
	for cop: Cop in cops:
		if cop != lawyer:
			witnesses.append(cop.net_id())
	for i in witnesses.size():
		var j := _rng.randi_range(i, witnesses.size() - 1)
		var swap := witnesses[i]
		witnesses[i] = witnesses[j]
		witnesses[j] = swap
	witness = 0
	contradictions = 0
	_call_next()


func _call_next() -> void:
	if witness >= witnesses.size():
		state = "done"
		say("TRIAL_JUDGE_DONE")
		return
	state = "calling"
	question = 0
	order = TrialAlibi.DETAILS.duplicate()
	for i in order.size():
		var j := _rng.randi_range(i, order.size() - 1)
		var swap := order[i]
		order[i] = order[j]
		order[j] = swap
	say("TRIAL_JUDGE_CALL_%d" % _rng.randi_range(0, CALL_LINES - 1))


## The witness she's calling or questioning (its net id), "" if none.
func witness_id() -> String:
	return witnesses[witness] if state in ["calling", "asking", "reacting"] and witness < witnesses.size() else ""


func is_witness(cop: Cop) -> bool:
	return cop != null and witness_id() != "" and cop.net_id() == witness_id()


## The detail she's asking about now ("" if she isn't asking).
func asking() -> String:
	return order[question] if state == "asking" and question < order.size() else ""


## The witness she called takes the stand: she asks the first question.
func take_stand(cop: Cop) -> void:
	if state != "calling" or not is_witness(cop):
		return
	cop.warp(stand_spot)
	state = "asking"
	_ask()


func _ask() -> void:
	say("TRIAL_ASK_%s" % asking(), 30.0)


## The witness on the stand answers `key` (a sign's text key): right, the next question; wrong, a contradiction.
func answer(cop: Cop, key: String) -> void:
	if state != "asking" or not is_witness(cop):
		return
	if key == TrialAlibi.answer(alibi, asking()):
		say("TRIAL_JUDGE_OK_%d" % _rng.randi_range(0, OK_LINES - 1))
	else:
		contradictions += 1
		if contradictions >= CONTRADICTIONS:
			state = "done"
			say("TRIAL_JUDGE_GUILTY", 6.0)
			guilty.emit()
			return
		say("TRIAL_JUDGE_WRONG_%d" % _rng.randi_range(0, WRONG_LINES - 1))
	state = "reacting"
	_react_left = REACT_TIME


## After reacting: the next question, or the next witness.
func _next() -> void:
	question += 1
	if question < QUESTIONS and question < order.size():
		state = "asking"
		_ask()
		return
	witness += 1
	_call_next()


## Back to before the court (a catch): she waits for the next trial.
func reset(new_alibi: Dictionary) -> void:
	alibi = new_alibi
	state = ""
	witnesses.clear()
	witness = 0
	question = 0
	contradictions = 0


func say(text: String, seconds := BUBBLE_TIME) -> void:
	line = text
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _physics_process(delta: float) -> void:
	if state == "reacting" and multiplayer.is_server():
		_react_left -= delta
		if _react_left <= 0.0:
			_next()
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()


## Online (NpcSync): where the trial is and what she said.
func net_state() -> Variant:
	return [state, witnesses, witness, question, order, contradictions, line, alibi]


func apply_net_state(state_now: Variant) -> void:
	state = state_now[0]
	witnesses.assign(state_now[1])
	witness = state_now[2]
	question = state_now[3]
	order.assign(state_now[4])
	contradictions = state_now[5]
	alibi = state_now[7]
	if state_now[6] != line:
		say(state_now[6])
