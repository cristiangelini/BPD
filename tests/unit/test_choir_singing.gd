extends GutTest

## The choir's rehearsal (infiltracion-coro.md, step 4, decision 101): Ernesto's baton up means sing and down means
## quiet, only the timing counts, and the choristers who hear a cop out of time (or see one off the platform, or
## without a robe) get suspicious.

const LEVEL := preload("res://scenes/levels/church_choir.tscn")

var chapel: ChurchChoir
var cop: Cop


func before_each() -> void:
	chapel = LEVEL.instantiate()
	cop = chapel.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(chapel)
	await wait_physics_frames(2)
	# This PC's cop, as VoiceChat.local_cop finds it.
	cop.input_enabled = true
	cop.put_on_disguise("robe", 0.0)


## The cop on a free spot of the platform, the song on and the baton `up` for long enough to count.
func _on_platform_singing(up: bool) -> void:
	cop.global_position = chapel.global_transform * chapel.free_spots[0]
	await wait_physics_frames(1)
	chapel.singing.start_song()
	chapel.singing._set_baton(up)
	chapel.singing.since_baton = ChoirSinging.GRACE


func _nearest_member() -> ClubMember:
	var nearest: ClubMember = chapel.members[0]
	for member in chapel.members:
		if member.global_position.distance_to(cop.global_position) < nearest.global_position.distance_to(cop.global_position):
			nearest = member
	return nearest


func test_the_first_song_starts_with_the_baton_up() -> void:
	assert_false(chapel.singing.is_song())
	chapel.singing._process(ChoirSinging.FIRST_SONG + 0.1)
	assert_true(chapel.singing.is_song())
	assert_true(chapel.singing.baton_up)
	assert_eq(chapel.ernesto.said(), "ERNESTO_SONG")


func test_the_baton_goes_up_and_down_during_a_song() -> void:
	chapel.singing.start_song()
	var changes := 0
	var was := chapel.singing.baton_up
	for i in int(ChoirSinging.SONG / 0.1):
		chapel.singing._process(0.1)
		if chapel.singing.baton_up != was:
			changes += 1
			was = chapel.singing.baton_up
	assert_gt(changes, 4, "phrases and rests")
	assert_false(chapel.singing.is_song(), "the song ended")
	assert_false(chapel.singing.baton_up, "and the baton is down")


func test_singing_with_the_baton_up_is_fine() -> void:
	await _on_platform_singing(true)
	chapel.singing.force_singing = true
	chapel.singing.judge()
	assert_eq(chapel.singing.good_seconds, 1)
	assert_eq(_nearest_member().suspicion, 0.0)


func test_silent_with_the_baton_up_the_neighbors_hear_it() -> void:
	await _on_platform_singing(true)
	chapel.singing.judge()
	assert_eq(chapel.singing.bad_seconds, 1)
	var nearest := _nearest_member()
	assert_lt(nearest.global_position.distance_to(cop.global_position), ClubSuspicion.HEAR_RANGE, "a neighbor close by")
	assert_eq(nearest.suspicion, ChoirSinging.SILENT)


func test_a_solo_with_the_baton_down_is_worse() -> void:
	await _on_platform_singing(false)
	chapel.singing.force_singing = true
	chapel.singing.judge()
	assert_eq(_nearest_member().suspicion, ChoirSinging.SOLO)


func test_right_after_the_baton_moves_it_doesnt_count_yet() -> void:
	await _on_platform_singing(true)
	chapel.singing._set_baton(false)
	chapel.singing.force_singing = true
	chapel.singing.judge()
	assert_eq(chapel.singing.bad_seconds, 0)


func test_off_the_platform_during_a_song_looks_suspicious() -> void:
	cop.global_position = chapel.global_transform * Vector3(0, 0.1, 3.0)
	await wait_physics_frames(1)
	assert_eq(chapel.suspicion.offence(cop, 0.0), 0.0, "robe on, no song")
	chapel.singing.start_song()
	assert_eq(chapel.suspicion.offence(cop, 0.0), ClubSuspicion.SITTING_OUT)


func test_without_a_robe_they_notice() -> void:
	cop.lose_disguise("robe")
	cop.put_on_disguise("wig", 0.0)
	cop.put_on_disguise("glasses", 0.0)
	assert_eq(chapel.suspicion.offence(cop, 0.0), ClubSuspicion.UNDISGUISED, "a grandparent isn't a chorister")
