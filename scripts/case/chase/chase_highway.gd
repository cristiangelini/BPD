class_name ChaseHighway
extends Node

## What only the highway chase has (persecucion-lugares.md, "En la autopista"): the slow traffic on the ring, half
## going each way, and the copilot's radio, where R calls for backup and the comisario answers with a different
## excuse each time. The backup never comes. Every number here is (propuesta).

const TRAFFIC := 10
## The lanes going the other way (the ring's outer half): by the median and by the guardrail.
const OTHER_FAST := HighwayLayout.MEDIAN / 2 + HighwayLayout.LANE / 2
const OTHER_SLOW := HighwayLayout.MEDIAN / 2 + HighwayLayout.LANE * 1.5
const EXCUSES := 8
const RADIO_COOLDOWN := 3.0

var case: ChaseCase
var traffic: Array[TrafficCar] = []
var calls := 0
var _cooldown := 0.0


func _ready() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("traffic %d" % case.case_seed)
	var clockwise: Array[PackedVector3Array] = [_lane(HighwayRoute.SLOW_LANE, false), _lane(HighwayRoute.FAST_LANE, false)]
	var other: Array[PackedVector3Array] = [_lane(OTHER_SLOW, true), _lane(OTHER_FAST, true)]
	for k in TRAFFIC:
		var car := TrafficCar.new()
		car.name = "Traffic%d" % k
		car.look = k
		car.lanes = clockwise if k % 2 == 0 else other
		car.suspect = case.truck
		case.get_parent().add_child(car)
		var lane := rng.randi_range(0, 1)
		var at := _spread(car.lanes[lane], (floorf(k / 2.0) + rng.randf_range(0.1, 0.6)) / ceilf(TRAFFIC / 2.0))
		car.place(lane, at[0], at[1])
		traffic.append(car)
	case.car.seats_changed.connect(_tell_copilot)


## A lane's loop in the world, in its driving order: clockwise, or `reversed` for the other way.
func _lane(offset: float, reversed: bool) -> PackedVector3Array:
	var loop := HighwayLayout.loop(offset)
	if reversed:
		loop.reverse()
	for i in loop.size():
		loop[i] = case.city_transform * loop[i]
	return loop


## Where `share` of the way around `loop` is (by length): [the piece's first point, how far along the piece].
static func _spread(loop: PackedVector3Array, share: float) -> Array:
	var total := 0.0
	for i in loop.size():
		total += loop[i].distance_to(loop[(i + 1) % loop.size()])
	var walked := 0.0
	for i in loop.size():
		var piece := loop[i].distance_to(loop[(i + 1) % loop.size()])
		if walked + piece >= share * total:
			return [i, (share * total - walked) / piece]
		walked += piece
	return [0, 0.0]


func _tell_copilot() -> void:
	var cop := case.tasks.local_cop()
	if case.tasks.does(cop, ChaseTasks.MAP_SEATS):
		cop.show_hint("HINT_CHASE_BACKUP")


func _physics_process(delta: float) -> void:
	_cooldown = maxf(_cooldown - delta, 0.0)
	var cop := case.tasks.local_cop()
	if case.chasing and case.tasks.does(cop, ChaseTasks.MAP_SEATS) and Input.is_action_just_pressed("ask"):
		call_backup()


## The copilot asks for backup: every cop hears the comisario's excuse of the day. Returns the excuse, or "" while
## the radio is still busy with the last one.
func call_backup() -> String:
	if _cooldown > 0.0:
		return ""
	_cooldown = RADIO_COOLDOWN
	var excuse := "CHASE_BACKUP_%d" % (posmod(calls + case.case_seed, EXCUSES) + 1)
	calls += 1
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(excuse)
	return excuse
