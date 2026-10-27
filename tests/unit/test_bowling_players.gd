extends GutTest

## The Thursday league's players (allanamiento-bolera.md, step 2): two on each league lane, each bowls a ball from the
## rack about every 20 s even with a cop on the lane, a bowled ball trips the cop it hits, and they complain (once
## every 10 s each) about a cop in the way, a taken ball, their pins knocked down or their screen broken.

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


func test_six_players_wait_by_their_lanes() -> void:
	var alley := _alley()
	assert_eq(alley.players.size(), 6)
	var lanes := {}
	for player: BowlPlayer in alley.players:
		assert_true(Bowling.LEAGUE_LANES.has(player.lane))
		lanes[player.lane] = lanes.get(player.lane, 0) + 1
		assert_false(Bowling.on_lane(player.position), "they wait off the lane")
	for lane: int in Bowling.LEAGUE_LANES:
		assert_eq(lanes[lane], 2, "two on lane %d" % lane)
	var first: Array = alley.players.map(func(p: BowlPlayer) -> float: return p.next_throw)
	assert_ne(first[0], first[1], "the two on a lane take turns")
	for key: String in ["PROMPT_TALK_BOWLER", "BOWL_PLAYER_THROW_1", "BOWL_PLAYER_IN_WAY", "BOWL_PLAYER_NO_BALL",
			"BOWL_PLAYER_GRABBED", "BOWL_PLAYER_PINS", "BOWL_PLAYER_SCREEN", "BOWL_PLAYER_TALK_4", "HINT_BOWL_HIT"]:
		assert_ne(tr(key), key, key)


func test_a_player_bowls_a_ball_from_the_rack_down_the_lane() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	var player: BowlPlayer = alley.players[0]
	player.next_throw = 0.0
	player.set_physics_process(true)
	await wait_seconds(BowlPlayer.STEP_UP + 0.2)
	assert_not_null(player.ball, "a ball in hand")
	assert_eq(player.ball.rack, Bowling.rack_of(player.lane), "from the lane's rack")
	assert_true(player.ball.bowled)
	assert_almost_eq(player.next_throw, BowlPlayer.THROW_EVERY, 1.5, "the next one in 20 s")
	await wait_seconds(3.5)
	assert_gt(alley.knocked(player.lane), 0, "pins down")
	assert_eq(player.complaints, 0, "nobody in the way")
	await wait_seconds(0.5)
	assert_almost_eq(player.position.z, player.home.z, 0.05, "back home")


func test_a_cop_on_the_lane_gets_a_complaint_and_a_ball() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	watch_signals(alley)
	var cop: Cop = alley.get_node("Cop")
	var player: BowlPlayer = alley.players[0]
	cop.global_position = alley.to_global(Vector3(Bowling.LANE_X[player.lane], 0.1, 1.5))
	cop.velocity = Vector3.ZERO
	assert_true(alley.cop_on_lane(player.lane))
	assert_false(alley.cop_on_lane(1), "not on the next lane")
	player.rng.seed = 1
	player.next_throw = 0.0
	player.set_physics_process(true)
	await wait_physics_frames(2)
	assert_signal_emitted(alley, "player_complained")
	assert_eq(player.said(), "BOWL_PLAYER_IN_WAY")
	await wait_seconds(BowlPlayer.STEP_UP + 1.0)
	assert_true(cop.is_staggered(), "the ball tripped the cop")


func test_complaints_come_once_every_ten_seconds() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	var player: BowlPlayer = alley.players[2]
	watch_signals(player)
	player.complain("BOWL_PLAYER_PINS")
	player.complain("BOWL_PLAYER_PINS")
	assert_signal_emit_count(player, "complained", 1)
	player._since_complaint = BowlPlayer.COMPLAIN_EVERY
	player.complain("BOWL_PLAYER_SCREEN")
	assert_signal_emit_count(player, "complained", 2)


func test_what_they_complain_about() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	var cop: Cop = alley.get_node("Cop")
	var grabber_id := cop.get_node("Grabber").get_instance_id()
	var player: BowlPlayer = alley.players[2]
	# A cop's ball knocked their pins down.
	var ball: BowlingBall = alley.balls[0]
	ball.last_holder = grabber_id
	alley.rolled.emit(player.lane, 4, ball)
	assert_eq(player.complaints, 1, "their pins")
	# Their lane's screen broke.
	player._since_complaint = BowlPlayer.COMPLAIN_EVERY
	alley.break_screen(player.lane)
	assert_eq(player.complaints, 2, "their screen")
	# A cop took the ball they bowled.
	player._since_complaint = BowlPlayer.COMPLAIN_EVERY
	player.ball = alley.balls[3]
	player.ball.bowled = true
	player.ball.hold(grabber_id, player.ball.global_position)
	player._physics_process(0.1)
	assert_eq(player.complaints, 3, "their ball")
	assert_null(player.ball)
	# The cops took every ball off the rack.
	player._since_complaint = BowlPlayer.COMPLAIN_EVERY
	for rack_ball: BowlingBall in alley.balls:
		if rack_ball.rack == Bowling.rack_of(player.lane):
			rack_ball.hold(grabber_id, rack_ball.global_position)
	assert_null(alley.rack_ball(Bowling.rack_of(player.lane)))
	player._try_throw()
	assert_eq(player.complaints, 4, "no balls")
	assert_eq(player.said(), "BOWL_PLAYER_NO_BALL")
