class_name PartyHall
extends InfiltrationPlace

## The costume party's "Salón Gala" (docs/diseno/infiltracion-fiesta.md, step 2, decision 171): one floor on its lot in
## the city, the front to +Z. The dance floor with its mirror ball in the middle, the long food table along the west
## wall, the three photo steps against the back wall with the party's banner over them, the coat check by the entrance
## (west) and the restroom (east), and behind, the hall's office (locked), where the gang keeps the jewels. The cops
## start in the station, where the party disguises are, and drive here. --place=party opens it from Play.
## Every number here is (propuesta).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const HALF_X := 12.0
const HALF_Z := 10.0
const FLOOR_TOP := 0.06
const ROOF := GameScale.FLOOR_HEIGHT
## The front entrance, an open doorway in the middle of the front wall.
const ENTRANCE_X := 0.0
## The dance floor in the middle, a checkerboard of TILE m squares, and the mirror ball over it.
const DANCE := Rect2(-4.0, -4.5, 8.0, 8.0)
const TILE := 1.0
## The long food table along the west wall.
const FOOD_TABLE_AT := Vector3(-10.6, 0, -1.5)
const FOOD_TABLE_SIZE := Vector3(1.0, 0.8, 6.0)
## The photo steps against the back wall: STEPS rows from STEPS_FRONT_Z back, each STEP_DEPTH deep and STEP_RISE higher
## than the one in front, from STEPS_X0 to STEPS_X1; on each, a spot to pose every SPOT_GAP m.
const STEPS := 3
const STEPS_X0 := -9.0
const STEPS_X1 := 3.0
const STEPS_FRONT_Z := -7.9
const STEP_DEPTH := 0.7
const STEP_RISE := 0.2
const SPOT_GAP := 2.0
## The coat check, west of the entrance behind its counter, open on its east side.
const COAT_CHECK := Rect2(-12.0, 6.65, 6.0, 3.35)
const COAT_COUNTER_Z := 6.4
## The restroom, east of the entrance, with its door into the hall on its west wall.
const RESTROOM_X := 7.5
const RESTROOM_Z := 6.0
const RESTROOM_DOOR_Z := 8.0
## The office at the back east corner, its locked door into the hall.
const OFFICE_X := 6.0
const OFFICE_Z := -6.5
const OFFICE_DOOR_X := 9.0
## Where the guests mingle: on the dance floor, by the food and around (step 2b picks GUESTS of them with the seed).
const MINGLE_SPOTS: Array[Vector3] = [
	Vector3(-3.0, 0, -3.5), Vector3(-1.0, 0, -3.0), Vector3(1.2, 0, -3.6), Vector3(3.0, 0, -2.8),
	Vector3(-2.6, 0, -1.0), Vector3(-0.4, 0, -0.6), Vector3(2.0, 0, -0.8), Vector3(-3.2, 0, 1.4),
	Vector3(-1.2, 0, 1.8), Vector3(1.0, 0, 1.2), Vector3(3.2, 0, 1.8), Vector3(-9.2, 0, -3.6),
	Vector3(-9.2, 0, -1.0), Vector3(-9.2, 0, 1.4), Vector3(6.0, 0, -2.0), Vector3(6.4, 0, 2.6),
]

const OUTSIDE := Color(0.55, 0.2, 0.45)
const INSIDE := Color(0.95, 0.9, 0.8)
const FLOOR := Color(0.36, 0.26, 0.2)
const TILE_A := Color(0.95, 0.95, 0.95)
const TILE_B := Color(0.12, 0.12, 0.16)
const STEP_COLOR := Color(0.75, 0.1, 0.18)
const TABLECLOTH := Color(0.96, 0.96, 0.92)
const WOOD := Color(0.48, 0.3, 0.18)
const MIRROR := Color(0.85, 0.88, 0.95)
const BALLOONS: Array[Color] = [Color(0.95, 0.2, 0.25), Color(0.2, 0.45, 0.95), Color(0.98, 0.85, 0.2),
	Color(0.3, 0.8, 0.4)]

var office_door: FrontDoor
## The spots to pose on the photo steps, in the hall's space.
var photo_spots: Array[Vector3] = []
var _build: PlaceBuilder


func _ready() -> void:
	variant = "party"
	take_seed()
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_hall()
	_build_steps()
	_build_rooms()
	office_door = DOOR_SCENE.instantiate()
	office_door.position = Vector3(OFFICE_DOOR_X - GameScale.DOOR_WIDTH / 2, FLOOR_TOP, OFFICE_Z)
	add_child(office_door)
	place_in_city("party_hall")


## The boss runs off from the street, out of the entrance (step 5).
func getaway_at() -> Transform3D:
	return Transform3D(global_basis, global_transform * Vector3(ENTRANCE_X, 0, HALF_Z + CityLayout.SIDEWALK + 2.0))


## Whether a world position is inside the hall.
func is_inside(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return absf(local.x) < HALF_X and absf(local.z) < HALF_Z and local.y < ROOF


## Whether a world position is in the office.
func in_back_room(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return local.x > OFFICE_X and local.x < HALF_X and local.z > -HALF_Z and local.z < OFFICE_Z and local.y < ROOF


## Whether a world position is up on the photo steps.
func on_steps(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	var back := STEPS_FRONT_Z - STEPS * STEP_DEPTH
	return local.x > STEPS_X0 and local.x < STEPS_X1 and local.z < STEPS_FRONT_Z and local.z > back \
		and local.y > FLOOR_TOP + STEP_RISE - 0.15 and local.y < ROOF


## Whether a world position is in the coat check, behind its counter.
func in_coat_check(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return COAT_CHECK.has_point(Vector2(local.x, local.z)) and local.y < ROOF


## Whether a world position is in the restroom.
func in_restroom(at: Vector3) -> bool:
	var local := global_transform.affine_inverse() * at
	return local.x > RESTROOM_X and local.x < HALF_X and local.z > RESTROOM_Z and local.z < HALF_Z and local.y < ROOF


## Floor, outer walls with the entrance, the roof, the sign, balloons by the door and the lights.
func _build_shell() -> void:
	_build.slab(-HALF_X, HALF_X, -HALF_Z, HALF_Z, FLOOR_TOP, FLOOR)
	_build.slab(-HALF_X - 0.2, HALF_X + 0.2, -HALF_Z - 0.2, HALF_Z + 0.2, ROOF, OUTSIDE.darkened(0.4))
	_build.wall("x", -HALF_Z, -HALF_X, HALF_X, 0, [], OUTSIDE)
	_build.wall("z", -HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE)
	_build.wall("z", HALF_X, -HALF_Z, HALF_Z, 0, [], OUTSIDE)
	_build.wall("x", HALF_Z, -HALF_X, HALF_X, 0, [ENTRANCE_X], OUTSIDE)
	var sign_label := Label3D.new()
	sign_label.text = "PLACE_PARTY_HALL"
	sign_label.font_size = 64
	sign_label.pixel_size = 0.01
	sign_label.outline_size = 14
	sign_label.position = Vector3(0, ROOF + 0.6, HALF_Z + 0.1)
	$Built.add_child(sign_label)
	# A bunch of balloons on each side of the door, so it reads as a party from the street.
	for side: float in [-1.0, 1.0]:
		for i in 4:
			var balloon := SphereMesh.new()
			balloon.radius = 0.22
			balloon.height = 0.5
			_build.mesh(balloon, Vector3(side * (1.6 + (i % 2) * 0.35), 1.9 + floorf(i / 2.0) * 0.45, HALF_Z + 0.35),
				BALLOONS[i])
	for x: float in [-7.0, 0.0, 7.0]:
		for z: float in [-8.0, -3.5, 1.0, 6.5]:
			_build.light(Vector3(x, ROOF - 0.6, z))


## The checkered dance floor with the mirror ball over it, and the long food table with its plates and the punch bowl.
func _build_hall() -> void:
	var columns := roundi(DANCE.size.x / TILE)
	var rows := roundi(DANCE.size.y / TILE)
	for i in columns:
		for j in rows:
			var at := Vector3(DANCE.position.x + (i + 0.5) * TILE, FLOOR_TOP + 0.005, DANCE.position.y + (j + 0.5) * TILE)
			_build.mesh_box(at, Vector3(TILE, 0.01, TILE), TILE_A if (i + j) % 2 == 0 else TILE_B)
	var middle := DANCE.get_center()
	var ball := SphereMesh.new()
	ball.radius = 0.3
	ball.height = 0.6
	_build.mesh(ball, Vector3(middle.x, ROOF - 0.6, middle.y), MIRROR)
	_build.mesh_box(Vector3(middle.x, ROOF - 0.25, middle.y), Vector3(0.02, 0.3, 0.02), TILE_B)
	_build.box(FOOD_TABLE_AT + Vector3(0, FLOOR_TOP + FOOD_TABLE_SIZE.y / 2, 0), FOOD_TABLE_SIZE, TABLECLOTH)
	var top := FLOOR_TOP + FOOD_TABLE_SIZE.y
	for i in 6:
		var plate := CylinderMesh.new()
		plate.top_radius = 0.16
		plate.bottom_radius = 0.12
		plate.height = 0.04
		_build.mesh(plate, FOOD_TABLE_AT + Vector3(0, top + 0.02, -2.5 + i), Color(0.9, 0.9, 0.95))
		_build.mesh_box(FOOD_TABLE_AT + Vector3(0, top + 0.07, -2.5 + i), Vector3(0.14, 0.06, 0.14), BALLOONS[i % 4])
	var bowl := CylinderMesh.new()
	bowl.top_radius = 0.25
	bowl.bottom_radius = 0.15
	bowl.height = 0.2
	_build.mesh(bowl, FOOD_TABLE_AT + Vector3(0, top + 0.1, 2.6), Color(0.85, 0.2, 0.35))


## The three photo steps against the back wall, a spot on each every SPOT_GAP m, and the banner over them.
func _build_steps() -> void:
	var width := STEPS_X1 - STEPS_X0
	var middle_x := (STEPS_X0 + STEPS_X1) / 2
	for k in STEPS:
		var height := STEP_RISE * (k + 1)
		var z := STEPS_FRONT_Z - (k + 0.5) * STEP_DEPTH
		_build.box(Vector3(middle_x, FLOOR_TOP + height / 2, z), Vector3(width, height, STEP_DEPTH),
			STEP_COLOR.darkened(k * 0.12))
		var spots := floori(width / SPOT_GAP)
		for i in spots:
			photo_spots.append(Vector3(STEPS_X0 + (i + 0.5) * SPOT_GAP, FLOOR_TOP + height, z))
	var banner := Label3D.new()
	banner.text = "PARTY_BANNER"
	banner.font_size = 48
	banner.pixel_size = 0.01
	banner.outline_size = 16
	banner.modulate = Color(1, 0.85, 0.2)
	banner.position = Vector3(middle_x, 2.3, -HALF_Z + 0.15)
	$Built.add_child(banner)
	_build.mesh_box(Vector3(middle_x, 2.3, -HALF_Z + 0.1), Vector3(width, 0.4, 0.02), Color(0.3, 0.1, 0.45))


## The coat check with its counter and coat rail, the restroom and the office.
func _build_rooms() -> void:
	# Coat check: the counter across its front, a rail of coats along the west wall.
	_build.box(Vector3(COAT_CHECK.position.x + COAT_CHECK.size.x / 2, FLOOR_TOP + 0.5, COAT_COUNTER_Z),
		Vector3(COAT_CHECK.size.x, 1.0, 0.5), WOOD)
	_build.mesh_box(Vector3(-11.6, FLOOR_TOP + 1.7, 8.3), Vector3(0.04, 0.04, 3.0), TILE_B)
	for i in 7:
		_build.mesh_box(Vector3(-11.6, FLOOR_TOP + 1.15, 7.0 + i * 0.42), Vector3(0.5, 1.0, 0.12),
			BALLOONS[i % 4].darkened(0.4))
	# Restroom: walls, a toilet and a sink.
	_build.wall("z", RESTROOM_X, RESTROOM_Z, HALF_Z, 0, [RESTROOM_DOOR_Z], INSIDE)
	_build.wall("x", RESTROOM_Z, RESTROOM_X, HALF_X, 0, [], INSIDE)
	_build.box(Vector3(11.3, FLOOR_TOP + 0.22, 9.2), Vector3(0.5, 0.44, 0.7), TILE_A)
	_build.box(Vector3(11.5, FLOOR_TOP + 0.45, 6.9), Vector3(0.6, 0.9, 0.5), TILE_A)
	# Office: walls, a desk and the safe.
	_build.wall("x", OFFICE_Z, OFFICE_X, HALF_X, 0, [OFFICE_DOOR_X], INSIDE)
	_build.wall("z", OFFICE_X, -HALF_Z, OFFICE_Z, 0, [], INSIDE)
	_build.box(Vector3(8.0, FLOOR_TOP + 0.4, -9.0), Vector3(2.0, 0.8, 0.9), WOOD)
	_build.box(Vector3(11.3, FLOOR_TOP + 0.5, -9.3), Vector3(0.8, 1.0, 0.8), Color(0.3, 0.32, 0.35))
