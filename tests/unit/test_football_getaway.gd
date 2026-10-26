extends GutTest

## The referee's getaway (politico-futbol.md, step 6, decision 179): Barullo's scooter waits on the street; a referee
## still loose at the final whistle rides off on it, and caught he counts as detained. Play draws the charity match a
## quarter of the politician's protections.

const LEVEL := preload("res://scenes/levels/football_pitch.tscn")

var pitch: FootballPitch
var case: FootballCase


func before_each() -> void:
	pitch = LEVEL.instantiate()
	pitch.case_seed = 7
	var cop: Cop = pitch.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(pitch)
	await wait_physics_frames(3)
	case = pitch.case


func test_the_scooter_waits_parked_on_the_street() -> void:
	var moto := pitch.moto
	assert_eq(moto.kind, SuspectCar.BARULLO_MOTO)
	assert_false(moto.driving)
	assert_false(moto.get_node("Rider").visible, "the referee is still on the pitch")
	var at := pitch.to_local(moto.global_position)
	assert_gt(at.z, FootballPitch.HALF + CityLayout.SIDEWALK, "on the street, past the sidewalk")
	await wait_physics_frames(20)
	assert_almost_eq(pitch.to_local(moto.global_position).x, at.x, 0.1, "parked, it stays")


func test_a_loose_referee_rides_off_at_the_final_whistle() -> void:
	pitch.match_clock.finished.emit()
	assert_not_null(case.chase)
	assert_eq(case.chase.suspect_id, SuspectCar.BARULLO_MOTO)
	assert_eq(case.chase.truck, pitch.moto, "the parked scooter is the one fleeing")
	assert_eq(case.chase.who, "referee")
	assert_false(pitch.referee.visible, "he left on it")
	assert_true(pitch.moto.get_node("Rider").visible)
	assert_eq(case.rows().size(), 6, "and the planilla asks to catch it")


func test_caught_he_counts_as_detained() -> void:
	pitch.score.scored.emit(FootballScore.Team.LUSTRE, pitch.politician)
	pitch.match_clock.finished.emit()
	case.chase.ended.emit(true)
	assert_true(case.referee_detained())
	assert_eq(case.report().salary, FootballCase.SALARY + FootballCase.REFEREE)
	await wait_seconds(FootballCase.SHIFT_DELAY + 0.3)
	assert_true(case.shift_over)


func test_a_jailed_referee_doesn_t_ride_off() -> void:
	pitch.referee.cuffed(Handcuffs.SECONDS)
	OwnerEscort.of(pitch.referee).board()
	pitch.match_clock.finished.emit()
	assert_null(case.chase)


func test_the_scooter_is_fast_and_leans_into_the_curves() -> void:
	assert_almost_eq(SuspectCar.SPEEDS[SuspectCar.BARULLO_MOTO], 45.0 / 3.6, 0.01)
	assert_gt(SuspectCar.TURN_SPEEDS[SuspectCar.BARULLO_MOTO], SuspectCar.TURN_SPEED)
	assert_true(ChaseSuspect.MODELS.has("referee"))


func test_play_draws_it() -> void:
	assert_has(PlaceDraw.RALLIES, "football")
	var found := false
	for i in 900:
		if PlaceDraw.pick(i + 1, [], 1) == "football":
			found = true
			break
	assert_true(found)


func test_the_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key: String in ["HINT_ESCAPE_REFEREE", "OBJ_FOOTBALL_CATCH_MOTO", "CHASE_REFEREE_LINE_1", "CHASE_REFEREE_LINE_2",
			"CHASE_REFEREE_LINE_3"]:
		assert_ne(tr(key), key)
