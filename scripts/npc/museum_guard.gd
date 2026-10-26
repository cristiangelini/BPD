class_name MuseumGuard
extends StaticBody3D

## One of the six guards of the city museum (escena-museo.md, "Los guardias iguales"): the same grey uniform, cap,
## flashlight and thick black mustache as the other five. Under the cap, his own hair (tinted); his glasses, if he
## wears them; his shoes (stretched to his size) and his teeth (shown when he bites). The cops make his file for the
## board (step 3) with E and what's in hand: the camera's flash (his photo: glasses and shoes), the print kit (his
## prints, no flour or gloves here), a donut or a loaf (he bites it: his teeth). With empty hands: first he swears he
## was in the bathroom and tells one detail of it (his alibi), then the cap comes off (his hair; one won't until he
## gets something to eat), then a pull on the mustache (a fake one comes off). Each goes to his file
## (CrimeSceneCase.guard_part). Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_guardia_museo.glb")
## Shoe sizes stretch the shoes from this much (the smallest) to this much (the biggest).
const SHOE_SCALE := Vector2(0.85, 1.3)
const LINES := 6
## Seconds his teeth show after a bite.
const TEETH_SECONDS := 2.0

## GuardTraits.draw: name, hair, glasses, shoe, teeth, mustache.
var traits := {}
## His locker's number, from 0 (the order of the case's traits).
var index := 0
var case: CrimeSceneCase
var told_alibi := false
var cap_on := true
var mustache_pulled := false
## He won't take off the cap until he gets something to eat.
var stubborn := false
var _teeth_left := 0.0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("museum_guards")
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
	_tint("hair", GuardTraits.HAIRS[traits.hair])
	part("glasses").visible = traits.glasses
	part("teeth").visible = false
	var size := inverse_lerp(GuardTraits.SHOE_MIN, GuardTraits.SHOE_MAX, traits.shoe)
	part("legs").scale.z = lerpf(SHOE_SCALE.x, SHOE_SCALE.y, size)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.2, 0)
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
	if _food(cop):
		return "PROMPT_GUARD_FEED"
	if cop.belt and cop.belt.held_tool() is PrintKit:
		return "PROMPT_GUARD_PRINTS"
	if told_alibi and cap_on:
		return "PROMPT_GUARD_CAP"
	if told_alibi and not mustache_pulled:
		return "PROMPT_GUARD_MUSTACHE"
	return "PROMPT_GUARD_TALK"


## E on him: food in hand, he bites it; with empty hands, his alibi, the cap, the mustache and then the alibi again.
## (The print kit and the camera work on their own: dusted, photographed.)
func use(cop: Cop) -> void:
	var food := _food(cop)
	if food:
		feed(food)
	elif not told_alibi:
		alibi()
	elif cap_on:
		ask_cap()
	elif not mustache_pulled:
		pull_mustache()
	else:
		alibi()


## He swears he was in the bathroom (a different way each time) and tells his detail of it: true if he was there.
func alibi() -> void:
	say(tr("GUARD_LINE_%d" % ((index + _lines_said) % LINES)) + " " + tr("ALIBI_" + str(traits.detail)), 5.0)
	_lines_said += 1
	if not told_alibi:
		told_alibi = true
		_file("alibi")


## Bites a donut from the box or the loaf: his teeth for the file. A stubborn one takes off the cap for it.
func feed(food: Node) -> void:
	if food is DonutBox and not (food as DonutBox).eat_one():
		say("MUSEUM_GUARD_NO_DONUTS")
		return
	if food is Bread:
		(food as Bread).eaten()
	_teeth_left = TEETH_SECONDS
	part("teeth").visible = true
	say("GUARD_BITES")
	_file("teeth")
	if stubborn:
		stubborn = false
		_take_off_cap()


func ask_cap() -> void:
	if stubborn:
		say("GUARD_CAP_NO")
		return
	_take_off_cap()


func _take_off_cap() -> void:
	cap_on = false
	part("cap").visible = false
	say("GUARD_CAP_OFF")
	_file("hair")


## A pull on the mustache: his own stays on ("¡Ay!"), a fake one comes off in the cop's hand.
func pull_mustache() -> void:
	mustache_pulled = true
	if traits.mustache:
		say("GUARD_MUSTACHE_REAL")
	else:
		part("mustache").visible = false
		say("GUARD_MUSTACHE_FAKE")
	_file("mustache")


## The camera's flash in his face (PhotoCamera): his photo, with his glasses and his shoes.
func photographed(_cop: Cop) -> void:
	say("GUARD_NO_FLASH")
	_file("photo")


## The print kit on him (PrintKit): his prints, clean.
func dusted(_cop: Cop) -> String:
	_file("prints")
	return tr("PRINTS_COOK") % traits.name


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


## A part of his model by name (cap, hair, mustache, glasses, teeth, legs).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D


func _tint(id: String, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	for mesh in part(id).find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
