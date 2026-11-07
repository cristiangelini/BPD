class_name CrazyYeastRig
extends PizzaRaidRig

## The crazy yeast (allanamiento-pizzeria.md, "La levadura loca"): Don Muzza smuggles super yeast. Dough oozes out from
## under the cold room's door, the story's own clue, and the dough balls on the dough table grow a size every GROW_EVERY
## seconds: at the last size they burst, and a cop closer than STICK_RANGE stays stuck in the dough for STICK_TIME
## seconds. Every number here is (propuesta).

const PUDDLE_MODEL := preload("res://assets/models/dough_puddle.glb")
const GROW_EVERY := 30.0
const SIZES: Array[float] = [1.0, 1.4, 1.9, 2.5]
const STICK_RANGE := 2.0
const STICK_TIME := 3.0
const PLOF := Color(0.96, 0.86, 0.62)

## The dough balls' size now (an index into SIZES), and seconds since they last grew.
var size := 0
var since_grew := 0.0
var bursts := 0
var puddle: ClueNote


func setup(place: PizzaRaid) -> void:
	super.setup(place)
	puddle = clue_item("DoughPuddle", PUDDLE_MODEL, Vector3(0.6, 0.05, 0.4),
		Vector3(PizzaRaid.COLD_DOOR_X, PizzaRaid.FLOOR_TOP + 0.03, PizzaRaid.COLD_Z + 0.35), "PROMPT_DOUGH_PUDDLE",
		"CLUE_DOUGH_PUDDLE")


func _physics_process(delta: float) -> void:
	# The host grows the dough; the guests take its size (net_state).
	if not multiplayer.is_server():
		return
	since_grew += delta
	if since_grew >= GROW_EVERY:
		since_grew = 0.0
		grow()


## The dough balls grow a size; past the last one they burst and start again.
func grow() -> void:
	if size == SIZES.size() - 1:
		burst()
		size = 0
	else:
		size += 1
	_show_size()


## Plof: every cop near the dough table stays stuck for a while.
func burst() -> void:
	bursts += 1
	var table := pizzeria.to_global(PizzaRaid.DOUGH_TABLE_AT)
	pizzeria.raid.float_label(tr("DOUGH_PLOF"), table + Vector3.UP * 1.6, PLOF)
	for cop: Cop in pizzeria.get_tree().get_nodes_in_group("cops"):
		var flat := cop.global_position - table
		flat.y = 0.0
		if flat.length() < STICK_RANGE:
			cop.stagger(STICK_TIME)
			cop.show_hint("HINT_DOUGH_STUCK")


func _show_size() -> void:
	for ball: Node3D in pizzeria.dough_balls:
		ball.scale = Vector3.ONE * SIZES[size]


func net_state() -> Variant:
	return size


func apply_net_state(state: Variant) -> void:
	if state != size:
		size = state
		_show_size()
