class_name SuspectCar
extends CharacterBody3D

## The chase suspect's vehicle (persecucion.md): it drives itself along its ChaseRoute, in its lane, slowing down to
## turn at the corners, and stops when something is in the way (the patrol car cutting it off). It counts how long it
## has been stuck, which is how the cops stop it. Forward is +Z, like the patrol car. Every number here is (propuesta).

## 40 km/h on the straight, slower than the patrol car's 60, and this share of it through a sharp turn.
const SPEED := 40.0 / 3.6
const TURN_SPEED := 0.45
## How fast it turns (radians a second) and how close to a corner counts as through it.
const TURN_RATE := 1.6
const REACH := 3.0
## Moving slower than this (or than STUCK_SHARE of his own speed) while it wants to drive counts as stuck.
const STUCK_SPEED := 1.0
const STUCK_SHARE := 0.2
## Nervous (the megaphone), he drives at this share of his speed.
const NERVOUS_SPEED := 0.6
## With his tires punctured (the spikes) he rolls to a halt in this many seconds.
const FLAT_STOP := 2.0
const WHEELS: Array[Vector3] = [Vector3(-1.1, 0.38, 1.7), Vector3(1.1, 0.38, 1.7), Vector3(-1.1, 0.38, -1.7),
	Vector3(1.1, 0.38, -1.7)]
## Each suspect's vehicle (ChaseCase.SUSPECTS); the trucks share one size and wheels.
const MODELS := {
	"ice_cream": preload("res://assets/models/ice_cream_truck.glb"),
	"moving_truck": preload("res://assets/models/moving_truck.glb"),
	"school_bus": preload("res://assets/models/school_bus.glb"),
	"rain": preload("res://assets/models/getaway_car.glb"),
	"night": preload("res://assets/models/getaway_car.glb"),
	"moto": preload("res://assets/models/delivery_scooter.glb"),
	"wheelchair": preload("res://assets/models/wheelchair.glb"),
	"highway": preload("res://assets/models/sports_car.glb"),
	"tow_truck": preload("res://assets/models/tow_truck.glb"),
	"golf_cart": preload("res://assets/models/golf_cart.glb"),
	# The dangerous suspect takes the old patrol car from behind the station (persecucion-final.md).
	"old_patrol": preload("res://assets/models/old_patrol_car.glb"),
	# The pastry contest's culprit runs off on his delivery bike (escena-del-crimen.md).
	"bike": preload("res://assets/models/delivery_bike.glb"),
}
## Who rides on top of it, where you can see them, each as [model, position, scale] (they get off when he gives up).
const RIDERS := {
	"moto": [[preload("res://assets/models/npc_repartidor.glb"), Vector3(0, 0.36, -0.15), 0.85]],
	"wheelchair": [[preload("res://assets/models/npc_abuelo.glb"), Vector3(0, 0.12, 0.02), 0.72]],
	"golf_cart": [[preload("res://assets/models/npc_sospechoso.glb"), Vector3(-0.3, 0.3, -0.2), 0.7],
		[preload("res://assets/models/npc_preso.glb"), Vector3(0.3, 0.3, -0.2), 0.7]],
	"bike": [[preload("res://assets/models/npc_pastelero.glb"), Vector3(0, 0.3, -0.35), 0.85]],
}
## The scooter and the wheelchair ride the sidewalk, not the street.
const LANES := {"moto": ChaseRoute.SIDEWALK_LANE, "wheelchair": ChaseRoute.SIDEWALK_LANE}
## The electric wheelchair goes at 8 km/h (persecucion.md).
## The delivery bike pedals at 25 km/h and turns tight.
const SPEEDS := {"wheelchair": 8.0 / 3.6, "tow_truck": 30.0 / 3.6, "golf_cart": 25.0 / 3.6, "bike": 25.0 / 3.6}
## The tow truck turns slowly and nearly stops to do it (persecucion-lugares.md): a cop cutting a corner on foot
## catches up with him.
## The golf cart turns very tight and hardly slows down to do it.
const TURN_RATES := {"tow_truck": 1.0, "golf_cart": 3.2, "bike": 3.2}
const TURN_SPEEDS := {"tow_truck": 0.3, "golf_cart": 0.75, "bike": 0.75}
const GOLF := "golf_cart"
const TOW := "tow_truck"
const OLD_PATROL := "old_patrol"
const BIKE := "bike"
## Where the towed patrol car hangs behind the tow truck: its middle, and its nose lifted this much.
const TOWED_AT := Vector3(0, 0.55, -5.6)
const TOWED_TILT := -0.12
## The sports car (persecucion-lugares.md): 90 km/h on the highway, 50 on the way there through the city.
const HIGHWAY := "highway"
const HIGHWAY_SPEED := 90.0 / 3.6
const HIGHWAY_CITY_SPEED := 50.0 / 3.6
## The cops' collision layer: on foot they're in the wheelchair's way (the cars ignore them).
const COPS_LAYER := 2
## Each vehicle's body (width, height, length) and wheels, when not the trucks'.
const SIZES := {"school_bus": Vector3(2.5, 2.9, 8.4), "rain": Vector3(2.1, 1.4, 4.6), "night": Vector3(2.1, 1.4, 4.6),
	"highway": Vector3(2.1, 1.1, 4.6), "tow_truck": Vector3(2.3, 2.4, 6.2), "golf_cart": Vector3(1.3, 1.8, 2.4),
	"moto": Vector3(0.8, 1.6, 1.9), "old_patrol": Vector3(2.1, 1.5, 4.6),
	"wheelchair": Vector3(0.8, 1.4, 1.2), "bike": Vector3(0.7, 1.6, 1.9)}
const BUS_WHEELS: Array[Vector3] = [Vector3(-1.15, 0.38, 2.7), Vector3(1.15, 0.38, 2.7), Vector3(-1.15, 0.38, -2.6),
	Vector3(1.15, 0.38, -2.6)]
const SEDAN_WHEELS: Array[Vector3] = [Vector3(-1.05, 0.38, 1.55), Vector3(1.05, 0.38, 1.55),
	Vector3(-1.05, 0.38, -1.55), Vector3(1.05, 0.38, -1.55)]
const TOW_WHEELS: Array[Vector3] = [Vector3(-1.15, 0.38, 2.0), Vector3(1.15, 0.38, 2.0), Vector3(-1.15, 0.38, -1.8),
	Vector3(1.15, 0.38, -1.8)]
## The scooter's wheels are part of its model.
const NO_WHEELS: Array[Vector3] = []
const OTHER_WHEELS := {"school_bus": BUS_WHEELS, "rain": SEDAN_WHEELS, "night": SEDAN_WHEELS, "moto": NO_WHEELS,
	"wheelchair": NO_WHEELS, "highway": SEDAN_WHEELS, "tow_truck": TOW_WHEELS, "golf_cart": NO_WHEELS,
	"old_patrol": SEDAN_WHEELS, "bike": NO_WHEELS}

## He drove through a corner: `turned` if he changed direction there (where the moving truck loses furniture).
signal corner_passed(turned: bool)

## Whose vehicle it is (set before it's added).
var kind := "ice_cream"
const WHEEL := preload("res://assets/models/car_wheel.glb")

## Where it drives through, in the world (set before it's added, or with follow()).
var points: Array[Vector3] = []
## The next point it heads for; past the last one it stops.
var next := 0
## Seconds it has been stuck in a row, and whether it's driving at all.
var stuck_for := 0.0
var driving := true
## Seconds he's still nervous for.
var nervous_left := 0.0
## His tires got punctured; how much of his speed he still has; seconds the net still holds him.
var punctured := false
var _rolling := 1.0
var tangled_left := 0.0
var _highway: Highway


func _ready() -> void:
	add_to_group("suspect_car")
	if kind == "wheelchair" or kind == TOW:
		set_collision_mask_value(COPS_LAYER, true)
	var shape := CollisionShape3D.new()
	var body := BoxShape3D.new()
	body.size = SIZES.get(kind, Vector3(2.2, 2.3, 5.2))
	shape.shape = body
	shape.position.y = body.size.y / 2 + 0.2
	add_child(shape)
	add_child((MODELS[kind] as PackedScene).instantiate())
	var riders: Array = RIDERS.get(kind, [])
	for k in riders.size():
		var rider: Node3D = (riders[k][0] as PackedScene).instantiate()
		rider.name = "Rider" if k == 0 else "Rider%d" % (k + 1)
		rider.position = riders[k][1]
		rider.scale = Vector3.ONE * float(riders[k][2])
		add_child(rider)
	if kind == TOW:
		var hook := TowHook.new()
		hook.name = "Hook"
		hook.position = Vector3(0, 1.2, -3.3)
		add_child(hook)
		add_collision_exception_with(hook)
	var wheels: Array[Vector3] = OTHER_WHEELS.get(kind, WHEELS)
	for at in wheels:
		var wheel: Node3D = WHEEL.instantiate()
		wheel.position = at
		add_child(wheel)


## Puts it at the start of `route` (in the city's space, which `city` places in the world), facing the way it goes.
func follow(route: ChaseRoute, city: Transform3D) -> void:
	retake(route, city)
	next = 1
	global_position = points[0]
	var ahead := points[1] - points[0]
	rotation.y = atan2(ahead.x, ahead.z)


## Drives off from where he's parked (`at`, in the world) and on along `route`: a chase in the middle of another case
## (persecucion-final.md).
func drive_from(at: Transform3D, route: ChaseRoute, city: Transform3D) -> void:
	retake(route, city)
	points.insert(0, at.origin)
	next = 1
	global_transform = at


## Puts it at the start of `path` (points in the city's space, like HighwayRoute's), facing the way it goes.
func follow_path(path: Array[Vector3], city: Transform3D) -> void:
	points.clear()
	for point in path:
		points.append(city * point)
	next = 1
	global_position = points[0]
	var ahead := points[1] - points[0]
	rotation.y = atan2(ahead.x, ahead.z)


## Where the patrol car he tows hangs, in the world.
func towed_transform() -> Transform3D:
	return global_transform * Transform3D(Basis(Vector3.RIGHT, TOWED_TILT), TOWED_AT)


## His speed on the straight here: the sports car's depends on whether he's on the highway.
func top_speed() -> float:
	if kind != HIGHWAY:
		return SPEEDS.get(kind, SPEED)
	if not is_instance_valid(_highway):
		_highway = get_tree().get_first_node_in_group("highway") as Highway
	return HIGHWAY_SPEED if _highway and _highway.covers(global_position) else HIGHWAY_CITY_SPEED


## Drives `route` from here on (he changed his mind at a corner), heading for the same next point.
func retake(route: ChaseRoute, city: Transform3D) -> void:
	points.clear()
	for point in route.waypoints(LANES.get(kind, ChaseRoute.LANE)):
		points.append(city * point)


## The spikes: his tires go flat and he rolls to a halt, for good.
func puncture() -> void:
	punctured = true


## He gives up and gets off: whoever rode on top isn't there anymore.
func get_off() -> void:
	for rider in [get_node_or_null("Rider"), get_node_or_null("Rider2")]:
		if rider:
			(rider as Node3D).hide()


## Online (NpcSync): what a guest's copy needs before it's added (one that drives off in the middle of a case).
func net_setup() -> Dictionary:
	return {"kind": kind}


## Online (NpcSync): whether he got off, so a guest's copy hides its riders too.
func net_state() -> Variant:
	var rider := get_node_or_null("Rider") as Node3D
	return rider != null and not rider.visible


func apply_net_state(state: Variant) -> void:
	if state:
		get_off()


## The net: he can't drive for `seconds`.
func tangle(seconds: float) -> void:
	tangled_left = maxf(tangled_left, seconds)


## Nervous for `seconds`: he slows down.
func scare(seconds: float) -> void:
	nervous_left = maxf(nervous_left, seconds)


## Whether the route changes direction at point `k`.
func _turns_at(k: int) -> bool:
	if k < 1 or k + 1 >= points.size():
		return false
	var into := points[k] - points[k - 1]
	var out := points[k + 1] - points[k]
	return absf(Vector2(into.x, into.z).angle_to(Vector2(out.x, out.z))) > PI / 4


func finished() -> bool:
	return next >= points.size()


func _physics_process(delta: float) -> void:
	velocity.y = 0.0 if is_on_floor() else velocity.y - GameScale.GRAVITY * delta
	nervous_left = maxf(nervous_left - delta, 0.0)
	tangled_left = maxf(tangled_left - delta, 0.0)
	if punctured:
		_rolling = maxf(_rolling - delta / FLAT_STOP, 0.0)
	if not driving or finished():
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return
	var to := points[next] - global_position
	to.y = 0.0
	if to.length() < REACH:
		next += 1
		corner_passed.emit(_turns_at(next - 1))
		return
	var forward := global_basis.z
	var turn := forward.signed_angle_to(to, Vector3.UP)
	# Flat or tangled, he can't get anywhere (and doesn't turn on the spot).
	var can_go := 0.0 if tangled_left > 0.0 else _rolling
	var rate: float = TURN_RATES.get(kind, TURN_RATE)
	rotation.y += clampf(turn, -rate * delta, rate * delta) * can_go
	# Slows down while its nose isn't on the next point yet: through the corners.
	var speed: float = top_speed() * lerpf(1.0, TURN_SPEEDS.get(kind, TURN_SPEED), clampf(absf(turn) / (PI / 2), 0.0, 1.0))
	if nervous_left > 0.0:
		speed *= NERVOUS_SPEED
	speed *= can_go
	var wish := global_basis.z * speed
	velocity.x = wish.x
	velocity.z = wish.z
	move_and_slide()
	var moved := Vector2(get_real_velocity().x, get_real_velocity().z).length()
	# The wheelchair is slow anyway: stuck is slower than a share of his own speed.
	var stuck_below := minf(STUCK_SPEED, top_speed() * STUCK_SHARE)
	stuck_for = stuck_for + delta if moved < stuck_below else 0.0
