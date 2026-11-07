class_name ZooKeeper
extends StaticBody3D

## One of the six keepers (escena-zoo.md, "Los seis cuidadores"): the same green overalls, rubber boots and cap as the
## other five. Under the cap, their own hair (tinted); their boots (stretched to their size), their teeth (shown when
## they bite) and, if a parrot pecked them, a band-aid on the right hand, seen while their rubber gloves are off. The
## cops make their file for the board (step 3) with E and what's in hand: the camera's flash (their photo: the boots),
## the print kit (their prints; a glove comes off if on), a donut or a loaf (they bite it: their teeth). With empty
## hands: first they tell which animal they look after and so what they smell of, then the cap comes off (their hair;
## one is too shy until they get something to eat), then they show their hands (a band-aid or not; not with the gloves
## on). Each goes to their file (CrimeSceneCase.guard_part). Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_cuidador.glb")
## Boot sizes stretch the boots from this much (the smallest) to this much (the biggest).
const SHOE_SCALE := Vector2(0.85, 1.3)
## Seconds their teeth show.
const SHOW_SECONDS := 2.5

## KeeperTraits.draw: name, hair, shoe, teeth, pecked, smell.
var traits := {}
## Their number, from 0 (the order of the case's traits).
var index := 0
var case: CrimeSceneCase
var talked := false
var cap_on := true
## Too shy to take off the cap until they get something to eat ("estoy despeinado").
var shy := false
var showed_hands := false
var gloves_on := false
var _teeth_left := 0.0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("zoo_keepers")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.5
	capsule.height = 1.6
	shape.shape = capsule
	shape.position.y = 0.8
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_tint("hair", KeeperTraits.HAIRS[traits.hair])
	part("teeth").visible = false
	part("bandage").visible = traits.pecked
	wear_gloves(false)
	var size := inverse_lerp(KeeperTraits.SHOE_MIN, KeeperTraits.SHOE_MAX, traits.shoe)
	part("legs").scale.z = lerpf(SHOE_SCALE.x, SHOE_SCALE.y, size)
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 2.1
	add_child(_bubble)


func prompt_key(cop: Cop) -> String:
	if cop and _food(cop):
		return "PROMPT_KEEPER_FEED"
	if cop and cop.belt and cop.belt.held_tool() is PrintKit:
		return "PROMPT_KEEPER_PRINTS"
	if talked and cap_on:
		return "PROMPT_KEEPER_CAP"
	if talked and not showed_hands:
		return "PROMPT_KEEPER_HANDS"
	return "PROMPT_KEEPER_TALK"


## E on them: food in hand, they bite it; with empty hands their animal and smell, the cap, their hands and then their
## animal again. (The print kit and the camera work on their own: dusted, photographed.)
func use(cop: Cop) -> void:
	var food := _food(cop) if cop else null
	if food:
		feed(food)
	elif talked and cap_on:
		ask_cap()
	elif talked and not showed_hands:
		show_hands()
	else:
		talk()


## The animal they look after, and so their smell: it goes to their file.
func talk() -> void:
	say(tr("KEEPER_SMELL_%s" % traits.smell))
	if not talked:
		talked = true
		_file("smell")


## Bites a donut from the box or the loaf: their teeth for the file. A shy one takes off the cap for it.
func feed(food: Node) -> void:
	if food is DonutBox and not (food as DonutBox).eat_one():
		say("KEEPER_NO_DONUTS")
		return
	if food is Bread:
		(food as Bread).eaten()
	_teeth_left = SHOW_SECONDS
	part("teeth").visible = true
	say("KEEPER_BITES")
	_file("teeth")
	if shy and cap_on:
		shy = false
		_take_off_cap()


func ask_cap() -> void:
	if shy:
		say("KEEPER_CAP_NO")
		return
	_take_off_cap()


func _take_off_cap() -> void:
	cap_on = false
	part("cap").visible = false
	say("KEEPER_CAP_OFF")
	_file("hair")


## They show their bare hands: a band-aid from a peck or not, for the file. Not with the feeding gloves on.
func show_hands() -> void:
	if gloves_on:
		say("KEEPER_HANDS_GLOVES")
		return
	showed_hands = true
	say("KEEPER_HANDS_PECKED" if traits.pecked else "KEEPER_HANDS_CLEAN")
	_file("peck")
	# A band-aid seen: the peck is one of the case's clues (Copito pecked whoever carried him off).
	if traits.pecked and case:
		case.found("peck")


## The camera's flash in their face (PhotoCamera): their photo, with their boots.
func photographed(_cop: Cop) -> void:
	say("KEEPER_FLASH")
	_file("photo")


## The print kit on them (PrintKit): their prints (the right glove comes off for it, if on).
func dusted(_cop: Cop) -> String:
	part("glove_right").visible = false
	_file("prints")
	return tr("PRINTS_COOK") % traits.name


## The rubber gloves on (feeding time) or off: on, they cover the hands and the band-aid.
func wear_gloves(on: bool) -> void:
	gloves_on = on
	part("glove_left").visible = on
	part("glove_right").visible = on
	part("bandage").visible = traits.pecked and not on


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


## A part of their model by name (cap, hair, teeth, legs, bandage, glove_left, glove_right).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D


func _tint(id: String, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	for mesh in part(id).find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
