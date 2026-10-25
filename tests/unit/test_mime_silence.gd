extends GutTest

## No talking at the mimes' theater (infiltracion-mimos.md, step 3, decision 170): the voice of a cop near a mime,
## close or by radio, raises that mime's suspicion wherever they look; away from the mimes it doesn't.

const LEVEL := preload("res://scenes/levels/mime_theater.tscn")

var theater: MimeTheater
var cop: Cop


func before_each() -> void:
	theater = LEVEL.instantiate()
	cop = theater.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(theater)
	await wait_physics_frames(2)


## Puts the cop in the hall, `away` meters in front of the first mime's mark, at the floor's height.
func _near_first_mime(away: float) -> ClubMember:
	var mime := theater.members[0]
	var local := mime.position + Vector3(0, 0.2, away)
	cop.global_position = theater.global_transform * local
	return mime


func test_a_mime_close_by_hears_the_cop_talk() -> void:
	var mime := _near_first_mime(3.0)
	theater.silence.heard_talking(cop)
	assert_almost_eq(mime.suspicion, MimeSilence.TALKING * MimeSilence.TALK_EVERY, 0.01)


func test_a_far_mime_does_not_hear_it() -> void:
	_near_first_mime(3.0)
	theater.silence.heard_talking(cop)
	for member: ClubMember in theater.members:
		if member.global_position.distance_to(cop.global_position) > MimeSilence.HEAR_RANGE:
			assert_eq(member.suspicion, 0.0, "too far to hear")


func test_they_hear_it_even_behind_their_back() -> void:
	var mime := _near_first_mime(-1.0)
	assert_false(mime.sees_cop(cop), "behind the mime")
	theater.silence.heard_talking(cop)
	assert_gt(mime.suspicion, 0.0)


func test_outside_the_theater_the_cops_talk_freely() -> void:
	cop.global_position = theater.global_transform * Vector3(0, 0.1, MimeTheater.HALF_Z + 4.0)
	theater.silence.heard_talking(cop)
	assert_eq(theater.suspicion.highest(), 0.0)


func test_talking_long_enough_gives_them_away() -> void:
	_near_first_mime(2.0)
	for i in int(100.0 / (MimeSilence.TALKING * MimeSilence.TALK_EVERY)) + 1:
		theater.silence.heard_talking(cop)
	assert_true(theater.suspicion.found_out)


func test_the_voice_chat_tells_the_mimes() -> void:
	var voice := VoiceChat.new(Net)
	add_child_autofree(voice)
	var mime := _near_first_mime(3.0)
	voice.spoke(cop)
	assert_gt(mime.suspicion, 0.0, "offline, this PC is the host")


func test_this_pc_sees_when_a_mime_can_hear() -> void:
	cop.input_enabled = true
	_near_first_mime(3.0)
	theater.silence._process(0.0)
	assert_true(theater.silence._hud.visible)
	cop.global_position = theater.global_transform * Vector3(0, 0.1, MimeTheater.HALF_Z + 4.0)
	theater.silence._process(0.0)
	assert_false(theater.silence._hud.visible)
