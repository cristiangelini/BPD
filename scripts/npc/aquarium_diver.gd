class_name AquariumDiver
extends StaticBody3D

## One of the six cleaning divers (escena-acuario.md, "Los seis buzos"): the same black wetsuit with a whale, hood,
## mask up on the forehead, gloves and flippers as the other five. Under the hood, their own hair (tinted); in the mask,
## prescription lenses if they need them; their flippers (stretched to their size) and their teeth (shown when they
## bite). The cops make their file for the board (step 3) with E and what's in hand: the camera's flash (their photo:
## lenses and flippers), the print kit (their prints), a donut or a loaf (they bite it: their teeth). With empty hands:
## first they tell which tank they look after, then the hood comes off (their hair; one won't until they get something
## to eat), then the right glove (the octopus ink on their hand, or a clean hand). Each goes to their file
## (CrimeSceneCase.guard_part). Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_buzo.glb")
## Flipper sizes stretch the flippers from this much (the smallest) to this much (the biggest).
const SHOE_SCALE := Vector2(0.85, 1.3)
const LINES := 4
## Seconds their teeth show after a bite.
const TEETH_SECONDS := 2.0

## DiverTraits.draw: name, hair, glasses, shoe, teeth, ink, tank.
var traits := {}
## Their number, from 0 (the order of the case's traits).
var index := 0
var case: CrimeSceneCase
var talked := false
var hood_on := true
var glove_on := true
## They won't take off the hood until they get something to eat.
var stubborn := false
var _teeth_left := 0.0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("aquarium_divers")
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
	_tint("hair", DiverTraits.HAIRS[traits.hair])
	part("glasses").visible = traits.glasses
	part("teeth").visible = false
	for side in ["left", "right"]:
		part("ink_%s" % side).visible = false
	var size := inverse_lerp(DiverTraits.SHOE_MIN, DiverTraits.SHOE_MAX, traits.shoe)
	part("legs").scale.z = lerpf(SHOE_SCALE.x, SHOE_SCALE.y, size)
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 2.2
	add_child(_bubble)


func prompt_key(cop: Cop) -> String:
	if cop and _food(cop):
		return "PROMPT_DIVER_FEED"
	if cop and cop.belt and cop.belt.held_tool() is PrintKit:
		return "PROMPT_DIVER_PRINTS"
	if talked and hood_on:
		return "PROMPT_DIVER_HOOD"
	if talked and glove_on:
		return "PROMPT_DIVER_GLOVE"
	return "PROMPT_DIVER_TALK"


## E on them: food in hand, they bite it; with empty hands, their tank, the hood, the glove and then their tank again.
## (The print kit and the camera work on their own: dusted, photographed.)
func use(cop: Cop) -> void:
	var food := _food(cop) if cop else null
	if food:
		feed(food)
	elif talked and hood_on:
		ask_hood()
	elif talked and glove_on:
		take_off_glove()
	else:
		talk()


## A line about their tank (a different one each time, in an order that starts at their number), which always says
## which animals they look after: it goes to their file.
func talk() -> void:
	say(tr("DIVER_LINE_%d" % ((index + _lines_said) % LINES)) % tank_name())
	_lines_said += 1
	if not talked:
		talked = true
		_file("tank")


## Bites a donut from the box or the loaf: their teeth for the file. A stubborn one takes off the hood for it.
func feed(food: Node) -> void:
	if food is DonutBox and not (food as DonutBox).eat_one():
		say("DIVER_NO_DONUTS")
		return
	if food is Bread:
		(food as Bread).eaten()
	_teeth_left = TEETH_SECONDS
	part("teeth").visible = true
	say("DIVER_BITES")
	_file("teeth")
	if stubborn:
		stubborn = false
		_take_off_hood()


func ask_hood() -> void:
	if stubborn:
		say("DIVER_HOOD_NO")
		return
	_take_off_hood()


func _take_off_hood() -> void:
	hood_on = false
	part("hood").visible = false
	say("DIVER_HOOD_OFF")
	_file("hair")


## The right glove comes off: the octopus ink on the hand shows, or a clean hand, and it goes to their file.
func take_off_glove() -> void:
	glove_on = false
	part("glove_right").visible = false
	part("ink_right").visible = traits.ink
	say("DIVER_INK" if traits.ink else "DIVER_CLEAN_HAND")
	_file("ink")


## The camera's flash in their face (PhotoCamera): their photo, with the lenses in their mask and their flippers.
func photographed(_cop: Cop) -> void:
	say("DIVER_NO_FLASH")
	_file("photo")


## The print kit on them (PrintKit): their prints.
func dusted(_cop: Cop) -> String:
	_file("prints")
	return tr("PRINTS_COOK") % traits.name


## The animals of the tank they look after, translated ("los tiburones").
func tank_name() -> String:
	return tr("CARE_%s" % traits.tank)


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


## A part of their model by name (hood, hair, mask, glasses, teeth, legs, glove_left, glove_right, ink_left,
## ink_right).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D


func _tint(id: String, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	for mesh in part(id).find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
