class_name ChessBoard
extends Node3D

## A chess board on one of the chess club's tables (infiltracion-ajedrez.md, step 3, decision 175): 8 x 8 squares of
## SQUARE, white's side toward +Z (the south seat), and a game halfway through on it (SETUP: a few pieces of each
## color, not the 32, so a cop finds one to move and the club keeps few loose bodies). A piece put down on another
## square, or knocked off the board, is a move (`moved`, from the host): the board doesn't check if it's legal. Its
## origin at the board's top, in its middle. Every number here is (propuesta).

signal moved(piece: ChessPiece, from: Vector2i, to: Vector2i)

const SQUARE := 0.1
const SIZE := 8
## Off the board.
const OFF := Vector2i(-1, -1)
## White's pieces, [kind, column, row]; black's are the same mirrored across the board.
const SETUP := [["rook", 0, 0], ["knight", 1, 0], ["bishop", 2, 0], ["queen", 3, 0], ["king", 4, 0], ["pawn", 4, 1]]
## A piece counts as put down when it rests this slow, this close above the board.
const RESTING := 0.05
const ABOVE := 0.06
const CHECK_EVERY := 0.2
const DARK := Color(0.35, 0.22, 0.12)
const LIGHT := Color(0.92, 0.88, 0.78)

var pieces: Array[ChessPiece] = []
## Where each piece was last put down (by its index in `pieces`), OFF when off the board.
var squares: Array[Vector2i] = []
var _check_left := CHECK_EVERY


func _ready() -> void:
	_build()
	for white: bool in [true, false]:
		for entry: Array in SETUP:
			var piece := ChessPiece.new()
			piece.kind = entry[0]
			piece.white = white
			piece.name = "%s_%s_%d" % [name, entry[0], 0 if white else 1]
			var at := Vector2i(entry[1], entry[2]) if white else Vector2i(SIZE - 1 - entry[1], SIZE - 1 - entry[2])
			add_child(piece)
			piece.position = center_of(at)
			piece.rotation.y = 0.0 if white else PI
			pieces.append(piece)
			squares.append(at)


## The middle of a square, in the board's space.
static func center_of(at: Vector2i) -> Vector3:
	return Vector3((at.x - (SIZE - 1) / 2.0) * SQUARE, 0, ((SIZE - 1) / 2.0 - at.y) * SQUARE)


## The square under a world position, or OFF.
func square_at(at: Vector3) -> Vector2i:
	var local := global_transform.affine_inverse() * at
	var col := floori(local.x / SQUARE + SIZE / 2.0)
	var row := floori(SIZE / 2.0 - local.z / SQUARE)
	if col < 0 or col >= SIZE or row < 0 or row >= SIZE or absf(local.y) > ABOVE:
		return OFF
	return Vector2i(col, row)


## The piece put down on `at`, if any.
func piece_on(at: Vector2i) -> ChessPiece:
	var index := squares.find(at)
	return pieces[index] if index != -1 and at != OFF else null


## How many pieces are off the board.
func knocked() -> int:
	return squares.count(OFF)


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	_check_left -= delta
	if _check_left > 0.0:
		return
	_check_left = CHECK_EVERY
	for i in pieces.size():
		var piece := pieces[i]
		if piece.is_held() or piece.linear_velocity.length() > RESTING:
			continue
		var now := square_at(piece.global_position)
		if now != squares[i]:
			var was := squares[i]
			squares[i] = now
			moved.emit(piece, was, now)


## The squares, the border and the board's base.
func _build() -> void:
	var base := MeshInstance3D.new()
	var slab := BoxMesh.new()
	slab.size = Vector3(SQUARE * SIZE + 0.06, 0.02, SQUARE * SIZE + 0.06)
	base.mesh = slab
	base.position.y = -0.011
	base.material_override = _material(DARK.darkened(0.3))
	add_child(base)
	var light := _material(LIGHT)
	var dark := _material(DARK)
	for col in SIZE:
		for row in SIZE:
			var square := MeshInstance3D.new()
			var tile := BoxMesh.new()
			tile.size = Vector3(SQUARE, 0.002, SQUARE)
			square.mesh = tile
			square.position = center_of(Vector2i(col, row)) + Vector3(0, -0.001, 0)
			square.material_override = light if (col + row) % 2 == 1 else dark
			add_child(square)


static func _material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	return material
