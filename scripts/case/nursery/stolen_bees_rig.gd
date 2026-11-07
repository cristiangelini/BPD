class_name StolenBeesRig
extends NurseryRig

## The stolen bees (allanamiento-vivero.md, "Las abejas robadas"): Doña Hortensia took a beekeeper's hive, bees and
## all. A cop this close to the hive hears the buzz, the story's own clue (on the checklist the first time). And the
## bees go after a cop who runs near the hive and give it little pushes, without hurting (Cristian's question 2,
## recommended answer), until it stops running or gets away. Every number here is (propuesta).

const HEAR_RANGE := 3.0
const CHECK_EVERY := 0.5
const BEES := 8
const BEE := Color(0.98, 0.8, 0.15)
## A running cop this close to the hive gets chased; farther than LOSE_RANGE from it, or walking, the bees go home.
const CHASE_RANGE := 6.0
const LOSE_RANGE := 10.0
## How fast the swarm flies, how close it gets to push, and the push (once every STING_EVERY seconds).
const FLY_SPEED := 5.0
const STING_RANGE := 1.0
const PUSH := 1.5
const PUSH_SECONDS := 0.2
const STING_EVERY := 2.0

var heard := false
var stings := 0
var bees: Array[MeshInstance3D] = []
## The cop the swarm is after, or null, and where the swarm is now (global).
var chasing: Cop
var swarm_at := Vector3.ZERO
var _since := 0.0
var _sting_left := 0.0
var _time := 0.0


func setup(place: Nursery) -> void:
	super.setup(place)
	var paint := StandardMaterial3D.new()
	paint.albedo_color = BEE
	paint.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	for i in BEES:
		var bee := MeshInstance3D.new()
		var ball := SphereMesh.new()
		ball.radius = 0.06
		ball.height = 0.12
		bee.mesh = ball
		bee.material_override = paint
		nursery.add_child(bee)
		bees.append(bee)
	swarm_at = home()
	_place_bees()


## Over the hive, wherever it is.
func home() -> Vector3:
	return nursery.main.global_position + Vector3.UP * 0.6


func _physics_process(delta: float) -> void:
	_time += delta
	_sting_left = maxf(_sting_left - delta, 0.0)
	_chase(delta)
	_place_bees()
	_since += delta
	if heard or _since < CHECK_EVERY:
		return
	_since = 0.0
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if cop.global_position.distance_to(nursery.main.global_position) <= HEAR_RANGE:
			hear()
			break


## A cop hears the buzz coming from the hiding spot: the first time it's a clue.
func hear() -> void:
	if heard:
		return
	heard = true
	nursery.raid.add_clue(tr("CLUE_BUZZING"))
	nursery.raid.float_label(tr("NURSERY_BUZZ"), nursery.main.global_position + Vector3.UP * 1.0, BEE)


## The swarm goes after a running cop near the hive, pushes it a little when it catches up, and goes home when the cop
## walks or gets away.
func _chase(delta: float) -> void:
	var hive := nursery.main.global_position
	if chasing and (not is_instance_valid(chasing) or not chasing.is_running
			or chasing.global_position.distance_to(hive) > LOSE_RANGE):
		chasing = null
	if chasing == null:
		for node in get_tree().get_nodes_in_group("cops"):
			var cop := node as Cop
			if cop and cop.is_running and cop.global_position.distance_to(hive) <= CHASE_RANGE:
				chasing = cop
				break
	var target := home() if chasing == null else chasing.global_position + Vector3.UP * 1.3
	swarm_at = swarm_at.move_toward(target, FLY_SPEED * delta)
	if chasing and _sting_left <= 0.0 and swarm_at.distance_to(target) <= STING_RANGE:
		sting(chasing)


## A little push on `cop`, away from the swarm, no harm done.
func sting(cop: Cop) -> void:
	_sting_left = STING_EVERY
	stings += 1
	var away := cop.global_position - swarm_at
	away.y = 0.0
	cop.knock_back((away.normalized() if away.length() > 0.01 else Vector3.FORWARD) * PUSH, PUSH_SECONDS)
	cop.show_hint("HINT_NURSERY_BEES")


func _place_bees() -> void:
	for i in bees.size():
		var angle := _time * 4.0 + i * TAU / bees.size()
		bees[i].global_position = swarm_at + Vector3(cos(angle) * 0.55, sin(_time * 7.0 + i) * 0.2,
			sin(angle * 1.3) * 0.55)
