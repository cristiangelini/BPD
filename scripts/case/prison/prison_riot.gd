class_name PrisonRiot
extends Node

## The riot in the prison's canteen (carcel-motin.md, step 2, decision 104): INMATES inmates at their places by the
## six tables, a different set of places for each seed, ANGRY_AT_START of them already angry and the rest somewhere in
## START_ANGER. Nothing moves until the first cop walks through the gate: then the riot is on (started) and every
## inmate's anger lives (PrisonInmate). `angry` counts the angry ones. Every number here is (propuesta).

signal started
## How many are angry now changed.
signal angry_changed(count: int)

const INMATES := 20
const ANGRY_AT_START := 6
const START_ANGER := Vector2(10.0, 45.0)
## The places by each table, from its middle: along it, and on either side out past its bench.
const PLACE_XS: Array[float] = [-1.4, -0.45, 0.45, 1.4]
const PLACE_Z := 1.25

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
		inmate.angry_changed.connect(_on_angry_changed.unbind(2))
		inmates.append(inmate)
	angry = count_angry()


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
