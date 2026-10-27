class_name PlanetariumGuide
extends StaticBody3D

## One of the six guides (escena-planetario.md, "Los seis guías"): the same white astronaut suit, helmet with the visor
## down, gloves and moon boots as the other five. Under the helmet, their own hair (tinted); their moon boots
## (stretched to their size), their teeth (shown when they bite) and the pin of their planet on the chest. The glow
## paint on their gloves only shows in the dark (`set_dark`). The cops make their file for the board (step 3) with E
## and what's in hand: the camera's flash (their photo: the moon boots), the print kit (their prints), a donut or a
## loaf (they bite it: their teeth). With empty hands: first they tell which planet they present, then the helmet comes
## off (their hair; one won't until they get something to eat); in the dark, E looks at their gloves (glow paint or
## none). Each goes to their file (CrimeSceneCase.guard_part). Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_guia.glb")
## Boot sizes stretch the boots from this much (the smallest) to this much (the biggest).
const SHOE_SCALE := Vector2(0.85, 1.3)
const LINES := 4
## Seconds their teeth show after a bite.
const TEETH_SECONDS := 2.0

## GuideTraits.draw: name, hair, shoe, teeth, glow, planet.
var traits := {}
## Their number, from 0 (the order of the case's traits).
var index := 0
var case: CrimeSceneCase
var talked := false
var helmet_on := true
## They won't take off the helmet until they get something to eat.
var stubborn := false
## The lights are out: the glow paint shows, if they have it.
var in_dark := false
var _teeth_left := 0.0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("planetarium_guides")
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
	_tint("hair", GuideTraits.HAIRS[traits.hair])
	_tint("pin", Planetarium.PLANET_COLORS[traits.planet])
	part("teeth").visible = false
	set_dark(false)
	var size := inverse_lerp(GuideTraits.SHOE_MIN, GuideTraits.SHOE_MAX, traits.shoe)
	part("legs").scale.z = lerpf(SHOE_SCALE.x, SHOE_SCALE.y, size)
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 2.2
	add_child(_bubble)


func prompt_key(cop: Cop) -> String:
	if cop and _food(cop):
		return "PROMPT_GUIDE_FEED"
	if cop and cop.belt and cop.belt.held_tool() is PrintKit:
		return "PROMPT_GUIDE_PRINTS"
	if in_dark:
		return "PROMPT_GUIDE_GLOVES"
	if talked and helmet_on:
		return "PROMPT_GUIDE_HELMET"
	return "PROMPT_GUIDE_TALK"


## E on them: food in hand, they bite it; with empty hands, in the dark their gloves, and with the lights on their
## planet, the helmet and then their planet again. (The print kit and the camera work on their own: dusted,
## photographed.)
func use(cop: Cop) -> void:
	var food := _food(cop) if cop else null
	if food:
		feed(food)
	elif in_dark:
		look_at_gloves()
	elif talked and helmet_on:
		ask_helmet()
	else:
		talk()


## A line about their planet (a different one each time, in an order that starts at their number), which always says
## which planet they present: it goes to their file.
func talk() -> void:
	say(tr("GUIDE_LINE_%d" % ((index + _lines_said) % LINES)) % planet_name())
	_lines_said += 1
	if not talked:
		talked = true
		_file("planet")


## Bites a donut from the box or the loaf: their teeth for the file. A stubborn one takes off the helmet for it.
func feed(food: Node) -> void:
	if food is DonutBox and not (food as DonutBox).eat_one():
		say("GUIDE_NO_DONUTS")
		return
	if food is Bread:
		(food as Bread).eaten()
	_teeth_left = TEETH_SECONDS
	part("teeth").visible = true
	say("GUIDE_BITES")
	_file("teeth")
	if stubborn:
		stubborn = false
		_take_off_helmet()


func ask_helmet() -> void:
	if stubborn:
		say("GUIDE_HELMET_NO")
		return
	_take_off_helmet()


func _take_off_helmet() -> void:
	helmet_on = false
	part("helmet").visible = false
	say("GUIDE_HELMET_OFF")
	_file("hair")


## In the dark, a look at their gloves: the glow paint shines on them, or nothing does. It goes to their file.
func look_at_gloves() -> void:
	say("GUIDE_GLOW" if traits.glow else "GUIDE_NO_GLOW")
	_file("glow")


## Lights out or back on: the glow paint on both gloves shows only in the dark.
func set_dark(on: bool) -> void:
	in_dark = on
	for side in ["left", "right"]:
		part("glow_%s" % side).visible = on and traits.glow


## The camera's flash in their face (PhotoCamera): their photo, with their moon boots.
func photographed(_cop: Cop) -> void:
	say("GUIDE_NO_FLASH")
	_file("photo")


## The print kit on them (PrintKit): their prints (a glove comes off for it).
func dusted(_cop: Cop) -> String:
	_file("prints")
	return tr("PRINTS_COOK") % traits.name


## The planet they present, translated ("Júpiter").
func planet_name() -> String:
	return tr("PLANET_%s" % traits.planet)


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


## A part of their model by name (helmet, hair, teeth, legs, pin, glove_left, glove_right, glow_left, glow_right).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D


func _tint(id: String, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	for mesh in part(id).find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
