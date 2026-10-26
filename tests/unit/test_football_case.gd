extends GutTest

## The bought referee and the match as a case (politico-futbol.md, step 5, decision 179): he whistles free kicks for
## the Veterans by the deputy's goal, the envelope and the thumbs up give him away, cuffed and in the patrol car he
## stops; the deputy's goal solves the case, the third real injury loses it, and the pay counts injuries, the win and
## the referee.

const LEVEL := preload("res://scenes/levels/football_pitch.tscn")

var pitch: FootballPitch
var case: FootballCase
var referee: FootballReferee
var cop: Cop


func before_each() -> void:
	pitch = LEVEL.instantiate()
	pitch.case_seed = 7
	cop = pitch.get_node("Cop")
	cop.input_enabled = false
	cop.get_node("Grabber").input_enabled = false
	add_child_autofree(pitch)
	await wait_physics_frames(3)
	case = pitch.case
	referee = pitch.referee


func test_he_whistles_free_kicks_by_the_deputy_s_goal() -> void:
	watch_signals(referee)
	referee.playing = true
	referee.call_foul()
	assert_signal_emitted(referee, "called")
	assert_string_starts_with(referee.said(), "FOOTBALL_REFEREE_CALL_")
	var ball := pitch.to_local(pitch.ball.global_position)
	assert_almost_eq(ball.x, FootballPitch.goal_at(-1.0).x + FootballReferee.FREE_KICK, 0.3, "right by the west goal")
	assert_eq(referee.calls, 1)


func test_a_handball_is_a_free_kick_too() -> void:
	referee.playing = true
	cop.get_node("Grabber").grab(pitch.ball)
	assert_eq(referee.calls, 1)


func test_the_envelope_and_the_thumbs_give_him_away() -> void:
	assert_not_null(referee.get_node("Model/Envelope"))
	assert_not_null(referee.get_node("Model/Pin"))
	assert_eq(referee.prompt_key(cop), "PROMPT_TALK_REFEREE")
	referee.use(cop)
	assert_eq(case.clues, ["envelope"])
	cop.global_position = referee.global_position + Vector3(3, 0.1, 0)
	referee.thumbs_up()
	assert_eq(case.clues, ["envelope", "thumbs"])
	assert_eq(pitch.barullo.said(), "FOOTBALL_BARULLO_NOD")


func test_cuffed_and_in_the_car_he_stops_whistling() -> void:
	referee.cuffed(Handcuffs.SECONDS)
	assert_false(referee.loose())
	referee.call_foul()
	assert_eq(referee.calls, 0, "no calls while cuffed")
	OwnerEscort.of(referee).board()
	assert_true(case.jailed)
	assert_true(case.rows()[3].done)


func test_the_deputy_s_goal_solves_it_and_the_pay_adds_up() -> void:
	assert_false(case.solved())
	pitch.score.scored.emit(FootballScore.Team.LUSTRE, cop)
	assert_false(case.solved(), "a cop's goal is no photo")
	pitch.score.scored.emit(FootballScore.Team.LUSTRE, pitch.politician)
	assert_true(case.solved())
	assert_eq(case.report().salary, FootballCase.SALARY)
	pitch.lustre.injured.emit(1)
	pitch.score.goals = [2, 0]
	OwnerEscort.of(referee).board()
	assert_eq(case.report().salary, FootballCase.SALARY - FootballCase.INJURY + FootballCase.WIN + FootballCase.REFEREE)
	assert_true(case.report().approved)


func test_the_third_injury_sends_him_off_in_an_ambulance() -> void:
	pitch.score.scored.emit(FootballScore.Team.LUSTRE, pitch.politician)
	pitch.lustre.injured.emit(3)
	assert_true(case.ambulance)
	assert_false(case.solved())
	assert_false(pitch.politician.visible)
	assert_eq(case.report().salary, 0)
	await wait_seconds(FootballCase.SHIFT_DELAY + 0.3)
	assert_true(case.shift_over)


func test_the_final_whistle_closes_the_case() -> void:
	pitch.score.scored.emit(FootballScore.Team.LUSTRE, pitch.politician)
	pitch.match_clock.finished.emit()
	assert_true(case.match_over)
	await wait_seconds(FootballCase.SHIFT_DELAY + 0.3)
	assert_true(case.shift_over)
	assert_true(case.solved())


func test_the_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key: String in ["PROMPT_TALK_REFEREE", "FOOTBALL_REFEREE_TALK_2", "FOOTBALL_REFEREE_CALL_3",
			"HINT_FOOTBALL_REFEREE_ENVELOPE", "HINT_FOOTBALL_REFEREE_THUMBS", "HINT_REFEREE_IN_CAR", "BRIEF_FOOTBALL_A",
			"BRIEF_FOOTBALL_C", "HINT_GO_FOOTBALL", "HINT_FOOTBALL_AMBULANCE", "OBJ_FOOTBALL_GOAL", "OBJ_FOOTBALL_INJURIES",
			"FOOTBALL_BARULLO_NOD"]:
		assert_ne(tr(key), key)
