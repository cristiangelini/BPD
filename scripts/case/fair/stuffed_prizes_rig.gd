class_name StuffedPrizesRig
extends FairRig

## The stuffed prizes (allanamiento-parque.md, "Los premios rellenos"): Don Tómbola sews stolen watches into the prize
## teddies and his "winners" carry them out. The bag of watches is hidden; the giant teddy goes "tic tac" when a cop is
## near, the story's own clue (on the checklist the first time), and the small teddies on the prize shelf weigh three
## times as much and land with a "clonc". Every number here is (propuesta).

## A cop this close to the giant teddy hears it, once every TICK_EVERY seconds.
const TICK_RANGE := 3.0
const TICK_EVERY := 1.5
const HEAVY := 3.0
## A small teddy this low (m over the floor) is on the floor.
const PLUSH_DOWN := 0.4

var ticks := 0
var cloncs := 0
var _since_tick := TICK_EVERY
## Small teddies lying on the floor right now.
var _down := {}


func setup(place: Fair) -> void:
	super.setup(place)
	for plush in place.plushes:
		plush.mass *= HEAVY


func _physics_process(delta: float) -> void:
	_since_tick += delta
	if _since_tick >= TICK_EVERY and _cop_near():
		tick()
	for i in fair.plushes.size():
		var plush := fair.plushes[i]
		if not is_instance_valid(plush):
			continue
		var down := fair.to_local(plush.global_position).y < Fair.FLOOR_TOP + PLUSH_DOWN
		if down and not _down.has(i):
			cloncs += 1
			fair.raid.float_label(tr("FAIR_CLONC"), plush.global_position + Vector3.UP * 0.5, Color(0.8, 0.8, 0.85))
		if down:
			_down[i] = true
		else:
			_down.erase(i)


## The giant teddy goes "tic tac"; the first time it's a clue.
func tick() -> void:
	_since_tick = 0.0
	ticks += 1
	fair.raid.float_label(tr("FAIR_TICK"), fair.to_global(Fair.TEDDY_AT + Vector3.UP * 1.6), Color(0.95, 0.85, 0.5))
	if ticks == 1:
		fair.raid.add_clue(tr("CLUE_TEDDY_TICKS"))


func _cop_near() -> bool:
	var at := fair.to_global(Fair.TEDDY_AT)
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if cop.global_position.distance_to(at) <= TICK_RANGE:
			return true
	return false
