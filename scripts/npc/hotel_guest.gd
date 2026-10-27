class_name HotelGuest
extends HotelStaff

## One of the six guests of the Hotel Gran Siesta (escena-hotel.md, "Los huéspedes iguales"): the same white bathrobe,
## slippers, towel on the head and cucumber slices on the eyes as the other five. Under the towel, their own hair;
## under the cucumbers, their glasses if they wear them; their teeth show when they bite. On them almost nothing shows,
## so their rooms are the clues (RoomThing). What they give the file themselves: their prints (the print kit), their
## teeth (a donut or a loaf, they bite it) and, with empty hands, a signature in the cop's notebook, with the left hand or
## the right. Then a line, a different one each time; asked for the towel, never ("¡recién me lavé el pelo!"). The
## camera gets nothing: the cucumbers. Every number here is (propuesta).

## Seconds their teeth show after a bite.
const TEETH_SECONDS := 2.0

## Their place in the case's order.
var index := 0
## GuestTraits.draw: name, hair, glasses, shoe, teeth, left, room, said.
var traits := {}
var signed := false
var _teeth_left := 0.0


func _ready() -> void:
	who = "guest"
	super()
	add_to_group("hotel_guests")
	if traits.has("hair"):
		var material := StandardMaterial3D.new()
		material.albedo_color = GuestTraits.HAIRS[traits.hair]
		for mesh in part("hair").find_children("*", "MeshInstance3D", true, false):
			(mesh as MeshInstance3D).material_override = material
	part("hair").visible = false
	part("glasses").visible = false
	part("teeth").visible = false


func prompt_key(cop: Cop) -> String:
	if _food(cop):
		return "PROMPT_GUARD_FEED"
	if cop.belt and cop.belt.held_tool() is PrintKit:
		return "PROMPT_GUARD_PRINTS"
	return "PROMPT_GUEST_SIGN" if not signed else "PROMPT_HOTEL_GUEST"


## E on them: food in hand, they bite it; with empty hands, first their signature, then their lines.
func use(cop: Cop) -> void:
	var food := _food(cop)
	if food:
		feed(food)
	elif not signed:
		sign_notebook()
	else:
		say(line_key(index + _lines_said))
		_lines_said += 1


## They sign the cop's notebook, with the left hand or the right: that goes to their file.
func sign_notebook() -> void:
	signed = true
	say("GUEST_SIGNS_LEFT" if traits.get("left", false) else "GUEST_SIGNS_RIGHT")
	_file("sign")


## They bite a donut from the box or the loaf: their teeth for the file.
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


## The print kit on them (PrintKit): their prints, clean.
func dusted(_cop: Cop) -> String:
	_file("prints")
	return tr("PRINTS_COOK") % traits.get("name", "")


## The camera's flash (PhotoCamera): the cucumbers hide everything.
func photographed(_cop: Cop) -> void:
	say("GUEST_NO_PHOTO")


func _physics_process(delta: float) -> void:
	super(delta)
	if _teeth_left > 0.0:
		_teeth_left -= delta
		part("teeth").visible = _teeth_left > 0.0


func _food(cop: Cop) -> Node:
	var held: Node = cop.get_node("Grabber").held
	return held if held is DonutBox or held is Bread else null


func _file(what: String) -> void:
	if case:
		case.guest_part(index, what)
