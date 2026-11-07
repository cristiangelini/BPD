class_name WatchesRig
extends KaraokeRig

## The speaker of watches (allanamiento-karaoke.md, "El parlante de los relojes"): Rosaura smuggles watches inside one
## of the stage speakers (drawn with the seed), the main evidence, 20 kg, so it takes two cops. It makes no sound, so
## the customers sing turned toward the other one, and up close it goes tick-tock: a cop next to it hears it (the
## first time, the clue). The fake gold watch and the ship's invoice are hidden. Every number here is (propuesta).

const SPEAKER_SCENE := preload("res://scenes/props/karaoke_watch_speaker.tscn")
## A cop this close to the speaker (along the floor) hears it tick.
const TICK_RANGE := 1.8
## How far the customers turn toward the speaker that works while they sing.
const LEAN := 0.5

## The mute speaker (an index into Karaoke.SPEAKER_X), the evidence that took its place, and whether a cop heard it.
var mute := 0
var speaker: Evidence
var heard := false
var _tick: Label3D


func shared() -> Array[String]:
	return ["heard"]


func setup(place: Karaoke) -> void:
	super.setup(place)
	mute = karaoke.case_seed % Karaoke.SPEAKER_X.size()
	for part: Node in karaoke.speakers[mute]:
		part.free()
	speaker = SPEAKER_SCENE.instantiate()
	speaker.position = Vector3(Karaoke.SPEAKER_X[mute], Karaoke.FLOOR_TOP + Karaoke.STAGE_SIZE.y + 0.91,
		Karaoke.SPEAKER_Z)
	karaoke.add_child(speaker)
	karaoke.main = speaker
	_tick = Label3D.new()
	_tick.text = "KARAOKE_TICK"
	_tick.font_size = 40
	_tick.pixel_size = 0.006
	_tick.outline_size = 10
	_tick.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_tick.no_depth_test = true
	_tick.position = Vector3.UP * 1.1
	_tick.hide()
	speaker.add_child(_tick)


## The cops close enough to the speaker to hear it tick.
func _listening() -> Array[Cop]:
	var cops: Array[Cop] = []
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		var flat := Vector2(cop.global_position.x - speaker.global_position.x,
			cop.global_position.z - speaker.global_position.z)
		if flat.length() < TICK_RANGE:
			cops.append(cop)
	return cops


func _physics_process(_delta: float) -> void:
	var near := _listening()
	_tick.visible = near.any(func(cop: Cop) -> bool: return is_mine(cop))
	if not near.is_empty() and not heard and multiplayer.is_server():
		heard = true
		karaoke.raid.add_clue(tr("KARAOKE_TICK_CLUE"))
	var singer := karaoke.on_turn
	if singer and singer.singing:
		var live: float = Karaoke.SPEAKER_X[1 - mute]
		singer.rotation.y = LEAN * signf(live - singer.position.x)
