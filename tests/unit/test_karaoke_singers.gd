extends GutTest

## The karaoke's microphones and customers (allanamiento-karaoke.md, step 2): five microphones in their stands, a
## cable that stops one at 4 m and trips a cop running over it, and the customers who go up in turn to sing at
## microphone 1 and complain when it's gone, taken from them or there's a cop on the stage.

const SCENE := preload("res://scenes/levels/karaoke.tscn")


func _karaoke() -> Karaoke:
	var place: Karaoke = SCENE.instantiate()
	place.case_seed = 5
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	return place


## Somebody's hands pulling `mic` toward `to` (karaoke space).
func _pull(place: Karaoke, mic: KaraokeMic, to: Vector3) -> Node:
	var hands := Node.new()
	add_child_autofree(hands)
	mic.hold(hands.get_instance_id(), place.to_global(to))
	return hands


func test_the_five_microphones_wait_in_their_stands() -> void:
	var place := _karaoke()
	await wait_physics_frames(10)
	assert_eq(place.mics.size(), 5)
	for mic in place.mics:
		assert_true(mic.in_stand)
		assert_lt(mic.global_position.distance_to(mic.clip_point()), 0.01, "in its clip, not on the floor")


func test_the_cable_stops_a_microphone_at_four_meters() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	var mic := place.mics[0]
	_pull(place, mic, Karaoke.MIC_STANDS[0] + Vector3(0, 1.2, 8.0))
	await wait_physics_frames(90)
	assert_false(mic.in_stand)
	assert_lt(mic.reach(), KaraokeMic.CABLE + 0.15, "the cable stops it")
	assert_gt(mic.reach(), KaraokeMic.CABLE - 0.5, "at the end of the cable")


func test_let_go_by_its_clip_it_goes_back_in() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	var mic := place.mics[1]
	var hands := _pull(place, mic, Karaoke.MIC_STANDS[1] + Vector3(0, 1.5, 0.1))
	await wait_physics_frames(20)
	mic.let_go(hands.get_instance_id())
	assert_true(mic.in_stand)
	assert_lt(mic.global_position.distance_to(mic.clip_point()), 0.01)


func test_a_cop_running_over_the_cable_trips() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	var mic := place.mics[2]
	var hands := _pull(place, mic, Karaoke.MIC_STANDS[2] + Vector3(3.0, 0.1, 0))
	await wait_physics_frames(40)
	mic.let_go(hands.get_instance_id())
	await wait_physics_frames(30)
	var cop: Cop = place.get_node("Cop")
	cop.global_position = place.to_global(Karaoke.MIC_STANDS[2] + Vector3(1.5, 0, 0.1))
	watch_signals(mic)
	cop.is_running = false
	mic._trip_cops()
	assert_false(cop.is_staggered(), "walking over it is fine")
	cop.is_running = true
	mic._trip_cops()
	assert_true(cop.is_staggered(), "running over it isn't")
	assert_signal_emitted(mic, "tripped")


func test_the_customers_go_up_in_turn_and_sing() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	assert_eq(place.singers.size(), Karaoke.SINGERS)
	place._turn_left = 0.0
	await wait_until(func() -> bool: return place.on_turn != null and place.on_turn.singing, 8.0)
	var singer := place.on_turn
	assert_true(singer.singing, "up at microphone 1")
	assert_lt(place.to_local(singer.global_position).distance_to(place.singer_spot()), 0.05)
	singer.sing_left = 0.01
	await wait_until(func() -> bool: return place.on_turn == null, 8.0)
	assert_null(place.on_turn, "back by their table")
	assert_lt(place.to_local(singer.global_position).distance_to(singer.home), 0.05)


func test_taking_the_microphone_from_a_singer_is_a_complaint() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	watch_signals(place)
	place._turn_left = 0.0
	await wait_until(func() -> bool: return place.on_turn != null and place.on_turn.singing, 8.0)
	var singer := place.on_turn
	_pull(place, place.mics[0], Karaoke.MIC_STANDS[0] + Vector3(0, 1.5, 1.0))
	await wait_physics_frames(2)
	assert_false(singer.singing, "they stop")
	assert_eq(singer.said(), "KARAOKE_SINGER_GRABBED")
	assert_eq(singer.complaints, 1)
	assert_signal_emitted(place, "singer_complained")


func test_no_microphone_in_the_stand_is_a_complaint() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	_pull(place, place.mics[0], Karaoke.MIC_STANDS[0] + Vector3(2.0, 0.5, 1.5))
	place._turn_left = 0.0
	var singer := place.singers[0]
	await wait_until(func() -> bool: return singer.complaints > 0, 8.0)
	assert_eq(singer.said(), "KARAOKE_SINGER_NO_MIC")
	assert_false(singer.singing)


func test_a_cop_on_the_stage_is_in_the_singer_s_way() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	var cop: Cop = place.get_node("Cop")
	assert_false(place.cop_on_stage())
	cop.global_position = place.to_global(Karaoke.STAGE_AT + Vector3(-3.0, Karaoke.STAGE_SIZE.y + 0.05, 0))
	await wait_physics_frames(5)
	assert_true(place.cop_on_stage())
	place._turn_left = 0.0
	await wait_until(func() -> bool: return place.on_turn != null and place.on_turn.singing, 8.0)
	await wait_physics_frames(2)
	assert_eq(place.on_turn.said(), "KARAOKE_SINGER_IN_WAY")
	assert_eq(place.on_turn.complaints, 1)
