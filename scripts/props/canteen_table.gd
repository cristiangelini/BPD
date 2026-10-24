class_name CanteenTable
extends AnimatableBody3D

## A canteen table with its benches (carcel-motin.md, step 3, decision 104), bolted together and heavy. E knocks it
## over toward the cop, onto its side: the top stands up as a wall between the cop and the inmates beyond it, and the
## inmates standing on that side jump back, upset (PrisonRiot listens to `tipped`). E again sets it back on its legs.
## Its origin is on the ground in its middle, long along X. Online, E happens on every PC (ActionSync), each one turning
## it the same way. Every number here is (propuesta).

signal tipped(table: CanteenTable, side: float)

const MODEL := preload("res://assets/models/canteen_table.glb")
const PARTS: Array[Array] = [[Vector3(0, 0.76, 0), Vector3(4.0, 0.06, 0.9)],
	[Vector3(0, 0.24, -0.75), Vector3(3.8, 0.48, 0.32)], [Vector3(0, 0.24, 0.75), Vector3(3.8, 0.48, 0.32)]]
## It turns on the floor under its bench's outer edge on the cop's side.
const PIVOT_Z := 0.95
const TIP_TIME := 0.4

## 0 on its legs; +1 or -1, the side (local Z) it fell toward.
var tipped_side := 0.0
var _standing: Transform3D
var _turn: Tween


func _ready() -> void:
	add_to_group("canteen_tables")
	_standing = transform
	add_child(MODEL.instantiate())
	for part in PARTS:
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = part[1]
		shape.shape = box
		shape.position = part[0]
		add_child(shape)


func prompt_key(_cop: Cop) -> String:
	return "PROMPT_RAISE_TABLE" if tipped_side != 0.0 else "PROMPT_TIP_TABLE"


func use(cop: Cop) -> void:
	if tipped_side != 0.0:
		_turn_to(_standing)
		tipped_side = 0.0
		return
	var side := 1.0 if (_standing.affine_inverse() * cop.global_position).z >= 0.0 else -1.0
	tip(side)


## Over onto its side toward local `side` (+1 or -1 on Z): the top ends up standing between that side and the other.
func tip(side: float) -> void:
	if tipped_side != 0.0:
		return
	tipped_side = side
	var pivot := Vector3(0, 0, side * PIVOT_Z)
	var over := Transform3D(Basis(Vector3.RIGHT, side * PI / 2), Vector3.ZERO)
	_turn_to(_standing * Transform3D(Basis.IDENTITY, pivot) * over * Transform3D(Basis.IDENTITY, -pivot))
	tipped.emit(self, side)


func is_tipped() -> bool:
	return tipped_side != 0.0


func _turn_to(to: Transform3D) -> void:
	if _turn:
		_turn.kill()
	if not is_inside_tree():
		transform = to
		return
	_turn = create_tween()
	_turn.tween_property(self, "transform", to, TIP_TIME)
