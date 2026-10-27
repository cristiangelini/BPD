class_name LooseWheelRig
extends FairRig

## The unchecked Ferris wheel (allanamiento-parque.md, "La vuelta al mundo sin control"): Don Tómbola never had the wheel
## inspected, he took nuts off it to sell them and signed the safety certificate himself. The fake certificate is the
## main evidence, hidden with the bag of nuts and the inspector's stamp. Loose nuts lie on the ground in front of the
## wheel, and the first one a cop picks up is the story's own clue (on the checklist). Each turn of the crank shakes
## the wheel and drops another nut. Every number here is (propuesta).

const NUT_MODEL := preload("res://assets/models/fair_nut.glb")
const NUT_SIZE := Vector3(0.09, 0.035, 0.08)
const NUT_KG := 0.2
## The nuts already on the ground, in front of the wheel's platform.
const NUTS: Array[Vector3] = [Vector3(-1.5, 0, 1.9), Vector3(0.8, 0, 2.3), Vector3(-0.4, 0, 2.9)]
## Where a shaken-off nut falls from, and at most how many fall.
const DROP_AT := Vector3(0, 2.5, 1.9)
const DROPS_MAX := 8
const SHAKE := 0.06

var nuts: Array[Grabbable] = []
var drops := 0
var picked := false
var _rng := RandomNumberGenerator.new()


func setup(place: Fair) -> void:
	super.setup(place)
	_rng.seed = hash(["loose wheel", place.case_seed])
	for at in NUTS:
		var nut := _nut()
		nut.position = Fair.WHEEL_AT + at + Vector3.UP * (Fair.FLOOR_TOP + NUT_SIZE.y / 2 + 0.01)
	place.rides.ride_started.connect(func(ride: String) -> void:
		if ride == "wheel":
			shake())


func _physics_process(_delta: float) -> void:
	if picked:
		return
	for nut in nuts:
		if nut.is_held():
			picked = true
			fair.raid.add_clue(tr("CLUE_LOOSE_NUTS"))
			return


## The crank shakes the wheel and a nut falls off it.
func shake() -> void:
	var tween := create_tween()
	for i in 4:
		tween.tween_property(fair.wheel, "position:x", Fair.WHEEL_AT.x + SHAKE * (1 - 2 * (i % 2)), 0.06)
	tween.tween_property(fair.wheel, "position:x", Fair.WHEEL_AT.x, 0.06)
	fair.raid.float_label(tr("FAIR_WHEEL_RATTLE"), fair.to_global(Fair.WHEEL_AT + Vector3.UP * 3.0),
		Color(0.85, 0.85, 0.9))
	if drops >= DROPS_MAX:
		return
	drops += 1
	var nut := _nut()
	nut.position = Fair.WHEEL_AT + DROP_AT + Vector3(_rng.randf_range(-1.2, 1.2), 0, 0)


func _nut() -> Grabbable:
	var nut := ClubEvidence.make_item("Nut", NUT_MODEL, NUT_SIZE, NUT_KG)
	(nut.get_child(1) as Node3D).position.y = -NUT_SIZE.y / 2
	fair.add_child(nut)
	nuts.append(nut)
	return nut
