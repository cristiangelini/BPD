class_name JailbreakLevel
extends Node3D

## The jailbreak's level (fuga.md, step 1): the first time a campaign misses its quota, the cops wake up at night
## locked in their own station's cells, two in each, with the patrol car parked outside. In front of the cells the
## night guard sits at his desk with his box of donuts, one of them with the key (step 2, NightGuard), and on each
## cell's floor lies something long to fish the box with: the broom and the fishing rod (step 3, HookStick). If the
## guard's suspicion fills up (step 4), he puts the cops who are out back in the cells, locks them, takes back his box
## and the stick they used, and keeps the key on his belt; the bar at the top shows his suspicion and the catches.
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

## How many times the guard can catch them (step 6 ends the campaign at the last one).
const CATCHES := 3

## Same seed, same jailbreak. 0 draws one.
@export var case_seed := 0
var city: City
var guard: NightGuard
var box: DonutBox
var sticks: Array[HookStick] = []
var box_home: Transform3D
var suspicion_bar: ProgressBar
var caught_label: Label


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
	_hud()
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
	box_home = lot * Transform3D(Basis(Vector3.UP, PI), BOX_AT)
	box.global_transform = box_home
	guard = NightGuard.new()
	guard.name = "NightGuard"
	add_child(guard)
	guard.global_transform = lot * Transform3D(Basis(Vector3.UP, PI), GUARD_AT)
	guard.setup(case_seed, box)
	guard.outside_cells = outside_cells
	guard.see_through = [desk.get_rid()]
	guard.caught.connect(_on_caught)
	for item: Array in STICKS:
		var stick := HookStick.new()
		stick.name = "Broom" if sticks.is_empty() else "FishingRod"
		stick.model = load(item[0])
		stick.length = item[1]
		add_child(stick)
		stick.global_transform = lot * Transform3D(Basis(Vector3.UP, item[3]), item[2])
		sticks.append(stick)


## Whether a world position is out of both cells (through an open door or never in).
func outside_cells(at: Vector3) -> bool:
	var local := (city.transform * CityLayout.lot("station")).affine_inverse() * at
	return not (local.x > StationRooms.FRONT_X and local.x < StationRooms.HALF_X
		and local.z > StationRooms.SPLIT_Z and local.z < StationRooms.CELL_FRONT_Z)


## The guard caught them: back in the cells, both doors locked, his box on the desk, the stick they used taken away,
## the key on his belt and his donuts out of their hands.
func _on_caught(_times: int) -> void:
	var slot := 0
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if outside_cells(cop.global_position):
			cop.warp(cop_spawn(slot))
			slot += 1
		cop.show_hint("HINT_GUARD_CAUGHT")
	for clue: Node in get_tree().get_nodes_in_group("guard_clues"):
		if clue is CellKey or (clue is LooseDonut and clue.has_key):
			guard.key_on_belt = true
		_drop(clue as Grabbable)
		clue.queue_free()
	for door in city.cell_doors:
		door.lock()
	for stick in sticks.duplicate():
		if stick.is_held() or stick.hooked or outside_cells(stick.global_position):
			stick.unhook()
			_drop(stick)
			sticks.erase(stick)
			stick.queue_free()
	_drop(box)
	box.linear_velocity = Vector3.ZERO
	box.global_transform = box_home


## Out of every cop's hands.
func _drop(item: Grabbable) -> void:
	for cop: Cop in item.handling_cops(0.0):
		cop.get_node("Grabber").release()


func _hud() -> void:
	var hud := CanvasLayer.new()
	hud.name = "SuspicionHud"
	var box_ui := VBoxContainer.new()
	box_ui.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	box_ui.position.y = 16
	var title := Label.new()
	title.text = "HUD_SUSPICION"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box_ui.add_child(title)
	suspicion_bar = ProgressBar.new()
	suspicion_bar.custom_minimum_size = Vector2(320, 18)
	suspicion_bar.show_percentage = false
	suspicion_bar.modulate = Color(1, 0.45, 0.3)
	box_ui.add_child(suspicion_bar)
	caught_label = Label.new()
	caught_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box_ui.add_child(caught_label)
	hud.add_child(box_ui)
	add_child(hud)


func _process(_delta: float) -> void:
	suspicion_bar.value = guard.suspicion
	caught_label.text = tr("HUD_GUARD_CAUGHT") % [guard.times_caught, CATCHES]
