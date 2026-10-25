class_name LaundryCart
extends AnimatableBody3D

## A laundry cart of the prison's laundry (carcel-lavanderia.md, step 2): a canvas basket on a steel frame with four
## wheels and a push bar, full of sheets, towels and socks. LaundryPlan draws which ones carry an inmate under the
## sheets (`hidden`) and on which of the truck's trips each one goes (`trip`). Its origin is on the ground in its
## middle, long along Z, the push bar at its +Z end. Step 3: E and staying close CHECK_TIME seconds digs through the
## sheets ("Puaj"); R knocks it over onto its side. Either way, an inmate under the sheets jumps out (`revealed`) and
## runs for the gate. LaundryWorker pushes it to the truck, where it's `loaded`. Online the host counts. Every number
## here is (propuesta).

## An inmate jumped out from under the sheets.
signal revealed(cart: LaundryCart)
## Up the truck's ramp, with or without someone in it.
signal loaded_up(cart: LaundryCart)

const SIZE := Vector3(0.7, 0.9, 1.0)
const WHEEL := 0.08
const CANVAS := Color(0.85, 0.82, 0.72)
const FRAME := Color(0.55, 0.58, 0.62)
## The sheets on top, drawn from these.
const LINENS: Array[Color] = [Color(0.95, 0.95, 0.92), Color(0.6, 0.75, 0.9), Color(0.95, 0.6, 0.35),
	Color(0.85, 0.85, 0.5), Color(0.7, 0.85, 0.7)]
const CHECK_TIME := 1.5
const CHECK_REACH := 2.4
const TIP_TIME := 0.4

## An inmate under the sheets (drawn by LaundryPlan).
var hidden := false
## The truck's trip it goes out on, from 0.
var trip := 0
## Which sheets go on top (LaundryPlan draws it, so it's the same on every PC).
var linen_seed := 0
## Its place among the carts (LaundryPlan.cart_spot).
var index := 0
## Dug through already, knocked over, up the truck's ramp; who's pushing it, and the cop digging through it now.
var checked := false
var tipped := false
var loaded := false
var pusher: LaundryWorker
var checked_by: Cop
## A guest's copy (step 7): the host counts.
var follower := false
var _check_left := 0.0
var _standing: Transform3D
var _turn: Tween


func _ready() -> void:
	add_to_group("laundry_carts")
	# Moved by code every physics frame (the pusher, the tip): sync_to_physics would keep it where the physics left it.
	sync_to_physics = false
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	shape.position.y = SIZE.y / 2
	add_child(shape)
	_build_model()


func _build_model() -> void:
	var bottom := WHEEL * 2
	var height := SIZE.y - bottom
	# The basket: four canvas sides and a bottom, open on top.
	add_child(CopTool.piece(CopTool.box(Vector3(SIZE.x, 0.03, SIZE.z)), CANVAS, Vector3(0, bottom, 0)))
	for side: float in [-1.0, 1.0]:
		add_child(CopTool.piece(CopTool.box(Vector3(0.03, height, SIZE.z)), CANVAS,
			Vector3(side * SIZE.x / 2, bottom + height / 2, 0)))
		add_child(CopTool.piece(CopTool.box(Vector3(SIZE.x, height, 0.03)), CANVAS,
			Vector3(0, bottom + height / 2, side * SIZE.z / 2)))
	# The frame along the rim, the push bar and the wheels.
	for side: float in [-1.0, 1.0]:
		add_child(CopTool.piece(CopTool.box(Vector3(0.04, 0.04, SIZE.z + 0.04)), FRAME, Vector3(side * SIZE.x / 2, SIZE.y, 0)))
		add_child(CopTool.piece(CopTool.box(Vector3(0.04, 0.3, 0.04)), FRAME,
			Vector3(side * SIZE.x / 2, SIZE.y + 0.15, SIZE.z / 2 + 0.05)))
		for end: float in [-1.0, 1.0]:
			add_child(CopTool.piece(CopTool.cylinder(WHEEL, 0.05), PrisonLevel.BARS,
				Vector3(side * (SIZE.x / 2 - 0.08), WHEEL, end * (SIZE.z / 2 - 0.1)), Vector3(0, 0, PI / 2)))
	add_child(CopTool.piece(CopTool.box(Vector3(SIZE.x + 0.04, 0.05, 0.05)), FRAME, Vector3(0, SIZE.y + 0.3, SIZE.z / 2 + 0.05)))
	# The sheets heaped on top, a little over the rim.
	var rng := RandomNumberGenerator.new()
	rng.seed = linen_seed
	for i in 3:
		var linen := CopTool.piece(CopTool.box(Vector3(SIZE.x - 0.1, 0.14, SIZE.z * rng.randf_range(0.4, 0.8))),
			LINENS[rng.randi_range(0, LINENS.size() - 1)],
			Vector3(rng.randf_range(-0.05, 0.05), SIZE.y - 0.12 + i * 0.06, rng.randf_range(-0.2, 0.2)),
			Vector3(0, rng.randf_range(-0.4, 0.4), 0))
		linen.name = "Linen%d" % i
		add_child(linen)


func prompt_key(_cop: Cop) -> String:
	if loaded or tipped:
		return ""
	return "PROMPT_CART_CHECKED" if checked or checked_by else "PROMPT_CHECK_CART"


## E: digs through the sheets while staying close (the host counts).
func use(cop: Cop) -> void:
	if loaded or tipped or checked or checked_by:
		return
	checked_by = cop
	_check_left = CHECK_TIME
	cop.show_hint("HINT_CART_DIGGING")


## R: knocked over, away from the cop. Returns true if it went over.
func ask(cop: Cop) -> bool:
	if loaded or tipped:
		return false
	var side := 1.0 if (global_transform.affine_inverse() * cop.global_position).x < 0.0 else -1.0
	tip(side)
	return true


## Over onto its side toward local `side` (+1 or -1 on X): the sheets spill and whoever was under them is out.
func tip(side: float) -> void:
	if tipped:
		return
	tipped = true
	checked_by = null
	_standing = global_transform
	var pivot := Vector3(side * SIZE.x / 2, 0, 0)
	var over := Transform3D(Basis(Vector3.BACK, -side * PI / 2), Vector3.ZERO)
	_turn_to(_standing * Transform3D(Basis.IDENTITY, pivot) * over * Transform3D(Basis.IDENTITY, -pivot))
	if hidden and not follower:
		_reveal()


## Back on its wheels, where it fell.
func set_upright() -> void:
	if not tipped:
		return
	tipped = false
	_turn_to(_standing)


## Up the truck's ramp: gone from the yard.
func load_up() -> void:
	if loaded:
		return
	loaded = true
	checked_by = null
	hide()
	collision_layer = 0
	loaded_up.emit(self)


func _reveal() -> void:
	hidden = false
	checked = true
	revealed.emit(self)


func _turn_to(to: Transform3D) -> void:
	if _turn:
		_turn.kill()
	if not is_inside_tree():
		global_transform = to
		return
	_turn = create_tween()
	_turn.tween_property(self, "global_transform", to, TIP_TIME)


func _physics_process(delta: float) -> void:
	if not checked_by:
		return
	if not is_instance_valid(checked_by) or checked_by.global_position.distance_to(global_position) > CHECK_REACH:
		checked_by = null
		return
	_check_left -= delta
	if _check_left > 0.0:
		return
	var cop := checked_by
	checked_by = null
	checked = true
	if follower:
		return
	if hidden:
		_reveal()
	else:
		cop.show_hint("HINT_CART_ONLY_SHEETS")
