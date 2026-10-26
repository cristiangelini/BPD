extends GutTest

## The chess club's boards (infiltracion-ajedrez.md, step 3, decision 175): on each table a board with a game halfway
## through, loose pieces that are grabbed and put down on another square (a move, from the host, legal or not) or
## knocked off, a clock that counts each turn down and passes it to the other side when pressed, and a stool behind
## each seat.

const LEVEL := preload("res://scenes/levels/chess_club.tscn")

var club: ChessClub
var cop: Cop


func before_each() -> void:
	club = LEVEL.instantiate()
	cop = club.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(club)
	await wait_physics_frames(2)


## Puts `piece` down, still, on `square` of `board` (or wherever `at` says, in the world).
func _put(board: ChessBoard, piece: ChessPiece, at: Vector3) -> void:
	piece.global_position = at
	piece.linear_velocity = Vector3.ZERO
	piece.angular_velocity = Vector3.ZERO
	board._check_left = 0.0
	board._physics_process(0.01)


func test_every_table_has_a_board_and_a_clock() -> void:
	assert_eq(club.boards.size(), ChessClub.TABLES.size())
	assert_eq(club.clocks.size(), ChessClub.TABLES.size())
	assert_not_null(club.stage_board, "and the Gran Maestro's on the stage")
	assert_not_null(club.stage_clock)
	for i in club.boards.size():
		var table := club.global_transform * ChessClub.TABLES[i]
		assert_lt(Vector2(club.boards[i].global_position.x - table.x, club.boards[i].global_position.z - table.z)
			.length(), 0.5, "the board on its table")
		assert_true(club.in_hall(club.boards[i].global_position))


func test_a_game_halfway_through_on_each_board() -> void:
	var board := club.boards[0]
	assert_eq(board.pieces.size(), ChessBoard.SETUP.size() * 2)
	var whites := board.pieces.filter(func(piece: ChessPiece) -> bool: return piece.white)
	assert_eq(whites.size(), ChessBoard.SETUP.size())
	for piece in board.pieces:
		assert_true(piece is Grabbable, "a loose body to grab")
		assert_ne(board.square_at(piece.global_position + Vector3.UP * 0.01), ChessBoard.OFF, "on the board")
	assert_eq(board.piece_on(Vector2i(4, 0)).kind, "king")
	assert_true(board.piece_on(Vector2i(4, 0)).white, "white's king on white's side")
	assert_false(board.piece_on(Vector2i(3, 7)).white, "black's king across")
	assert_eq(board.knocked(), 0)


func test_the_squares_and_their_middles_agree() -> void:
	var board := club.boards[2]
	for at: Vector2i in [Vector2i(0, 0), Vector2i(7, 7), Vector2i(3, 5)]:
		assert_eq(board.square_at(board.to_global(ChessBoard.center_of(at))), at)
	assert_eq(board.square_at(board.to_global(Vector3(0.6, 0, 0))), ChessBoard.OFF, "beside the board")
	assert_eq(board.square_at(board.to_global(Vector3(0, -0.5, 0))), ChessBoard.OFF, "under it")


func test_putting_a_piece_on_another_square_is_a_move() -> void:
	var board := club.boards[0]
	var pawn := board.piece_on(Vector2i(4, 1))
	watch_signals(board)
	_put(board, pawn, board.to_global(ChessBoard.center_of(Vector2i(4, 3))))
	assert_signal_emitted_with_parameters(board, "moved", [pawn, Vector2i(4, 1), Vector2i(4, 3)])
	assert_eq(board.piece_on(Vector2i(4, 3)), pawn)
	var knight := board.piece_on(Vector2i(1, 0))
	_put(board, knight, board.to_global(ChessBoard.center_of(Vector2i(7, 6))))
	assert_eq(board.piece_on(Vector2i(7, 6)), knight, "a knight across the whole board: not checked")


func test_a_piece_in_the_hand_isnt_a_move_yet() -> void:
	var board := club.boards[0]
	var queen := board.piece_on(Vector2i(3, 0))
	queen.hold(1, queen.global_position)
	watch_signals(board)
	_put(board, queen, board.to_global(ChessBoard.center_of(Vector2i(3, 4))))
	assert_signal_not_emitted(board, "moved")
	queen.let_go(1)
	_put(board, queen, board.to_global(ChessBoard.center_of(Vector2i(3, 4))))
	assert_signal_emitted(board, "moved")


func test_a_piece_knocked_off_the_board() -> void:
	var board := club.boards[1]
	var rook := board.piece_on(Vector2i(0, 0))
	_put(board, rook, board.to_global(Vector3(0, -0.6, 0.7)))
	assert_eq(board.knocked(), 1)
	assert_null(board.piece_on(Vector2i(0, 0)))


func test_the_clock_passes_the_turn() -> void:
	var clock := club.clocks[0]
	assert_eq(clock.prompt_key(cop), "PROMPT_CHESS_CLOCK")
	watch_signals(clock)
	clock.use(cop)
	assert_signal_not_emitted(clock, "pressed", "stopped, it's only a click")
	clock.start(ChessClock.BLACK)
	clock.left = 3.0
	clock.use(cop)
	assert_signal_emitted_with_parameters(clock, "pressed", [cop, ChessClock.BLACK])
	assert_eq(clock.turn, ChessClock.WHITE)
	assert_eq(clock.left, ChessClock.TURN, "a whole turn for the other side")


func test_the_clock_runs_out() -> void:
	var clock := club.clocks[0]
	watch_signals(clock)
	clock.start(ChessClock.WHITE)
	clock.left = 0.01
	await wait_process_frames(3)
	assert_signal_emitted_with_parameters(clock, "flagged", [ChessClock.WHITE])
	assert_eq(clock.turn, ChessClock.STOPPED)


func test_a_stool_behind_each_seat_leaves_room_to_stand() -> void:
	for seat: Array in ChessClub.seats():
		var at: Vector3 = club.global_transform * (seat[0] + Vector3(0, 1.0, 0))
		var space := club.get_world_3d().direct_space_state
		var query := PhysicsPointQueryParameters3D.new()
		query.position = at + Vector3.DOWN * 0.6
		assert_true(space.intersect_point(query).filter(func(hit: Dictionary) -> bool:
			return hit.collider is StaticBody3D and not hit.collider is ClubMember).is_empty(), "nothing where the player stands")


func test_the_clock_text_is_translated() -> void:
	TranslationServer.set_locale("es")
	assert_ne(tr("PROMPT_CHESS_CLOCK"), "PROMPT_CHESS_CLOCK")
