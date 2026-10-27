extends GutTest

## The alley's balls and pins (allanamiento-bolera.md, step 2): three balls on each rack, a ball rolled down a lane
## knocks pins down, comes back to its rack from the pit and the machine counts the pins and sets them up again; a cop
## running on a waxed lane skates.

const SCENE := preload("res://scenes/levels/bowling.tscn")


func _alley() -> Bowling:
	var alley: Bowling = SCENE.instantiate()
	alley.case_seed = 5
	alley.get_node("Cop").input_enabled = false
	alley.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(alley)
	# The league players bowl on their own (test_bowling_players.gd); here they wait.
	for player: BowlPlayer in alley.players:
		player.set_physics_process(false)
	return alley


func test_nine_balls_rest_on_their_racks() -> void:
	var alley := _alley()
	assert_eq(alley.balls.size(), 9)
	await wait_physics_frames(60)
	for ball: BowlingBall in alley.balls:
		assert_between(ball.mass, 4.0, 7.0)
		assert_lt(ball.position.distance_to(Bowling.rack_spot(ball.rack, ball.slot)), 0.05, ball.name)


func test_a_ball_rolled_down_a_lane_knocks_pins_and_comes_back() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	watch_signals(alley)
	var ball: BowlingBall = alley.balls[4]
	ball.position = Vector3(Bowling.LANE_X[2], Bowling.FLOOR_TOP + BowlingBall.RADIUS + 0.01, 3.0)
	ball.linear_velocity = alley.global_basis * Vector3(0, 0, -8.0)
	await wait_seconds(2.5)
	assert_gt(alley.knocked(2), 0, "pins down")
	assert_eq(alley.knocked(1), 0, "the next lane's stand")
	await wait_seconds(Bowling.RETURN_TIME + 0.5)
	assert_lt(ball.position.distance_to(Bowling.rack_spot(ball.rack, ball.slot)), 0.3, "back on its rack")
	await wait_seconds(Bowling.RESET_TIME - Bowling.RETURN_TIME + 0.5)
	assert_signal_emitted(alley, "rolled")
	var params: Array = get_signal_parameters(alley, "rolled")
	assert_eq(params[0], 2)
	assert_gt(params[1], 0)
	assert_eq(params[2], ball)
	assert_eq(alley.knocked(2), 0, "set up again")


func test_a_cop_running_on_a_lane_skates_walking_doesnt() -> void:
	var alley := _alley()
	await wait_physics_frames(2)
	var cop: Cop = alley.get_node("Cop")
	cop.global_position = alley.to_global(Vector3(Bowling.LANE_X[3], 0.2, 0.0))
	cop.is_running = false
	cop.velocity = alley.global_basis * Vector3(0, 0, -2.0)
	alley._skate(0.1)
	assert_false(cop.is_staggered(), "walking is fine")
	cop.is_running = true
	cop.velocity = alley.global_basis * Vector3(0, 0, -5.0)
	alley._skate(0.1)
	assert_true(cop.is_staggered(), "running skates")
	assert_true(Bowling.on_lane(Vector3(Bowling.LANE_X[0], 0, 0)))
	assert_false(Bowling.on_lane(Vector3(5.0, 0, 0)), "the carpet isn't waxed")
	assert_ne(tr("HINT_BOWL_SKATE"), "HINT_BOWL_SKATE")
