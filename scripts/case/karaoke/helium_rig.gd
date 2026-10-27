class_name HeliumRig
extends KaraokeRig

## The juice of inspiration (allanamiento-karaoke.md, "El jugo de la inspiración"): Rosaura puts helium from the bar's
## balloon tank in the juice, so the customers sing in a squeaky voice and laugh by themselves, and they come back for
## more. A glass of juice sits on the bar: a cop who picks it up talks squeaky for SQUEAK_TIME seconds ("I'm the
## law!") and the first time that's the clue. The tank, the box of empty balloons and the juice's recipe are hidden.
## Every number here is (propuesta).

const GLASS_MODEL := preload("res://assets/models/karaoke_juice_glass.glb")
const GLASS_AT := Vector3(7.4, Karaoke.FLOOR_TOP + 1.1 + 0.07, 3.0)
const GLASS_SIZE := Vector3(0.08, 0.12, 0.08)
const SQUEAK_TIME := 8.0
## How often a customer singing squeaks and laughs.
const GIGGLE_EVERY := 6.0

var glass: Grabbable
var noticed := false
## cop -> seconds left talking squeaky.
var squeaky := {}
var _giggle_left := GIGGLE_EVERY


func shared() -> Array[String]:
	return ["noticed"]


func setup(place: Karaoke) -> void:
	super.setup(place)
	karaoke.main = karaoke.hidden[0]
	glass = ClubEvidence.make_item("JuiceGlass", GLASS_MODEL, GLASS_SIZE, 0.3)
	(glass.get_child(1) as Node3D).position.y = -GLASS_SIZE.y / 2
	glass.position = GLASS_AT
	karaoke.add_child(glass)


## A cop who picks up the glass talks squeaky for a while; the first time, the clue.
func _squeak(cop: Cop) -> void:
	if not squeaky.has(cop):
		var voice := Label3D.new()
		voice.name = "Squeak"
		voice.text = "KARAOKE_SQUEAK"
		voice.font_size = 36
		voice.pixel_size = 0.005
		voice.outline_size = 10
		voice.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		voice.no_depth_test = true
		voice.position = Vector3.UP * 2.1
		cop.add_child(voice)
	squeaky[cop] = SQUEAK_TIME
	if not noticed and multiplayer.is_server():
		noticed = true
		karaoke.raid.add_clue(tr("KARAOKE_SQUEAK_CLUE"))


func _physics_process(delta: float) -> void:
	for cop: Cop in glass.handling_cops(0.0):
		_squeak(cop)
	for cop: Variant in squeaky.keys():
		squeaky[cop] -= delta
		if not is_instance_valid(cop):
			squeaky.erase(cop)
		elif squeaky[cop] <= 0.0:
			squeaky.erase(cop)
			(cop as Cop).get_node("Squeak").free()
	var singer := karaoke.on_turn
	if not singer or not singer.singing:
		_giggle_left = GIGGLE_EVERY
		return
	_giggle_left -= delta
	if _giggle_left <= 0.0:
		_giggle_left = GIGGLE_EVERY
		singer.say("KARAOKE_HELIUM_SING")
