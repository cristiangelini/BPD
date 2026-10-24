class_name PrisonRiot
extends Node

## The riot in the prison's canteen (carcel-motin.md, step 2, decision 104): INMATES inmates at their places by the
## six tables, a different set of places for each seed, ANGRY_AT_START of them already angry and the rest somewhere in
## START_ANGER. Nothing moves until the first cop walks through the gate: then the riot is on (started) and every
## inmate's anger lives (PrisonInmate). `angry` counts the angry ones. Step 2b: an angry inmate throws food at a cop
## within COP_REACH COP_SHARE of the time, and otherwise at another inmate within INMATE_REACH (target_for), so the anger
## spreads from table to table. Step 3: a cop with SLIP_STAINS stains of food on them slips and falls (drops what they
## hold, the stains come off); a table knocked over pushes the inmates on that side back, TIP_ANGER more upset.
## Step 4: RINGLEADERS inmates, each at a different table chosen by the seed, lead the riot from on top of their table:
## every RILE_EVERY seconds they're loose they climb back up and get their table RILE_ANGER angrier. Knocking the table
## over brings them down; cuffed, they're walked to the punishment cell (PrisonEscort) and `jailed` counts them. The
## jailed don't count as angry. Every number here is (propuesta).

signal started
## How many are angry now changed.
signal angry_changed(count: int)
## One more ringleader is in the punishment cell.
signal ringleader_jailed(count: int)

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
const RINGLEADERS := 3
const RILE_EVERY := 30.0
const RILE_ANGER := 40.0
const RILES := 3

var prison: PrisonLevel
var inmates: Array[PrisonInmate] = []
var running := false
var angry := 0
var ringleaders: Array[PrisonInmate] = []
var jailed := 0
## A guest's riot: the host's says when it starts and how angry everyone is (NpcSync).
var follower := false
var _rng := RandomNumberGenerator.new()
var _rile_left := 0.0


func setup(level: PrisonLevel, case_seed: int) -> void:
	prison = level
	_rng.seed = hash(["prison riot", case_seed])
	# Each place with its table: [transform, table].
	var places: Array[Array] = []
	for table in level.tables:
		for side: float in [-1.0, 1.0]:
			for x in PLACE_XS:
				# Facing the table: their front (-Z) toward its middle.
				var turn := 0.0 if side > 0 else PI
				places.append([Transform3D(Basis(Vector3.UP, turn), table.position + Vector3(x, 0.05, side * PLACE_Z)),
					table])
	for i in range(places.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var swap := places[i]
		places[i] = places[j]
		places[j] = swap
	var led: Array[CanteenTable] = []
	for i in INMATES:
		var inmate := PrisonInmate.new()
		inmate.name = "Inmate%d" % i
		inmate.table = places[i][1]
		# The first ones at RINGLEADERS different tables lead them (the places are already shuffled by the seed).
		inmate.ringleader = led.size() < RINGLEADERS and not led.has(inmate.table)
		if inmate.ringleader:
			led.append(inmate.table)
		inmate.anger = 100.0 if i < ANGRY_AT_START or inmate.ringleader \
			else _rng.randf_range(START_ANGER.x, START_ANGER.y)
		level.add_child(inmate)
		inmate.global_transform = level.global_transform * places[i][0]
		inmate.riot = self
		if inmate.ringleader:
			ringleaders.append(inmate)
			inmate.climb()
			PrisonEscort.to_cell(inmate, level).boarded.connect(_on_jailed)
		inmate.angry_changed.connect(_on_angry_changed.unbind(2))
		inmate.threw.connect(func(_by: PrisonInmate, food: RallyThrowable) -> void: food.burst.connect(_on_burst))
		inmates.append(inmate)
	angry = count_angry()
	for table in level.tables:
		table.tipped.connect(_on_tipped)


func count_angry() -> int:
	return inmates.filter(func(inmate: PrisonInmate) -> bool:
		return inmate.is_angry() and not inmate.is_jailed()).size()


## The riot is on: every inmate's anger lives.
func start() -> void:
	if running:
		return
	running = true
	_rile_left = RILE_EVERY
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
	# A ringleader up on it comes down on the far side.
	for leader in ringleaders:
		if leader.table == table and leader.is_on_table():
			leader.jump_down(-side)


## Every loose ringleader climbs back on their table and gets everyone at it angrier.
func rile() -> void:
	for leader in ringleaders:
		if leader.is_cuffed() or leader.is_jailed():
			continue
		leader.climb()
		leader.say("RINGLEADER_SHOUT_%d" % _rng.randi_range(1, RILES))
		for inmate in inmates:
			if inmate.table == leader.table and inmate != leader and not inmate.is_cuffed():
				inmate.raise(RILE_ANGER)


func _on_jailed() -> void:
	jailed += 1
	_on_angry_changed()
	ringleader_jailed.emit(jailed)


func _on_angry_changed() -> void:
	var now := count_angry()
	if now != angry:
		angry = now
		angry_changed.emit(angry)


func _physics_process(delta: float) -> void:
	if follower:
		return
	if running:
		_rile_left -= delta
		if _rile_left <= 0.0:
			_rile_left = RILE_EVERY
			rile()
		return
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if prison.inside_walls(cop.global_position):
			start()
			return
