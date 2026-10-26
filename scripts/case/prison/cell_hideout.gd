class_name CellHideout
extends StaticBody3D

## One of the four places in a cell of the block where a tunnel could hide (carcel-tunel.md, step 2): the poster on a
## side wall, the bunk against the back wall, the toilet in a corner or the rug on the floor. E and staying close
## CHECK_TIME seconds moves it aside ("¿Qué hay acá atrás?"); if the tunnel is behind it, it stays moved and the hole
## shows (`found`). Checked, it says so. Its origin is on the floor (on the wall for the poster), turned so its -Z faces
## into the cell. Online the host decides. Every number here is (propuesta).

signal checked_one(hideout: CellHideout, had_tunnel: bool)
## Step 5: E with a CementBag in hand on the open hole.
signal poured(hideout: CellHideout, cop: Cop, bag: CementBag)

enum Kind { POSTER, BUNK, TOILET, RUG }

const CHECK_TIME := 1.5
const CHECK_REACH := 2.2
const MOVE_TIME := 0.4
const HOLE_RADIUS := 0.35
const POSTER_HEIGHT := 1.35
const POSTER_SIZE := Vector2(0.6, 0.85)
const BUNK_SIZE := Vector3(1.9, 0.5, 0.8)
const TOILET_SIZE := Vector3(0.45, 0.45, 0.6)
const RUG_SIZE := Vector2(1.2, 1.0)
const POSTER_COLORS: Array[Color] = [Color(0.85, 0.3, 0.35), Color(0.3, 0.55, 0.85), Color(0.95, 0.8, 0.3),
	Color(0.45, 0.75, 0.4)]
const RUG_COLORS: Array[Color] = [Color(0.55, 0.25, 0.2), Color(0.25, 0.35, 0.55), Color(0.5, 0.45, 0.2)]
const PORCELAIN := Color(0.93, 0.94, 0.96)
const DARK := Color(0.07, 0.05, 0.04)
const DIRT := Color(0.42, 0.3, 0.18)
const CEMENT := Color(0.62, 0.62, 0.6)

var kind := Kind.POSTER
## Its cell of the block (0 to 7) and whether the tunnel starts behind it.
var cell := 0
var has_tunnel := false
var look := 0
var checked := false
var checked_by: Cop
## Step 5: the hole filled with cement.
var sealed := false
## A guest's copy (step 7): the host decides.
var follower := false
var _check_left := 0.0
var _thing: Node3D
var _hole: Node3D
var _shape: CollisionShape3D
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_to_group("cell_hideouts")
	# With the people (layer 8): the inmates walk past the rug and the bunk's end, the cops bump into them.
	collision_layer = 8
	_thing = Node3D.new()
	_thing.name = "Thing"
	add_child(_thing)
	var size := _shape_size()
	_shape = CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	_shape.shape = box
	_shape.position = Vector3(0, size.y / 2, 0) if kind != Kind.POSTER else Vector3(0, 0, -size.z / 2)
	add_child(_shape)
	match kind:
		Kind.POSTER:
			_thing.add_child(CopTool.piece(CopTool.box(Vector3(POSTER_SIZE.x, POSTER_SIZE.y, 0.01)),
				POSTER_COLORS[look % POSTER_COLORS.size()], Vector3(0, 0, -0.01)))
			_thing.add_child(CopTool.piece(CopTool.cylinder(0.12, 0.012), Color(0.95, 0.9, 0.8),
				Vector3(0, 0.08, -0.02), Vector3(PI / 2, 0, 0)))
		Kind.BUNK:
			_thing.add_child(CopTool.piece(CopTool.box(BUNK_SIZE), PrisonLevel.ORANGE, Vector3(0, BUNK_SIZE.y / 2, 0)))
			_thing.add_child(CopTool.piece(CopTool.box(Vector3(0.4, 0.1, 0.6)), Color(0.95, 0.95, 0.9),
				Vector3(BUNK_SIZE.x / 2 - 0.3, BUNK_SIZE.y + 0.05, 0)))
		Kind.TOILET:
			_thing.add_child(CopTool.piece(CopTool.cylinder(0.2, 0.42), PORCELAIN, Vector3(0, 0.21, -0.05)))
			_thing.add_child(CopTool.piece(CopTool.box(Vector3(0.42, 0.35, 0.16)), PORCELAIN, Vector3(0, 0.6, 0.2)))
		Kind.RUG:
			_thing.add_child(CopTool.piece(CopTool.box(Vector3(RUG_SIZE.x, 0.015, RUG_SIZE.y)),
				RUG_COLORS[look % RUG_COLORS.size()], Vector3(0, 0.008, 0)))
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.4 - (POSTER_HEIGHT if kind == Kind.POSTER else 0.0), 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 32
	_bubble.hide()
	add_child(_bubble)
	_hole = Node3D.new()
	_hole.name = "Hole"
	_hole.visible = false
	add_child(_hole)
	if kind == Kind.POSTER:
		# A crawl hole low in the wall, under where the poster hung, with its dirt on the floor.
		_hole.position = Vector3(0, 0.4 - POSTER_HEIGHT, -0.005)
		_hole.add_child(CopTool.piece(CopTool.cylinder(HOLE_RADIUS, 0.01), DARK, Vector3.ZERO, Vector3(PI / 2, 0, 0)))
		_hole.add_child(CopTool.piece(CopTool.cylinder(0.3, 0.06), DIRT, Vector3(0.35, -0.37, -0.35)))
	else:
		_hole.position = Vector3(0, 0.012, 0)
		_hole.add_child(CopTool.piece(CopTool.cylinder(HOLE_RADIUS, 0.01), DARK))
		_hole.add_child(CopTool.piece(CopTool.cylinder(0.25, 0.08), DIRT, Vector3(HOLE_RADIUS + 0.25, 0.02, -0.3)))


## What it's checked by: the poster's thin board on the wall or the thing on the floor.
func _shape_size() -> Vector3:
	match kind:
		Kind.POSTER:
			return Vector3(POSTER_SIZE.x, POSTER_SIZE.y, 0.08)
		Kind.BUNK:
			return BUNK_SIZE
		Kind.TOILET:
			return TOILET_SIZE
	return Vector3(RUG_SIZE.x, 0.03, RUG_SIZE.y)


func prompt_key(cop: Cop) -> String:
	if sealed:
		return "PROMPT_TUNNEL_SEALED"
	if is_open():
		return "PROMPT_POUR_CEMENT" if cop.get_node("Grabber").held is CementBag else "PROMPT_TUNNEL_NEEDS_CEMENT"
	return "PROMPT_HIDEOUT_CHECKED" if checked else "PROMPT_CHECK_HIDEOUT"


## E: moves it aside while staying close (the host decides what's behind). On the open hole with a bag of cement in
## hand, pours it in.
func use(cop: Cop) -> void:
	if is_open() and not sealed:
		var bag: Variant = cop.get_node("Grabber").held
		if bag is CementBag:
			poured.emit(self, cop, bag)
		else:
			cop.show_hint("HINT_TUNNEL_NEEDS_CEMENT")
		return
	if checked or checked_by:
		return
	checked_by = cop
	_check_left = CHECK_TIME
	cop.show_hint("HINT_HIDEOUT_SEARCHING")


## Whether the hole behind it shows (the tunnel, found).
func is_open() -> bool:
	return _hole.visible


## Checked: back in place, or moved aside for good over the tunnel's hole.
func set_checked(open: bool) -> void:
	checked = true
	if not open or _hole.visible:
		return
	_hole.visible = true
	var move := create_tween()
	match kind:
		Kind.POSTER:
			# It comes off the wall and lands on the floor, leaning against it.
			move.tween_property(_thing, "position", Vector3(0, 0.45 - POSTER_HEIGHT, -0.2), MOVE_TIME)
			move.parallel().tween_property(_thing, "rotation:x", -0.35, MOVE_TIME)
		Kind.BUNK:
			move.tween_property(_thing, "position:z", -0.9, MOVE_TIME)
		Kind.TOILET:
			move.tween_property(_thing, "position", Vector3(0.45, 0, -0.5), MOVE_TIME)
			move.parallel().tween_property(_thing, "rotation:y", 0.5, MOVE_TIME)
		Kind.RUG:
			# Rolled up toward its far end.
			move.tween_property(_thing, "scale:z", 0.2, MOVE_TIME)
			move.parallel().tween_property(_thing, "position:z", RUG_SIZE.y * 0.45, MOVE_TIME)
	if kind == Kind.BUNK:
		# The bunk's body goes with it: the hole's spot is free.
		_shape.position.z = -0.9


## A line over it for `seconds` (step 3: the digging behind it, "scrich, scrich").
func say(key: String, seconds := 1.5) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = seconds


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()


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
	if follower:
		return
	set_checked(has_tunnel)
	cop.show_hint("HINT_TUNNEL_FOUND" if has_tunnel else "HINT_HIDEOUT_NOTHING_%d" % kind)
	checked_one.emit(self, has_tunnel)


## The hole filled with cement, for good.
func seal() -> void:
	if sealed:
		return
	sealed = true
	set_checked(true)
	var hole := _hole.get_child(0) as MeshInstance3D
	var material := StandardMaterial3D.new()
	material.albedo_color = CEMENT
	hole.material_override = material


## Online: whether it's checked, the hole shows and it's sealed (NpcSync, step 7).
func net_state() -> Array:
	return [checked, _hole.visible, sealed]


func apply_net_state(state: Variant) -> void:
	if state[0] and not checked:
		set_checked(state[1])
	if state[2] and not sealed:
		seal()
