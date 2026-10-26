extends GutTest

## The ball and the goals (politico-futbol.md, step 2, decision 179): a cop kicks the ball at their feet with left
## click, harder the longer it's held, E passes it, grabbing it is a handball, a ball in the net is a goal for the team
## attacking that end and a ball out comes back in.

const LEVEL := preload("res://scenes/levels/football_pitch.tscn")

var pitch: FootballPitch
var cop: Cop


func before_each() -> void:
	pitch = LEVEL.instantiate()
	pitch.case_seed = 7
	cop = pitch.get_node("Cop")
	cop.input_enabled = false
	cop.get_node("Grabber").input_enabled = false
	add_child_autofree(pitch)
	await wait_physics_frames(3)


## Puts the cop `back` m behind the ball, facing +X (toward the east goal), on the ground.
func _behind_ball(back := 0.7) -> void:
	cop.global_position = pitch.ball.global_position + Vector3(-back, -0.1, 0)
	cop.rotation.y = -PI / 2
	cop.camera.rotation.x = 0.0


func test_the_ball_waits_on_the_center_spot() -> void:
	var at := pitch.to_local(pitch.ball.global_position)
	assert_almost_eq(at.x, FootballPitch.CENTER.x, 0.05)
	assert_almost_eq(at.z, FootballPitch.CENTER.z, 0.05)
	assert_almost_eq(pitch.ball.mass, FootballBall.KG, 0.001)
	assert_true(pitch.ball.continuous_cd, "a hard shot doesn't go through the net")


func test_only_a_ball_in_front_and_close_is_at_the_feet() -> void:
	_behind_ball()
	assert_true(pitch.ball.at_feet(cop))
	assert_eq(FootballBall.near_feet(cop), pitch.ball)
	cop.rotation.y = PI / 2
	assert_false(pitch.ball.at_feet(cop), "behind them it isn't")
	_behind_ball(3.0)
	assert_null(FootballBall.near_feet(cop), "too far")


func test_holding_the_click_kicks_harder() -> void:
	assert_almost_eq(FootballBall.power_for(0.0), FootballBall.KICK_SOFT, 0.01)
	assert_almost_eq(FootballBall.power_for(5.0), FootballBall.KICK_HARD, 0.01)
	_behind_ball()
	var grabber: Grabber = cop.get_node("Grabber")
	assert_true(grabber.start_kick(), "with the ball at the feet the click kicks")
	grabber.kick_held = FootballBall.CHARGE
	grabber.end_kick()
	assert_almost_eq(pitch.ball.linear_velocity.length(), FootballBall.KICK_HARD, 0.5)
	assert_gt(pitch.ball.linear_velocity.x, 15.0, "where the cop looks")
	assert_gt(pitch.ball.linear_velocity.y, 0.0, "a little up")
	assert_eq(pitch.ball.last_touch, cop)
	assert_null(grabber.held, "and nobody holds it")


func test_e_passes_it_along_the_ground() -> void:
	_behind_ball()
	assert_eq(pitch.ball.prompt_key(cop), "PROMPT_KICK_BALL")
	pitch.ball.use(cop)
	assert_almost_eq(pitch.ball.linear_velocity.length(), FootballBall.PASS, 0.5)


func test_grabbing_it_is_a_handball() -> void:
	watch_signals(pitch.score)
	cop.get_node("Grabber").grab(pitch.ball)
	assert_signal_emitted(pitch.score, "handball")


func test_a_shot_into_the_east_net_is_a_goal_for_the_deputy_s_team() -> void:
	watch_signals(pitch.score)
	# The veterans' keeper (step 3) steps aside: this is about the line, not the saves.
	for player: FootballPlayer in pitch.match_clock.players:
		player.global_position += Vector3(0, 0, 40)
	pitch.ball.global_position = pitch.to_global(FootballPitch.goal_at(1.0) + Vector3(-8, 0.3, 0))
	_behind_ball()
	pitch.ball.kick(cop, Vector3(1, 0.05, 0).normalized(), FootballBall.KICK_HARD)
	await wait_until(func() -> bool: return pitch.score.goals[FootballScore.Team.LUSTRE] > 0, 2.0)
	assert_eq(pitch.score.goals, [1, 0])
	assert_signal_emitted_with_parameters(pitch.score, "scored", [FootballScore.Team.LUSTRE, cop])
	await wait_seconds(FootballScore.GOAL_PAUSE + 0.3)
	assert_lt(pitch.ball.global_position.distance_to(pitch.score.center()), 0.5, "back on the center spot")


func test_the_west_net_counts_for_the_veterans() -> void:
	pitch.ball.global_position = pitch.to_global(FootballPitch.goal_at(-1.0) + Vector3(-0.6, 0.3, 0))
	await wait_physics_frames(2)
	assert_eq(pitch.score.goals, [0, 1])


func test_a_ball_out_comes_back_in() -> void:
	pitch.ball.global_position = pitch.to_global(FootballPitch.CENTER + Vector3(5, 0.3, FootballPitch.HALF_WIDTH + 2))
	await wait_seconds(FootballScore.OUT_PAUSE + 0.3)
	assert_true(pitch.on_field(pitch.ball.global_position), "back inside the lines")
	assert_eq(pitch.score.goals, [0, 0], "no goal")


func test_the_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key: String in ["PROMPT_KICK_BALL", "HUD_FOOTBALL_SCORE", "HINT_FOOTBALL_GOAL_LUSTRE"]:
		assert_ne(tr(key), key)
