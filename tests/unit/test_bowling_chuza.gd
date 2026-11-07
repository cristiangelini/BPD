extends GutTest

## Don Chuza at the bowling alley (allanamiento-bolera.md, step 3): he walks his round, a strike calls him to that
## lane where he celebrates with his back to the alley, a cop's strike makes the strikes rest and the third one gives
## the cops away, and the league's complaints reach his complaint.

const SCENE := preload("res://scenes/levels/bowling.tscn")


func _alley() -> Bowling:
	var alley: Bowling = SCENE.instantiate()
	alley.case_seed = 5
	alley.get_node("Cop").input_enabled = false
	alley.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(alley)
	for player: BowlPlayer in alley.players:
		player.set_physics_process(false)
	return alley


## A ball that last flew from the cop's hands.
func _cop_ball(alley: Bowling) -> BowlingBall:
	var ball: BowlingBall = alley.balls[0]
	ball.last_holder = alley.get_node("Cop/Grabber").get_instance_id()
	return ball


func test_he_walks_his_round() -> void:
	var alley := _alley()
	assert_not_null(alley.owner_boss)
	assert_eq(alley.owner_boss.voice, "CHUZA")
	var start := alley.owner_boss.global_position
	await wait_seconds(1.5)
	assert_gt(alley.owner_boss.global_position.distance_to(start), 0.8, "on his way")
	assert_eq(alley.owner_boss.complaint, 0.0)


func test_a_cops_strike_calls_him_to_celebrate() -> void:
	var alley := _alley()
	var boss := alley.owner_boss
	boss.start_at(3)
	boss.fix_time = 3.0
	await wait_physics_frames(2)
	alley.rolled.emit(2, Bowling.PINS, _cop_ball(alley))
	assert_true(alley.strike_call.is_jammed, "called")
	assert_eq(alley.strike_call.lane, 2)
	assert_eq(boss.errand(), "printer")
	await wait_seconds(3.0)
	assert_true(boss.is_fixing(), "celebrating")
	assert_almost_eq(boss.global_position.x, Bowling.LANE_X[2], 0.4, "at the lane")
	assert_false(boss.can_see(alley.to_global(Bowling.TILL_ON)), "his back to the alley")
	await wait_seconds(3.5)
	assert_false(boss.is_fixing(), "back to his round")
	assert_false(alley.strike_call.is_jammed)


func test_nine_pins_arent_a_strike() -> void:
	var alley := _alley()
	alley.rolled.emit(2, 9, _cop_ball(alley))
	assert_false(alley.strike_call.is_jammed)


func test_cop_strikes_rest_and_the_third_gives_them_away() -> void:
	var alley := _alley()
	var call := alley.strike_call
	watch_signals(call)
	call.strike(1, true)
	assert_signal_emit_count(call, "called", 1)
	call.fix()
	call.strike(1, true)
	assert_signal_emit_count(call, "called", 1, "resting")
	call.rest_left = 0.0
	call.strike(3, true)
	assert_signal_emit_count(call, "called", 2)
	call.fix()
	call.rest_left = 0.0
	call.strike(3, true)
	assert_signal_emitted(call, "caught_on")
	assert_signal_emit_count(call, "called", 2, "no celebration")
	assert_eq(alley.owner_boss.complaint, Bowling.CAUGHT_ON)


func test_a_players_strike_calls_him_and_doesnt_count() -> void:
	var alley := _alley()
	alley.rolled.emit(0, Bowling.PINS, null)
	assert_true(alley.strike_call.is_jammed)
	assert_eq(alley.strike_call.calls, 0)
	assert_eq(alley.strike_call.rest_left, 0.0)


func test_the_leagues_complaints_reach_him() -> void:
	var alley := _alley()
	alley.players[0].complain("BOWL_PLAYER_PINS")
	assert_eq(alley.owner_boss.complaint, Bowling.PLAYER_COMPLAINT)
	alley.players[0].complain("BOWL_PLAYER_PINS")
	assert_eq(alley.owner_boss.complaint, Bowling.PLAYER_COMPLAINT, "each one's cooldown")
	alley.players[1].complain("BOWL_PLAYER_PINS")
	assert_eq(alley.owner_boss.complaint, Bowling.PLAYER_COMPLAINT * 2)
	for key: String in ["CHUZA_LINE_1", "CHUZA_PRINTER", "CHUZA_FIX_3", "CHUZA_FIX_DONE", "CHUZA_HURT", "CHUZA_DOOR",
			"CHUZA_SAW", "CHUZA_NOTHING", "CHUZA_OFFENDED", "CHUZA_LAWYER", "CHUZA_CAUGHT_ON", "CHUZA_PLAYER",
			"CHUZA_CASE", "CHUZA_SCREEN", "BOWL_STRIKE_SCREEN"]:
		assert_ne(tr(key), key, key)
