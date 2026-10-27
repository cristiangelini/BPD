class_name LibraryReader
extends StaticBody3D

## One of the six readers of the club (escena-biblioteca.md, "Los seis lectores en pijama"): the same striped pajamas
## with a mouse, nightcap, sleep mask and slippers as the other five, a book open in their hands. Under the nightcap,
## their own hair (tinted); their glasses, if they wear them; their slippers (stretched to their size) and their teeth
## (shown when they bite). The cops make their file for the board (step 3) with E and what's in hand: the camera's
## flash (their photo: glasses and slippers), the print kit (their prints), a donut or a loaf (they bite it: their
## teeth). With empty hands: first they whisper what they read (the kind of book), then the nightcap comes off (their
## hair; one won't until they get something to eat). The gold dust on their hands only shows under a flashlight: lit,
## the hands glitter or not, and that goes to the file too. Each goes to their file (CrimeSceneCase.guard_part).
## Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_lector.glb")
## Slipper sizes stretch the slippers from this much (the smallest) to this much (the biggest).
const SHOE_SCALE := Vector2(0.85, 1.3)
const LINES := 4
## Seconds their teeth show after a bite.
const TEETH_SECONDS := 2.0
## Where their hands are, for the flashlight, and how often they look for a lit beam, in seconds.
const HANDS_AT := Vector3(0, 0.66, 0.2)
const LIGHT_CHECK := 0.2

## ReaderTraits.draw: name, hair, glasses, shoe, teeth, dust, genre.
var traits := {}
## Their number, from 0 (the order of the case's traits).
var index := 0
var case: CrimeSceneCase
var talked := false
var cap_on := true
## They won't take off the nightcap until they get something to eat.
var stubborn := false
## A flashlight is on their hands right now.
var lit := false
var _teeth_left := 0.0
var _light_left := 0.0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("library_readers")
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
	_tint("hair", ReaderTraits.HAIRS[traits.hair])
	part("glasses").visible = traits.glasses
	part("teeth").visible = false
	for side in ["left", "right"]:
		part("dust_%s" % side).visible = false
	var size := inverse_lerp(ReaderTraits.SHOE_MIN, ReaderTraits.SHOE_MAX, traits.shoe)
	part("legs").scale.z = lerpf(SHOE_SCALE.x, SHOE_SCALE.y, size)
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 2.2
	add_child(_bubble)


func prompt_key(cop: Cop) -> String:
	if cop and _food(cop):
		return "PROMPT_READER_FEED"
	if cop and cop.belt and cop.belt.held_tool() is PrintKit:
		return "PROMPT_READER_PRINTS"
	if talked and cap_on:
		return "PROMPT_READER_CAP"
	return "PROMPT_READER_TALK"


## E on them: food in hand, they bite it; with empty hands, the whisper, the nightcap and then whispers again.
## (The print kit, the camera and the flashlight work on their own: dusted, photographed, lit.)
func use(cop: Cop) -> void:
	var food := _food(cop) if cop else null
	if food:
		feed(food)
	elif talked and cap_on:
		ask_cap()
	else:
		talk()


## A whisper about their book (a different line each time, in an order that starts at their number), which always
## says what kind of book it is: it goes to their file.
func talk() -> void:
	say(tr("READER_LINE_%d" % ((index + _lines_said) % LINES)) % genre_name())
	_lines_said += 1
	if not talked:
		talked = true
		_file("genre")


## Bites a donut from the box or the loaf: their teeth for the file. A stubborn one takes off the nightcap for it.
func feed(food: Node) -> void:
	if food is DonutBox and not (food as DonutBox).eat_one():
		say("READER_NO_DONUTS")
		return
	if food is Bread:
		(food as Bread).eaten()
	_teeth_left = TEETH_SECONDS
	part("teeth").visible = true
	say("READER_BITES")
	_file("teeth")
	if stubborn:
		stubborn = false
		_take_off_cap()


func ask_cap() -> void:
	if stubborn:
		say("READER_CAP_NO")
		return
	_take_off_cap()


func _take_off_cap() -> void:
	cap_on = false
	part("nightcap").visible = false
	say("READER_CAP_OFF")
	_file("hair")


## The camera's flash in their face (PhotoCamera): their photo, with their glasses and their slippers.
func photographed(_cop: Cop) -> void:
	say("READER_NO_FLASH")
	_file("photo")


## The print kit on them (PrintKit): their prints.
func dusted(_cop: Cop) -> String:
	_file("prints")
	return tr("PRINTS_COOK") % traits.name


## A flashlight on their hands, or off them: the gold dust glitters while it's lit, and the first time it goes to
## their file (dust or clean hands).
func light_hands(on: bool) -> void:
	if on == lit:
		return
	lit = on
	for side in ["left", "right"]:
		part("dust_%s" % side).visible = on and traits.dust
	if on:
		say("READER_DUST_SHINES" if traits.dust else "READER_CLEAN_HANDS")
		_file("dust")


## Whether a cop's flashlight reaches their hands (Flashlight.reaches, no wall in between).
func hands_lit() -> bool:
	var hands := to_global(HANDS_AT)
	for cop: Node in get_tree().get_nodes_in_group("cops"):
		if cop is Cop and (cop as Cop).belt and (cop as Cop).belt.flashlight \
				and (cop as Cop).belt.flashlight.reaches(hands, self):
			return true
	return false


## The kind of book they read, translated ("piratas").
func genre_name() -> String:
	return tr("GENRE_%s" % traits.genre)


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
	_light_left -= delta
	if _light_left <= 0.0:
		_light_left = LIGHT_CHECK
		light_hands(hands_lit())
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()


func _food(cop: Cop) -> Node:
	var held: Node = cop.get_node("Grabber").held
	return held if held is DonutBox or held is Bread else null


func _file(what: String) -> void:
	if case:
		case.guard_part(index, what)


## A part of their model by name (nightcap, hair, glasses, teeth, legs, mask, book, dust_left, dust_right).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D


func _tint(id: String, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	for mesh in part(id).find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
