class_name GarbageBag
extends StaticBody3D

## The night guard's giant garbage bag in the garbage truck jailbreak (docs/diseno/fuga-basura.md): open on a cell's
## floor while he empties the bin, then knotted and dragged behind him to the dumpster (GarbageGuard). Step 2: while
## it's open, a crouched cop gets in with E (one per bag) and goes wherever the bag goes, out of sight; E again gets out.
## Step 3: the level makes his roll of bags at the start (so they're the same on every PC): one not `in_use` is on
## the roll, out of sight; the truck puts the ones it takes back on it. Inside one the screen is dark.

const MODEL := preload("res://assets/models/garbage_bag.glb")

## Out of the roll (on a floor, dragged or in the dumpster).
var in_use := false
## Lying open on the floor (he's emptying the bin into it), or knotted.
var is_open := true
## The cop hiding inside, if any.
var hider: Cop
## Where it waits on the roll.
var home: Transform3D
var _model: Node3D
var _shape: CollisionShape3D
var _dark: CanvasLayer


func _ready() -> void:
	add_to_group("garbage_bags")
	collision_layer = 8
	_shape = CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.7, 0.9, 0.65)
	_shape.shape = box
	_shape.position.y = 0.45
	add_child(_shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_dark = CanvasLayer.new()
	_dark.layer = 5
	var black := ColorRect.new()
	black.color = Color(0, 0, 0, 0.94)
	black.set_anchors_preset(Control.PRESET_FULL_RECT)
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dark.add_child(black)
	var line := Label.new()
	line.text = "HUD_IN_BAG"
	line.set_anchors_preset(Control.PRESET_CENTER)
	line.add_theme_font_size_override("font_size", 28)
	black.add_child(line)
	add_child(_dark)
	_refresh()


## Off the roll, open at `at`.
func take(at: Vector3) -> void:
	in_use = true
	is_open = true
	global_transform = Transform3D(Basis.IDENTITY, at)
	_refresh()


## Back on the roll, empty.
func put_away() -> void:
	let_out(false)
	in_use = false
	is_open = true
	global_transform = home
	_refresh()


func prompt_key(cop: Cop) -> String:
	if hider == cop:
		return "PROMPT_BAG_OUT"
	if hider or not is_open or not in_use:
		return ""
	return "PROMPT_BAG_HIDE" if cop.is_crouching else "PROMPT_BAG_CROUCH"


func use(cop: Cop) -> void:
	if hider == cop:
		let_out()
	elif not hider and in_use and is_open and cop.is_crouching:
		hider = cop
		cop.seated_in = self
		cop.tuck_away(true)
		_hold_hider()
		_refresh()


## E from inside (the cop's seated_in): out, the same as `use` through the cop, so it happens on every PC.
func stand_up() -> void:
	if hider:
		hider.act("use", self)


## The hider climbs out next to the bag (also when the bag goes). `move` false leaves the cop where it is (the host
## moved it already, or the truck takes it).
func let_out(move := true) -> void:
	if not hider:
		return
	var cop := hider
	hider = null
	if cop.seated_in == self:
		cop.seated_in = null
	cop.tuck_away(false)
	if move:
		cop.global_position = global_position + Vector3.UP * 0.1
	_refresh()


func hold_point(_cop: Cop) -> Vector3:
	return global_position


func _physics_process(_delta: float) -> void:
	_hold_hider()


func _hold_hider() -> void:
	if hider:
		hider.global_position = global_position
		hider.velocity = Vector3.ZERO


func _exit_tree() -> void:
	let_out()


func knot() -> void:
	is_open = false
	_refresh()


## Open, it's flatter and wider on the floor. Off the roll only; dark for the player inside.
func _refresh() -> void:
	if not _model:
		return
	_model.scale = Vector3(1.2, 0.45, 1.2) if is_open else Vector3.ONE
	visible = in_use
	_shape.disabled = not in_use
	_dark.visible = hider != null and hider.input_enabled


## Online: on the roll or not, open or not, and who's inside (NpcSync). Getting in goes through the cop's action, on
## every PC; getting out of a bag the host emptied (a catch, the truck) comes from here.
func net_state() -> Variant:
	return [in_use, is_open, hider.net_id() if hider else ""]


func apply_net_state(state: Variant) -> void:
	if hider and state[2] == "":
		let_out(false)
	in_use = state[0]
	is_open = state[1]
	_refresh()
