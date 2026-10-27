class_name BoothFourRig
extends KaraokeRig

## Booth 4 (allanamiento-karaoke.md, "La cabina 4"): behind the west wall, next to booth 3, Rosaura has a booth on no
## plan where she records pirated records of her customers singing. On the wall there's a door "4" painted where no
## booth is, and from it someone can be heard singing though nobody's there: a cop next to it hears it (the first
## time, the clue). The box of pirated records, the fake record label's stamp and the list of buyers are hidden. Every
## number here is (propuesta).

## The painted door, on the west wall beside booth 3 (its middle on the floor).
const DOOR_AT := Vector3(-Karaoke.HALF_X + PlaceBuilder.WALL / 2 + 0.02, Karaoke.FLOOR_TOP, 6.8)
const DOOR_RED := Color(0.62, 0.16, 0.22)
const KNOB := Color(0.95, 0.8, 0.3)
## A cop this close to the painted door (along the floor) hears the singing behind it.
const HEAR_RANGE := 2.0

var heard := false
var _voice: Label3D


func shared() -> Array[String]:
	return ["heard"]


func setup(place: Karaoke) -> void:
	super.setup(place)
	karaoke.main = karaoke.hidden[0]
	var height := GameScale.DOOR_HEIGHT
	karaoke._build.mesh_box(DOOR_AT + Vector3(0, height / 2, 0), Vector3(0.02, height, GameScale.DOOR_WIDTH), DOOR_RED)
	karaoke._build.mesh_box(DOOR_AT + Vector3(0.02, 1.0, -GameScale.DOOR_WIDTH / 2 + 0.15), Vector3(0.04, 0.08, 0.08),
		KNOB)
	karaoke._label("KARAOKE_BOOTH_4", DOOR_AT + Vector3(0.03, height + 0.25, 0), 28, PI / 2)
	_voice = Label3D.new()
	_voice.text = "KARAOKE_BOOTH4_VOICE"
	_voice.font_size = 36
	_voice.pixel_size = 0.005
	_voice.outline_size = 10
	_voice.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_voice.no_depth_test = true
	_voice.position = DOOR_AT + Vector3(0.3, 1.6, 0)
	_voice.hide()
	karaoke.add_child(_voice)


func _physics_process(_delta: float) -> void:
	var door := karaoke.to_global(DOOR_AT)
	var near: Array[Cop] = []
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if Vector2(cop.global_position.x - door.x, cop.global_position.z - door.z).length() < HEAR_RANGE:
			near.append(cop)
	_voice.visible = near.any(func(cop: Cop) -> bool: return is_mine(cop))
	if not near.is_empty() and not heard and multiplayer.is_server():
		heard = true
		karaoke.raid.add_clue(tr("KARAOKE_BOOTH4_CLUE"))
