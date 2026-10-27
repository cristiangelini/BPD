class_name MansionNephew
extends StaticBody3D

## One of Señora Ofelia's six nephews (escena-gato.md, "Los seis sobrinos iguales"): the same green sweater with the
## ginger cat, red beanie and scarf as the other five. Under the beanie, their own hair (tinted); their glasses, if they
## wear them; their shoes (stretched to their size) and their teeth (shown when they bite). The cops make their file for
## the board (step 4) with E and what's in hand: the camera's flash (their photo: glasses and shoes), the print kit
## (their prints), a donut or a loaf (they bite it: their teeth). With empty hands: first they talk about the
## inheritance and say their catchphrase, then the beanie comes off (their hair; one won't until they get something to
## eat), then they roll up their sleeves (the scratch, or none). Each goes to their file (CrimeSceneCase.guard_part).
## Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_sobrino_tia.glb")
## Shoe sizes stretch the shoes from this much (the smallest) to this much (the biggest).
const SHOE_SCALE := Vector2(0.85, 1.3)
const LINES := 5
## Seconds their teeth show after a bite.
const TEETH_SECONDS := 2.0

## NephewTraits.draw: name, hair, glasses, shoe, teeth, scratch, tic.
var traits := {}
## Their suitcase's number, from 0 (the order of the case's traits).
var index := 0
var case: CrimeSceneCase
var talked := false
var beanie_on := true
var sleeves_up := false
## They won't take off the beanie until they get something to eat.
var stubborn := false
var _teeth_left := 0.0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("mansion_nephews")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.7
	shape.shape = capsule
	shape.position.y = 0.85
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_tint("hair", NephewTraits.HAIRS[traits.hair])
	part("glasses").visible = traits.glasses
	part("teeth").visible = false
	for hand in NephewTraits.HANDS:
		part("scratch_%s" % hand).visible = false
	var size := inverse_lerp(NephewTraits.SHOE_MIN, NephewTraits.SHOE_MAX, traits.shoe)
	part("legs").scale.z = lerpf(SHOE_SCALE.x, SHOE_SCALE.y, size)
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 2.2
	add_child(_bubble)


func prompt_key(cop: Cop) -> String:
	if _food(cop):
		return "PROMPT_NEPHEW_FEED"
	if cop.belt and cop.belt.held_tool() is PrintKit:
		return "PROMPT_NEPHEW_PRINTS"
	if talked and beanie_on:
		return "PROMPT_NEPHEW_BEANIE"
	if talked and not sleeves_up:
		return "PROMPT_NEPHEW_SLEEVES"
	return "PROMPT_NEPHEW_TALK"


## E on them: food in hand, they bite it; with empty hands, the talk, the beanie, the sleeves and then talk again.
## (The print kit and the camera work on their own: dusted, photographed.)
func use(cop: Cop) -> void:
	var food := _food(cop)
	if food:
		feed(food)
	elif not talked:
		talk()
	elif beanie_on:
		ask_beanie()
	elif not sleeves_up:
		roll_up_sleeves()
	else:
		talk()


## A line about the inheritance (a different one each time, in an order that starts at their number) ending with their
## catchphrase, which goes to their file.
func talk() -> void:
	say(tr("NEPHEW_LINE_%d" % ((index + _lines_said) % LINES)) % catchphrase())
	_lines_said += 1
	if not talked:
		talked = true
		_file("tic")


## Bites a donut from the box or the loaf: their teeth for the file. A stubborn one takes off the beanie for it.
func feed(food: Node) -> void:
	if food is DonutBox and not (food as DonutBox).eat_one():
		say("NEPHEW_NO_DONUTS")
		return
	if food is Bread:
		(food as Bread).eaten()
	_teeth_left = TEETH_SECONDS
	part("teeth").visible = true
	say("NEPHEW_BITES")
	_file("teeth")
	if stubborn:
		stubborn = false
		_take_off_beanie()


func ask_beanie() -> void:
	if stubborn:
		say("NEPHEW_BEANIE_NO")
		return
	_take_off_beanie()


func _take_off_beanie() -> void:
	show_look(false, sleeves_up)
	say("NEPHEW_BEANIE_OFF")
	_file("hair")


## Rolls up the sweater's sleeves: the scratch shows on that hand, or the arms are clean.
func roll_up_sleeves() -> void:
	show_look(beanie_on, true)
	say("NEPHEW_SCRATCH_ROSES" if traits.scratch != "" else "NEPHEW_NO_SCRATCH")
	_file("scratch")


## Shows him with or without his beanie, and with his sleeves rolled up or not (online, as the host's).
func show_look(beanie: bool, sleeves: bool) -> void:
	beanie_on = beanie
	sleeves_up = sleeves
	part("beanie").visible = beanie
	for hand in NephewTraits.HANDS:
		part("cuff_%s" % hand).visible = not sleeves
		part("scratch_%s" % hand).visible = sleeves and traits.scratch == hand


## Cuffed: the señora doesn't like her nephews in handcuffs, unless it's the culprit or the board said so.
func cuffed(_seconds: float) -> void:
	var mansion := get_parent() as CatMansion
	if case and mansion and mansion.patience and not case.accused and index != case.plan.culprit:
		mansion.patience.lose("wrong_cuff")


## The camera's flash in their face (PhotoCamera): their photo, with their glasses and their shoes.
func photographed(_cop: Cop) -> void:
	say("NEPHEW_NO_FLASH")
	_file("photo")


## The print kit on them (PrintKit): their prints.
func dusted(_cop: Cop) -> String:
	_file("prints")
	return tr("PRINTS_COOK") % traits.name


## Their catchphrase, translated.
func catchphrase() -> String:
	return tr("NEPHEW_TIC_%d" % traits.tic)


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
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()


func _food(cop: Cop) -> Node:
	var held: Node = cop.get_node("Grabber").held
	return held if held is DonutBox or held is Bread else null


func _file(what: String) -> void:
	if case:
		case.guard_part(index, what)


## A part of their model by name (beanie, hair, glasses, teeth, legs, scratch_left, scratch_right, cuff_left...).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D


func _tint(id: String, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	for mesh in part(id).find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
