class_name PrisonRiot
extends Node

## The riot in the prison's canteen (carcel-motin.md, step 2, decision 104): INMATES inmates at their places by the
## six tables, a different set of places for each seed, ANGRY_AT_START of them already angry and the rest somewhere in
## START_ANGER. Nothing moves until the first cop walks through the gate: then the riot is on (started) and every
## inmate's anger lives (PrisonInmate). `angry` counts the angry ones. Step 2b: an angry inmate throws food at a cop
## within COP_REACH COP_SHARE of the time, and otherwise at another inmate within INMATE_REACH (target_for), so the anger
## spreads from table to table. Step 3: a cop with SLIP_STAINS stains of food on them slips and falls (drops what they
## hold, the stains come off); a table knocked over pushes the inmates on that side back, TIP_ANGER more upset.
## Every number here is (propuesta).

signal started
## How many are angry now changed.
signal angry_changed(count: int)

const INMATES := 20
const ANGRY_AT_START := 5
const START_ANGER := Vector2(10.0, 45.0)
## The places by each table, from its middle: along it, and on either side out past its bench.
const PLACE_XS: Array[float] = [-1.4, -0.45, 0.45, 1.4]
const PLACE_Z := 1.25
const COP_REACH := 12.0
const COP_SHARE := 0.4
const INMATE_REACH := 8.0
const SLIP_STAINS := 5
const SLIP_TIME := 2.0
const SLIP_PUSH := 3.0
## A knocked over table pushes the inmates within TIP_REACH on that side this far back.
const TIP_REACH := 2.2
const TIP_PUSH := 1.0
const TIP_ANGER := 20.0

var prison: PrisonLevel
var inmates: Array[PrisonInmate] = []
var running := false
var angry := 0
## A guest's riot: the host's says when it starts and how angry everyone is (NpcSync).
var follower := false
var _rng := RandomNumberGenerator.new()


func setup(level: PrisonLevel, case_seed: int) -> void:
	prison = level
	_rng.seed = hash(["prison riot", case_seed])
	var places: Array[Transform3D] = []
	for table in level.tables:
		for side: float in [-1.0, 1.0]:
			for x in PLACE_XS:
				# Facing the table: their front (-Z) toward its middle.
				var turn := 0.0 if side > 0 else PI
				places.append(Transform3D(Basis(Vector3.UP, turn), table.position + Vector3(x, 0.05, side * PLACE_Z)))
	for i in range(places.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var swap := places[i]
		places[i] = places[j]
		places[j] = swap
	for i in INMATES:
		var inmate := PrisonInmate.new()
		inmate.name = "Inmate%d" % i
		inmate.anger = 100.0 if i < ANGRY_AT_START else _rng.randf_range(START_ANGER.x, START_ANGER.y)
		level.add_child(inmate)
		inmate.global_transform = level.global_transform * places[i]
		inmate.riot = self
		inmate.angry_changed.connect(_on_angry_changed.unbind(2))
		inmate.threw.connect(func(_by: PrisonInmate, food: RallyThrowable) -> void: food.burst.connect(_on_burst))
		inmates.append(inmate)
	angry = count_angry()
	for table in level.tables:
		table.tipped.connect(_on_tipped)


func count_angry() -> int:
	return inmates.filter(func(inmate: PrisonInmate) -> bool: return inmate.is_angry()).size()


## The riot is on: every inmate's anger lives.
func start() -> void:
	if running:
		return
	running = true
	for inmate in inmates:
		inmate.active = true
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		cop.show_hint("HINT_RIOT_STARTED")
	started.emit()


## Who `inmate` throws at: the nearest cop within COP_REACH, COP_SHARE of the time; otherwise another inmate within
## INMATE_REACH, at random. Null when there's no one.
func target_for(inmate: PrisonInmate) -> Node3D:
	var nearest: Cop
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		var away := cop.global_position.distance_to(inmate.global_position)
		if away < COP_REACH and (not nearest or away < nearest.global_position.distance_to(inmate.global_position)):
			nearest = cop
	if nearest and _rng.randf() < COP_SHARE:
		return nearest
	var near := inmates.filter(func(other: PrisonInmate) -> bool:
		return other != inmate and other.global_position.distance_to(inmate.global_position) < INMATE_REACH)
	if near.is_empty():
		return nearest
	return near[_rng.randi_range(0, near.size() - 1)]


## Food burst on a cop: with SLIP_STAINS stains on them they slip.
func _on_burst(_food: RallyThrowable, on: Node) -> void:
	if on is Cop and stains_on(on as Cop) >= SLIP_STAINS:
		slip(on as Cop)


func stains_on(cop: Cop) -> int:
	return cop.get_children().filter(func(child: Node) -> bool:
		return child.is_in_group("food_stains") and not child.is_queued_for_deletion()).size()


## Down they go on the mash: whatever they held drops, and the fall wipes the stains off.
func slip(cop: Cop) -> void:
	cop.get_node("Grabber").release()
	var away := Vector3(randf_range(-1, 1), 0, randf_range(-1, 1))
	cop.knock_back(away.normalized() * SLIP_PUSH if away.length() > 0.01 else Vector3.ZERO, SLIP_TIME)
	cop.stats["food_slips"] = cop.stats.get("food_slips", 0) + 1
	cop.show_hint("HINT_FOOD_SLIPPED")
	for child in cop.get_children():
		if child.is_in_group("food_stains"):
			child.queue_free()


## A table went over toward `side`: the inmates standing there jump back, upset.
func _on_tipped(table: CanteenTable, side: float) -> void:
	for inmate in inmates:
		var at := table.global_transform.affine_inverse() * inmate.global_position
		if absf(at.x) < CanteenTable.PARTS[0][1].x / 2 + 0.3 and at.z * side > 0.0 and absf(at.z) < TIP_REACH:
			inmate.global_position += table.global_transform.basis.z * side * TIP_PUSH
			inmate.raise(TIP_ANGER)


func _on_angry_changed() -> void:
	var now := count_angry()
	if now != angry:
		angry = now
		angry_changed.emit(angry)


func _physics_process(_delta: float) -> void:
	if running or follower:
		return
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if prison.inside_walls(cop.global_position):
			start()
			return
