class_name GarbageBag
extends StaticBody3D

## The night guard's giant garbage bag in the garbage truck jailbreak (docs/diseno/fuga-basura.md): open on a cell's
## floor while he empties the bin, then knotted and dragged behind him to the dumpster (GarbageGuard). Step 2: while
## it's open, a crouched cop gets in with E (one per bag) and goes wherever the bag goes, out of sight; E again gets out.

const MODEL := preload("res://assets/models/garbage_bag.glb")

## Lying open on the floor (he's emptying the bin into it), or knotted.
var is_open := true
## The cop hiding inside, if any.
var hider: Cop
var _model: Node3D


func _ready() -> void:
	add_to_group("garbage_bags")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.7, 0.9, 0.65)
	shape.shape = box
	shape.position.y = 0.45
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_refresh()


func prompt_key(cop: Cop) -> String:
	if hider == cop:
		return "PROMPT_BAG_OUT"
	if hider or not is_open:
		return ""
	return "PROMPT_BAG_HIDE" if cop.is_crouching else "PROMPT_BAG_CROUCH"


func use(cop: Cop) -> void:
	if hider == cop:
		let_out()
	elif not hider and is_open and cop.is_crouching:
		hider = cop
		cop.seated_in = self
		cop.tuck_away(true)
		_hold_hider()


## E from inside (the cop's seated_in): out, the same as `use` through the cop, so it happens on every PC.
func stand_up() -> void:
	if hider:
		hider.act("use", self)


## The hider climbs out next to the bag (also when the bag goes).
func let_out() -> void:
	if not hider:
		return
	var cop := hider
	hider = null
	cop.seated_in = null
	cop.tuck_away(false)
	cop.global_position = global_position + Vector3.UP * 0.1


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


## Open, it's flatter and wider on the floor.
func _refresh() -> void:
	_model.scale = Vector3(1.2, 0.45, 1.2) if is_open else Vector3.ONE
