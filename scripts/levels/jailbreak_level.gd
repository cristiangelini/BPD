class_name JailbreakLevel
extends Node3D

## The jailbreak's level (fuga.md, step 1): the first time a campaign misses its quota, the cops wake up at night
## locked in their own station's cells, two in each, with the patrol car parked outside. In front of the cells the
## night guard sits at his desk with his box of donuts, one of them with the key (step 2, NightGuard).
## --place=jailbreak opens it from Play.

const DESK_MODEL := preload("res://assets/models/station_desk.glb")
const BOX_SCENE := preload("res://scenes/props/guard_donut_box.tscn")
## In the station's own space (StationRooms): the desk 2.9 m from the bars, between the two cell doors, with the
## guard behind it facing the cells and the box on it (propuesta).
const DESK_AT := Vector3(10.5, 0, 7.4)
const GUARD_AT := Vector3(10.5, 0, 8.4)
const BOX_AT := Vector3(10.5, 0.87, 7.25)

## Same seed, same jailbreak. 0 draws one.
@export var case_seed := 0
var city: City
var guard: NightGuard
var box: DonutBox


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	city = $City
	# At night the comisario and the armero went home.
	for npc: Node in [city.comisario, city.armero]:
		if npc:
			npc.queue_free()
	for door in city.cell_doors:
		door.lock()
	_guard_desk()
	$Cop.global_transform = cop_spawn(0)
	$PatrolCar.global_transform = (city.transform * CityLayout.parking("station")).translated_local(Vector3.UP * 0.05)
	($Cop as Cop).show_hint.call_deferred("HINT_JAILED")


## Where the cop in `slot` wakes up: two in each cell (Net puts every player's cop here online).
func cop_spawn(slot: int) -> Transform3D:
	return ($City as Node3D).transform * CityLayout.jail_spawn(slot).translated(Vector3.UP * 0.1)


func _guard_desk() -> void:
	var lot := city.transform * CityLayout.lot("station")
	var desk := StaticBody3D.new()
	desk.name = "GuardDesk"
	add_child(desk)
	desk.global_transform = lot * Transform3D(Basis(Vector3.UP, PI), DESK_AT)
	desk.add_child(DESK_MODEL.instantiate())
	var shape := CollisionShape3D.new()
	var solid := BoxShape3D.new()
	solid.size = StationRooms.SOLID["station_desk"]
	shape.shape = solid
	shape.position.y = solid.size.y / 2
	desk.add_child(shape)
	box = BOX_SCENE.instantiate()
	box.name = "GuardDonutBox"
	add_child(box)
	box.global_transform = lot * Transform3D(Basis(Vector3.UP, PI), BOX_AT)
	guard = NightGuard.new()
	guard.name = "NightGuard"
	add_child(guard)
	guard.global_transform = lot * Transform3D(Basis(Vector3.UP, PI), GUARD_AT)
	guard.setup(case_seed, box)
