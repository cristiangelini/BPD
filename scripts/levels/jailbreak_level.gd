class_name JailbreakLevel
extends Node3D

## The jailbreak's level (fuga.md, step 1): the first time a campaign misses its quota, the cops wake up at night
## locked in their own station's cells, two in each, with the patrol car parked outside. In front of the cells the
## night guard sits at his desk with his box of donuts, one of them with the key (step 2, NightGuard), and on each
## cell's floor lies something long to fish the box with: the broom and the fishing rod (step 3, HookStick).
## --place=jailbreak opens it from Play.

const DESK_MODEL := preload("res://assets/models/station_desk.glb")
const BOX_SCENE := preload("res://scenes/props/guard_donut_box.tscn")
## In the station's own space (StationRooms): the desk 2.9 m from the bars, between the two cell doors, with the
## guard behind it facing the cells and the box on it (propuesta).
const DESK_AT := Vector3(10.5, 0, 7.4)
const GUARD_AT := Vector3(10.5, 0, 8.4)
const BOX_AT := Vector3(10.5, 0.87, 7.25)
## Something to fish the box with, lying on the floor of each cell (step 3): [model, length, grip, turn].
const STICKS := [
	["res://assets/models/broom.glb", 2.8, Vector3(9.8, 0.06, 3.9), PI / 2],
	["res://assets/models/fishing_rod.glb", 3.0, Vector3(11.2, 0.06, 3.9), -PI / 2],
]

## Same seed, same jailbreak. 0 draws one.
@export var case_seed := 0
var city: City
var guard: NightGuard
var box: DonutBox
var sticks: Array[HookStick] = []


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
	for item: Array in STICKS:
		var stick := HookStick.new()
		stick.name = "Broom" if sticks.is_empty() else "FishingRod"
		stick.model = load(item[0])
		stick.length = item[1]
		add_child(stick)
		stick.global_transform = lot * Transform3D(Basis(Vector3.UP, item[3]), item[2])
		sticks.append(stick)
