class_name Bowling
extends Node3D

## The bowling alley "Bolos Chuza Feliz" as a place to raid (docs/diseno/allanamiento-bolera.md, step 1): an alley on
## its lot in the city, open and with the front to +Z. Six lanes run from the approach by the door (their foul line at
## FOUL_Z) to the pins at the back, with a curb between lanes, the pin machines over their ends and a narrow corridor
## behind them. Between each two lanes stands a ball return, over the foul line hang the score screens and behind the
## approach the benches. On the east side are the shoe counter by the door (the office's key in its till), the bar with
## the popcorn machine, and the owner's office in the back east corner, locked, with the trophy case. The trophy case
## breaks if something hits it fast and a screen if a ball flies into it, a fine each. Every number here is (propuesta).

signal trophy_case_broken
signal screen_broken(lane: int)
## A ball reached lane `lane`'s pit and the machine counted the pins down before setting them up again (step 2).
signal rolled(lane: int, knocked: int, ball: BowlingBall)
## A league player complained (Don Chuza adds it to the complaint, step 3).
signal player_complained(player: BowlPlayer)

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const PIN_MODEL := preload("res://assets/models/bowling_pin.glb")
const SETTER_MODEL := preload("res://assets/models/pin_setter.glb")
const RETURN_MODEL := preload("res://assets/models/ball_return.glb")
const SCREEN_MODEL := preload("res://assets/models/score_screen.glb")
const COUNTER_MODEL := preload("res://assets/models/shoe_counter.glb")
const BAR_MODEL := preload("res://assets/models/bowling_bar.glb")
const POPCORN_MODEL := preload("res://assets/models/popcorn_machine.glb")
const CASE_MODEL := preload("res://assets/models/trophy_case.glb")
const BENCH_MODEL := preload("res://assets/models/bowling_bench.glb")
const GIANT_PIN_MODEL := preload("res://assets/models/giant_pin.glb")
const HALF_X := 15.0
const HALF_Z := 12.0
const WALL_TOP := 5.0
const BUILDING_TOP := 7.0
const FLOOR_TOP := 0.06
## The open doorway in the front wall, between the lanes and the shoe counter.
const ENTRANCE_X := 0.5
const ENTRANCE_WIDTH := 4.0
const ENTRANCE_HEIGHT := 3.0

## The lanes: their middles, the wood's width (the gutters on both sides), where the approach ends and where the head
## pin stands; the curbs between lanes run from the foul line to the pin wall.
const LANE_X: Array[float] = [-12.5, -10.9, -9.3, -7.7, -6.1, -4.5]
const LANE_PITCH := 1.6
const LANE_WIDTH := 1.05
const FOUL_Z := 4.0
const HEAD_PIN_Z := -6.6
const PIN_WALL_Z := -9.0
const CURB_SIZE := Vector3(0.1, 0.12, FOUL_Z - PIN_WALL_Z)
## The 10 pins of a lane: rows of 1 to 4, 0.3 m apart, from the head pin back.
const PIN_SPACING := 0.3
const PIN_SIZE := Vector3(0.12, 0.38, 0.12)
const PIN_KG := 1.5
## The corridor behind the pin machines, its door at its east end.
const CORRIDOR_EAST_X := -3.0
const CORRIDOR_DOOR_Z := -10.6
const SETTER_Z := -8.5
## The ball returns, between lanes 1-2, 3-4 and 5-6, the benches behind them and the score screens over the foul line.
const RETURN_X: Array[float] = [-11.7, -8.5, -5.3]
const RETURN_Z := 5.4
const RETURN_SIZE := Vector3(0.62, 0.86, 1.0)
const BENCH_Z := 7.6
const SCREEN_Z := 3.8
const SCREEN_Y := 3.3
const SCREEN_SIZE := Vector3(1.2, 0.7, 0.3)
const SCREEN_SPEED := 3.0
const SCREEN_FINE := 15
## The balls (step 2): three on each return's rack, their weights, and the rack they rest on (behind the hood). A ball
## in a lane's pit comes back to its rack RETURN_TIME later, and the machine sets the pins up RESET_TIME after it
## came, counting the ones down: tipped over or moved off their place.
const BALL_KG: Array[float] = [4.0, 5.0, 6.0, 7.0, 5.0, 6.0, 7.0, 4.0, 6.0]
const RACK_SIZE := Vector3(0.6, 0.5, 0.6)
const RACK_Z := 0.2
const SLOT_STEP := 0.22
const PIT_SIZE := Vector3(1.5, 0.8, 1.6)
const PIT_Z := -8.2
const RETURN_TIME := 4.0
const RESET_TIME := 6.0
const PIN_DOWN := 0.7
const PIN_MOVED := 0.25
## The waxed lanes: a cop running on one skates on, pushed along, and can't skate again for a moment.
const SKATE_TIME := 0.9
const SKATE_PUSH := 3.0
const SKATE_AGAIN := 1.5
## The Thursday league: two players on each of these lanes, waiting between the rack and the bench.
const LEAGUE_LANES: Array[int] = [0, 2, 4]
const PLAYER_Z := 6.6
const PLAYER_GAP := 0.3
## The shoe counter east of the door (its till holds the office's key), the bar and the popcorn machine.
const COUNTER_AT := Vector3(6.0, FLOOR_TOP, 9.0)
const COUNTER_SIZE := Vector3(4.1, 1.1, 0.8)
const TILL_ON := Vector3(4.6, FLOOR_TOP + 1.12, 9.0)
const BAR_AT := Vector3(5.0, FLOOR_TOP, 0.0)
const BAR_SIZE := Vector3(3.1, 1.1, 0.8)
const POPCORN_AT := Vector3(7.3, FLOOR_TOP, 0.0)
const POPCORN_SIZE := Vector3(0.6, 0.92, 0.6)
const FRIDGE_AT := Vector3(2.8, FLOOR_TOP, -0.8)
const FRIDGE_SIZE := Vector3(0.8, 1.8, 0.7)
## The office in the back east corner, its door in its front wall (OFFICE_Z), with the desk and the trophy case against
## the east wall.
const OFFICE_X := 8.0
const OFFICE_Z := -4.0
const OFFICE_DOOR_X := 10.5
const DESK_AT := Vector3(11.5, FLOOR_TOP, -9.5)
const DESK_SIZE := Vector3(1.8, 0.8, 0.9)
const CASE_AT := Vector3(14.4, FLOOR_TOP, -7.5)
const CASE_SIZE := Vector3(0.6, 2.0, 2.0)
const CASE_SPEED := 3.0
const CASE_FINE := 30

## Hiding spots: where something can wait, with its surface height, and whether a heavy item fits.
const SPOTS := [
	{"id": "in_ball_return", "at": Vector3(-8.5, FLOOR_TOP, 6.2), "heavy": true},
	{"id": "in_pin_machine_corridor", "at": Vector3(-9.3, FLOOR_TOP, -11.2), "heavy": true},
	{"id": "in_old_pins_store", "at": Vector3(-1.0, FLOOR_TOP, -11.0), "heavy": true},
	{"id": "behind_trophy_case", "at": Vector3(13.6, FLOOR_TOP, -5.2), "heavy": true},
	{"id": "in_bowl_office_corner", "at": Vector3(9.0, FLOOR_TOP, -11.2), "heavy": true},
	{"id": "behind_shoe_counter", "at": Vector3(7.5, FLOOR_TOP, 10.0), "heavy": true},
	{"id": "on_shoe_shelf", "at": Vector3(5.0, FLOOR_TOP + 1.4, 10.5), "heavy": false},
	{"id": "under_bench", "at": Vector3(-5.3, FLOOR_TOP, 7.6), "heavy": false},
	{"id": "by_popcorn_machine", "at": Vector3(7.3, FLOOR_TOP + 0.95, 0.0), "heavy": false},
	{"id": "behind_bar", "at": Vector3(5.0, FLOOR_TOP, -0.9), "heavy": false},
	{"id": "in_lane_6_gutter", "at": Vector3(-3.95, FLOOR_TOP, -2.0), "heavy": false},
	{"id": "on_bowl_desk", "at": Vector3(11.5, FLOOR_TOP + 0.8, -9.5), "heavy": false},
]

const OUTSIDE := Color(0.95, 0.55, 0.25)
const CARPET := Color(0.26, 0.22, 0.42)
const LANE_WOOD := Color(0.86, 0.68, 0.42)
const GUTTER := Color(0.32, 0.34, 0.38)
const CEILING := Color(0.16, 0.16, 0.22)
const WOOD := Color(0.6, 0.44, 0.3)
const DARK := Color(0.1, 0.1, 0.12)
const GLASS := Color(0.6, 0.82, 0.95)

## Where the patrol car parks at the station, in this scene's space.
var station_parking: Transform3D
var city_map: CityMap
var office_door: FrontDoor
var till: Till
## Each lane's pins, in rows from the head pin, and where each one stands.
var pins: Array = []
var pin_homes: Array = []
var balls: Array[BowlingBall] = []
var players: Array[BowlPlayer] = []
## Ball -> seconds until it's back on its rack; lane -> seconds until its pins are set up, and the ball that came.
var _returning := {}
var _resetting := {}
var _last_ball := {}
## Cop -> seconds until it can skate again.
var _skated := {}
var case_broken := false
var broken_screens: Array[int] = []
## Money taken off the case pay: the trophy case and the screens.
var fines := 0
## Same seed, same alley (the stories and the hiding spots come from it, step 5).
@export var case_seed := 0
var _build: PlaceBuilder
@onready var car: PatrolCar = $PatrolCar


func _ready() -> void:
	if case_seed == 0:
		case_seed = PlaceDraw.take_seed()
	if case_seed == 0:
		case_seed = PlaceDraw.new_seed()
	_build = PlaceBuilder.new($Built)
	_build_shell()
	_build_lanes()
	_build_front()
	_build_office()
	_build_pins()
	_build_balls()
	_build_players()
	office_door = _door(OFFICE_DOOR_X)
	var city: Node3D = $City
	city.transform = CityLayout.anchor("bowling")
	station_parking = city.transform * CityLayout.parking("station")
	car.global_transform = station_parking.translated_local(Vector3.UP * 0.05)
	$Cop.global_position = car.to_global(Vector3(2.5, 0.1, 0.55))
	city_map = CityMap.new()
	add_child(city_map)
	city_map.setup(city, "bowling", car)


## The carpet, the walls with the doorway, the dark ceiling with its lights, the roof, the sign and its giant pin.
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
	_label("PLACE_BOWLING", Vector3(-6.0, WALL_TOP + 0.9, HALF_Z + 0.08), 110)
	_model(GIANT_PIN_MODEL, Vector3(-12.5, BUILDING_TOP, HALF_Z - 1.0))
	for x: float in [-11.0, -6.0, -1.0, 5.0, 11.0]:
		for z: float in [-6.0, 0.0, 7.0]:
			_build.light(Vector3(x, 4.6, z))


## The six lanes with their gutters and curbs, the pin machines and the wall over the pins, the corridor behind them,
## the ball returns, the benches and the score screens.
func _build_lanes() -> void:
	var length := FOUL_Z - PIN_WALL_Z
	var mid_z := (FOUL_Z + PIN_WALL_Z) / 2
	for i in LANE_X.size():
		var x := LANE_X[i]
		_build.mesh_box(Vector3(x, FLOOR_TOP + 0.005, mid_z), Vector3(LANE_WIDTH, 0.01, length), LANE_WOOD)
		for side: float in [-1.0, 1.0]:
			var gutter_x := x + side * (LANE_WIDTH / 2 + 0.12)
			_build.mesh_box(Vector3(gutter_x, FLOOR_TOP + 0.004, mid_z), Vector3(0.24, 0.008, length), GUTTER)
		_build.mesh_box(Vector3(x, FLOOR_TOP + 0.012, FOUL_Z), Vector3(LANE_WIDTH, 0.01, 0.05), Color(0.85, 0.2, 0.2))
		_model(SETTER_MODEL, Vector3(x, FLOOR_TOP, SETTER_Z))
		var screen := _model(SCREEN_MODEL, Vector3(x, SCREEN_Y, SCREEN_Z))
		screen.name = "Screen%d" % i
		var pit := _area(Vector3(x, FLOOR_TOP + PIT_SIZE.y / 2, PIT_Z), PIT_SIZE)
		pit.body_entered.connect(func(body: Node3D) -> void:
			if body is BowlingBall and not (body as BowlingBall).is_held():
				in_pit(i, body))
		var hit := _area(Vector3(x, SCREEN_Y, SCREEN_Z), SCREEN_SIZE)
		hit.body_entered.connect(func(body: Node3D) -> void:
			if body is RigidBody3D and (body as RigidBody3D).linear_velocity.length() > SCREEN_SPEED:
				break_screen(i))
	# A curb on each lane's outer edge, so a ball stays in its lane.
	for i in LANE_X.size() + 1:
		var x := LANE_X[0] - LANE_PITCH / 2 + i * LANE_PITCH
		_build.box(Vector3(x, FLOOR_TOP + CURB_SIZE.y / 2, mid_z), CURB_SIZE, GUTTER.darkened(0.3))
	# The wall over the pins (the pit under it lets pins and balls through) and the corridor of the machines.
	var west := -HALF_X
	_build.wall_at("x", PIN_WALL_Z, west, CORRIDOR_EAST_X, 1.0, WALL_TOP - 1.0, [], DARK.lightened(0.15))
	_build.wall_at("z", CORRIDOR_EAST_X, -HALF_Z, PIN_WALL_Z, 0.0, WALL_TOP, [CORRIDOR_DOOR_Z], DARK.lightened(0.15))
	for x: float in RETURN_X:
		# The hood where the balls come up, and the lower rack they rest on.
		_solid(Vector3(x, FLOOR_TOP + RETURN_SIZE.y / 2, RETURN_Z - 0.3), Vector3(RETURN_SIZE.x, RETURN_SIZE.y, 0.4))
		_solid(Vector3(x, FLOOR_TOP + RACK_SIZE.y / 2, RETURN_Z + RACK_Z), RACK_SIZE)
		_model(RETURN_MODEL, Vector3(x, FLOOR_TOP, RETURN_Z))
		_solid(Vector3(x, FLOOR_TOP + 0.45, BENCH_Z), Vector3(2.4, 0.9, 0.5))
		_model(BENCH_MODEL, Vector3(x, FLOOR_TOP, BENCH_Z), PI)
	# The old pins' store against the back wall, east of the corridor, open on top.
	_build.open_box(Vector3(-1.0, FLOOR_TOP, -11.0), Vector3(1.6, 0.9, 1.2), "top", WOOD.darkened(0.2))


## The shoe counter with its till, the bar, the popcorn machine and the drinks fridge.
func _build_front() -> void:
	_solid(COUNTER_AT + Vector3(0, COUNTER_SIZE.y / 2, 0), COUNTER_SIZE)
	_solid(COUNTER_AT + Vector3(0, 1.1, 1.4), Vector3(4.0, 2.2, 0.4))
	_model(COUNTER_MODEL, COUNTER_AT, PI)
	till = Till.new()
	till.position = TILL_ON + Vector3.UP * Till.SIZE.y / 2
	till.key_hint = "HINT_TILL_KEY_BOWLING"
	add_child(till)
	_solid(BAR_AT + Vector3(0, BAR_SIZE.y / 2, 0), BAR_SIZE)
	_model(BAR_MODEL, BAR_AT)
	_solid(POPCORN_AT + Vector3(0, POPCORN_SIZE.y / 2, 0), POPCORN_SIZE)
	_model(POPCORN_MODEL, POPCORN_AT)
	_build.box(FRIDGE_AT + Vector3(0, FRIDGE_SIZE.y / 2, 0), FRIDGE_SIZE, Color(0.9, 0.92, 0.95))
	_build.mesh_box(FRIDGE_AT + Vector3(0, FRIDGE_SIZE.y / 2, FRIDGE_SIZE.z / 2 + 0.01), Vector3(0.7, 1.6, 0.02), GLASS)


## The owner's office (walls, its locked door, the desk and the trophy case that breaks).
func _build_office() -> void:
	_build.wall_at("x", OFFICE_Z, OFFICE_X, HALF_X, 0.0, WALL_TOP, [OFFICE_DOOR_X], OUTSIDE.lightened(0.2))
	_build.wall_at("z", OFFICE_X, -HALF_Z, OFFICE_Z, 0.0, WALL_TOP, [], OUTSIDE.lightened(0.2))
	_build.legs(DESK_AT, Vector2(DESK_SIZE.x, DESK_SIZE.z), DESK_SIZE.y - 0.04, DARK)
	_build.box(DESK_AT + Vector3(0, DESK_SIZE.y - 0.02, 0), Vector3(DESK_SIZE.x, 0.04, DESK_SIZE.z), WOOD)
	_solid(CASE_AT + Vector3(0, CASE_SIZE.y / 2, 0), CASE_SIZE)
	_model(CASE_MODEL, CASE_AT, -PI / 2)
	var glass := _area(CASE_AT + Vector3(-CASE_SIZE.x / 2 - 0.2, CASE_SIZE.y / 2, 0), Vector3(0.4, CASE_SIZE.y, CASE_SIZE.z))
	glass.body_entered.connect(func(hit: Node3D) -> void:
		if hit is RigidBody3D and (hit as RigidBody3D).linear_velocity.length() > CASE_SPEED:
			break_trophy_case())


## The 10 pins of each lane, asleep until something knocks them.
func _build_pins() -> void:
	for x: float in LANE_X:
		var lane: Array[RigidBody3D] = []
		var homes: Array[Vector3] = []
		for row in 4:
			for i in row + 1:
				var at := Vector3(x + (i - row / 2.0) * PIN_SPACING, FLOOR_TOP + PIN_SIZE.y / 2 + 0.005,
					HEAD_PIN_Z - row * PIN_SPACING * 0.87)
				var pin := ClubEvidence.make_item("Pin", PIN_MODEL, PIN_SIZE, PIN_KG)
				(pin.get_child(1) as Node3D).position.y = -PIN_SIZE.y / 2
				add_child(pin)
				pin.position = at
				pin.sleeping = true
				lane.append(pin)
				homes.append(at)
		pins.append(lane)
		pin_homes.append(homes)


## Three balls on each return's rack, of different weights and colors.
func _build_balls() -> void:
	for rack in RETURN_X.size():
		for slot in 3:
			var ball := BowlingBall.make(BALL_KG[(rack * 3 + slot) % BALL_KG.size()], rack * 3 + slot)
			ball.name = "Ball%d" % (rack * 3 + slot)
			ball.rack = rack
			ball.slot = slot
			add_child(ball)
			ball.position = rack_spot(rack, slot)
			ball.sleeping = true
			balls.append(ball)


## The league's six players, two to a lane, each with its own first turn so the lanes take turns.
func _build_players() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = hash(["bowling players", case_seed])
	for i in LEAGUE_LANES.size() * 2:
		var player := BowlPlayer.new()
		player.name = "Player%d" % i
		player.look = "bowler" if i % 2 == 0 else "bowler_b"
		player.alley = self
		player.lane = LEAGUE_LANES[i / 2]
		player.home = Vector3(LANE_X[player.lane] + (i % 2 * 2 - 1) * PLAYER_GAP, FLOOR_TOP, PLAYER_Z)
		player.next_throw = 3.0 + (i / 2) * 2.0 + (i % 2) * BowlPlayer.THROW_EVERY / 2
		player.rng.seed = rng.randi()
		player.position = player.home
		add_child(player)
		player.complained.connect(player_complained.emit)
		players.append(player)


## Where slot `slot` of rack `rack` holds a ball.
static func rack_spot(rack: int, slot: int) -> Vector3:
	return Vector3(RETURN_X[rack], FLOOR_TOP + RACK_SIZE.y + BowlingBall.RADIUS + 0.01,
		RETURN_Z + RACK_Z - SLOT_STEP + slot * SLOT_STEP)


## The rack beside lane `lane` (each one serves the two lanes on its sides).
static func rack_of(lane: int) -> int:
	return lane / 2


## A ball resting on rack `rack`, nobody holding it (null: the cops took them all).
func rack_ball(rack: int) -> BowlingBall:
	for ball: BowlingBall in balls:
		if ball.rack == rack and not ball.is_held() and not ball.bowled \
				and ball.position.distance_to(rack_spot(rack, ball.slot)) < RACK_SIZE.x:
			return ball
	return null


## The ball leaves a league player's hand at lane `lane`'s foul line with `velocity` (alley space).
func bowl(ball: BowlingBall, lane: int, velocity: Vector3) -> void:
	ball.position = Vector3(LANE_X[lane], FLOOR_TOP + BowlingBall.RADIUS + 0.01, FOUL_Z - 0.3)
	ball.angular_velocity = Vector3.ZERO
	ball.linear_velocity = global_basis * velocity
	ball.sleeping = false
	ball.bowled = true
	# It flew from the player's hands, not from the last cop's who held it.
	ball.last_holder = 0


## Whether a ball is on its way or the machine hasn't set lane `lane`'s pins up again yet.
func lane_busy(lane: int) -> bool:
	return _resetting.has(lane) or _last_ball.has(lane)


## Whether a cop is standing on lane `lane`, between the foul line and the pins.
func cop_on_lane(lane: int) -> bool:
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		var at := to_local(cop.global_position)
		if on_lane(at) and absf(at.x - LANE_X[lane]) < LANE_WIDTH / 2:
			return true
	return false


## A ball reached lane `lane`'s pit: it goes back to its rack, and the machine will count and set up the pins.
func in_pit(lane: int, ball: BowlingBall) -> void:
	if _returning.has(ball):
		return
	_returning[ball] = RETURN_TIME
	_last_ball[lane] = ball
	if not _resetting.has(lane):
		_resetting[lane] = RESET_TIME


## How many of lane `lane`'s pins are down: tipped over or moved off their place.
func knocked(lane: int) -> int:
	var down := 0
	for i in (pins[lane] as Array).size():
		var pin: RigidBody3D = pins[lane][i]
		var home: Vector3 = pin_homes[lane][i]
		var moved := Vector2(pin.position.x - home.x, pin.position.z - home.z).length()
		if pin.basis.y.dot(Vector3.UP) < PIN_DOWN or moved > PIN_MOVED:
			down += 1
	return down


## The machine counts lane `lane`'s pins down and stands all ten up again.
func reset_pins(lane: int) -> void:
	var down := knocked(lane)
	for i in (pins[lane] as Array).size():
		var pin: RigidBody3D = pins[lane][i]
		pin.linear_velocity = Vector3.ZERO
		pin.angular_velocity = Vector3.ZERO
		pin.transform = Transform3D(Basis.IDENTITY, pin_homes[lane][i])
		pin.sleeping = true
	rolled.emit(lane, down, _last_ball.get(lane) as BowlingBall)
	_last_ball.erase(lane)


## The ball comes up its return: onto its own slot of the rack, or on top of whatever is there.
func send_back(ball: BowlingBall) -> void:
	ball.bowled = false
	ball.linear_velocity = Vector3.ZERO
	ball.angular_velocity = Vector3.ZERO
	ball.position = rack_spot(ball.rack, ball.slot)
	ball.sleeping = false


func _physics_process(delta: float) -> void:
	for ball: BowlingBall in _returning.keys():
		_returning[ball] -= delta
		if _returning[ball] <= 0.0:
			_returning.erase(ball)
			if is_instance_valid(ball) and not ball.is_held():
				send_back(ball)
	for lane: int in _resetting.keys():
		_resetting[lane] -= delta
		if _resetting[lane] <= 0.0:
			_resetting.erase(lane)
			reset_pins(lane)
	_skate(delta)


## This PC's own cop running on a waxed lane skates on, out of control (a copy of another player's cop only follows).
func _skate(delta: float) -> void:
	for cop: Variant in _skated.keys():
		_skated[cop] -= delta
		if _skated[cop] <= 0.0 or not is_instance_valid(cop):
			_skated.erase(cop)
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if cop.sync and not cop.sync.is_multiplayer_authority():
			continue
		if _skated.has(cop) or not cop.is_running or not on_lane(to_local(cop.global_position)):
			continue
		var flat := Vector3(cop.velocity.x, 0, cop.velocity.z)
		if flat.length() < 0.5:
			continue
		_skated[cop] = SKATE_AGAIN
		cop.knock_back(flat.normalized() * SKATE_PUSH, SKATE_TIME)
		cop.show_hint("HINT_BOWL_SKATE")


## Whether `at` (alley space) is on the wood of a lane, between the foul line and the pins.
static func on_lane(at: Vector3) -> bool:
	if at.z > FOUL_Z or at.z < HEAD_PIN_Z:
		return false
	for x: float in LANE_X:
		if absf(at.x - x) < LANE_WIDTH / 2:
			return true
	return false


## The trophy case's glass broke, once: a fine and the cracks over it.
func break_trophy_case() -> void:
	if case_broken:
		return
	case_broken = true
	fines += CASE_FINE
	for i in 6:
		_build.mesh_box(CASE_AT + Vector3(-CASE_SIZE.x / 2 - 0.02, 0.4 + i * 0.27, -0.7 + (i % 3) * 0.6),
			Vector3(0.02, 0.02, 0.6), DARK)
	_say(CASE_AT + Vector3(-1.0, 2.6, 0), "BOWL_CASE_BROKEN")
	trophy_case_broken.emit()


## A ball flew into lane `lane`'s screen, once per screen: a fine and the screen goes dark.
func break_screen(lane: int) -> void:
	if broken_screens.has(lane):
		return
	broken_screens.append(lane)
	fines += SCREEN_FINE
	_build.mesh_box(Vector3(LANE_X[lane], SCREEN_Y, SCREEN_Z + 0.06), Vector3(1.12, 0.62, 0.01), DARK)
	_say(Vector3(LANE_X[lane], SCREEN_Y + 0.8, SCREEN_Z), "BOWL_SCREEN_BROKEN")
	screen_broken.emit(lane)


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
func _say(at: Vector3, key: String) -> void:
	var label := Label3D.new()
	label.text = key
	label.font_size = 48
	label.pixel_size = 0.01
	label.outline_size = 12
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.position = at
	add_child(label)
	get_tree().create_timer(3.0).timeout.connect(label.queue_free)


## A model only for the look, standing at `at` and turned `turn` around Y.
func _model(scene: PackedScene, at: Vector3, turn := 0.0) -> Node3D:
	var look: Node3D = scene.instantiate()
	look.position = at
	look.rotation.y = turn
	$Built.add_child(look)
	return look
