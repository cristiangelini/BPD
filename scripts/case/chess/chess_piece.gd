class_name ChessPiece
extends Grabbable

## A chess piece on one of the chess club's boards (infiltracion-ajedrez.md, step 3, decision 175): a pawn, a rook, a
## knight, a bishop, a queen or a king, white or black. A loose body like any other: grabbed and put down on another
## square it's a move (ChessBoard), knocked over it rolls. The board's pieces are made with the level on every PC, so
## online they are kept the same like the other props (PropSync).

const KINDS: Array[String] = ["pawn", "rook", "knight", "bishop", "queen", "king"]
const HEIGHTS := {"pawn": 0.1, "rook": 0.13, "knight": 0.14, "bishop": 0.15, "queen": 0.15, "king": 0.17}
const WIDTH := 0.06

var kind := "pawn"
var white := true


func _ready() -> void:
	add_to_group("chess_pieces")
	mass = 0.15
	collision_layer = 4
	collision_mask = 15
	can_sleep = true
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(WIDTH, HEIGHTS[kind], WIDTH)
	shape.shape = box
	shape.position.y = box.size.y / 2
	add_child(shape)
	var model: PackedScene = load("res://assets/models/chess_%s_%s.glb" % [kind, "white" if white else "black"])
	add_child(model.instantiate())


## Whether it stands about upright.
func is_upright() -> bool:
	return global_basis.y.dot(Vector3.UP) > 0.8
