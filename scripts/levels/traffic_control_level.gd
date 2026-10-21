class_name TrafficControlLevel
extends Node3D

## The traffic control's level (control-transito.md): the whole city with the station, the cops in the guard room,
## the patrol car at the door and, next to it on the sidewalk, the cones and the barrier. The checkpoint is painted on
## the westbound lane of the street in front of the station, toward the corner. --place=traffic opens it from Play.
## Once it's set up, the cars come and queue up (TrafficQueue), with the patience meter at the top.

## Along the street in front of the station, from the station's middle toward the east corner, in meters.
const CHECKPOINT_ALONG := 24.0
const CONES := 4
## On the sidewalk by the station's door: the barrier and a row of cones to its west.
const BARRIER_FROM_DOOR := Vector3(6, 0, 1.5)
const CONES_FROM_DOOR := Vector3(-5, 0, 1.5)

## Same seed, same cars. 0 draws one.
@export var case_seed := 0
var checkpoint: TrafficCheckpoint
var queue: TrafficQueue


## Where the checkpoint goes in the city's space: cars run west (-X) on the north half of the street.
static func checkpoint_at() -> Transform3D:
	var p := CityLayout.place("station")
	var x := CityLayout.block_center(p.block).x + CHECKPOINT_ALONG
	var z := CityLayout.street_z(p.block.y + 1) - CityLayout.STREET / 4
	return Transform3D(Basis(Vector3.UP, PI / 2), Vector3(x, 0, z))


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
	queue = TrafficQueue.new()
	queue.name = "Queue"
	queue.checkpoint = checkpoint
	queue.case_seed = case_seed
	add_child(queue)
	queue.passed.connect(_on_passed)
	var meters := TrafficMeters.new()
	meters.queue = queue
	add_child(meters)


func _on_passed(_car: QueueCar, sneaked: bool) -> void:
	if sneaked:
		for cop: Cop in get_tree().get_nodes_in_group("cops"):
			cop.show_hint("HINT_CAR_SNEAKED")
