class_name SheetRope
extends Grabbable

## The bunks' sheets knotted into a rope in the roof jailbreak (docs/diseno/fuga-techo.md, step 3): a sheet or a rope
## in hand, E on another one ties them with a loose knot (the host makes the new rope); with empty hands, E on it
## tightens its first loose knot, TIGHTEN_PUSHES presses. In hand, E on the roof's antenna ties it there (RoofAntenna).
## Every number here is (propuesta).

const MODEL := preload("res://assets/models/sheet_rope.glb")
const SIZE := Vector3(0.5, 0.2, 0.5)
## How much rope each sheet makes (m).
const SHEET_LENGTH := 2.0
const TIGHTEN_PUSHES := 4
const PUSH_EVERY := 0.5

## Each knot between two sheets: true once tight.
@export var knots: Array = []
## Presses given to the knot being tightened.
var turns := 0
var _next_push_ms := 0


func _init() -> void:
	collision_layer = 4
	collision_mask = 15
	mass = 2.0
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = SIZE
	shape.shape = box
	add_child(shape)
	add_child(MODEL.instantiate())


func _ready() -> void:
	add_to_group("sheet_ropes")


## What a guest's copy needs (PropSync).
func net_setup() -> Dictionary:
	return {"knots": knots}


func sheets() -> int:
	return knots.size() + 1


func is_tight() -> bool:
	return not knots.has(false)


## How many sheets `item` is (a sheet, or a rope), 0 if neither.
static func sheets_of(item: Node) -> int:
	if item is BedSheet:
		return 1
	if item is SheetRope:
		return (item as SheetRope).sheets()
	return 0


## The host: ties `held` (a sheet or a rope, in `cop`'s hands) to `other` with a loose knot, into a new rope where
## `other` was. Returns it.
static func tie(cop: Cop, held: Grabbable, other: Grabbable) -> SheetRope:
	var rope := SheetRope.new()
	rope.knots = ((held as SheetRope).knots if held is SheetRope else []) + [false] \
		+ ((other as SheetRope).knots if other is SheetRope else [])
	var at := other.global_transform
	for item: Grabbable in [held, other]:
		for holder: Cop in item.handling_cops(0.0):
			holder.get_node("Grabber").release()
		item.queue_free()
	other.get_parent().add_child(rope)
	rope.global_transform = at
	cop.show_hint("HINT_KNOT_LOOSE", true)
	return rope


func prompt_key(cop: Cop) -> String:
	var held: Node = cop.get_node("Grabber").held
	if sheets_of(held) > 0 and held != self:
		return "PROMPT_KNOT"
	if not held and not is_tight():
		return "PROMPT_TIGHTEN"
	return "PROMPT_GRAB" if not held else ""


func use(cop: Cop) -> void:
	var held: Node = cop.get_node("Grabber").held
	if sheets_of(held) > 0 and held != self:
		if multiplayer.is_server():
			tie(cop, held, self)
		return
	if held or is_tight():
		return
	var now := Time.get_ticks_msec()
	if now < _next_push_ms:
		return
	_next_push_ms = now + int(PUSH_EVERY * 1000.0)
	tighten(cop)


## One more press on the first loose knot; the last one makes it tight.
func tighten(cop: Cop) -> void:
	var knot := knots.find(false)
	if knot < 0:
		return
	turns += 1
	if turns >= TIGHTEN_PUSHES:
		turns = 0
		knots[knot] = true
		cop.show_hint("HINT_KNOT_TIGHT")
