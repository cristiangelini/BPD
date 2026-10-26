extends GutTest

## The match (politico-futbol.md, step 3, decision 179): everyone waits until a cop steps onto the field, 2 halves with
## a break, the nearest veteran goes for the ball and kicks it at the west goal, the keeper stops a slow shot and lets a
## hard one in, the advisors stand, and the deputy runs for the ball and kicks it badly.

const LEVEL := preload("res://scenes/levels/football_pitch.tscn")

var pitch: FootballPitch
var game: FootballMatch
var cop: Cop


func before_each() -> void:
	pitch = LEVEL.instantiate()
	pitch.case_seed = 7
	cop = pitch.get_node("Cop")
	cop.input_enabled = false
	cop.get_node("Grabber").input_enabled = false
	add_child_autofree(pitch)
	await wait_physics_frames(3)
	game = pitch.match_clock


func _player(role: String) -> FootballPlayer:
	for player in game.players:
		if player.role == role:
			return player
	return null


func test_seven_veterans_and_two_advisors_wait_in_their_spots() -> void:
	assert_eq(game.players.filter(func(p: FootballPlayer) -> bool: return p.team == FootballScore.Team.VETERANS).size(), 7)
	assert_eq(game.players.filter(func(p: FootballPlayer) -> bool: return p.role == "advisor").size(), 2)
	assert_eq(game.state, FootballMatch.State.WAITING)
	await wait_physics_frames(30)
	var veteran := _player("veteran")
	assert_lt(Vector2(veteran.position.x - veteran.home.x, veteran.position.z - veteran.home.z).length(), 0.3,
		"nobody moves before the match")


func test_a_cop_on_the_field_starts_it_and_gets_a_bib() -> void:
	cop.global_position = pitch.to_global(FootballPitch.CENTER + Vector3(-5, 0.1, 0))
	await wait_physics_frames(2)
	assert_eq(game.state, FootballMatch.State.FIRST)
	assert_true(cop.has_node("Bib"), "they play on the deputy's team")


func test_two_halves_with_a_break() -> void:
	watch_signals(game)
	game.start()
	game.left = 0.01
	await wait_physics_frames(2)
	assert_eq(game.state, FootballMatch.State.BREAK)
	assert_signal_emitted(game, "half_time")
	assert_false(_player("veteran").playing, "nobody plays in the break")
	game.left = 0.01
	await wait_physics_frames(2)
	assert_eq(game.state, FootballMatch.State.SECOND)
	game.left = 0.01
	await wait_physics_frames(2)
	assert_eq(game.state, FootballMatch.State.OVER)
	assert_signal_emitted(game, "finished")
	assert_almost_eq(game.played(), FootballMatch.HALF * 2, 0.01)


func test_the_nearest_veteran_goes_for_the_ball_and_kicks_it_west() -> void:
	game.start()
	pitch.ball.global_position = pitch.to_global(FootballPitch.CENTER + Vector3(12, 0.2, -3))
	await wait_physics_frames(2)
	var chasers := game.players.filter(func(p: FootballPlayer) -> bool: return p.chaser)
	assert_eq(chasers.size(), 1, "one veteran goes for it")
	watch_signals(pitch.ball)
	await wait_until(func() -> bool: return pitch.ball.last_touch is FootballPlayer, 6.0)
	assert_true(pitch.ball.last_touch is FootballPlayer, "he got there and kicked it")
	assert_lt(pitch.ball.linear_velocity.x, 0.0, "toward the west goal")


func test_the_keeper_stops_a_slow_shot_but_not_a_hard_one() -> void:
	game.start()
	var keeper := _player("keeper")
	await wait_physics_frames(2)
	pitch.ball.global_position = keeper.global_position + Vector3(-2.5, 0.5, 0)
	pitch.ball.kick(cop, Vector3(1, 0, 0), 6.0)
	await wait_physics_frames(30)
	assert_eq(pitch.ball.last_touch, keeper, "a slow one he stops")
	assert_eq(pitch.score.goals[FootballScore.Team.LUSTRE], 0)
	assert_true(FootballPlayer.SAVE_SPEED < FootballBall.KICK_HARD, "a full kick beats him")


func test_the_deputy_runs_for_the_ball_and_kicks_it() -> void:
	# Only him on the field, so no veteran gets there first.
	pitch.lustre.playing = true
	var deputy := pitch.politician
	pitch.ball.global_position = deputy.global_position + Vector3(-3, 0.2, 0)
	pitch.ball.linear_velocity = Vector3.ZERO
	await wait_until(func() -> bool: return pitch.lustre.kicks > 0, 5.0)
	assert_eq(pitch.lustre.kicks, 1)
	assert_eq(pitch.ball.last_touch, deputy)
	assert_string_starts_with(deputy.said(), "FOOTBALL_LUSTRE_KICK_")


func test_the_deputy_aims_badly() -> void:
	game.start()
	var on_target := 0
	var goal := pitch.to_global(FootballPitch.goal_at(1.0))
	for i in 60:
		pitch.ball.global_position = pitch.to_global(FootballPitch.CENTER + Vector3(0, 0.2, 0))
		pitch.ball.linear_velocity = Vector3.ZERO
		pitch.lustre.kick()
		var v := pitch.ball.linear_velocity
		var to := goal - pitch.ball.global_position
		if Vector2(v.x, v.z).angle_to(Vector2(to.x, to.z)) < 0.15 and Vector2(v.x, v.z).angle_to(Vector2(to.x, to.z)) > -0.15:
			on_target += 1
	assert_between(on_target, 10, 35, "about one in three at the goal from the middle")


func test_the_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key: String in ["FOOTBALL_KEEPER_SAVE", "FOOTBALL_LUSTRE_KICK_4", "HUD_FOOTBALL_CLOCK", "HINT_FOOTBALL_HALF_TIME"]:
		assert_ne(tr(key), key)
