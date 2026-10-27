class_name RoomThing
extends StaticBody3D

## A thing in a guest's room of the hotel (escena-hotel.md, "Los huéspedes iguales"): what doesn't show on a guest in
## a bathrobe shows in their room. The shoes by the bed (their size), the hairbrush on the nightstand (their hair), the
## nightstand with or without glasses, and the suitcase with its owner's tag. E on one: the cops read it, and it goes
## to the file of whoever the file says sleeps there (CrimeSceneCase.room_part); the suitcase says who really does
## (CrimeSceneCase.open_suitcase). Every number here is (propuesta).

const SIZES := {"shoe": Vector3(0.4, 0.12, 0.34), "hair": Vector3(0.22, 0.06, 0.08), "glasses": Vector3(0.2, 0.05, 0.12),
	"suitcase": Vector3(0.7, 0.25, 0.5)}
## The shoes are this long for the smallest size and this long for the biggest.
const SHOE_LENGTH := Vector2(0.24, 0.34)
const LEATHER := Color(0.45, 0.28, 0.15)
const PLASTIC := Color(0.2, 0.5, 0.85)

## shoe, hair, glasses or suitcase.
var what := "shoe"
var room := 0
## The traits of whoever really sleeps in this room (GuestTraits).
var sleeper := {}
var case: CrimeSceneCase
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	name = "%s_%d" % [what.capitalize(), room]
	collision_layer = 1
	var size: Vector3 = SIZES[what]
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position.y = size.y / 2
	add_child(shape)
	_looks()
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 0.6, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 32
	_bubble.hide()
	add_child(_bubble)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_ROOM_" + what


## E on it: what it says about its owner, into a file.
func use(cop: Cop) -> void:
	match what:
		"shoe":
			_say(tr("FILE_SHOE") % sleeper.shoe)
		"hair":
			_say(tr("FILE_HAIR") % tr("HAIR_" + str(sleeper.hair)))
		"glasses":
			_say(tr("FILE_GLASSES") if sleeper.glasses else tr("ROOM_NO_GLASSES"))
		"suitcase":
			_say(tr("ROOM_TAG") % sleeper.name)
	if case:
		if what == "suitcase":
			case.open_suitcase(room)
			if case.place and case.place.has_method("search"):
				case.place.call("search", "suitcase", cop, room)
		else:
			case.room_part(room, what)


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _say(text: String) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = 3.0


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()


## What it looks like: two shoes as long as the size, a brush with a tuft of the hair, glasses or just a book, a
## suitcase with its paper tag.
func _looks() -> void:
	var builder := PlaceBuilder.new(self)
	match what:
		"shoe":
			var size := inverse_lerp(GuestTraits.SHOE_MIN, GuestTraits.SHOE_MAX, sleeper.shoe)
			var length := lerpf(SHOE_LENGTH.x, SHOE_LENGTH.y, size)
			for x in [-0.08, 0.08]:
				builder.mesh_box(Vector3(x, 0.05, 0), Vector3(0.11, 0.1, length), LEATHER)
		"hair":
			builder.mesh_box(Vector3(-0.04, 0.015, 0), Vector3(0.14, 0.03, 0.06), PLASTIC)
			builder.mesh_box(Vector3(0.07, 0.015, 0), Vector3(0.08, 0.02, 0.025), PLASTIC)
			builder.mesh_box(Vector3(-0.04, 0.04, 0), Vector3(0.12, 0.02, 0.05), GuestTraits.HAIRS[sleeper.hair])
		"glasses":
			builder.mesh_box(Vector3(0, 0.015, 0), Vector3(0.16, 0.03, 0.11), Hotel.CARPET)
			if sleeper.glasses:
				builder.mesh_box(Vector3(0, 0.04, 0), Vector3(0.14, 0.02, 0.04), Color(0.08, 0.08, 0.1))
		"suitcase":
			builder.mesh_box(Vector3(0, 0.125, 0), SIZES.suitcase, LEATHER)
			builder.mesh_box(Vector3(0.36, 0.2, 0), Vector3(0.02, 0.1, 0.07), Color(0.95, 0.92, 0.8))
