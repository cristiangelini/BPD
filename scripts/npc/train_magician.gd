class_name TrainMagician
extends StaticBody3D

## One of the six magicians on the train El Lento (escena-tren.md, "Los magos iguales"): the same black cape, top hat,
## long fake beard and white gloves as the other five. Under the hat, his own hair (tinted); his glasses, if he wears
## them; his shoes (stretched to his size) and his teeth (shown when he bites). E on him: a trick, a different one
## each time (a dove, a long hanky, a coin from behind the cop's ear), and he says his stage name.
## His file for the board (step 3) goes by the sticker on his cape (Train.stick_sticker), since in every tunnel the six
## swap seats: E with a sticker in hand sticks it; the camera's flash (his glasses and shoes), the print kit (his
## prints: he takes a glove off), a donut or a loaf (he bites it: his teeth); with empty hands, after his first trick,
## the hat comes off for a moment (his hair) and then he ties a knot in his hanky (which hand he uses). Each goes to the
## file of his sticker (CrimeSceneCase.magician_part). Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_mago.glb")
## Shoe sizes stretch the shoes from this much (the smallest) to this much (the biggest).
const SHOE_SCALE := Vector2(0.85, 1.3)
const TRICKS: Array[String] = ["dove", "hanky", "coin"]
## Seconds a trick's prop shows, his teeth after a bite and his hair before the hat goes back on.
const TRICK_SECONDS := 2.0
const TEETH_SECONDS := 2.0
const HAT_SECONDS := 3.0

## MagicianTraits.draw: name, hair, glasses, left, shoe, teeth.
var traits := {}
## His place in the case's traits, from 0.
var index := 0
var tricks_done := 0
var train: Train
var case: CrimeSceneCase
var hat_on := true
var knot_tied := false
var _trick_left := 0.0
var _teeth_left := 0.0
var _hat_left := 0.0
var _sticker: Label3D
var _hat_done := false
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("train_magicians")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_tint("hair", MagicianTraits.HAIRS[traits.hair])
	part("glasses").visible = traits.glasses
	part("teeth").visible = false
	for trick in TRICKS:
		part(trick).visible = false
	var size := inverse_lerp(MagicianTraits.SHOE_MIN, MagicianTraits.SHOE_MAX, traits.shoe)
	part("legs").scale.z = lerpf(SHOE_SCALE.x, SHOE_SCALE.y, size)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.3, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


func prompt_key(cop: Cop) -> String:
	var held: Node = cop.get_node("Grabber").held
	if held is TrainSticker:
		return "PROMPT_MAGICIAN_STICKER"
	if held is DonutBox or held is Bread:
		return "PROMPT_MAGICIAN_FEED"
	if cop.belt and cop.belt.held_tool() is PrintKit:
		return "PROMPT_MAGICIAN_PRINTS"
	if tricks_done > 0 and hat_on and not _asked_hat():
		return "PROMPT_MAGICIAN_HAT"
	if tricks_done > 0 and not knot_tied and _asked_hat():
		return "PROMPT_MAGICIAN_KNOT"
	return "PROMPT_MAGICIAN_TALK"


## E on him: a sticker in hand goes on his cape, food he bites; with empty hands, a trick, then the hat, then the
## knot, then tricks again.
func use(cop: Cop) -> void:
	var held: Node = cop.get_node("Grabber").held
	if held is TrainSticker:
		var sticker := held as TrainSticker
		cop.get_node("Grabber").release()
		if train:
			train.stick_sticker(sticker.number, self)
		sticker.queue_free()
	elif held is DonutBox or held is Bread:
		feed(held)
	elif tricks_done > 0 and not _asked_hat():
		take_off_hat()
	elif tricks_done > 0 and not knot_tied:
		tie_knot()
	else:
		trick()


## Bites a donut from the box or the loaf: his teeth for the file.
func feed(food: Node) -> void:
	if food is DonutBox and not (food as DonutBox).eat_one():
		say("MAGICIAN_NO_DONUTS")
		return
	if food is Bread:
		(food as Bread).eaten()
	_teeth_left = TEETH_SECONDS
	part("teeth").visible = true
	say("MAGICIAN_BITES")
	_file("teeth")


## The hat comes off for a moment, with a bow: his hair for the file.
func take_off_hat() -> void:
	hat_on = false
	part("hat").visible = false
	_hat_left = HAT_SECONDS
	say("MAGICIAN_HAT_OFF")
	_file("hair")


## He ties his hanky in a knot, with his own hand: which one, for the file.
func tie_knot() -> void:
	knot_tied = true
	say("MAGICIAN_KNOT_LEFT" if traits.left else "MAGICIAN_KNOT_RIGHT")
	_file("knot")


## The camera's flash (PhotoCamera): his photo, with his glasses and his shoes.
func photographed(_cop: Cop) -> void:
	say("MAGICIAN_PHOTO")
	_file("photo")


## The print kit on him (PrintKit): he takes a glove off for it.
func dusted(_cop: Cop) -> String:
	_file("prints")
	return tr("PRINTS_COOK") % traits.name


## The sticker on his cape, by number (-1: none).
func show_sticker(number: int) -> void:
	if _sticker:
		_sticker.queue_free()
		_sticker = null
	if number < 0:
		return
	_sticker = Label3D.new()
	_sticker.name = "Sticker"
	_sticker.text = str(number + 1)
	_sticker.font_size = 64
	_sticker.pixel_size = 0.003
	_sticker.modulate = Color(0.1, 0.1, 0.12)
	_sticker.outline_modulate = TrainSticker.PAPER
	_sticker.outline_size = 40
	_sticker.position = Vector3(0, 0.95, 0.42)
	add_child(_sticker)


## The number of the sticker he wears, or -1.
func sticker() -> int:
	return int(_sticker.text) - 1 if _sticker else -1


## Whether the hat came off once (it went back on after a while).
func _asked_hat() -> bool:
	return not hat_on or _hat_done


func _file(what: String) -> void:
	if case:
		case.magician_part(index, what)


## The next trick: its prop shows for a moment and he says his stage name.
func trick() -> void:
	var kind := TRICKS[tricks_done % TRICKS.size()]
	tricks_done += 1
	for other in TRICKS:
		part(other).visible = other == kind
	_trick_left = TRICK_SECONDS
	say(tr("MAGICIAN_TRICK_" + kind) % traits.name)


## The trick showing now, or "".
func showing() -> String:
	for kind in TRICKS:
		if part(kind).visible:
			return kind
	return ""


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func say(text: String, seconds := 3.5) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


func _physics_process(delta: float) -> void:
	if _teeth_left > 0.0:
		_teeth_left -= delta
		part("teeth").visible = _teeth_left > 0.0
	if _hat_left > 0.0:
		_hat_left -= delta
		if _hat_left <= 0.0:
			hat_on = true
			_hat_done = true
			part("hat").visible = true
	if _trick_left > 0.0:
		_trick_left -= delta
		if _trick_left <= 0.0:
			for kind in TRICKS:
				part(kind).visible = false
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()


## A part of his model by name (hat, hair, beard, glasses, teeth, legs, gloves, wand, dove, hanky, coin).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D


func _tint(id: String, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	for mesh in part(id).find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
