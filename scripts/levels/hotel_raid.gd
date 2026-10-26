class_name HotelRaid
extends Node3D

## The raid on the Hotel Gran Siesta (hotel-allanamiento.md, step 1, decision 240). The building is the crime scene's
## (Hotel, with crime_scene off: no guests, one 13 behind the wardrobe); the raid puts on top what makes it a raid:
## the rooms and the suite locked, the master key on the board behind the desk (or the ram), the vases downstairs and
## the bedside lamps upstairs that break into fines, and the hiding spots. Don Bostezo watches from the desk and fills
## the complaint meter; the little pillow on the desk puts him to sleep and the bell wakes him (step 2). Doña Escoba and
## the case come in the next steps. Every number here is (propuesta).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const VASE_SCENE := preload("res://scenes/props/ornament_vase.tscn")
const LAMP_SCENE := preload("res://scenes/props/hotel_lamp.tscn")
## The suite's door in `doors` (rooms go by their number).
const SUITE_DOOR := 0
const VASE_HALF_HEIGHT := 0.13
const LAMP_HALF_HEIGHT := 0.21
## The vases: on the reception desk, on the piano and on each dining table.
const VASES: Array[Vector3] = [
	Vector3(-1.2, 1.05, -6.5), Vector3(-11.6, 1.1, -6.5), Vector3(-10.0, 0.77, 0.0), Vector3(-8.0, 0.77, 4.0),
	Vector3(-11.5, 0.77, 4.5),
]
## The little pillow on the desk, on don Bostezo's side, and the bell's collision over the hotel's bell.
const PILLOW_AT := Vector3(0.2, 1.11, -6.65)
const BELL_HIT_AT := Vector3(0.9, 1.12, -6.4)
## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "hotel_in_tub", "at": Hotel.TUB_AT + Vector3(0, 0.6, 0), "heavy": true},
	{"id": "hotel_by_lift", "at": Hotel.LIFT_AT + Vector3(0, Hotel.FLOOR_TOP, 0.5), "heavy": true},
	{"id": "hotel_behind_desk", "at": Vector3(1.2, Hotel.FLOOR_TOP, -7.6), "heavy": true},
	{"id": "hotel_room_13", "at": Vector3(3.5, Hotel.UP, -4.0), "heavy": true},
	{"id": "hotel_by_suite_bed", "at": Hotel.SUITE_BED_AT + Vector3(1.6, 0, 0), "heavy": true},
	{"id": "hotel_behind_piano", "at": Vector3(Hotel.PIANO_AT.x, Hotel.FLOOR_TOP, -7.8), "heavy": true},
	{"id": "hotel_on_piano", "at": Hotel.PIANO_AT + Vector3(0.4, 1.1, 0), "heavy": false},
	{"id": "hotel_on_bed_14", "at": Vector3(7.0, Hotel.UP + 0.5, Hotel.BACK_Z + 1.1), "heavy": false},
	{"id": "hotel_in_case", "at": Hotel.CASE_AT + Vector3(0, 0.9, 0), "heavy": false},
	{"id": "hotel_in_plant", "at": Hotel.PLANT_AT + Vector3(0, 0.5, 0), "heavy": false},
	{"id": "hotel_on_armchair", "at": Hotel.ARMCHAIRS[1] + Vector3(0, 0.5, 0.1), "heavy": false},
	{"id": "hotel_on_table", "at": Hotel.TABLES[0] + Vector3(0.25, 0.77, 0.25), "heavy": false},
]

## Same seed, same draw. 0 draws one.
@export var case_seed := 0
## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var hotel: Hotel
var key_board: HotelKeyBoard
## The locked doors by room number, the suite's under SUITE_DOOR.
var doors: Dictionary = {}
var vases: Array[Ornament] = []
var lamps: Array[Ornament] = []
var broken_goods := 0
var fines := 0
var concierge: HotelConcierge
var pillow: HotelPillow
var bell: HotelBell
var complaint_bar: ProgressBar
@onready var car: PatrolCar = $PatrolCar


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	hotel = Hotel.new()
	hotel.name = "Hotel"
	hotel.crime_scene = false
	hotel.case_seed = case_seed
	add_child(hotel)
	_place_doors()
	_place_key_board()
	_place_fragile()
	_place_concierge()
	var city: Node3D = $City
	city.transform = CityLayout.anchor("hotel")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))


## A locked door on each guest room (the 13 has none: the wardrobe hides it) and on the suite. Each one hangs from
## its hinge, turned on a holder so it swings into its room.
func _place_doors() -> void:
	var half := GameScale.DOOR_WIDTH / 2
	for number: int in Hotel.ROOMS:
		if number == Hotel.HIDDEN_ROOM:
			continue
		var room: Dictionary = Hotel.ROOMS[number]
		if room.side == "n":
			doors[number] = _door(Vector3(room.door - half, Hotel.UP, -Hotel.CORRIDOR), 0.0)
		else:
			doors[number] = _door(Vector3(room.door + half, Hotel.UP, Hotel.CORRIDOR), PI)
	doors[SUITE_DOOR] = _door(Vector3(Hotel.SUITE_X, Hotel.UP, Hotel.DOOR_SUITE_Z + half), PI / 2)


## FrontDoor swings to an absolute turn, so a turned door sits on a holder that carries the turn.
func _door(at: Vector3, turn: float) -> FrontDoor:
	var holder := Node3D.new()
	holder.position = at
	holder.rotation.y = turn
	add_child(holder)
	var door: FrontDoor = DOOR_SCENE.instantiate()
	holder.add_child(door)
	return door


func _place_key_board() -> void:
	key_board = HotelKeyBoard.new()
	key_board.name = "KeyBoard"
	key_board.position = Hotel.KEY_BOARD_AT
	add_child(key_board)


## The vases downstairs and a lamp on every nightstand upstairs: each one that breaks is a fine.
func _place_fragile() -> void:
	for at: Vector3 in VASES:
		vases.append(_fragile(VASE_SCENE, at + Vector3.UP * (VASE_HALF_HEIGHT + 0.005)))
	for number: int in Hotel.ROOMS:
		var room: Dictionary = Hotel.ROOMS[number]
		var north: bool = room.side == "n"
		var far := (Hotel.BACK_Z + 1.1) if north else (Hotel.FRONT_Z - 1.1)
		var stand := Vector3(Hotel.room_middle(number).x + 1.1, Hotel.UP + 0.6, far + (-0.6 if north else 0.6))
		lamps.append(_fragile(LAMP_SCENE, stand + Vector3.UP * (LAMP_HALF_HEIGHT + 0.005)))


func _fragile(scene: PackedScene, at: Vector3) -> Ornament:
	var item: Ornament = scene.instantiate()
	item.position = at
	add_child(item)
	item.broken.connect(_on_fragile_broken)
	return item


func _on_fragile_broken(at: Vector3) -> void:
	broken_goods += 1
	fines += Ornament.FINE
	concierge.saw(at, HotelConcierge.SAW_BREAK)


## Don Bostezo behind the desk, the pillow and the bell on it, and the complaint meter. A rammed door reaches him
## anywhere, and the key only counts if he's awake.
func _place_concierge() -> void:
	concierge = HotelConcierge.new()
	concierge.name = "Concierge"
	concierge.position = Hotel.CONCIERGE_AT + Vector3(0, Hotel.FLOOR_TOP, 0)
	add_child(concierge)
	pillow = HotelPillow.new()
	pillow.name = "Pillow"
	pillow.position = PILLOW_AT
	pillow.concierge = concierge
	add_child(pillow)
	bell = HotelBell.new()
	bell.name = "Bell"
	bell.position = BELL_HIT_AT
	bell.concierge = concierge
	add_child(bell)
	for door: FrontDoor in doors.values():
		door.broken.connect(concierge.door_broken)
	key_board.taken.connect(concierge.key_taken)
	var hud := CanvasLayer.new()
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	box.offset_top = 12
	hud.add_child(box)
	var title := Label.new()
	title.text = "HUD_COMPLAINT"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(title)
	complaint_bar = ProgressBar.new()
	complaint_bar.custom_minimum_size = Vector2(320, 18)
	complaint_bar.show_percentage = false
	complaint_bar.modulate = Color(1, 0.45, 0.35)
	box.add_child(complaint_bar)
	add_child(hud)
	concierge.complaint_changed.connect(func(value: float) -> void: complaint_bar.value = value)
