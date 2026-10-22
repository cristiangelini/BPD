extends GutTest

## The club's waltz (infiltracion.md, step 5): it plays every few minutes, the cops dance on the dance floor with H
## on the first beat, and sitting it out or stepping on feet makes the grandparents suspicious.

const LEVEL := preload("res://scenes/levels/grandpa_club.tscn")

var club: GrandpaClub
var cop: Cop


func before_each() -> void:
	club = LEVEL.instantiate()
	club.case_seed = 4242
	cop = club.get_node("Cop")
	add_child_autofree(club)
	await wait_physics_frames(2)
	club.bingo.set_physics_process(false)
	club.suspicion.set_physics_process(false)
	club.dance.set_process(false)


func _to_floor() -> void:
	var middle := GrandpaClub.DANCE_FLOOR.get_center()
	cop.global_position = club.global_transform * Vector3(middle.x, 0.1, middle.y)
	await wait_physics_frames(1)


func test_the_waltz_comes_with_a_warning() -> void:
	club.dance.next_left = ClubDance.WARNING + 0.5
	club.dance._process(1.0)
	assert_eq(club.chela.said(), "CHELA_WALTZ_SOON")
	assert_false(club.dance.is_waltz())
	club.dance._process(ClubDance.WARNING)
	assert_true(club.dance.is_waltz())
	assert_eq(club.chela.said(), "CHELA_WALTZ")


func test_it_ends_and_comes_back_later() -> void:
	club.dance.start_waltz()
	club.dance._process(ClubDance.WALTZ + 0.1)
	assert_false(club.dance.is_waltz())
	assert_almost_eq(club.dance.next_left, ClubDance.DANCE_EVERY, 1.0)


func test_a_step_on_the_first_beat_is_a_good_bar() -> void:
	await _to_floor()
	club.dance.start_waltz()
	watch_signals(club.dance)
	club.dance._process(0.05)
	club.dance.step()
	club.dance._process(ClubDance.BEAT * 3)
	assert_eq(club.dance.good_bars, 1)
	assert_signal_not_emitted(club.dance, "stumbled")


func test_a_step_off_the_beat_or_no_step_is_a_stumble() -> void:
	await _to_floor()
	club.dance.start_waltz()
	watch_signals(club.dance)
	club.dance._process(ClubDance.BEAT * 1.5)
	club.dance.step()
	assert_signal_emit_count(club.dance, "stumbled", 1, "off the beat")
	club.dance._process(ClubDance.BEAT * 1.5 + 0.05)
	club.dance._process(ClubDance.BEAT * 3)
	assert_eq(club.dance.bad_bars, 3, "that bar and the next had no step on the beat")


func test_off_the_floor_nothing_is_judged() -> void:
	club.dance.start_waltz()
	club.dance._process(ClubDance.BEAT * 7)
	assert_eq(club.dance.bad_bars, 0)


func test_sitting_out_the_waltz_is_suspicious() -> void:
	cop.put_on_disguise("wig", 0.0)
	cop.put_on_disguise("glasses", 0.0)
	cop.global_position = club.global_transform * Vector3(0, 0.1, 0)
	assert_eq(club.suspicion.offence(cop, 0.0), 0.0)
	club.dance.start_waltz()
	assert_eq(club.suspicion.offence(cop, 0.0), ClubSuspicion.SITTING_OUT)
	await _to_floor()
	assert_eq(club.suspicion.offence(cop, 0.0), 0.0, "dancing")


func test_a_stumble_seen_raises_suspicion() -> void:
	var watcher: ClubMember = club.members[0]
	cop.global_position = watcher.global_position - watcher.global_basis.z * 2.0
	await wait_physics_frames(1)
	club.dance.stumbled.emit(cop)
	assert_eq(watcher.suspicion, ClubSuspicion.STUMBLE)


func test_the_waltz_music_is_one_looping_bar() -> void:
	var stream := ClubDance.waltz_stream()
	assert_eq(stream.loop_mode, AudioStreamWAV.LOOP_FORWARD)
	assert_almost_eq(stream.data.size() / 2.0 / ClubDance.MIX_RATE, ClubDance.BEAT * 3, 0.01)
