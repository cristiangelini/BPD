class_name ChessGames
extends Node

## The chess club's games (infiltracion-ajedrez.md, step 4, decision 175): FIRST seconds in and then every EVERY
## seconds a member at a table with a free seat across challenges a cop in the club ("¡Tú, el nuevo! ¿Una partida?").
## The cop has JOIN seconds to stand at that seat; then they play GAME seconds in turns on the table's clock: the
## member moves one of his pieces and hits the clock, and the cop has ChessClock.TURN seconds to move a piece with the
## hands (ChessBoard.moved, legal or not, the member only comments) and hit the clock. Not showing up, running out of
## time or standing up in the middle end the game and make the members in the hall suspicious, and knocking the board
## over (KNOCK pieces off) much more; hitting the clock without a move, a little. At the end the member is pleased and
## tells some gossip. The host decides all of it and tells the guests. Every number here is (propuesta).

signal challenged(table: int, cop: Cop)
signal started(table: int)
signal failed(amount: float)
signal finished(table: int)

const FIRST := 20.0
const EVERY := 45.0
const JOIN := 15.0
const GAME := 60.0
## How long the member thinks before his move.
const THINK := 2.0
const NO_SHOW := 20.0
const TIME := 20.0
const LEFT := 30.0
const KNOCKED := 40.0
const NO_MOVE := 10.0
## A cop this close (m, on the floor) to the seat is sitting at it; further than LEAVE in a game, he stood up.
const SEAT_REACH := 0.7
const LEAVE := 1.5
## This many pieces off the board is the board knocked over.
const KNOCK := 3
const COMMENTS := 5
const IDLE := 0
const WAITING := 1
const PLAYING := 2

var club: ChessClub
var case_seed := 0
var state := IDLE
## Seconds to the next challenge (host).
var next_left := FIRST
## The game's table (by ChessClub.TABLES), the member who challenged, the cop and the seat he plays from.
var table := -1
var challenger: ClubMember
var cop: Cop
var seat: Array = []
## The cop's side on the clock (white from the south seat) and whether he moved this turn.
var cop_side := ChessClock.WHITE
var moved := false
## Seconds left to sit down, of the game, and of the member's thinking (-1 when it isn't his turn to move).
var join_left := 0.0
var game_left := 0.0
var think_left := -1.0
var _rng := RandomNumberGenerator.new()
var _comment := 0


func _ready() -> void:
	_rng.seed = hash(["chess games", case_seed])
	for i in club.boards.size():
		club.boards[i].moved.connect(_on_moved.bind(i))
		club.clocks[i].pressed.connect(_on_pressed.bind(i))
		club.clocks[i].flagged.connect(_on_flagged.bind(i))


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	match state:
		IDLE:
			next_left -= delta
			if next_left <= 0.0:
				challenge()
		WAITING:
			join_left -= delta
			if cop_at_seat():
				_start()
			elif join_left <= 0.0:
				_fail(NO_SHOW, "CHESS_NO_SHOW")
		PLAYING:
			_play(delta)


## Host: a member at a table with a free seat across challenges a cop in the club (this one: tests and the debug
## panel). Nothing if there's no cop in the club or no such table.
func challenge(who: Cop = null) -> bool:
	next_left = EVERY
	if state != IDLE:
		return false
	if not who:
		var inside := club.get_tree().get_nodes_in_group("cops").filter(func(one: Cop) -> bool:
			return club.is_inside(one.global_position))
		if inside.is_empty():
			return false
		who = inside[_rng.randi_range(0, inside.size() - 1)]
	var options := _open_tables()
	if options.is_empty():
		return false
	var pick: Array = options[_rng.randi_range(0, options.size() - 1)]
	table = pick[0]
	challenger = pick[1]
	seat = pick[2]
	cop = who
	cop_side = ChessClock.WHITE if seat[1] == 0.0 else ChessClock.BLACK
	state = WAITING
	join_left = JOIN
	challenger.say("CHESS_CHALLENGE")
	cop.show_hint("HINT_CHESS_CHALLENGED")
	challenged.emit(table, cop)
	return true


## Whether the challenged cop stands at his seat.
func cop_at_seat() -> bool:
	if not cop or seat.is_empty():
		return false
	var at: Vector3 = club.global_transform * seat[0]
	return Vector2(cop.global_position.x - at.x, cop.global_position.z - at.z).length() < SEAT_REACH


## The tables with one member at a seat and the seat across free: [table, member, free seat].
func _open_tables() -> Array[Array]:
	var open: Array[Array] = []
	var seats := ChessClub.seats()
	for i in ChessClub.TABLES.size():
		var taken: Array[ClubMember] = []
		for side in 2:
			taken.append(_member_at(seats[i * 2 + side][0]))
		if taken[0] and not taken[1]:
			open.append([i, taken[0], seats[i * 2 + 1]])
		elif taken[1] and not taken[0]:
			open.append([i, taken[1], seats[i * 2]])
	return open


func _member_at(at: Vector3) -> ClubMember:
	for member in club.members:
		if Vector2(member.position.x - at.x, member.position.z - at.z).length() < 0.1:
			return member
	return null


func _start() -> void:
	state = PLAYING
	game_left = GAME
	club.boards[table].reset()
	_clock().start(1 - cop_side)
	think_left = THINK
	started.emit(table)


func _play(delta: float) -> void:
	game_left -= delta
	if _seat_distance() > LEAVE:
		_fail(LEFT, "CHESS_LEFT")
		return
	if game_left <= 0.0:
		_finish()
		return
	if think_left >= 0.0:
		think_left -= delta
		if think_left < 0.0:
			_member_moves()


func _seat_distance() -> float:
	var at: Vector3 = club.global_transform * seat[0]
	return Vector2(cop.global_position.x - at.x, cop.global_position.z - at.z).length()


## The member moves one of his pieces still on the board to an empty square and hits the clock.
func _member_moves() -> void:
	var board := club.boards[table]
	var mine: Array[int] = []
	for i in board.pieces.size():
		if board.pieces[i].white != (cop_side == ChessClock.WHITE) and board.squares[i] != ChessBoard.OFF:
			mine.append(i)
	if not mine.is_empty():
		var index := mine[_rng.randi_range(0, mine.size() - 1)]
		var to := Vector2i(_rng.randi_range(0, ChessBoard.SIZE - 1), _rng.randi_range(0, ChessBoard.SIZE - 1))
		if not board.piece_on(to):
			board.put(index, to)
	moved = false
	_clock().use(null)
	cop.show_hint("HINT_CHESS_YOUR_TURN")


func _on_moved(piece: ChessPiece, _from: Vector2i, _to: Vector2i, at: int) -> void:
	if state != PLAYING or at != table:
		return
	if club.boards[table].knocked() >= KNOCK:
		_fail(KNOCKED, "CHESS_KNOCKED")
		return
	if _clock().turn != cop_side:
		return
	moved = true
	if piece.white != (cop_side == ChessClock.WHITE):
		challenger.say("CHESS_NOT_YOURS")


func _on_pressed(_by: Cop, side: int, at: int) -> void:
	if state != PLAYING or at != table or side != cop_side:
		return
	if moved:
		challenger.say("CHESS_COMMENT_%d" % (_comment % COMMENTS))
		_comment += 1
	else:
		challenger.say("CHESS_NO_MOVE")
		_raise(NO_MOVE)
	think_left = THINK


func _on_flagged(side: int, at: int) -> void:
	if state == PLAYING and at == table and side == cop_side:
		_fail(TIME, "CHESS_TIME")


## The game ends well: the member is pleased and tells some gossip.
func _finish() -> void:
	var done := table
	challenger.say("CHESS_GG")
	_end()
	finished.emit(done)


## The game ends badly: `line` from the member and the hall's members get suspicious.
func _fail(amount: float, line: String) -> void:
	challenger.say(line)
	_raise(amount)
	_end()
	failed.emit(amount)


func _raise(amount: float) -> void:
	for member in club.members:
		if club.in_hall(member.global_position + Vector3.UP):
			club.suspicion.raise(member, amount)


func _end() -> void:
	if table != -1:
		_clock().stop()
	state = IDLE
	next_left = EVERY
	think_left = -1.0
	table = -1
	seat = []


func _clock() -> ChessClock:
	return club.clocks[table]
