class_name JewelsRig
extends PizzaRaidRig

## The jewels in the muzza (allanamiento-pizzeria.md, "Las joyas en la muzza"): Don Muzza hides stolen jewels in
## frozen pizzas. In the yard's bin lies a half-eaten slice with a ring in the cheese, the story's own clue; and E on
## the counter's tower of pizza boxes lifts the next box from the top: two of them, drawn with the seed, clink like
## coins (on the checklist the first time). Every number here is (propuesta).

const SLICE_MODEL := preload("res://assets/models/bitten_slice_ring.glb")
const CLINKING := 2
const LIFT := 0.15
const LIFT_TIME := 0.25
const COINS := Color(1.0, 0.85, 0.3)

## The box the next E lifts (0 is the top one), and the ones that clink.
var next_box := 0
var clinking: Array[int] = []
var heard_coins := false
var button: PushButton
var bitten_slice: ClueNote


func setup(place: PizzaRaid) -> void:
	super.setup(place)
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["jewels", place.case_seed])
	var boxes: Array = range(PizzaRaid.TOWER_BOXES)
	for i in CLINKING:
		clinking.append(boxes.pop_at(rng.randi_range(0, boxes.size() - 1)))
	button = PushButton.new()
	button.prompt = "PROMPT_TOWER_LIFT"
	button.position = PizzaRaid.TOWER_AT + Vector3(0, PizzaRaid.TOWER_BOXES * 0.025, 0.22)
	place.add_child(button)
	for part in button.get_children():
		if part is MeshInstance3D:
			part.hide()
	button.pressed.connect(func(_cop: Cop) -> void: lift_next())
	bitten_slice = clue_item("BittenSlice", SLICE_MODEL, Vector3(0.2, 0.03, 0.22), PizzaRaid.BIN_AT + Vector3(0, 0.08, 0),
		"PROMPT_BITTEN_SLICE", "CLUE_BITTEN_SLICE")


## Lifts the next box from the top of the tower for a moment; a clinking one goes on the checklist the first time.
func lift_next() -> void:
	var index := next_box
	next_box = (next_box + 1) % PizzaRaid.TOWER_BOXES
	var look: Node3D = pizzeria.tower_boxes[PizzaRaid.TOWER_BOXES - 1 - index]
	var rest := look.position
	var tween := look.create_tween()
	tween.tween_property(look, "position", rest + Vector3.UP * LIFT, LIFT_TIME)
	tween.tween_property(look, "position", rest, LIFT_TIME)
	if not clinking.has(index):
		return
	pizzeria.raid.float_label(tr("TOWER_COINS"), pizzeria.to_global(rest) + Vector3.UP * 0.5, COINS)
	if not heard_coins:
		heard_coins = true
		pizzeria.raid.add_clue(tr("CLUE_TOWER_COINS"))
