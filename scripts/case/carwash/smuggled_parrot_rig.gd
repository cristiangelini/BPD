class_name SmuggledParrotRig
extends CarWashRig

## The smuggled parrot (allanamiento-lavadero.md, "El loro de contrabando"): Don Chorro keeps a smuggled parrot in its
## cage, hidden, waiting for the buyer. Every SQUAWK_EVERY seconds the parrot squawks from wherever it is; the first
## squawk is always "¡Lavado premium!", and then it repeats Don Chorro's lines in his voice. A cop who hears it (this
## close) the first time gets the story's own clue on the checklist. Every number here is (propuesta).

const SQUAWK_EVERY := 15.0
const HEAR_RANGE := 8.0
## What the parrot says, in turn: the premium wash and Don Chorro's own lines.
const SQUAWKS := ["PARROT_PREMIUM", "CHORRO_LINE_1", "PARROT_PREMIUM", "CHORRO_LINE_4", "CHORRO_LINE_2"]
const PARROT := Color(0.3, 0.85, 0.4)

var heard := false
var squawks := 0
var _since := 0.0


func _physics_process(delta: float) -> void:
	_since += delta
	if _since >= SQUAWK_EVERY:
		_since = 0.0
		squawk()


## The parrot squawks from its cage; a cop near enough hears it, and the first time it's a clue.
func squawk() -> void:
	if not is_instance_valid(car_wash.main):
		return
	var at := car_wash.main.global_position
	car_wash.raid.float_label(tr("PARROT_SAYS") % tr(SQUAWKS[squawks % SQUAWKS.size()]), at + Vector3.UP * 0.9, PARROT)
	squawks += 1
	if heard:
		return
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if cop.global_position.distance_to(at) <= HEAR_RANGE:
			heard = true
			car_wash.raid.add_clue(tr("CLUE_PARROT_PREMIUM"))
			return
