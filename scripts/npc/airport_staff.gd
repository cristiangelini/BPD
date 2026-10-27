class_name AirportStaff
extends CharacterBody3D

## The airport's staff (politico-aeropuerto.md, step 5, decision 231): the porter Tobías Cargo by the belt's start with
## his hand cart, the check-in clerk by the counter and the gate agent by the gate's desk. The porter works for
## councillor Fina Embrollo (`bought`): E on him shows Embrollo's logo on his keychain (`found_clue("keychain")`); every
## PHONE_EVERY seconds he whispers into his phone, seen by a cop within SEE (`found_clue("phone")`); a cop within
## RIBBON_SEE of his cart sees the spare yellow ribbon on it (`found_clue("ribbon")`). Every TRICK_EVERY seconds, if no
## cop is within WATCH of him and the odd suitcase is lying around (not held, not on the belt, not through the X-ray
## yet), he puts it back on the belt (`tricked`). Cuffed, he's caught and E walks him to the patrol car (OwnerEscort);
## the clerk or the gate agent protest, the cuffs open at once and the case pays for it (`wrongly_cuffed`). Every
## number here is (propuesta).

signal found_clue(kind: String)
signal tricked
signal cuffed_now
signal wrongly_cuffed

const ROLES: Array[String] = ["porter", "clerk", "gate"]
const MODELS := {"porter": preload("res://assets/models/npc_mudancero.glb"),
	"clerk": preload("res://assets/models/npc_recepcionista.glb"), "gate": preload("res://assets/models/npc_empleado.glb")}
const SAY_TIME := 3.0
const PHONE_EVERY := 14.0
const SEE := 4.0
const RIBBON_SEE := 2.0
const TRICK_EVERY := 25.0
const WATCH := 8.0
const TALKS := 3
## His hand cart, beside him (his space, he faces -Z).
const CART_AT := Vector3(0.9, 0, 0)
const LOGO := Color(0.85, 0.2, 0.55)
const RIBBON := Color(0.95, 0.78, 0.29)
const CART := Color(0.35, 0.37, 0.4)

var role := "porter"
var bought := false
var airport: Airport
## A guest's copy (NpcSync): the host's decides.
var follower := false
var clues: Array[String] = []
var _model: Node3D
var _cart: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _cuffed_left := 0.0
var _phone_left := PHONE_EVERY
var _trick_left := TRICK_EVERY
var _talk := 0


func _ready() -> void:
	add_to_group("airport_staff")
	bought = role == "porter"
	collision_layer = 8
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.5
	shape.shape = capsule
	shape.position.y = 0.75
	add_child(shape)
	_model = MODELS[role].instantiate()
	_model.name = "Model"
	# The models face +Z; they face -Z like everyone else.
	_model.rotation.y = PI
	add_child(_model)
	if bought:
		# Embrollo's pink logo on the keychain at his belt (model space), and his cart with the spare ribbon.
		_model.add_child(_box("Keychain", Vector3(0.06, 0.08, 0.02), Vector3(0.24, 0.72, 0.2), LOGO))
		_cart = Node3D.new()
		_cart.name = "Cart"
		_cart.top_level = true
		add_child(_cart)
		_cart.global_transform = global_transform.translated_local(CART_AT)
		_cart.add_child(_box("Base", Vector3(0.6, 0.06, 0.9), Vector3(0, 0.15, 0), CART))
		_cart.add_child(_box("Handle", Vector3(0.6, 0.9, 0.05), Vector3(0, 0.6, 0.45), CART))
		for i in 3:
			var roll := _box("Ribbon%d" % i, Vector3(0.18, 0.18, 0.08), Vector3(-0.18 + i * 0.18, 0.27, -0.15), RIBBON)
			_cart.add_child(roll)
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


func prompt_key(cop: Cop) -> String:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		return escort.prompt_key(cop)
	return "PROMPT_TALK_STAFF"


## E: one of his lines; the porter's keychain is seen.
func use(cop: Cop) -> void:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		escort.use(cop)
		return
	if follower:
		return
	say("AIRPORT_%s_TALK_%d" % [role.to_upper(), _talk % TALKS + 1])
	_talk += 1
	if bought:
		_find("keychain", cop)


func _find(kind: String, cop: Cop) -> void:
	if clues.has(kind):
		return
	clues.append(kind)
	cop.show_hint("HINT_PORTER_%s" % kind.to_upper())
	found_clue.emit(kind)


func cuffed(seconds: float) -> void:
	if follower:
		_cuffed_left = maxf(_cuffed_left, seconds)
		return
	if not bought:
		say("AIRPORT_STAFF_WRONG_CUFF")
		wrongly_cuffed.emit()
		return
	_cuffed_left = maxf(_cuffed_left, seconds)
	say("AIRPORT_PORTER_CUFFED")
	cuffed_now.emit()


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


## Neither cuffed, nor walked to the patrol car, nor in it: still at work.
func loose() -> bool:
	var escort := OwnerEscort.of(self)
	return not is_cuffed() and not (escort and (escort.escorted_by or escort.in_car))


## Embrollo calls him: he whispers into his phone, and a cop close enough sees it.
func whisper() -> void:
	_phone_left = PHONE_EVERY
	say("AIRPORT_PORTER_PHONE")
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if cop.global_position.distance_to(global_position) < SEE:
			_find("phone", cop)


## Whether a cop is close enough to see what he does.
func watched() -> bool:
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if cop.global_position.distance_to(global_position) < WATCH:
			return true
	return false


## The odd suitcase back on the belt, if it's lying around and nobody's looking.
func try_trick() -> bool:
	_trick_left = TRICK_EVERY
	var odd := airport.odd
	if watched() or not odd.visible or odd.is_held() or odd.has_meta("xrayed") or airport.belt.on_belt(odd):
		return false
	airport.belt.put_on(odd)
	say("AIRPORT_PORTER_WHISTLE")
	tricked.emit()
	return true


## What the escort calls (OwnerEscort): a line for `seconds`.
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


## What a guest's copy needs besides where he is and what he says (NpcSync): cuffed.
func net_state() -> Array:
	return [is_cuffed()]


func apply_net_state(state: Variant) -> void:
	_cuffed_left = Handcuffs.SECONDS if state[0] else 0.0


func _physics_process(delta: float) -> void:
	_cuffed_left = maxf(_cuffed_left - delta, 0.0)
	velocity = Vector3(0, 0.0 if is_on_floor() else velocity.y - GameScale.GRAVITY * delta, 0)
	move_and_slide()
	if follower or not bought or not loose() or not airport.belt.running:
		return
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if cop.global_position.distance_to(_cart.global_position) < RIBBON_SEE:
			_find("ribbon", cop)
	_phone_left -= delta
	if _phone_left <= 0.0:
		whisper()
	_trick_left -= delta
	if _trick_left <= 0.0:
		try_trick()


func _process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
