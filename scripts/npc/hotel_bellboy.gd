class_name HotelBellboy
extends HotelStaff

## Tito, the bellboy, the hotel case's witness (escena-hotel.md, "Las pistas"): he saw the culprit's cucumbers fall off
## on the stairs last night, but his hands are always full. His suitcase waits at his feet and he asks for it to be
## carried up to a room (drawn with the seed); once it's in that room, E on him and he tells whether the culprit wore
## glasses. Cuffed, or with his suitcase dropped down the stairs, he's offended and says nothing more for the whole
## case. Every number here is (propuesta).

const SUITCASE_KG := 8.0
const SUITCASE_SIZE := Vector3(0.55, 0.42, 0.2)
const SUITCASE_AT := Vector3(0.6, 0, 0.3)
const LEATHER := Color(0.45, 0.25, 0.15)

var hotel: Hotel
## He saw the culprit: the witness is one of the case's clues.
var knows := false
var offended := false
## The room he wants his suitcase in.
var asked_room := 11
var delivered := false
var suitcase: Grabbable
var _suitcase_floor := 0


func _ready() -> void:
	who = "bellboy"
	super()
	part("suitcase").hide()
	suitcase = Grabbable.new()
	suitcase.name = "TitoSuitcase"
	suitcase.mass = SUITCASE_KG
	suitcase.collision_layer = 4
	suitcase.collision_mask = 15
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SUITCASE_SIZE
	shape.shape = box
	shape.position.y = SUITCASE_SIZE.y / 2
	suitcase.add_child(shape)
	var builder := PlaceBuilder.new(suitcase)
	builder.mesh_box(Vector3(0, SUITCASE_SIZE.y / 2, 0), SUITCASE_SIZE, LEATHER)
	builder.mesh_box(Vector3(0, SUITCASE_SIZE.y + 0.03, 0), Vector3(0.16, 0.06, 0.04), LEATHER.darkened(0.4))
	suitcase.position = position + SUITCASE_AT.rotated(Vector3.UP, rotation.y)
	get_parent().add_child.call_deferred(suitcase)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_HOTEL_BELLBOY"


func use(_cop: Cop) -> void:
	if offended:
		say("HOTEL_BELLBOY_OFFENDED")
	elif not delivered:
		say(tr("HOTEL_BELLBOY_ASK") % asked_room, 5.0)
	elif knows and case:
		case.found("witness")
		say("HOTEL_BELLBOY_SAW_GLASSES" if case.culprit().glasses else "HOTEL_BELLBOY_SAW_NO_GLASSES", 6.0)
	else:
		say("HOTEL_BELLBOY_NOTHING")


func cuffed(_seconds: float) -> void:
	offend()


func offend() -> void:
	if offended:
		return
	offended = true
	say("HOTEL_BELLBOY_OFFENDED")
	if knows and case:
		case.ruin("witness")


func _physics_process(delta: float) -> void:
	super(delta)
	if not hotel or not is_instance_valid(suitcase) or not suitcase.is_inside_tree() or delivered:
		return
	var at := suitcase.global_position
	var now := hotel.floor_of(at + Vector3.UP * 0.1)
	# Down the stairs on its own, not in anyone's hands.
	if _suitcase_floor == 1 and now == 0 and not suitcase.is_held():
		offend()
	_suitcase_floor = now
	if not offended and hotel.room_of(at + Vector3.UP * 0.1) == asked_room:
		delivered = true
		say("HOTEL_BELLBOY_THANKS")
