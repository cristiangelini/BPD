class_name TvTechnician
extends CharacterBody3D

## One of the 3 technicians at the control room's console (politico-debate.md, step 5, decision 230); the seed picks
## which one Malvón bought (`bought`). Each has a coffee cup by his place on the console: the bought one's has Malvón's
## purple logo, seen when a cop talks to him (E, `found_clue("cup")`). Every PHONE_EVERY seconds the bought one gets a
## message and smiles at his phone; a cop within SEE of him sees it (`found_clue("phone")`). The third clue, the
## warning light lit at his place, is the case's (DebateCase). Cuffed, the bought one is caught and E walks him to the
## patrol car (OwnerEscort); an honest one protests, the cuffs open at once and the case pays for it
## (`wrongly_cuffed`). Every number here is (propuesta).

signal found_clue(kind: String)
signal cuffed_now
signal wrongly_cuffed

const MODELS: Array[PackedScene] = [preload("res://assets/models/npc_tecnico.glb"),
	preload("res://assets/models/npc_tecnica.glb"), preload("res://assets/models/npc_tecnico_b.glb")]
const SAY_TIME := 3.0
const PHONE_EVERY := 12.0
const PHONE_TIME := 3.0
const SEE := 4.0
const TALKS := 3
## The cup on the console in front of him, in his space (he faces -Z).
const CUP_AT := Vector3(0.25, 0.92, -0.75)
const CUP := Color(0.95, 0.95, 0.92)
const LOGO := Color(0.48, 0.23, 0.6)
const PHONE := Color(0.1, 0.1, 0.12)

## Which of the 3 he is (his model, his name and his lines).
var index := 0
var bought := false
## A guest's copy (NpcSync): the host's decides.
var follower := false
var clues: Array[String] = []
var _model: Node3D
var _phone: MeshInstance3D
var _bubble: Label3D
var _bubble_left := 0.0
var _cuffed_left := 0.0
var _phone_left := PHONE_EVERY
var _talk := 0


func _ready() -> void:
	add_to_group("tv_technicians")
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.5
	shape.shape = capsule
	shape.position.y = 0.75
	add_child(shape)
	_model = MODELS[index].instantiate()
	_model.name = "Model"
	_model.rotation.y = PI
	add_child(_model)
	# The cup stays on the console when he's walked away.
	var cup := _box("Cup", Vector3(0.09, 0.12, 0.09), Vector3.ZERO, CUP)
	cup.top_level = true
	add_child(cup)
	cup.global_transform = global_transform.translated_local(CUP_AT)
	if bought:
		cup.add_child(_box("Logo", Vector3(0.06, 0.06, 0.01), Vector3(0, 0, 0.046), LOGO))
	_phone = _box("Phone", Vector3(0.08, 0.14, 0.015), Vector3(0.15, 1.2, -0.3), PHONE)
	_phone.hide()
	add_child(_phone)
	_bubble = MarketShopper.make_bubble()
	add_child(_bubble)


func _box(node_name: String, size: Vector3, at: Vector3, color: Color) -> MeshInstance3D:
	var box := MeshInstance3D.new()
	box.name = node_name
	var mesh := BoxMesh.new()
	mesh.size = size
	box.mesh = mesh
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	box.material_override = material
	box.position = at
	return box


## His model's name without "npc_": tecnico, tecnica or tecnico_b.
func look() -> String:
	return MODELS[index].resource_path.get_file().get_basename().trim_prefix("npc_")


func prompt_key(cop: Cop) -> String:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		return escort.prompt_key(cop)
	return "PROMPT_TALK_TECHNICIAN"


## E: one of his lines, and a look at his cup.
func use(cop: Cop) -> void:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		escort.use(cop)
		return
	if follower:
		return
	say("TV_TECH_%d_TALK_%d" % [index + 1, _talk % TALKS + 1])
	_talk += 1
	if bought:
		_find("cup", cop)


func _find(kind: String, cop: Cop) -> void:
	if clues.has(kind):
		return
	clues.append(kind)
	cop.show_hint("HINT_TECH_%s" % kind.to_upper())
	found_clue.emit(kind)


## The light warning of a trick lit at his place while `cop` was in the control room (DebateCase).
func light_seen(cop: Cop) -> void:
	if bought:
		_find("light", cop)


func cuffed(seconds: float) -> void:
	if follower:
		_cuffed_left = maxf(_cuffed_left, seconds)
		return
	if not bought:
		say("TV_TECH_WRONG_CUFF")
		wrongly_cuffed.emit()
		return
	_cuffed_left = maxf(_cuffed_left, seconds)
	say("TV_TECH_CUFFED")
	cuffed_now.emit()


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


## Neither cuffed, nor walked to the patrol car, nor in it: still at the console.
func loose() -> bool:
	var escort := OwnerEscort.of(self)
	return not is_cuffed() and not (escort and (escort.escorted_by or escort.in_car))


## A message from Malvón's campaign: he smiles at his phone, and a cop close enough sees it.
func check_phone() -> void:
	_phone_left = PHONE_EVERY
	_phone.show()
	get_tree().create_timer(PHONE_TIME).timeout.connect(_phone.hide)
	say("TV_TECH_PHONE")
	for cop: Node in get_tree().get_nodes_in_group("cops"):
		if (cop as Node3D).global_position.distance_to(global_position) < SEE:
			_find("phone", cop as Cop)
			return


## What the escort calls (OwnerEscort).
func _say(key: String, seconds := SAY_TIME) -> void:
	say(key)
	_bubble_left = seconds


func _raise(_points: float) -> void:
	pass


func say(key: String) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = SAY_TIME


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func net_state() -> Array:
	return [is_cuffed()]


func apply_net_state(state: Variant) -> void:
	_cuffed_left = Handcuffs.SECONDS if state[0] else 0.0


func _physics_process(delta: float) -> void:
	_cuffed_left = maxf(_cuffed_left - delta, 0.0)
	velocity = Vector3(0, 0.0 if is_on_floor() else velocity.y - GameScale.GRAVITY * delta, 0)
	move_and_slide()
	if follower or not bought or not loose():
		return
	_phone_left -= delta
	if _phone_left <= 0.0:
		check_phone()


func _process(delta: float) -> void:
	var escort := OwnerEscort.of(self)
	_model.rotation.y = 0.0 if escort and (escort.escorted_by or escort.in_car) else PI
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
