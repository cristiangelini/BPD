class_name GiantPizzaRig
extends PizzaRaidRig

## The giant pizza (allanamiento-pizzeria.md, "La pizza gigante"): Don Muzza prints fake bills and keeps them in a
## safe behind the giant pizza "Récord del barrio" on the dining room's wall. One of its pepperoni slices has a lock,
## the story's own clue, and pushed hard (a run or a throw) the pizza turns like a door and shows the safe.

## Where the keyhole is on the pizza (GiantPizzaDoor's space): the one pepperoni with a lock.
const KEYHOLE_AT := Vector3(1.15, 0.3, 0.08)
const CREAK := Color(1.0, 0.9, 0.4)

var lock: ClueNote


func setup(place: PizzaRaid) -> void:
	super.setup(place)
	var door := pizzeria.giant_pizza
	door.can_swing = true
	lock = clue_item("PepperoniLock", null, Vector3(0.14, 0.14, 0.04), Vector3.ZERO, "PROMPT_PEPPERONI_LOCK",
		"CLUE_PEPPERONI_LOCK")
	lock.freeze = true
	lock.reparent(door.panel, false)
	lock.position = KEYHOLE_AT
	door.swung.connect(_on_swung)


func _on_swung() -> void:
	var door := pizzeria.giant_pizza
	pizzeria.raid.float_label(tr("GIANT_PIZZA_CREAK"), door.to_global(Vector3(GiantPizzaDoor.DIAMETER / 2, 0.9, 0.3)),
		CREAK)


func net_state() -> Variant:
	return pizzeria.giant_pizza.is_open


func apply_net_state(state: Variant) -> void:
	if state and not pizzeria.giant_pizza.is_open:
		pizzeria.giant_pizza.swing_open()
