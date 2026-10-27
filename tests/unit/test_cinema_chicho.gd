extends GutTest

## Chicho and the seat next to him (docs/diseno/allanamiento-cine.md, step 4): he sits in a free seat drawn with the
## seed; a cop who sits next to him and stays SIT_SECONDS hears what he saw, once per cop; getting up sooner gets
## "¡Shhh, que viene lo mejor!" and starts over.

const SCENE := preload("res://scenes/levels/cinema.tscn")


func _cinema(case_seed := 5) -> Cinema:
	var cinema: Cinema = SCENE.instantiate()
	cinema.case_seed = case_seed
	cinema.get_node("Cop").input_enabled = false
	cinema.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(cinema)
	return cinema


func test_he_sits_in_a_free_seat_with_a_free_one_beside_him() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	var mine := cinema.to_local(cinema.chicho.global_position)
	var side := cinema.to_local(cinema.side_seat.global_position)
	assert_almost_eq(side.x - mine.x, Cinema.SEAT_STEP, 0.01, "the seat to his right")
	assert_almost_eq(side.z, mine.z, 0.01, "in his row")
	for spectator in cinema.spectators:
		assert_gt(spectator.position.distance_to(mine), 0.5, "nobody in his seat")
		assert_gt(spectator.position.distance_to(side), 0.5, "nor in the one beside him")
	var other := _cinema(77)
	await wait_physics_frames(2)
	assert_ne(other.chicho.position, cinema.chicho.position, "another seed, another seat")


func test_sitting_it_out_beside_him_he_tells_once() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	var cop: Cop = cinema.get_node("Cop")
	cinema.chicho.clue = "the clue"
	cinema.chicho.clue_speech = "what he saw"
	watch_signals(cinema.chicho)
	cinema.side_seat.use(cop)
	assert_eq(cop.seated_in, cinema.side_seat)
	await wait_seconds(CinemaUsher.SIT_SECONDS + 0.5)
	assert_signal_emitted_with_parameters(cinema.chicho, "told", ["the clue"])
	assert_eq(cinema.chicho.said(), "what he saw")
	cinema.side_seat.use(cop)
	assert_null(cop.seated_in, "E again stands up")
	cinema.side_seat.use(cop)
	await wait_seconds(CinemaUsher.SIT_SECONDS + 0.5)
	assert_signal_emit_count(cinema.chicho, "told", 1, "once per cop")


func test_getting_up_too_soon_starts_over() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	var cop: Cop = cinema.get_node("Cop")
	cinema.chicho.clue_speech = "what he saw"
	cinema.side_seat.use(cop)
	await wait_seconds(3.0)
	cinema.side_seat.use(cop)
	assert_eq(cinema.chicho.said(), "CHICHO_EARLY")
	assert_eq(cinema.chicho.sat_for, 0.0)
	assert_false(cinema.chicho.listeners.has(cop))


func test_a_seated_cop_blocks_nobody() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	var cop: Cop = cinema.get_node("Cop")
	cinema.side_seat.use(cop)
	await wait_physics_frames(2)
	for spectator in cinema.spectators:
		assert_false(spectator.view_blocked())
