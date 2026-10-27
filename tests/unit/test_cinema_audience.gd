extends GutTest

## The cinema's audience and film (docs/diseno/allanamiento-cine.md, step 2): six spectators in seats drawn with the
## seed, who shush a cop bumping into them or standing in front of them, and the film that keeps running on the
## screen until the tape is cut.

const SCENE := preload("res://scenes/levels/cinema.tscn")


func _cinema(case_seed := 5) -> Cinema:
	var cinema: Cinema = SCENE.instantiate()
	cinema.case_seed = case_seed
	cinema.get_node("Cop").input_enabled = false
	cinema.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(cinema)
	return cinema


func _seats(cinema: Cinema) -> Array:
	return cinema.spectators.map(func(spectator: CinemaSpectator) -> int: return spectator.seat)


func test_six_spectators_sit_in_seats_drawn_with_the_seed() -> void:
	var cinema := _cinema(5)
	var seats := _seats(cinema)
	assert_gte(seats.size(), Cinema.SPECTATORS, "six, plus whoever the story sits")
	var unique := {}
	for seat: int in seats:
		unique[seat] = true
	assert_eq(unique.size(), seats.size(), "one each")
	for spectator in cinema.spectators:
		assert_almost_eq(spectator.position.y, cinema.seats[spectator.seat].y + 0.05, 0.01, "on their seat")
	assert_eq(_seats(_cinema(5)), seats, "same seed, same seats")
	assert_ne(_seats(_cinema(6)), seats, "another seed, other seats")


func test_a_fast_bump_gets_a_shush_once_in_a_while() -> void:
	var cinema := _cinema()
	var spectator := cinema.spectators[0]
	watch_signals(cinema)
	assert_true(spectator.shush())
	assert_eq(spectator.said(), "CINEMA_SHUSH")
	assert_false(spectator.shush(), "not again so soon")
	assert_eq(cinema.shushes, 1)
	assert_signal_emitted_with_parameters(cinema, "shushed", [spectator])
	var prop := ClubEvidence.make_item("Thrown", Cinema.POPCORN_MODEL, Vector3(0.3, 0.3, 0.3), 2.0)
	var other := cinema.spectators[1]
	cinema.add_child(prop)
	prop.global_position = other.global_position + Vector3(0, 2.5, 0)
	prop.linear_velocity = Vector3(0, -8.0, 0)
	await wait_physics_frames(30)
	assert_eq(other.shushes, 1, "a prop falling on them")


func test_standing_in_front_of_a_spectator_gets_a_shush() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	var spectator := cinema.spectators[0]
	var cop: Cop = cinema.get_node("Cop")
	assert_false(spectator.view_blocked())
	cop.global_position = spectator.global_position + Vector3(0, 0.2, 0.7)
	cop.velocity = Vector3.ZERO
	await wait_physics_frames(2)
	assert_true(spectator.view_blocked())
	await wait_seconds(CinemaSpectator.BLOCK_SECONDS + 0.3)
	assert_eq(spectator.shushes, 1, "the cop was in the way")


func test_the_film_runs_until_the_tape_is_cut() -> void:
	var cinema := _cinema()
	assert_true(cinema.film_running)
	cinema._film_left = 0.05
	await wait_physics_frames(10)
	assert_eq(cinema.film_line, 1, "the next scene")
	assert_eq(cinema._subtitle.text, "CINEMA_FILM_1")
	cinema.cut_film()
	assert_false(cinema.film_running)
	assert_eq(cinema._subtitle.text, "CINEMA_FILM_CUT")
	for spectator in cinema.spectators:
		assert_eq(spectator.said(), "CINEMA_BOO", "everyone boos")
	cinema._film_left = 0.05
	await wait_physics_frames(10)
	assert_eq(cinema.film_line, 1, "stopped")
	cinema.mend_film()
	assert_true(cinema.film_running)
	assert_eq(cinema._subtitle.text, "CINEMA_FILM_1", "where it was")


func test_a_spectator_answers_without_looking() -> void:
	var cinema := _cinema()
	var spectator := cinema.spectators[2]
	assert_eq(spectator.prompt_key(null), "PROMPT_CINEMA_SPECTATOR")
	spectator.use(null)
	assert_string_starts_with(spectator.said(), "CINEMA_SPECTATOR_LINE_")
	assert_ne(tr(spectator.said()), spectator.said())
