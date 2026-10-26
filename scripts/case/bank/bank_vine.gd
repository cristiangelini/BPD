class_name BankVine
extends StaticBody3D

## A vine wall grown from a handful of seeds a gardener robber threw (robo-banco-semillas.md, step 2, decision 129). It
## grows from the floor to its full SIZE in GROW_TIME and stops the cops (and what they throw) but not the gang, who know
## the way through the leaves (it's on the props' layer, which robbers don't collide with). After LIFE it dries up
## and falls away. A cop with pruning shears in hand cuts it, one snip per E, SNIPS snips in all: two cops with shears
## cut it in half the time. Its origin is on the floor at its middle, its face to local ±Z. Every number here is
## (propuesta).

signal cut_now(vine: BankVine)

const SIZE := Vector3(3.0, 2.0, 0.4)
const GROW_TIME := 3.0
const LIFE := 30.0
const DRY_TIME := 1.5
const SNIPS := 4
const GREEN := Color(0.2, 0.5, 0.2)
const DRY := Color(0.55, 0.45, 0.25)
## How many leafy lumps make the wall.
const LUMPS := 9

var grown := 0.0
var life_left := LIFE
var snips_left := SNIPS
var drying := false
var _box: BoxShape3D
var _shape: CollisionShape3D
var _leaves: Node3D
var _paint: StandardMaterial3D


func _ready() -> void:
	add_to_group("bank_vines")
	collision_layer = 4
	collision_mask = 0
	_box = BoxShape3D.new()
	_shape = CollisionShape3D.new()
	_shape.shape = _box
	add_child(_shape)
	_paint = StandardMaterial3D.new()
	_paint.albedo_color = GREEN
	_leaves = Node3D.new()
	_leaves.name = "Leaves"
	add_child(_leaves)
	for i in LUMPS:
		var lump := MeshInstance3D.new()
		var ball := SphereMesh.new()
		ball.radius = 0.45
		ball.height = 0.8
		lump.mesh = ball
		lump.material_override = _paint
		var column := i % 3
		var row := i / 3
		lump.position = Vector3((column - 1) * 1.0 + (0.2 if row == 1 else 0.0), 0.35 + row * 0.65, 0.0)
		_leaves.add_child(lump)
	var stem := CopTool.piece(CopTool.box(Vector3(SIZE.x * 0.9, 0.06, 0.06)), GREEN.darkened(0.4),
		Vector3(0, SIZE.y * 0.5, 0), Vector3(0, 0, 0.3))
	_leaves.add_child(stem)
	_show()


func is_grown() -> bool:
	return grown >= 1.0


func prompt_key(cop: Cop) -> String:
	return "PROMPT_CUT_VINE" if holds_shears(cop) else "PROMPT_VINE"


static func holds_shears(cop: Cop) -> bool:
	return cop.get_node("Grabber").held is PruningShears


## E: a snip with the shears in hand; without them, a hint.
func use(cop: Cop) -> void:
	if drying:
		return
	if not holds_shears(cop):
		cop.show_hint("HINT_VINE_NEEDS_SHEARS")
		return
	snips_left -= 1
	if snips_left <= 0:
		cut_now.emit(self)
		dry()


## Dried up or cut: it falls away in DRY_TIME and nothing stops anyone there.
func dry() -> void:
	if drying:
		return
	drying = true
	collision_layer = 0
	_paint.albedo_color = DRY


func _physics_process(delta: float) -> void:
	if drying:
		grown -= delta / DRY_TIME
		if grown <= 0.0:
			queue_free()
			return
	else:
		grown = minf(grown + delta / GROW_TIME, 1.0)
		life_left -= delta
		if life_left <= 0.0:
			dry()
	_show()


func _show() -> void:
	var part := clampf(grown, 0.02, 1.0)
	_box.size = Vector3(SIZE.x, SIZE.y * part, SIZE.z)
	_shape.position.y = SIZE.y * part / 2.0
	_leaves.scale = Vector3(1.0, part, 1.0)
