class_name LaundryCart
extends AnimatableBody3D

## A laundry cart of the prison's laundry (carcel-lavanderia.md, step 2): a canvas basket on a steel frame with four
## wheels and a push bar, full of sheets, towels and socks. LaundryPlan draws which ones carry an inmate under the
## sheets (`hidden`) and on which of the truck's trips each one goes (`trip`). Its origin is on the ground in its
## middle, long along Z, the push bar at its +Z end. Step 3: E and staying close CHECK_TIME seconds digs through the
## sheets ("Puaj"); R knocks it over onto its side. Either way, an inmate under the sheets jumps out (`revealed`) and
## runs for the gate. LaundryWorker pushes it to the truck, where it's `loaded`. Online the host counts. Step 4: the
## tells. Someone under the sheets sneezes every SNEEZE_EVERY seconds, and in some carts (`foot_out`) a shoe sticks out
## over the rim; a cat asleep in the towels of some empty carts (`has_cat`) meows and wiggles the sheets just the same,
## and digging through finds it. The tells come from `tell_seed`, the same on every PC. Every number here is
## (propuesta).

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
## The tells (step 4): how often, how long the line stays up, and how far the sheets wiggle.
const SNEEZE_EVERY := Vector2(10.0, 18.0)
const MEOW_EVERY := Vector2(10.0, 18.0)
const SAY_TIME := 2.0
const WIGGLE := 0.06
const CAT_MODEL := preload("res://assets/models/cat_michi.glb")

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
## The tells (step 4): a shoe sticking out, a cat in the towels, and the seed of when they sneeze or meow.
var foot_out := false
var has_cat := false
var tell_seed := 0
var _check_left := 0.0
var _tells := RandomNumberGenerator.new()
var _tell_left := -1.0
var _bubble: Label3D
var _bubble_left := 0.0
var _foot: Node3D
var _linens: Array[Node3D] = []
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
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, SIZE.y + 0.6, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.hide()
	add_child(_bubble)
	# A shoe of whoever is under the sheets, over the rim by the push bar.
	_foot = Node3D.new()
	_foot.name = "Foot"
	_foot.add_child(CopTool.piece(CopTool.box(Vector3(0.12, 0.1, 0.26)), PrisonLevel.BARS, Vector3(0, 0, 0.05)))
	_foot.add_child(CopTool.piece(CopTool.cylinder(0.05, 0.2), PrisonLevel.ORANGE, Vector3(0, -0.12, -0.06)))
	_foot.position = Vector3(0.18, SIZE.y + 0.05, SIZE.z / 2 - 0.05)
	_foot.rotation.x = -0.5
	_foot.visible = hidden and foot_out
	add_child(_foot)


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
		_linens.append(linen)


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
	if follower:
		return
	if hidden:
		_reveal()
	elif has_cat:
		checked = true
		_show_cat()


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
	_foot.hide()
	revealed.emit(self)


## The cat found in the towels: up on top of the sheets, looking around.
func _show_cat() -> void:
	if get_node_or_null("Cat"):
		return
	var cat: Node3D = CAT_MODEL.instantiate()
	cat.name = "Cat"
	cat.scale = Vector3.ONE * 0.7
	cat.position = Vector3(0, SIZE.y + 0.05, 0)
	add_child(cat)
	say("CART_MEOW")


## What a guest's copy needs besides where it is and what it says (NpcSync, step 7).
func net_state() -> Array:
	return [checked, tipped, loaded, _foot.visible, get_node_or_null("Cat") != null]


func apply_net_state(net: Variant) -> void:
	checked = net[0]
	tipped = net[1]
	_foot.visible = net[3]
	if net[4] and not get_node_or_null("Cat"):
		_show_cat()
	if net[2] and not loaded:
		loaded = true
		hide()
		collision_layer = 0


func say(key: String, seconds := SAY_TIME) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = seconds


func said() -> String:
	return _bubble.text if _bubble.visible else ""


## Whether there's anything in it that gives tells: someone under the sheets, or a cat.
func has_tells() -> bool:
	return (hidden or has_cat) and not loaded and not checked


## Seconds to the next sneeze or meow.
func _next_tell() -> float:
	var every := SNEEZE_EVERY if hidden else MEOW_EVERY
	return _tells.randf_range(every.x, every.y)


## Every so often: a sneeze (or a meow) and the sheets wiggle.
func _tell(delta: float) -> void:
	if _tell_left < 0.0:
		_tells.seed = tell_seed
		_tell_left = _next_tell()
	_tell_left -= delta
	if _tell_left > 0.0:
		return
	_tell_left = _next_tell()
	say("CART_SNEEZE" if hidden else "CART_MEOW")
	var wiggle := create_tween()
	for linen in _linens:
		wiggle.parallel().tween_property(linen, "position:y", linen.position.y + WIGGLE, 0.1)
	for linen in _linens:
		wiggle.chain().tween_property(linen, "position:y", linen.position.y, 0.15)


func _turn_to(to: Transform3D) -> void:
	if _turn:
		_turn.kill()
	if not is_inside_tree():
		global_transform = to
		return
	_turn = create_tween()
	_turn.tween_property(self, "global_transform", to, TIP_TIME)


func _process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()
	if has_tells():
		_tell(delta)


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
	elif has_cat:
		_show_cat()
		cop.show_hint("HINT_CART_CAT")
	else:
		cop.show_hint("HINT_CART_ONLY_SHEETS")
