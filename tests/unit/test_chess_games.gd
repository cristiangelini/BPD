extends GutTest

## The chess club's games (infiltracion-ajedrez.md, step 4, decision 175): a member challenges a cop, the cop stands
## at the free seat across and they play on the clock: the member moves and hits it, the cop moves a piece with his
## hands and hits it. Not showing up, running out of time, standing up and knocking the board over make the hall
## suspicious; playing to the end pleases the member.

const LEVEL := preload("res://scenes/levels/chess_club.tscn")

var club: ChessClub
var cop: Cop
var games: ChessGames


func before_each() -> void:
	club = LEVEL.instantiate()
	cop = club.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(club)
	await wait_physics_frames(2)
	games = club.games
	games.set_physics_process(false)


func _step(seconds: float) -> void:
	var left := seconds
	while left > 0.0:
		games._physics_process(minf(left, 0.1))
		left -= 0.1


func _hall_suspicion() -> float:
	var total := 0.0
	for member in club.members:
		total += member.suspicion
	return total


## The cop challenged and standing at his seat, the game on.
func _sit() -> void:
	assert_true(games.challenge(cop))
	cop.global_position = club.global_transform * (games.seat[0] + Vector3(0, 0.1, 0))
	_step(0.1)
	assert_eq(games.state, ChessGames.PLAYING)


## The cop moves one of his pieces to an empty square.
func _cop_moves() -> void:
	var board := club.boards[games.table]
	for i in board.pieces.size():
		if board.pieces[i].white == (games.cop_side == ChessClock.WHITE) and board.squares[i] != ChessBoard.OFF:
			for col in ChessBoard.SIZE:
				var to := Vector2i(col, 4)
				if not board.piece_on(to):
					board.pieces[i].global_position = board.to_global(ChessBoard.center_of(to))
					board._check_left = 0.0
					board._physics_process(0.01)
					return


func test_the_first_challenge_comes_after_a_while() -> void:
	assert_eq(games.state, ChessGames.IDLE)
	assert_almost_eq(games.next_left, ChessGames.FIRST, 0.5)


func test_a_member_challenges_a_cop_from_a_table_with_a_free_seat() -> void:
	watch_signals(games)
	assert_true(games.challenge(cop))
	assert_signal_emitted(games, "challenged")
	assert_eq(games.state, ChessGames.WAITING)
	assert_eq(games.challenger.said(), "CHESS_CHALLENGE")
	assert_eq(games._member_at(games.seat[0]), null, "the seat is free")
	assert_true(club.in_hall(games.challenger.global_position + Vector3.UP))
	assert_false(games.challenge(cop), "one game at a time")


func test_no_cop_in_the_club_no_challenge() -> void:
	assert_false(club.is_inside(cop.global_position), "the cops start at the station")
	games.next_left = 0.0
	_step(0.1)
	assert_eq(games.state, ChessGames.IDLE)


func test_not_showing_up_raises_the_hall() -> void:
	games.challenge(cop)
	watch_signals(games)
	_step(ChessGames.JOIN + 0.2)
	assert_signal_emitted_with_parameters(games, "failed", [ChessGames.NO_SHOW])
	assert_eq(games.state, ChessGames.IDLE)
	assert_gt(_hall_suspicion(), 0.0)


func test_sitting_down_starts_the_game_with_the_members_move() -> void:
	await _sit()
	var clock := club.clocks[games.table]
	assert_eq(clock.turn, 1 - games.cop_side, "the member's turn first")
	_step(ChessGames.THINK + 0.1)
	assert_eq(clock.turn, games.cop_side, "he moved and hit the clock")


func test_the_cops_move_and_the_clock() -> void:
	await _sit()
	_step(ChessGames.THINK + 0.1)
	_cop_moves()
	assert_true(games.moved)
	club.clocks[games.table].use(cop)
	assert_true(games.challenger.said().begins_with("CHESS_COMMENT_"))
	assert_eq(_hall_suspicion(), 0.0)


func test_the_clock_without_a_move_is_a_little_suspicious() -> void:
	await _sit()
	_step(ChessGames.THINK + 0.1)
	club.clocks[games.table].use(cop)
	assert_eq(games.challenger.said(), "CHESS_NO_MOVE")
	assert_gt(_hall_suspicion(), 0.0)
	assert_eq(games.state, ChessGames.PLAYING, "the game goes on")


func test_running_out_of_time_loses() -> void:
	await _sit()
	_step(ChessGames.THINK + 0.1)
	watch_signals(games)
	club.clocks[games.table].flagged.emit(games.cop_side)
	assert_signal_emitted_with_parameters(games, "failed", [ChessGames.TIME])
	assert_eq(club.clocks[0].turn, ChessClock.STOPPED)


func test_standing_up_in_the_middle() -> void:
	await _sit()
	watch_signals(games)
	cop.global_position += club.global_basis.x * 3.0
	_step(0.1)
	assert_signal_emitted_with_parameters(games, "failed", [ChessGames.LEFT])


func test_knocking_the_board_over() -> void:
	await _sit()
	var board := club.boards[games.table]
	watch_signals(games)
	for i in ChessGames.KNOCK:
		board.pieces[i].global_position = board.to_global(Vector3(0, -0.6, 0.8 + i * 0.1))
	board._check_left = 0.0
	board._physics_process(0.01)
	assert_signal_emitted_with_parameters(games, "failed", [ChessGames.KNOCKED])
	assert_eq(games.challenger.said(), "CHESS_KNOCKED")


func test_playing_to_the_end_pleases_him() -> void:
	await _sit()
	watch_signals(games)
	games.game_left = 0.05
	_step(0.1)
	assert_signal_emitted(games, "finished")
	assert_eq(games.challenger.said(), "CHESS_GG")
	assert_eq(_hall_suspicion(), 0.0)


func test_a_new_game_sets_the_board_up_again() -> void:
	var board := club.boards[0]
	board.put(0, Vector2i(7, 4))
	board.reset()
	assert_eq(board.piece_on(Vector2i(0, 0)), board.pieces[0])


func test_the_game_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	var keys: Array[String] = ["CHESS_CHALLENGE", "HINT_CHESS_CHALLENGED", "HINT_CHESS_YOUR_TURN", "CHESS_NO_SHOW",
		"CHESS_TIME", "CHESS_LEFT", "CHESS_KNOCKED", "CHESS_NO_MOVE", "CHESS_NOT_YOURS", "CHESS_GG"]
	for i in ChessGames.COMMENTS:
		keys.append("CHESS_COMMENT_%d" % i)
	for key in keys:
		assert_ne(tr(key), key)
