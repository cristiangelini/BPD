class_name PostCarrier
extends StaticBody3D

## One of the six mail carriers (escena-correo.md, "Los seis carteros"): the same cap, yellow vest, leather bag and
## gloves as the other five. Under the cap, their own hair (tinted); their shoes (stretched to their size), their teeth
## (shown when they bite), their tongue and the tag of their route on the bag. The cops make their file for the board
## (step 3) with E and what's in hand: the camera's flash (their photo: the shoes), the print kit (their prints), a
## donut or a loaf (they bite it: their teeth). With empty hands: first they tell which route they cover, then the cap
## comes off (their hair; one won't until they get something to eat), then they stick out their tongue (blue from La
## Vaquita Azul's old glue, or pink; a bite before anyone looks washes the blue off for good). Each goes to their file
## (CrimeSceneCase.guard_part). Every number here is (propuesta).

const MODEL := preload("res://assets/models/npc_postal.glb")
## Shoe sizes stretch the shoes from this much (the smallest) to this much (the biggest).
const SHOE_SCALE := Vector2(0.85, 1.3)
const LINES := 4
const PINK := Color(0.95, 0.5, 0.55)
const BLUE := Color(0.2, 0.35, 0.95)
## Seconds their teeth or their tongue show.
const SHOW_SECONDS := 2.5

## CarrierTraits.draw: name, hair, shoe, teeth, blue, route.
var traits := {}
## Their number, from 0 (the order of the case's traits).
var index := 0
var case: CrimeSceneCase
var talked := false
var cap_on := true
## They won't take off the cap until they get something to eat.
var stubborn := false
var tongue_seen := false
## A bite before anyone looked at their tongue washed the blue off: it says nothing any more.
var washed := false
var _teeth_left := 0.0
var _tongue_left := 0.0
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0
var _lines_said := 0


func _ready() -> void:
	add_to_group("post_carriers")
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
	_tint("hair", CarrierTraits.HAIRS[traits.hair])
	_tint("tag", PostOffice.ROUTE_COLORS[traits.route])
	_tint("tongue", PINK)
	part("teeth").visible = false
	part("tongue").visible = false
	var size := inverse_lerp(CarrierTraits.SHOE_MIN, CarrierTraits.SHOE_MAX, traits.shoe)
	part("legs").scale.z = lerpf(SHOE_SCALE.x, SHOE_SCALE.y, size)
	_bubble = MarketShopper.make_bubble()
	_bubble.position.y = 2.2
	add_child(_bubble)


func prompt_key(cop: Cop) -> String:
	if cop and _food(cop):
		return "PROMPT_CARRIER_FEED"
	if cop and cop.belt and cop.belt.held_tool() is PrintKit:
		return "PROMPT_CARRIER_PRINTS"
	if talked and cap_on:
		return "PROMPT_CARRIER_CAP"
	if talked and not tongue_seen:
		return "PROMPT_CARRIER_TONGUE"
	return "PROMPT_CARRIER_TALK"


## E on them: food in hand, they bite it; with empty hands their route, the cap, the tongue and then their route again.
## (The print kit and the camera work on their own: dusted, photographed.)
func use(cop: Cop) -> void:
	var food := _food(cop) if cop else null
	if food:
		feed(food)
	elif talked and cap_on:
		ask_cap()
	elif talked and not tongue_seen:
		stick_out_tongue()
	else:
		talk()


## A line about their route (a different one each time, in an order that starts at their number), which always says
## which route they cover: it goes to their file.
func talk() -> void:
	say(tr("CARRIER_LINE_%d" % ((index + _lines_said) % LINES)) % route_name())
	_lines_said += 1
	if not talked:
		talked = true
		_file("route")


## Bites a donut from the box or the loaf: their teeth for the file. A stubborn one takes off the cap for it. A bite
## before anyone looked at their tongue washes the blue off.
func feed(food: Node) -> void:
	if food is DonutBox and not (food as DonutBox).eat_one():
		say("CARRIER_NO_DONUTS")
		return
	if food is Bread:
		(food as Bread).eaten()
	_teeth_left = SHOW_SECONDS
	part("teeth").visible = true
	say("CARRIER_BITES")
	_file("teeth")
	if not tongue_seen:
		washed = true
	if stubborn:
		stubborn = false
		_take_off_cap()


func ask_cap() -> void:
	if stubborn:
		say("CARRIER_CAP_NO")
		return
	_take_off_cap()


func _take_off_cap() -> void:
	cap_on = false
	part("cap").visible = false
	say("CARRIER_CAP_OFF")
	_file("hair")


## They stick out their tongue: blue or pink, for the file; washed, pink and it says nothing.
func stick_out_tongue() -> void:
	tongue_seen = true
	_tongue_left = SHOW_SECONDS
	part("tongue").visible = true
	var blue: bool = traits.blue and not washed
	_tint("tongue", BLUE if blue else PINK)
	if washed:
		say("CARRIER_TONGUE_WASHED")
		if case:
			case.file_part(index, "tongue")
		return
	say("CARRIER_TONGUE_BLUE" if blue else "CARRIER_TONGUE_PINK")
	_file("tongue")


## The camera's flash in their face (PhotoCamera): their photo, with their shoes.
func photographed(_cop: Cop) -> void:
	say("CARRIER_FLASH")
	_file("photo")


## The print kit on them (PrintKit): their prints (a glove comes off for it). A cop with Doña Sellito's stamp on
## the face gets nothing (SortingMachine.stamp).
func dusted(cop: Cop) -> String:
	if cop and case and case.place is PostOffice and (case.place as PostOffice).sorting \
			and (case.place as PostOffice).sorting.is_stamped(cop):
		return tr("HINT_STAMPED_NO_PRINTS")
	_file("prints")
	return tr("PRINTS_COOK") % traits.name


## The route they cover, translated ("el recorrido rojo").
func route_name() -> String:
	return tr("ROUTE_%s" % traits.route)


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
	if _tongue_left > 0.0:
		_tongue_left -= delta
		part("tongue").visible = _tongue_left > 0.0
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()


func _food(cop: Cop) -> Node:
	var held: Node = cop.get_node("Grabber").held
	return held if held is DonutBox or held is Bread else null


func _file(what: String) -> void:
	if case:
		case.guard_part(index, what)


## A part of their model by name (cap, hair, teeth, tongue, legs, tag, glove_left, glove_right).
func part(id: String) -> Node3D:
	return _model.find_child(id, true, false) as Node3D


func _tint(id: String, color: Color) -> void:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	for mesh in part(id).find_children("*", "MeshInstance3D", true, false):
		(mesh as MeshInstance3D).material_override = material
