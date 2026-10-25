class_name TrafficControlLevel
extends Node3D

## The traffic control's level (control-transito.md): the whole city with the station, the cops in the guard room,
## the patrol car at the door and, next to it on the sidewalk, the cones and the barrier. The checkpoint is painted on
## the westbound lane of the street in front of the station, toward the corner. --place=traffic opens it from Play.
## Once it's set up, the cars come and queue up (TrafficQueue), with the patience meter at the top. The comisario
## gives the case (TrafficCase). A quarter of the matches are the rush hour, a quarter the clown convoy
## (control-payasos.md), a quarter the fruit truck (control-frutas.md) and a quarter the crowded car
## (control-auto-lleno.md), by the seed; --traffic=<variant> picks one.

## Along the street in front of the station, from the station's middle toward the east corner, in meters.
const CHECKPOINT_ALONG := 24.0
const CONES := 4
## On the sidewalk by the station's door: the barrier and a row of cones to its west.
const BARRIER_FROM_DOOR := Vector3(6, 0, 1.5)
const CONES_FROM_DOOR := Vector3(-5, 0, 1.5)
## The clown convoy's sponge (control-payasos.md, step 5), on the sidewalk between the barrier and the cones.
const SPONGE_FROM_DOOR := Vector3(1, 0, 1.5)
## What Play draws, a quarter each (propuesta).
const VARIANTS: Array[String] = ["rush_hour", "clown_convoy", "fruit_truck", "crowded_car"]

## Same seed, same cars. 0 draws one.
@export var case_seed := 0
## TrafficQueue.VARIANTS; empty takes --traffic=<variant> from the user args, or draws it with the seed.
@export var variant := ""
var checkpoint: TrafficCheckpoint
var queue: TrafficQueue
var plan: WantedPlan
var clues: TrafficClues
var meters: TrafficMeters
var case: TrafficCase
var sponge: ClownSponge


## Where the checkpoint goes in the city's space: cars run west (-X) on the north half of the street.
static func checkpoint_at() -> Transform3D:
	var p := CityLayout.place("station")
	var x := CityLayout.block_center(p.block).x + CHECKPOINT_ALONG
	var z := CityLayout.street_z(p.block.y + 1) - CityLayout.STREET / 4
	return Transform3D(Basis(Vector3.UP, PI / 2), Vector3(x, 0, z))


static func variant_from(chosen: String, args: PackedStringArray, case_seed := 0) -> String:
	if TrafficQueue.VARIANTS.has(chosen):
		return chosen
	for arg in args:
		if arg.begins_with("--traffic=") and TrafficQueue.VARIANTS.has(arg.trim_prefix("--traffic=")):
			return arg.trim_prefix("--traffic=")
	return VARIANTS[hash(["traffic variant", case_seed]) % VARIANTS.size()]


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	var city: City = $City
	$Cop.global_transform = (city.transform * CityLayout.station_spawn(0)).translated(Vector3.UP * 0.1)
	$PatrolCar.global_transform = (city.transform * CityLayout.parking("station")).translated_local(Vector3.UP * 0.05)
	checkpoint = TrafficCheckpoint.new()
	checkpoint.name = "Checkpoint"
	add_child(checkpoint)
	checkpoint.global_transform = city.transform * checkpoint_at()
	var door := city.transform * CityLayout.door_of("station")
	var barrier := RoadBarrier.new()
	barrier.name = "Barrier"
	add_child(barrier)
	barrier.global_position = door + BARRIER_FROM_DOOR + Vector3.UP * 0.05
	for i in CONES:
		var cone := TrafficCone.new()
		cone.name = "Cone%d" % i
		add_child(cone)
		cone.global_position = door + CONES_FROM_DOOR + Vector3(-0.8 * i, 0.05, 0)
	var chosen := variant_from(variant, OS.get_cmdline_user_args(), case_seed)
	plan = WantedPlan.draw(case_seed, chosen == "clown_convoy", chosen == "fruit_truck", chosen == "crowded_car",
		chosen == "ghost_car")
	if plan.convoy:
		sponge = ClownSponge.new()
		sponge.name = "Sponge"
		add_child(sponge)
		sponge.global_position = door + SPONGE_FROM_DOOR + Vector3.UP * 0.1
	queue = TrafficQueue.new()
	queue.name = "Queue"
	queue.checkpoint = checkpoint
	queue.case_seed = case_seed
	queue.plan = plan
	queue.variant = chosen
	add_child(queue)
	queue.passed.connect(_on_passed)
	meters = TrafficMeters.new()
	meters.queue = queue
	add_child(meters)
	clues = TrafficClues.new()
	clues.name = "Clues"
	clues.plan = plan
	clues.clue_given.connect(_on_clue)
	case = TrafficCase.new()
	case.name = "Case"
	case.case_seed = case_seed
	case.plan = plan
	case.queue = queue
	case.clues = clues
	case.patrol_car = $PatrolCar
	case.shift_screen = $ShiftScreen
	add_child(case)
	case.start(city.comisario)


## The comisario gives the first clue with the case; the rest come by radio.
func _on_clue(index: int, text: String) -> void:
	meters.show_clues(clues.known_text())
	if index > 0:
		for cop: Cop in get_tree().get_nodes_in_group("cops"):
			cop.show_hint(tr("HINT_RADIO_CLUE") % text)


func _on_passed(_car: QueueCar, sneaked: bool) -> void:
	if sneaked:
		for cop: Cop in get_tree().get_nodes_in_group("cops"):
			cop.show_hint("HINT_CAR_SNEAKED")
