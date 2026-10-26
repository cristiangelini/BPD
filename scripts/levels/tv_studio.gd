class_name TvStudio
extends Node3D

## The city's TV channel (politico-debate.md, step 1, decision 230): block (1, 4), its front to +Z on the street, where
## Deputy Lustre debates candidate Rita Malvón live. The building is 34 x 22 m: on the west the studio, two floors
## tall, with the set at the back (the two lecterns, the moderator's desk and the big on-air screen over them), the
## audience's stand of 3 steps at the front and the lighting rig hanging from the roof; on the east, a wing with the
## lobby and the stairs at the front and the makeup room at the back, and over the makeup room the control room, its
## console behind a window that looks down into the studio. The cops start in the station and drive here; --place=debate
## opens it from Play. Step 2: the 3 cameras on wheels (TvCamera) and the big screen, which shows live what the camera
## on air sees. Step 3: Lustre, Malvón and the moderator at their places and the debate (TvDebate). Every number here
## is (propuesta).

const LECTERN_MODEL := preload("res://assets/models/tv_lectern.glb")
const DESK_MODEL := preload("res://assets/models/tv_anchor_desk.glb")
const CONSOLE_MODEL := preload("res://assets/models/tv_console.glb")
const MIRROR_MODEL := preload("res://assets/models/makeup_mirror.glb")
## The building (CityLayout "tv_studio"): half its width (x) and depth (z), and its roof.
const HALF_X := 17.0
const HALF_Z := 11.0
const ROOF := 7.0
const FLOOR_TOP := 0.06
## The wall between the studio (west) and the east wing, and the wing's wall between the lobby and the makeup room.
const WING_X := 5.0
const WING_SPLIT := -1.0
## The front doors, 3 m wide: the studio's (for the public and the deputy) and the lobby's.
const DOORWAY := 3.0
const DOORWAY_HEIGHT := 3.0
const STUDIO_DOOR_X := -15.0
const LOBBY_DOOR_X := 11.0
## The doors through the wing's wall, from the studio to the makeup room and to the lobby.
const MAKEUP_DOOR_Z := -6.0
const LOBBY_DOOR_Z := 6.0
## The stairs in the lobby, up along -Z to the control room.
const STAIRS_FOOT := Vector3(14.5, 0, 5.0)
const STAIRS_RUN := 6.0
## The control room's window into the studio: from this high over its floor to this high, and how far along z.
const WINDOW := Vector2(0.5, 2.3)
const WINDOW_Z := Vector2(-10.4, -1.6)
## The set: its floor, the lecterns (Malvón's on the west, Lustre's on the east), the moderator's desk and the screen.
const SET := Rect2(-15.0, -11.0, 18.0, 6.0)
const LECTERNS: Array[Vector3] = [Vector3(-11, 0, -6.0), Vector3(-1, 0, -6.0)]
const LECTERN_TURN := 0.25
const DESK_AT := Vector3(-6, 0, -8.5)
const SCREEN_AT := Vector3(-6, 3.9, -HALF_Z + 0.2)
const SCREEN := Vector2(9.0, 4.2)
## The audience's stand: 3 steps rising toward the front, each this deep and high, this long along x.
const STAND_X := Vector2(-12.0, 0.0)
const STAND_FRONT := 4.5
const STAND_STEPS := 3
const STEP := Vector2(1.6, 0.45)
const PUBLIC := 12
## The control room's console along the window, its operators to +X, and their 3 chairs.
const CONSOLE_AT := Vector3(6.3, 0, -6.0)
const CHAIRS_X := 7.5
const CHAIRS_Z: Array[float] = [-8.5, -6.0, -3.5]
const MIRROR_AT := Vector3(11, 0, -10.6)
## The 3 cameras between the stand and the set, each aimed at what it shoots: Malvón, the moderator and Lustre.
const CAMERAS: Array[Vector3] = [Vector3(-10, 0, 0), Vector3(-6, 0, 1), Vector3(-2, 0, 0)]
const SHOTS: Array[Vector3] = [Vector3(-11, 1.5, -6), Vector3(-6, 1.3, -8.5), Vector3(-1, 1.5, -6)]
## The camera on air when the studio opens: Lustre's.
const FIRST_ON_AIR := 2
## Where each of them stands: this far behind the lectern or the desk, facing the cameras.
const BEHIND := 0.65
## The picture the screen shows, in pixels.
const FEED_SIZE := Vector2i(768, 360)

const WALL := Color(0.62, 0.7, 0.82)
const BAND := Color(0.85, 0.2, 0.25)
const STUDIO_WALL := Color(0.16, 0.17, 0.22)
const FLOOR := Color(0.3, 0.3, 0.33)
const SET_FLOOR := Color(0.18, 0.28, 0.55)
const STAND := Color(0.45, 0.47, 0.52)
const SEAT := Color(0.75, 0.2, 0.25)
const RIG := Color(0.12, 0.12, 0.14)
const GLASS := Color(0.7, 0.85, 0.95, 0.35)
const ON_AIR := Color(0.95, 0.1, 0.12)
const LOBBY := Color(0.93, 0.9, 0.82)

## The case's seed (who sits where, later steps).
var case_seed := 0
## The big screen over the set and the red on-air light.
var screen: MeshInstance3D
var on_air: MeshInstance3D
## The 3 cameras, which one is on air, and the picture it makes for the screen (step 2).
var cameras: Array[TvCamera] = []
var on_air_index := -1
var feed: SubViewport
var feed_camera: Camera3D
## The debate and who's in it (step 3).
var politician: Politician
var malvon: RallyFan
var moderator: RallyFan
var debate: TvDebate
var lecterns: Array[Node3D] = []
var public: Array[RallyFan] = []
var _build: PlaceBuilder

@onready var car: PatrolCar = $PatrolCar
@onready var city: Node3D = $City


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_studio()
	_build_wing()
	_seat_public()
	_place_cameras()
	put_on_air(FIRST_ON_AIR)
	politician = Politician.new()
	politician.name = "Politician"
	_stand(politician, LECTERNS[1])
	malvon = _guest("Malvon", "candidata", LECTERNS[0])
	moderator = _guest("Moderator", "moderadora", DESK_AT)
	debate = TvDebate.new()
	debate.name = "Debate"
	debate.setup(self, politician, malvon, moderator)
	add_child(debate)
	city.transform = CityLayout.anchor("tv_studio")
	car.global_transform = (city.transform * CityLayout.parking("station")).translated_local(Vector3.UP * 0.05)
	$Cop.global_transform = (city.transform * CityLayout.station_spawn(0)).translated(Vector3.UP * 0.1)


## Puts camera `index` on air: its tally lights and the screen shows what it sees.
func put_on_air(index: int) -> void:
	on_air_index = index
	for i in cameras.size():
		cameras[i].on_air = i == index
	_process(0.0)


## The camera on air, or null.
func camera_on_air() -> TvCamera:
	return cameras[on_air_index] if on_air_index >= 0 and on_air_index < cameras.size() else null


func _process(_delta: float) -> void:
	var live := camera_on_air()
	if live:
		feed_camera.global_transform = live.lens()


## Someone behind a lectern or the desk, facing the cameras (NPCs face -Z).
func _stand(who: Node3D, spot: Vector3) -> void:
	add_child(who)
	who.position = spot + Vector3(0, FLOOR_TOP + 0.05, -BEHIND)
	who.rotation.y = PI


func _guest(guest_name: String, look: String, spot: Vector3) -> RallyFan:
	var guest := RallyFan.new()
	guest.name = guest_name
	guest.look = look
	_stand(guest, spot)
	return guest


## The 3 cameras on their spots, each aimed at its shot.
func _place_cameras() -> void:
	for i in CAMERAS.size():
		var camera := TvCamera.new()
		camera.name = "Camera%d" % i
		add_child(camera)
		camera.position = CAMERAS[i] + Vector3.UP * FLOOR_TOP
		camera.aim_at(to_global(SHOTS[i]))
		cameras.append(camera)


## Whether a world position is inside the studio (not the wing).
func in_studio(at: Vector3) -> bool:
	var local := to_local(at)
	return local.x > -HALF_X and local.x < WING_X and absf(local.z) < HALF_Z


## Whether a world position is up in the control room.
func in_control_room(at: Vector3) -> bool:
	var local := to_local(at)
	return local.x > WING_X and local.x < HALF_X and local.z > -HALF_Z and local.z < WING_SPLIT \
		and local.y > GameScale.FLOOR_HEIGHT - 0.5


## The floor, the outer walls with the two front doors and the sign, the roof and the antenna on it.
func _build_shell() -> void:
	_build.slab(-HALF_X, WING_X, -HALF_Z, HALF_Z, FLOOR_TOP + 0.02, FLOOR)
	_build.slab(WING_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP + 0.02, LOBBY)
	_build.slab(-HALF_X - 0.3, HALF_X + 0.3, -HALF_Z - 0.3, HALF_Z + 0.3, ROOF + 0.2, WALL.darkened(0.4))
	var y := ROOF / 2
	_build.box(Vector3(0, y, -HALF_Z), Vector3(HALF_X * 2, ROOF, PlaceBuilder.WALL), WALL)
	for side: float in [-1.0, 1.0]:
		_build.box(Vector3(side * HALF_X, y, 0), Vector3(PlaceBuilder.WALL, ROOF, HALF_Z * 2), WALL)
	var edges: Array[float] = [-HALF_X, STUDIO_DOOR_X - DOORWAY / 2, STUDIO_DOOR_X + DOORWAY / 2,
		LOBBY_DOOR_X - DOORWAY / 2, LOBBY_DOOR_X + DOORWAY / 2, HALF_X]
	for i in range(0, edges.size(), 2):
		var middle := (edges[i] + edges[i + 1]) / 2
		_build.box(Vector3(middle, y, HALF_Z), Vector3(edges[i + 1] - edges[i], ROOF, PlaceBuilder.WALL), WALL)
	for x: float in [STUDIO_DOOR_X, LOBBY_DOOR_X]:
		var lintel := ROOF - DOORWAY_HEIGHT
		_build.box(Vector3(x, DOORWAY_HEIGHT + lintel / 2, HALF_Z), Vector3(DOORWAY, lintel, PlaceBuilder.WALL), WALL)
	_build.mesh_box(Vector3(0, ROOF - 1.6, HALF_Z + 0.1), Vector3(HALF_X * 2, 1.6, 0.05), BAND)
	_label("PLACE_TV_STUDIO", Vector3(-4, ROOF - 1.6, HALF_Z + 0.14), 0.0, 120)
	_label("TV_STUDIO_DOOR", Vector3(STUDIO_DOOR_X, DOORWAY_HEIGHT + 0.4, HALF_Z + 0.12), 0.0, 44)
	_label("TV_LOBBY_DOOR", Vector3(LOBBY_DOOR_X, DOORWAY_HEIGHT + 0.4, HALF_Z + 0.12), 0.0, 44)
	# The antenna mast on the roof, with its cross bars and the red light on top.
	var mast := Vector3(12, ROOF + 0.2, -8)
	_build.mesh_box(mast + Vector3(0, 4, 0), Vector3(0.25, 8, 0.25), RIG)
	for i in 3:
		_build.mesh_box(mast + Vector3(0, 3 + i * 1.8, 0), Vector3(2.4 - i * 0.6, 0.1, 0.1), RIG)
	_build.mesh(_glow_sphere(), mast + Vector3(0, 8.2, 0), ON_AIR)


## The studio's dark walls, the set with its lecterns, desk and screen, the stand and the lighting rig.
func _build_studio() -> void:
	var inner := HALF_X - 0.1
	_build.mesh_box(Vector3(-HALF_X + 0.1, ROOF / 2, 0), Vector3(0.02, ROOF, HALF_Z * 2), STUDIO_WALL)
	_build.mesh_box(Vector3((WING_X - inner) / 2, ROOF / 2, -HALF_Z + 0.1), Vector3(WING_X + inner, ROOF, 0.02),
		STUDIO_WALL)
	_build.mesh_box(Vector3(SET.get_center().x, FLOOR_TOP + 0.03, SET.get_center().y), Vector3(SET.size.x, 0.02,
		SET.size.y), SET_FLOOR)
	for i in LECTERNS.size():
		var lectern: Node3D = LECTERN_MODEL.instantiate()
		lectern.name = "Lectern%d" % i
		lectern.position = LECTERNS[i] + Vector3.UP * FLOOR_TOP
		lectern.rotation.y = LECTERN_TURN * (1.0 if i == 0 else -1.0)
		$Built.add_child(lectern)
		lecterns.append(lectern)
		var solid := _build.body(lectern.position + Vector3.UP * 0.55)
		solid.rotation.y = lectern.rotation.y
		_build.shape(solid, Vector3(0.7, 1.1, 0.5))
		_label("TV_NAME_%d" % i, lectern.position + Vector3(0, 0.75, 0.27).rotated(Vector3.UP, lectern.rotation.y),
			lectern.rotation.y, 24)
	var desk: Node3D = DESK_MODEL.instantiate()
	desk.name = "Desk"
	desk.position = DESK_AT + Vector3.UP * FLOOR_TOP
	$Built.add_child(desk)
	_build.shape(_build.body(desk.position + Vector3.UP * 0.42), Vector3(2.5, 0.84, 0.85))
	screen = MeshInstance3D.new()
	screen.name = "Screen"
	var quad := QuadMesh.new()
	quad.size = SCREEN
	screen.mesh = quad
	# Its own light, so the studio's spots don't show on it: what the camera on air sees, live.
	feed = SubViewport.new()
	feed.name = "Feed"
	feed.size = FEED_SIZE
	feed.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(feed)
	feed_camera = Camera3D.new()
	feed_camera.name = "FeedCamera"
	feed_camera.fov = TvCamera.FOV
	feed.add_child(feed_camera)
	var live := StandardMaterial3D.new()
	live.albedo_color = Color.WHITE
	live.albedo_texture = feed.get_texture()
	live.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	screen.material_override = live
	screen.position = SCREEN_AT
	$Built.add_child(screen)
	# The channel's logo in the corner, like on TV.
	_label("PLACE_TV_STUDIO", SCREEN_AT + Vector3(SCREEN.x / 2 - 1.3, -SCREEN.y / 2 + 0.35, 0.02), 0.0, 36)
	_build.mesh_box(SCREEN_AT + Vector3(0, 0, -0.06), Vector3(SCREEN.x + 0.3, SCREEN.y + 0.3, 0.1), RIG)
	on_air = MeshInstance3D.new()
	on_air.name = "OnAir"
	var lamp := BoxMesh.new()
	lamp.size = Vector3(2.2, 0.6, 0.1)
	on_air.mesh = lamp
	on_air.material_override = _glow(ON_AIR)
	on_air.position = SCREEN_AT + Vector3(0, SCREEN.y / 2 + 0.6, 0)
	$Built.add_child(on_air)
	_label("TV_ON_AIR", on_air.position + Vector3(0, 0, 0.07), 0.0, 40)
	_build_stand()
	_build_rig()


## The audience's stand: STAND_STEPS steps rising to the front, each with a red bench along it.
func _build_stand() -> void:
	var length := STAND_X.y - STAND_X.x
	var middle := (STAND_X.x + STAND_X.y) / 2
	for i in STAND_STEPS:
		var height := STEP.y * (i + 1)
		var z := STAND_FRONT + STEP.x * (i + 0.5)
		_build.box(Vector3(middle, FLOOR_TOP + height / 2, z), Vector3(length, height, STEP.x), STAND)
		_build.mesh_box(Vector3(middle, FLOOR_TOP + height + 0.03, z + STEP.x / 2 - 0.3), Vector3(length, 0.06, 0.5),
			SEAT)


## The lighting rig: three bars across the studio under the roof, a spot on each lectern and the desk, and a few
## soft lights over the stand.
func _build_rig() -> void:
	for z: float in [-8.0, -1.0, 4.0]:
		_build.mesh_box(Vector3(-6, ROOF - 0.8, z), Vector3(20, 0.15, 0.15), RIG)
	var targets: Array[Vector3] = [LECTERNS[0], LECTERNS[1], DESK_AT]
	for i in targets.size():
		var spot := SpotLight3D.new()
		spot.name = "Spot%d" % i
		var from := Vector3(targets[i].x, ROOF - 1.0, -1.0)
		spot.transform = Transform3D(Basis.looking_at(targets[i] + Vector3.UP * 1.4 - from), from)
		spot.light_color = Color(1.0, 0.95, 0.85)
		spot.light_energy = 6.0
		spot.spot_range = 9.5
		spot.spot_angle = 16.0
		$Built.add_child(spot)
		_build.mesh_box(spot.position + Vector3(0, 0.15, 0), Vector3(0.35, 0.35, 0.45), RIG)
	for x: float in [-12.0, -6.0, 0.0]:
		for z: float in [-5.0, 4.0]:
			var lamp := OmniLight3D.new()
			lamp.position = Vector3(x, ROOF - 1.5, z)
			lamp.light_color = Color(0.85, 0.88, 1.0)
			lamp.light_energy = 0.9
			lamp.omni_range = 10.0
			$Built.add_child(lamp)


## The east wing: the wall to the studio with its two doors and the control room's window, the lobby with the
## reception desk and the stairs, the makeup room and, over it, the control room with the console and the chairs.
func _build_wing() -> void:
	var level := GameScale.FLOOR_HEIGHT
	# The wall to the studio: two doors on the ground, then the control room's window over the makeup room.
	_build.wall("z", WING_X, -HALF_Z, HALF_Z, 0, [MAKEUP_DOOR_Z, LOBBY_DOOR_Z], WALL)
	var low := level + WINDOW.x
	var high := level + WINDOW.y
	_wall_z(-HALF_Z, WINDOW_Z.x, level - PlaceBuilder.SLAB, ROOF)
	_wall_z(WINDOW_Z.y, HALF_Z, level - PlaceBuilder.SLAB, ROOF)
	_wall_z(WINDOW_Z.x, WINDOW_Z.y, level - PlaceBuilder.SLAB, low)
	_wall_z(WINDOW_Z.x, WINDOW_Z.y, high, ROOF)
	_build.box(Vector3(WING_X, (low + high) / 2, (WINDOW_Z.x + WINDOW_Z.y) / 2),
		Vector3(0.05, high - low, WINDOW_Z.y - WINDOW_Z.x), GLASS)
	# The makeup room's wall to the lobby, the control room's floor over it and its wall over the stairs' top.
	_build.wall("x", WING_SPLIT, WING_X, HALF_X, 0, [8.0], WALL)
	_build.slab(WING_X, HALF_X, -HALF_Z, WING_SPLIT, level, FLOOR)
	_build.wall("x", WING_SPLIT, WING_X, HALF_X, 1, [STAIRS_FOOT.x], WALL)
	_build.box(Vector3((WING_X + HALF_X) / 2, (level * 2 + ROOF) / 2, WING_SPLIT),
		Vector3(HALF_X - WING_X, ROOF - level * 2, PlaceBuilder.WALL), WALL)
	_build.stairs(STAIRS_FOOT + Vector3.UP * FLOOR_TOP, STAIRS_RUN, LOBBY.darkened(0.3))
	_build.box(Vector3(9.0, FLOOR_TOP + 0.55, 8.0), Vector3(3.0, 1.1, 0.8), SEAT)
	var mirror: Node3D = MIRROR_MODEL.instantiate()
	mirror.name = "Mirror"
	mirror.position = MIRROR_AT + Vector3.UP * FLOOR_TOP
	$Built.add_child(mirror)
	_build.shape(_build.body(mirror.position + Vector3(0, 0.4, 0)), Vector3(1.4, 0.8, 0.5))
	_build.light(Vector3(11, level - 0.4, -6))
	var console: Node3D = CONSOLE_MODEL.instantiate()
	console.name = "Console"
	console.position = CONSOLE_AT + Vector3.UP * level
	$Built.add_child(console)
	_build.shape(_build.body(console.position + Vector3(0, 0.45, 0)), Vector3(1.0, 0.9, 8.0))
	for z: float in CHAIRS_Z:
		_build.box(Vector3(CHAIRS_X, level + 0.25, z), Vector3(0.5, 0.5, 0.5), RIG)
	_build.light(Vector3(11, level * 2 - 0.4, -6))
	_build.light(Vector3(11, level - 0.4, 6))


## A piece of the wing's wall (at x = WING_X) from z0 to z1 and from y0 to y1.
func _wall_z(z0: float, z1: float, y0: float, y1: float) -> void:
	_build.box(Vector3(WING_X, (y0 + y1) / 2, (z0 + z1) / 2), Vector3(PlaceBuilder.WALL, y1 - y0, z1 - z0), WALL)


## PUBLIC neighbors on the stand's benches, their seats drawn by the seed, facing the set.
func _seat_public() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["tv public", case_seed])
	var per_step := ceili(float(PUBLIC) / STAND_STEPS)
	var length := STAND_X.y - STAND_X.x
	for i in PUBLIC:
		var step := i % STAND_STEPS
		var column := floori(float(i) / STAND_STEPS)
		var along := STAND_X.x + length * (column + 0.5) / per_step + rng.randf_range(-0.4, 0.4)
		var fan := RallyFan.new()
		fan.name = "Public%d" % i
		fan.look = RallyCrowd.LOOKS[rng.randi() % RallyCrowd.LOOKS.size()]
		fan.position = Vector3(along, FLOOR_TOP + STEP.y * (step + 1) + 0.05, STAND_FRONT + STEP.x * (step + 0.5) - 0.2)
		# NPCs face -Z: toward the set.
		add_child(fan)
		public.append(fan)


func _glow(color: Color) -> StandardMaterial3D:
	var glow := StandardMaterial3D.new()
	glow.albedo_color = color
	glow.emission_enabled = true
	glow.emission = color
	glow.emission_energy_multiplier = 2.0
	return glow


func _glow_sphere() -> SphereMesh:
	var ball := SphereMesh.new()
	ball.radius = 0.25
	ball.height = 0.5
	return ball


func _label(key: String, at: Vector3, turn: float, size: int) -> void:
	var label := Label3D.new()
	label.text = key
	label.font_size = size
	label.pixel_size = 0.01
	label.outline_size = 12
	label.position = at
	label.rotation.y = turn
	$Built.add_child(label)
