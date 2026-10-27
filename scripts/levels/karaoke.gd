class_name Karaoke
extends Node3D

## The karaoke "Karaoke El Desafine" as a place to raid (docs/diseno/allanamiento-karaoke.md, step 1): a karaoke on its
## lot in the city, open and with the front to +Z. The stage stands against the back wall, with its steps on the east
## side, a speaker at each end and the lyrics screen over it; east of it the sound guy's booth with the console, and the
## owner's office in the back east corner, locked, with the desk and the rack of dresses. The room has eight round
## tables under the disco ball, the three private booths along the west wall and the bar by the door on the east side
## (the office's key in its till), with the ice machine, the juice fridge and the stack of chairs. The lyrics screen
## breaks if something hits it fast and the disco ball falls if something thrown hits it, a fine each. Every number
## here is (propuesta).

signal screen_broken
signal disco_ball_fell

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const SPEAKER_MODEL := preload("res://assets/models/stage_speaker.glb")
const SCREEN_MODEL := preload("res://assets/models/lyrics_screen.glb")
const CONSOLE_MODEL := preload("res://assets/models/sound_console.glb")
const BAR_MODEL := preload("res://assets/models/karaoke_bar.glb")
const ICE_MODEL := preload("res://assets/models/ice_machine.glb")
const TABLE_MODEL := preload("res://assets/models/karaoke_table.glb")
const DISCO_MODEL := preload("res://assets/models/disco_ball.glb")
const SOFA_MODEL := preload("res://assets/models/booth_sofa.glb")
const RACK_MODEL := preload("res://assets/models/dress_rack.glb")
const CHAIRS_MODEL := preload("res://assets/models/chair_stack.glb")
const NOTE_MODEL := preload("res://assets/models/neon_note.glb")
const HALF_X := 12.0
const HALF_Z := 10.0
const WALL_TOP := 4.5
const BUILDING_TOP := 6.0
const FLOOR_TOP := 0.06
## The open doorway in the middle of the front wall.
const ENTRANCE_X := 0.0
const ENTRANCE_WIDTH := 3.5
const ENTRANCE_HEIGHT := 3.0

## The stage against the back wall (its middle on the floor), the steps up on its east end and its front edge.
const STAGE_AT := Vector3(-2.0, FLOOR_TOP, -7.5)
const STAGE_SIZE := Vector3(10.0, 0.6, 4.0)
const STEPS_X := 2.2
const STEPS_RUN := 1.6
const STEPS_WIDTH := 1.4
const SPEAKER_X: Array[float] = [-6.3, 2.3]
const SPEAKER_Z := -8.7
const SPEAKER_SIZE := Vector3(1.0, 1.8, 0.8)
## The lyrics screen over the stage, on the back wall.
const SCREEN_AT := Vector3(-2.0, 2.9, -9.8)
const SCREEN_SIZE := Vector3(5.0, 2.4, 0.6)
const SCREEN_SPEED := 3.0
const SCREEN_FINE := 30
## The disco ball over the middle of the room, and what knocks it down.
const DISCO_AT := Vector3(-2.5, 3.6, 0.5)
const DISCO_SIZE := Vector3(0.7, 0.7, 0.7)
const DISCO_SPEED := 3.0
const DISCO_FINE := 15
## The round tables of the room.
const TABLES: Array[Vector3] = [Vector3(-6.0, 0, -2.5), Vector3(-2.5, 0, -2.5), Vector3(1.0, 0, -2.5),
	Vector3(-6.0, 0, 1.0), Vector3(-2.5, 0, 1.0), Vector3(1.0, 0, 1.0), Vector3(-6.0, 0, 4.5), Vector3(-2.5, 0, 4.5)]
const TABLE_SIZE := Vector3(0.9, 0.78, 0.9)
## The three private booths along the west wall, each from its back wall (x = -HALF_X) to its door wall (BOOTH_X),
## their middles along Z.
const BOOTH_X := -9.0
const BOOTH_Z: Array[float] = [-2.5, 0.5, 3.5]
const BOOTH_DEPTH := 3.0
const BOOTH_TOP := 2.6
## The sound guy's console, east of the stage, its knobs to the back where he stands.
const CONSOLE_AT := Vector3(6.0, FLOOR_TOP, -7.0)
const CONSOLE_SIZE := Vector3(2.4, 1.0, 0.8)
## The bar by the door (its till holds the office's key), the ice machine, the juice fridge and the stack of chairs.
const BAR_AT := Vector3(7.5, FLOOR_TOP, 3.0)
const BAR_SIZE := Vector3(3.7, 1.1, 0.8)
const TILL_ON := Vector3(6.2, FLOOR_TOP + 1.12, 3.0)
const ICE_AT := Vector3(10.6, FLOOR_TOP, 1.4)
const ICE_SIZE := Vector3(0.9, 1.0, 0.7)
const FRIDGE_AT := Vector3(6.2, FLOOR_TOP, 1.2)
const FRIDGE_SIZE := Vector3(0.8, 1.8, 0.7)
const CHAIRS_AT := Vector3(11.3, FLOOR_TOP, -2.5)
## The office in the back east corner, its door in its front wall (OFFICE_Z), with the desk and the rack of dresses.
const OFFICE_X := 8.0
const OFFICE_Z := -4.5
const OFFICE_DOOR_X := 10.0
const DESK_AT := Vector3(9.6, FLOOR_TOP, -9.0)
const DESK_SIZE := Vector3(1.8, 0.8, 0.9)
const RACK_AT := Vector3(11.4, FLOOR_TOP, -7.5)

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "behind_stage_speaker", "at": Vector3(-8.0, FLOOR_TOP, -8.6), "heavy": true},
	{"id": "at_stage_foot", "at": Vector3(-5.5, FLOOR_TOP, -5.0), "heavy": true},
	{"id": "behind_sound_console", "at": Vector3(6.0, FLOOR_TOP, -8.8), "heavy": true},
	{"id": "by_ice_machine", "at": Vector3(10.6, FLOOR_TOP, 0.4), "heavy": true},
	{"id": "in_karaoke_office_corner", "at": Vector3(11.2, FLOOR_TOP, -5.4), "heavy": true},
	{"id": "by_chair_stack", "at": Vector3(11.3, FLOOR_TOP, -1.4), "heavy": true},
	{"id": "on_booth_1_sofa", "at": Vector3(-11.0, FLOOR_TOP + 0.46, -2.5), "heavy": false},
	{"id": "in_booth_3", "at": Vector3(-10.0, FLOOR_TOP, 4.6), "heavy": false},
	{"id": "under_dress_rack", "at": Vector3(11.4, FLOOR_TOP, -7.5), "heavy": false},
	{"id": "under_karaoke_table", "at": Vector3(-6.0, FLOOR_TOP, 4.5), "heavy": false},
	{"id": "on_karaoke_bar", "at": Vector3(8.6, FLOOR_TOP + 1.1, 3.0), "heavy": false},
	{"id": "on_karaoke_desk", "at": Vector3(9.6, FLOOR_TOP + 0.8, -9.0), "heavy": false},
]

const OUTSIDE := Color(0.45, 0.25, 0.6)
const CARPET := Color(0.2, 0.14, 0.3)
const STAGE_WOOD := Color(0.22, 0.2, 0.26)
const STAGE_EDGE := Color(1.0, 0.36, 0.82)
const CEILING := Color(0.1, 0.08, 0.14)
const WOOD := Color(0.5, 0.36, 0.26)
const DARK := Color(0.1, 0.1, 0.12)
const GLASS := Color(0.6, 0.82, 0.95)
const SPOT_COLORS: Array[Color] = [Color(1.0, 0.4, 0.85), Color(0.4, 0.6, 1.0), Color(1.0, 0.85, 0.3)]

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var city_map: CityMap
var office_door: FrontDoor
var till: Till
var screen_cracked := false
var disco_fallen := false
## Money taken off the case pay: the lyrics screen and the disco ball.
var fines := 0
## Same seed, same karaoke (the stories and the hiding spots come from it, step 5).
@export var case_seed := 0
var _build: PlaceBuilder
var _disco: Node3D
@onready var car: PatrolCar = $PatrolCar


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_stage()
	_build_room()
	_build_booths()
	_build_bar()
	_build_office()
	office_door = _door(OFFICE_DOOR_X)
	var city: Node3D = $City
	city.transform = CityLayout.anchor("karaoke")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "karaoke", car)


## The carpet, the walls with the doorway, the dark ceiling with its lights, the roof, the sign and its neon note.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, CARPET)
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, WALL_TOP + PlaceBuilder.SLAB, CEILING)
	var x0 := ENTRANCE_X - ENTRANCE_WIDTH / 2
	var x1 := ENTRANCE_X + ENTRANCE_WIDTH / 2
	_build.wall_at("x", HALF_Z, -HALF_X, x0, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("x", HALF_Z, x1, HALF_X, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("x", HALF_Z, x0, x1, ENTRANCE_HEIGHT, WALL_TOP - ENTRANCE_HEIGHT, [], OUTSIDE)
	_build.wall_at("x", -HALF_Z, -HALF_X, HALF_X, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("z", -HALF_X, -HALF_Z, HALF_Z, 0.0, WALL_TOP, [], OUTSIDE)
	_build.wall_at("z", HALF_X, -HALF_Z, HALF_Z, 0.0, WALL_TOP, [], OUTSIDE)
	var upper := BUILDING_TOP - WALL_TOP - PlaceBuilder.SLAB
	_build.box(Vector3(0, WALL_TOP + PlaceBuilder.SLAB + upper / 2, 0), Vector3(HALF_X * 2, upper, HALF_Z * 2), OUTSIDE)
	_label("PLACE_KARAOKE", Vector3(-4.5, WALL_TOP + 0.6, HALF_Z + 0.08), 110)
	_label("KARAOKE_MOTTO", Vector3(-4.5, ENTRANCE_HEIGHT + 0.6, HALF_Z + 0.08), 60)
	_model(NOTE_MODEL, Vector3(7.5, BUILDING_TOP, HALF_Z - 1.0))
	for x: float in [-9.0, -4.0, 1.0, 6.0, 10.0]:
		for z: float in [-5.0, 0.5, 6.0]:
			_build.light(Vector3(x, 4.1, z)).light_energy = 1.1


## The stage with its colored edge and steps, the speakers, the lyrics screen and the spotlights over it.
func _build_stage() -> void:
	_build.box(STAGE_AT + Vector3(0, STAGE_SIZE.y / 2, 0), STAGE_SIZE, STAGE_WOOD)
	_build.mesh_box(STAGE_AT + Vector3(0, STAGE_SIZE.y - 0.04, STAGE_SIZE.z / 2 + 0.01), Vector3(STAGE_SIZE.x, 0.06, 0.03),
		STAGE_EDGE)
	_steps(Vector3(STEPS_X, FLOOR_TOP, STAGE_AT.z + STAGE_SIZE.z / 2 + STEPS_RUN))
	for x: float in SPEAKER_X:
		var at := Vector3(x, FLOOR_TOP + STAGE_SIZE.y, SPEAKER_Z)
		_solid(at + Vector3(0, SPEAKER_SIZE.y / 2, 0), SPEAKER_SIZE)
		_model(SPEAKER_MODEL, at)
	_model(SCREEN_MODEL, SCREEN_AT + Vector3(0, 0, 0.1))
	var hit := _area(SCREEN_AT + Vector3(0, 0, SCREEN_SIZE.z / 2), SCREEN_SIZE)
	hit.body_entered.connect(func(body: Node3D) -> void:
		if body is RigidBody3D and (body as RigidBody3D).linear_velocity.length() > SCREEN_SPEED:
			break_screen())
	for i in SPOT_COLORS.size():
		var light := _build.light(Vector3(-5.0 + i * 3.0, 3.8, -6.5))
		light.light_color = SPOT_COLORS[i]
		light.light_energy = 2.0


## Steps up the front of the stage from `foot` (on the floor, in front of them), a ramp to walk on.
func _steps(foot: Vector3) -> void:
	var rise := STAGE_SIZE.y
	var count := 3
	for i in count:
		var top := foot.y + (i + 1) * rise / count
		var depth := STEPS_RUN / count
		_build.mesh_box(Vector3(foot.x, (foot.y + top) / 2, foot.z - (i + 0.5) * depth),
			Vector3(STEPS_WIDTH, top - foot.y, depth), STAGE_WOOD.lightened(0.2))
	var ramp := _build.body(foot + Vector3(0, rise / 2, -STEPS_RUN / 2))
	ramp.rotation.x = atan2(rise, STEPS_RUN)
	_build.shape(ramp, Vector3(STEPS_WIDTH, 0.05, Vector2(STEPS_RUN, rise).length()))


## The round tables and the disco ball hanging over them.
func _build_room() -> void:
	for at: Vector3 in TABLES:
		var floor_at := at + Vector3.UP * FLOOR_TOP
		_solid(floor_at + Vector3(0, TABLE_SIZE.y / 2, 0), TABLE_SIZE)
		_model(TABLE_MODEL, floor_at)
	_disco = _model(DISCO_MODEL, DISCO_AT)
	var hit := _area(DISCO_AT, DISCO_SIZE)
	hit.body_entered.connect(func(body: Node3D) -> void:
		if body is RigidBody3D and (body as RigidBody3D).linear_velocity.length() > DISCO_SPEED:
			drop_disco_ball())


## The three private booths along the west wall: their walls, a door each, the sofa and the number over the door.
func _build_booths() -> void:
	var z0 := BOOTH_Z[0] - BOOTH_DEPTH / 2
	var z1 := BOOTH_Z[BOOTH_Z.size() - 1] + BOOTH_DEPTH / 2
	_build.wall_at("z", BOOTH_X, z0, z1, 0.0, BOOTH_TOP, Array(BOOTH_Z), OUTSIDE.darkened(0.3))
	for z: float in [z0, z1] + BOOTH_Z.slice(0, BOOTH_Z.size() - 1).map(func(mid: float) -> float:
			return mid + BOOTH_DEPTH / 2):
		_build.wall_at("x", z, -HALF_X, BOOTH_X, 0.0, BOOTH_TOP, [], OUTSIDE.darkened(0.3))
	for i in BOOTH_Z.size():
		var sofa := Vector3(-HALF_X + 0.5, FLOOR_TOP, BOOTH_Z[i])
		_solid(sofa + Vector3(0.1, 0.4, 0), Vector3(0.7, 0.8, 2.4))
		_model(SOFA_MODEL, sofa, PI / 2)
		_label("KARAOKE_BOOTH_%d" % (i + 1), Vector3(BOOTH_X + 0.08, GameScale.DOOR_HEIGHT + 0.25, BOOTH_Z[i]), 28, PI / 2)


## The bar with its till, the ice machine, the juice fridge and the stack of chairs.
func _build_bar() -> void:
	_solid(BAR_AT + Vector3(0, BAR_SIZE.y / 2, 0), BAR_SIZE)
	_model(BAR_MODEL, BAR_AT)
	till = Till.new()
	till.position = TILL_ON + Vector3.UP * Till.SIZE.y / 2
	till.key_hint = "HINT_TILL_KEY_KARAOKE"
	add_child(till)
	_solid(ICE_AT + Vector3(0, ICE_SIZE.y / 2, 0), ICE_SIZE)
	_model(ICE_MODEL, ICE_AT)
	_build.box(FRIDGE_AT + Vector3(0, FRIDGE_SIZE.y / 2, 0), FRIDGE_SIZE, Color(0.9, 0.92, 0.95))
	_build.mesh_box(FRIDGE_AT + Vector3(0, FRIDGE_SIZE.y / 2, FRIDGE_SIZE.z / 2 + 0.01), Vector3(0.7, 1.6, 0.02), GLASS)
	_solid(CHAIRS_AT + Vector3(0, 0.75, 0), Vector3(0.5, 1.5, 0.5))
	_model(CHAIRS_MODEL, CHAIRS_AT)


## The sound guy's console and the owner's office (walls, its locked door, the desk and the rack of dresses).
func _build_office() -> void:
	_solid(CONSOLE_AT + Vector3(0, CONSOLE_SIZE.y / 2, 0), CONSOLE_SIZE)
	_model(CONSOLE_MODEL, CONSOLE_AT)
	_build.wall_at("x", OFFICE_Z, OFFICE_X, HALF_X, 0.0, WALL_TOP, [OFFICE_DOOR_X], OUTSIDE.lightened(0.2))
	_build.wall_at("z", OFFICE_X, -HALF_Z, OFFICE_Z, 0.0, WALL_TOP, [], OUTSIDE.lightened(0.2))
	_build.legs(DESK_AT, Vector2(DESK_SIZE.x, DESK_SIZE.z), DESK_SIZE.y - 0.04, DARK)
	_build.box(DESK_AT + Vector3(0, DESK_SIZE.y - 0.02, 0), Vector3(DESK_SIZE.x, 0.04, DESK_SIZE.z), WOOD)
	_model(RACK_MODEL, RACK_AT, PI / 2)


## Something hit the lyrics screen hard, once: a fine, the cracks and the screen goes dark.
func break_screen() -> void:
	if screen_cracked:
		return
	screen_cracked = true
	fines += SCREEN_FINE
	_build.mesh_box(SCREEN_AT + Vector3(0, 0, 0.17), Vector3(4.8, 2.2, 0.01), DARK)
	for i in 5:
		_build.mesh_box(SCREEN_AT + Vector3(-1.6 + i * 0.8, -0.4 + (i % 3) * 0.4, 0.18), Vector3(1.0, 0.03, 0.01),
			Color(0.7, 0.72, 0.78))
	_say(SCREEN_AT + Vector3(0, 1.6, 0.5), "KARAOKE_SCREEN_BROKEN")
	screen_broken.emit()


## Something thrown knocked the disco ball down, once: a fine and its mirrors all over the floor under it.
func drop_disco_ball() -> void:
	if disco_fallen:
		return
	disco_fallen = true
	fines += DISCO_FINE
	_disco.hide()
	var rng := RandomNumberGenerator.new()
	rng.seed = case_seed
	for i in 14:
		var at := Vector3(DISCO_AT.x + rng.randf_range(-1.2, 1.2), FLOOR_TOP + 0.01, DISCO_AT.z + rng.randf_range(-1.2, 1.2))
		_build.mesh_box(at, Vector3(0.08, 0.01, 0.08), Color(0.9, 0.92, 0.96))
	_say(DISCO_AT + Vector3(0, -1.0, 0), "KARAOKE_DISCO_BROKEN")
	disco_ball_fell.emit()


## A locked door in the office's front wall, its middle at x.
func _door(x: float) -> FrontDoor:
	var door: FrontDoor = DOOR_SCENE.instantiate()
	door.position = Vector3(x - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, OFFICE_Z)
	add_child(door)
	return door


## A box only to bump into, under a model that gives the look.
func _solid(center: Vector3, size: Vector3) -> void:
	_build.shape(_build.body(center), size)


func _area(center: Vector3, size: Vector3) -> Area3D:
	var area := Area3D.new()
	area.position = center
	area.collision_layer = 0
	area.collision_mask = 4
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	area.add_child(shape)
	add_child(area)
	return area


func _label(key: String, at: Vector3, size: int, turn := 0.0, pixel := 0.01) -> void:
	var label := Label3D.new()
	label.text = key
	label.font_size = size
	label.pixel_size = pixel
	label.outline_size = 18
	label.double_sided = false
	label.position = at
	label.rotation.y = turn
	$Built.add_child(label)


## A floating line over `at` for a few seconds.
func _say(at: Vector3, key: String, seconds := 3.0) -> void:
	var label := Label3D.new()
	label.text = key
	label.font_size = 48
	label.pixel_size = 0.01
	label.outline_size = 12
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = at
	add_child(label)
	get_tree().create_timer(seconds).timeout.connect(label.queue_free)


## A model only for the look, standing at `at` and turned `turn` around Y.
func _model(scene: PackedScene, at: Vector3, turn := 0.0) -> Node3D:
	var look: Node3D = scene.instantiate()
	look.position = at
	look.rotation.y = turn
	$Built.add_child(look)
	return look
