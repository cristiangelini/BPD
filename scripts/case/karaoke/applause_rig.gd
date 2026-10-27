class_name ApplauseRig
extends KaraokeRig

## The applause machine (allanamiento-karaoke.md, "La máquina de aplausos"): Rosaura's nephew wins the Thursday contest
## every week thanks to a machine of recorded applause. While a customer sings, however off key, applause plays every
## APPLAUSE_EVERY seconds, and it comes from a speaker in the ceiling, not from the room: a cop under it when it plays
## hears where it comes from (the first time, the clue). On the east wall hangs the frame with the nephew's 10 cups.
## The machine, the tapes of applause and the list of winners are hidden. Every number here is (propuesta).

const SPEAKER_MODEL := preload("res://assets/models/ceiling_speaker.glb")
const FRAME_MODEL := preload("res://assets/models/nephew_frame.glb")
const SPEAKER_AT := Vector3(-6.0, Karaoke.WALL_TOP - 0.05, 3.0)
const FRAME_AT := Vector3(Karaoke.HALF_X - 0.06, 1.6, 7.0)
const APPLAUSE_EVERY := 5.0
## A cop this close to the speaker (along the floor) hears that the applause comes from it.
const HEAR_RANGE := 3.0

var heard := false
var applauses := 0
var _applause_left := APPLAUSE_EVERY


func shared() -> Array[String]:
	return ["heard"]


func setup(place: Karaoke) -> void:
	super.setup(place)
	karaoke.main = karaoke.hidden[0]
	karaoke._model(SPEAKER_MODEL, SPEAKER_AT)
	karaoke._model(FRAME_MODEL, FRAME_AT, -PI / 2)
	karaoke._label("KARAOKE_NEPHEW_FRAME", FRAME_AT + Vector3(-0.02, -0.75, 0), 32, -PI / 2, 0.005)


## Applause out of the ceiling speaker; a cop under it notices where it comes from.
func applaud() -> void:
	applauses += 1
	karaoke._say(SPEAKER_AT + Vector3.DOWN * 0.6, "KARAOKE_APPLAUSE", 2.0)
	if heard:
		return
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		var at := karaoke.to_local(cop.global_position)
		if Vector2(at.x - SPEAKER_AT.x, at.z - SPEAKER_AT.z).length() < HEAR_RANGE:
			heard = true
			karaoke.raid.add_clue(tr("KARAOKE_APPLAUSE_CLUE"))
			return


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server() or not karaoke.on_turn or not karaoke.on_turn.singing:
		_applause_left = APPLAUSE_EVERY
		return
	_applause_left -= delta
	if _applause_left <= 0.0:
		_applause_left = APPLAUSE_EVERY
		applaud()
