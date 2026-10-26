class_name SchoolPupil
extends StaticBody3D

## A pupil of the Los Girasoles school (politico-escuela.md, step 2, decision 210): a child in a white smock with a
## backpack, sitting at a desk of the classroom, one of four looks. E on them: something a child says, a different line
## each time. Step 3: they walk out to the playground for recess, back to their desk and out front for the photo
## (`walk`, along the corners the school gives). Step 4: each holds a card with the question for the deputy, which a
## cop reads within READ_REACH; in the questions they put their hand up (`raise_hand`, waving it if the card is a trap)
## and read it out when he picks them. Step 5: E takes the card into the cop's hands (SchoolCard); an innocent pupil
## at their desk says it was theirs and cries until a cop gives them a candy, and after CRY_TIME crying it counts
## against the pay (`cried`). A trap's pupil tells who gave it to them. E with a card on a pupil with none gives it
## back. Step 8, online: the host's pupil decides and a guest's copy follows it (NpcSync): the card, the hand, the
## crying; a card or a candy spawned on the host reaches the guest through PropSync and its holder's hands are told.
## Every number here is (propuesta).

const MODELS: Array[PackedScene] = [
	preload("res://assets/models/npc_alumno.glb"), preload("res://assets/models/npc_alumna.glb"),
	preload("res://assets/models/npc_alumno_b.glb"), preload("res://assets/models/npc_alumna_b.glb"),
]
## The pear body is a grown-up's: a child is this much of it (about 1 m).
const KID_SCALE := 0.62
const LINES := 8
const SAY_TIME := 4.0
const SPEED := 1.4
const ARRIVED := 0.1
## A cop this close reads what the card says.
const READ_REACH := 2.0
const READ_TIME := 6.0
## Crying this long without a candy, it counts (the teacher notices).
const CRY_TIME := 10.0
const SOB_EVERY := 2.5
const TRAP_TELLS := 3
const SMOCK := Color(0.96, 0.96, 0.95)
const CARD := Color(1.0, 0.98, 0.9)

## Their card went to a cop's hands.
signal card_taken(pupil: SchoolPupil, was_trap: bool)
## They cried CRY_TIME without a candy: it counts against the pay.
signal cried(pupil: SchoolPupil)

## Which of the four looks (0 to 3) and which desk (0 to 19, row by row from the front).
@export var look := 0
var desk := 0
## Which line comes next (the school draws a different start for each).
var next_line := 0
## Where they're walking (world space, corner by corner), after `_wait_left` seconds, and which way to face at the end.
var _path: Array[Vector3] = []
var _wait_left := 0.0
var _face_at_end := Vector3.ZERO
var _bubble: Label3D
var _bubble_left := 0.0
## The text key of their card ("" with none) and whether the janitor's (a question that sinks the deputy).
var card := ""
var trap := false
var hand_up := false
var _arm: Node3D
var _card_text: CloseLabel
var _wave := 0.0
## Violet paint on their fingers, which a cop up close can take for the janitor's ink (step 6).
var stained := false
var crying := false
## A guest's copy (NpcSync): the host's decides what happens.
var follower := false
## Seconds crying, and whether it already counted.
var cry_for := 0.0
var cry_counted := false
var _sob_left := 0.0


func _ready() -> void:
	add_to_group("school_pupils")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.3
	capsule.height = 1.0
	shape.shape = capsule
	shape.position.y = 0.5
	add_child(shape)
	var model: Node3D = MODELS[look % MODELS.size()].instantiate()
	model.name = "Model"
	# The models face +Z; the pupil faces -Z like everyone else.
	model.rotation.y = PI
	model.scale = Vector3.ONE * KID_SCALE
	add_child(model)
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 1.3
	add_child(_bubble)
	_build_arm()


func prompt_key(cop: Cop) -> String:
	var held: Grabbable = cop.get_node("Grabber").held
	if held is SchoolCandy and crying:
		return "PROMPT_GIVE_CANDY"
	if held is SchoolCard and not has_card():
		return "PROMPT_GIVE_CARD"
	if held != null:
		return "PROMPT_HOLDING"
	return "PROMPT_TAKE_CARD" if has_card() else "PROMPT_TALK_PUPIL"


## E on them; `how` "point" is a cop by the deputy pointing at them from afar (SchoolQuestions.try_point).
func use(cop: Cop, how := "") -> void:
	if follower:
		return
	if how == "point":
		(get_parent() as SchoolVisitLevel).questions.point_from(cop, self)
		return
	var grabber: Grabber = cop.get_node("Grabber")
	var held := grabber.held
	if held is SchoolCandy and crying:
		grabber.release()
		held.queue_free()
		tell_hands(cop)
		calm()
		return
	if held is SchoolCard and not has_card():
		grabber.release()
		var given := held as SchoolCard
		hold_card(given.key, given.trap)
		held.queue_free()
		tell_hands(cop)
		calm()
		return
	if held == null and has_card():
		_give_card(cop)
		return
	say("PUPIL_%d" % (next_line % LINES))
	next_line += 1


## Stops crying (a candy, or their card back).
func calm() -> void:
	if not crying:
		return
	crying = false
	say("PUPIL_THANKS")


## The card goes into the cop's hands; an innocent pupil sitting at their desk cries over it.
func _give_card(cop: Cop) -> void:
	var was_trap := trap
	var card_node := SchoolCard.make(card, trap)
	cop.get_parent().add_child(card_node)
	card_node.global_position = cop.camera.global_position - cop.camera.global_basis.z * 0.6
	cop.get_node("Grabber").grab(card_node)
	tell_hands(cop)
	var seated := not walking()
	hold_card("")
	card_taken.emit(self, was_trap)
	if was_trap:
		say("PUPIL_TRAP_TOLD_%d" % (desk % TRAP_TELLS))
	elif seated:
		crying = true
		cry_for = 0.0
		_sob_left = SOB_EVERY
		say("PUPIL_MINE", SOB_EVERY)


## Online, the host put something in (or took it out of) a guest's cop's hands: its owner is told.
static func tell_hands(cop: Cop) -> void:
	if cop.sync and not cop.sync.is_multiplayer_authority():
		cop.sync.tell_held()


## What a guest's copy needs besides where they are and what they say (NpcSync): the card, the hand and the crying.
func net_state() -> Array:
	return [card, trap, hand_up, crying]


func apply_net_state(state: Variant) -> void:
	if state[0] != card or state[1] != trap:
		hold_card(state[0], state[1])
	if state[2] != hand_up:
		raise_hand(state[2])
	crying = state[3]


## Walks through `points` (world space) after `delay` seconds and ends up looking along `facing` (or wherever the last
## stretch went, with none).
func walk(points: Array[Vector3], delay := 0.0, facing := Vector3.ZERO) -> void:
	_path = points.duplicate()
	_wait_left = delay
	_face_at_end = facing


func walking() -> bool:
	return not _path.is_empty()


func _physics_process(delta: float) -> void:
	if _path.is_empty():
		return
	if _wait_left > 0.0:
		_wait_left -= delta
		return
	var to := _path[0] - global_position
	to.y = 0.0
	var step := SPEED * delta
	if to.length() <= maxf(step, ARRIVED):
		global_position = Vector3(_path[0].x, global_position.y, _path[0].z)
		_path.remove_at(0)
		if _path.is_empty() and _face_at_end.length() > 0.01:
			look_at(global_position + _face_at_end, Vector3.UP)
		return
	look_at(global_position + to, Vector3.UP)
	global_position += to.normalized() * step


## Gives them a card: its text key and whether it's a trap. "" takes it away.
func hold_card(key: String, is_trap := false) -> void:
	card = key
	trap = is_trap and key != ""
	_card_text.text = key
	_card_text.shown = key != ""
	_arm.get_node("Card").visible = key != ""
	if key == "":
		raise_hand(false)


func has_card() -> bool:
	return card != ""


## Up only with a card and at their desk; a trap's is waved about.
func raise_hand(up: bool) -> void:
	hand_up = up and has_card() and not walking()
	_arm.rotation.x = 0.0 if hand_up else -PI * 0.45
	_arm.rotation.z = 0.0


## Reads the card out loud (the deputy gave them the floor).
func read_card() -> void:
	say(card, READ_TIME)


## Whether a cop is near enough to read the card.
func card_shown() -> bool:
	return _card_text.visible


func say(key: String, seconds := SAY_TIME) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = seconds


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _process(delta: float) -> void:
	if hand_up and trap:
		_wave += delta * 9.0
		_arm.rotation.z = sin(_wave) * 0.35
	if crying:
		_cry(delta)
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()


func _cry(delta: float) -> void:
	cry_for += delta
	_sob_left -= delta
	if _sob_left <= 0.0:
		_sob_left = SOB_EVERY
		say("PUPIL_CRY", SOB_EVERY)
	if cry_for >= CRY_TIME and not cry_counted:
		cry_counted = true
		cried.emit(self)



## A right arm in the smock's white that goes up with the card in its hand, and the card's text over it.
func _build_arm() -> void:
	_arm = Node3D.new()
	_arm.name = "Arm"
	_arm.position = Vector3(-0.2, 0.62, 0.0)
	add_child(_arm)
	var sleeve := MeshInstance3D.new()
	var capsule := CapsuleMesh.new()
	capsule.radius = 0.05
	capsule.height = 0.42
	sleeve.mesh = capsule
	sleeve.position.y = 0.2
	sleeve.material_override = _flat(SMOCK)
	_arm.add_child(sleeve)
	var paper := MeshInstance3D.new()
	paper.name = "Card"
	var box := BoxMesh.new()
	box.size = Vector3(0.16, 0.11, 0.01)
	paper.mesh = box
	paper.position = Vector3(0, 0.44, -0.04)
	paper.material_override = _flat(CARD)
	paper.visible = false
	_arm.add_child(paper)
	raise_hand(false)
	_card_text = CloseLabel.new()
	_card_text.name = "CardText"
	_card_text.reach = READ_REACH
	_card_text.shown = false
	_card_text.font_size = 22
	_card_text.outline_size = 6
	_card_text.width = 360.0
	_card_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_card_text.modulate = Color(0.2, 0.2, 0.45)
	_card_text.outline_modulate = CARD
	_card_text.pixel_size = 0.003
	_card_text.position.y = 1.05
	add_child(_card_text)


static func _flat(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	return material
