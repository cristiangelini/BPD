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
## Packed with people (control-auto-lleno.md), he drives at this share of his speed.
const HEAVY_SPEED := 0.8
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
	# Doña Chela found out runs off on her motorized walker (infiltracion.md).
	"walker": preload("res://assets/models/motor_walker.glb"),
	# Maestro Ernesto found out runs off in the choir's van, with the choir inside singing (infiltracion-coro.md).
	"choir_van": preload("res://assets/models/choir_van.glb"),
	# El Oso gets away from the bank in the robbers' van, or on foot with a sack of money if it's boxed in
	# (robo-banco.md): on foot the "vehicle" is the sack he carries, and he's its rider.
	"robbers_van": preload("res://assets/models/robbers_van.glb"),
	"bear_on_foot": preload("res://assets/models/money_bag.glb"),
	# The bank's manager who was the boss drives off in his own car with the sacks in its trunk (robo-banco-gerente.md).
	"manager_car": preload("res://assets/models/manager_car.glb"),
	# The last heckler of the rally runs off on a kick scooter (proteccion-politico.md); set_rider puts them on it.
	"kick_scooter": preload("res://assets/models/kick_scooter.glb"),
	# The prison's last ringleader rolls off downhill on the kitchen's food cart (carcel-motin.md), behind it.
	"food_cart": preload("res://assets/models/food_cart.glb"),
	"inmate_on_foot": preload("res://assets/models/ball_and_chain.glb"),
	# The market's spiteful vendor pedals off on his vegetable tricycle (politico-mercado.md), losing veggies in curves.
	"veggie_trike": preload("res://assets/models/veggie_trike.glb"),
	# The circus's culprit runs off in the clown car, dropping inflatable clowns (escena-circo.md).
	"clown_car": preload("res://assets/models/clown_car.glb"),
	# The traffic control's wanted car, in its paint (control-transito.md): the traffic car it was in the queue.
	"traffic_0": preload("res://assets/models/traffic_car_0.glb"),
	"traffic_1": preload("res://assets/models/traffic_car_1.glb"),
	"traffic_2": preload("res://assets/models/traffic_car_2.glb"),
	"traffic_3": preload("res://assets/models/traffic_car_3.glb"),
	# The fruit truck control's wanted pickup (control-frutas.md), dropping watermelons at the corners.
	"fruit_truck": preload("res://assets/models/fruit_truck.glb"),
	# The roof robbery's El Oso gets away hanging from the giant toy helicopter's rope, low over the street
	# (robo-banco-techo.md): it flies AIR_AT up, over everything, and he hangs under it.
	"toy_helicopter": preload("res://assets/models/toy_helicopter.glb"),
}
## Who rides on top of it, where you can see them, each as [model, position, scale] (they get off when he gives up).
const RIDERS := {
	"moto": [[preload("res://assets/models/npc_repartidor.glb"), Vector3(0, 0.36, -0.15), 0.85]],
	"wheelchair": [[preload("res://assets/models/npc_abuelo.glb"), Vector3(0, 0.12, 0.02), 0.72]],
	"golf_cart": [[preload("res://assets/models/npc_sospechoso.glb"), Vector3(-0.3, 0.3, -0.2), 0.7],
		[preload("res://assets/models/npc_preso.glb"), Vector3(0.3, 0.3, -0.2), 0.7]],
	"bike": [[preload("res://assets/models/npc_pastelero.glb"), Vector3(0, 0.3, -0.35), 0.85]],
	"walker": [[preload("res://assets/models/npc_chela.glb"), Vector3(0, 0.13, -0.32), 0.85]],
	"choir_van": [[preload("res://assets/models/npc_ernesto.glb"), Vector3(-0.45, 0.4, 1.3), 0.85]],
	"robbers_van": [[preload("res://assets/models/npc_ladron_oso.glb"), Vector3(-0.5, 0.4, 1.4), 0.85]],
	"bear_on_foot": [[preload("res://assets/models/npc_ladron_oso.glb"), Vector3(0, 0, -0.35), 1.15]],
	"kick_scooter": [[preload("res://assets/models/npc_vecina.glb"), Vector3(0, 0.15, -0.1), 0.85]],
	"food_cart": [[preload("res://assets/models/npc_preso.glb"), Vector3(0, 0.05, -0.95), 0.9]],
	"inmate_on_foot": [[preload("res://assets/models/npc_preso.glb"), Vector3(0, 0, 0), 0.85]],
	"veggie_trike": [[preload("res://assets/models/npc_puestero.glb"), Vector3(0, 0.25, -0.45), 0.85]],
	"clown_car": [[preload("res://assets/models/npc_payaso.glb"), Vector3(0, 0.45, -0.25), 0.8]],
	"toy_helicopter": [[preload("res://assets/models/npc_ladron_oso.glb"), Vector3(0, 2.4, 0), 0.85]],
}
## Who rides inside and stays there when he gives up, the same way: the choristers in the van, seen through its open
## windows, singing all the way.
const PASSENGERS := {
	"choir_van": [[preload("res://assets/models/npc_corista.glb"), Vector3(-0.5, 0.4, -0.1), 0.85],
		[preload("res://assets/models/npc_corista_b.glb"), Vector3(0.5, 0.4, -0.1), 0.85],
		[preload("res://assets/models/npc_corista_b.glb"), Vector3(-0.5, 0.4, -1.4), 0.85],
		[preload("res://assets/models/npc_corista.glb"), Vector3(0.5, 0.4, -1.4), 0.85]],
}
## The scooter and the wheelchair ride the sidewalk, not the street.
const LANES := {"moto": ChaseRoute.SIDEWALK_LANE, "wheelchair": ChaseRoute.SIDEWALK_LANE,
	"walker": ChaseRoute.SIDEWALK_LANE, "bear_on_foot": ChaseRoute.SIDEWALK_LANE, "kick_scooter": ChaseRoute.SIDEWALK_LANE,
	"food_cart": ChaseRoute.SIDEWALK_LANE, "veggie_trike": ChaseRoute.SIDEWALK_LANE, "inmate_on_foot": ChaseRoute.SIDEWALK_LANE}
## The electric wheelchair goes at 8 km/h (persecucion.md).
## The delivery bike pedals at 25 km/h and turns tight. Doña Chela's walker's motor does 10 km/h. The choir's old van,
## full, does 35. El Oso running with his sack does 12, the heckler's kick scooter 15 and the food cart, downhill, 14
## (propuesta). The loaded vegetable trike, 16, and an inmate off the transfer bus, dragging the ball and chain, 11.
## The clown car does 30, honking all the way.
const SPEEDS := {"bear_on_foot": 12.0 / 3.6, "wheelchair": 8.0 / 3.6, "tow_truck": 30.0 / 3.6, "golf_cart": 25.0 / 3.6, "bike": 25.0 / 3.6,
	"walker": 10.0 / 3.6, "choir_van": 35.0 / 3.6, "kick_scooter": 15.0 / 3.6,
	"food_cart": 14.0 / 3.6, "veggie_trike": 16.0 / 3.6, "inmate_on_foot": 11.0 / 3.6, "clown_car": 30.0 / 3.6,
	"toy_helicopter": 20.0 / 3.6}
## The tow truck turns slowly and nearly stops to do it (persecucion-lugares.md): a cop cutting a corner on foot
## catches up with him.
## The golf cart turns very tight and hardly slows down to do it.
const TURN_RATES := {"tow_truck": 1.0, "golf_cart": 3.2, "bike": 3.2, "clown_car": 3.0}
const TURN_SPEEDS := {"tow_truck": 0.3, "golf_cart": 0.75, "bike": 0.75, "clown_car": 0.75}
const GOLF := "golf_cart"
const TOW := "tow_truck"
const OLD_PATROL := "old_patrol"
const BIKE := "bike"
const WALKER := "walker"
const CHOIR_VAN := "choir_van"
const ROBBERS_VAN := "robbers_van"
const BEAR_ON_FOOT := "bear_on_foot"
const MANAGER_CAR := "manager_car"
const KICK_SCOOTER := "kick_scooter"
const FOOD_CART := "food_cart"
const INMATE_ON_FOOT := "inmate_on_foot"
const VEGGIE_TRIKE := "veggie_trike"
const CLOWN_CAR := "clown_car"
const FRUIT_TRUCK := "fruit_truck"
const TOY_HELICOPTER := "toy_helicopter"
## The toy helicopter flies this high (its skids), with the rope down to El Oso's hands; he hangs with his feet over a
## patrol car's roof, so it can pass right under him. Nothing gets in its way, and it doesn't fall.
const AIR_AT := 5.2
const ROPE_FROM := 3.9
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
	"wheelchair": Vector3(0.8, 1.4, 1.2), "bear_on_foot": Vector3(0.9, 1.8, 0.9), "choir_van": Vector3(2.0, 1.95, 4.6), "walker": Vector3(0.7, 1.6, 1.3), "kick_scooter": Vector3(0.6, 1.6, 1.0), "food_cart": Vector3(0.8, 1.6, 2.2), "veggie_trike": Vector3(1.0, 1.6, 2.0), "inmate_on_foot": Vector3(0.8, 1.6, 0.9), "bike": Vector3(0.7, 1.6, 1.9), "clown_car": Vector3(1.3, 1.4, 2.0), "traffic_0": Vector3(2.1, 1.4, 4.6),
	"traffic_1": Vector3(2.1, 1.4, 4.6), "traffic_2": Vector3(2.1, 1.4, 4.6), "traffic_3": Vector3(2.1, 1.4, 4.6),
	"manager_car": Vector3(2.1, 1.4, 4.6), "fruit_truck": Vector3(2.1, 1.75, 4.6),
	"toy_helicopter": Vector3(0.6, 0.6, 0.6)}
const BUS_WHEELS: Array[Vector3] = [Vector3(-1.15, 0.38, 2.7), Vector3(1.15, 0.38, 2.7), Vector3(-1.15, 0.38, -2.6),
	Vector3(1.15, 0.38, -2.6)]
const SEDAN_WHEELS: Array[Vector3] = [Vector3(-1.05, 0.38, 1.55), Vector3(1.05, 0.38, 1.55),
	Vector3(-1.05, 0.38, -1.55), Vector3(1.05, 0.38, -1.55)]
const TOW_WHEELS: Array[Vector3] = [Vector3(-1.15, 0.38, 2.0), Vector3(1.15, 0.38, 2.0), Vector3(-1.15, 0.38, -1.8),
	Vector3(1.15, 0.38, -1.8)]
## The scooter's wheels are part of its model.
const NO_WHEELS: Array[Vector3] = []
const OTHER_WHEELS := {"school_bus": BUS_WHEELS, "rain": SEDAN_WHEELS, "night": SEDAN_WHEELS, "moto": NO_WHEELS,
	"wheelchair": NO_WHEELS, "walker": NO_WHEELS, "bear_on_foot": NO_WHEELS, "kick_scooter": NO_WHEELS, "food_cart": NO_WHEELS, "veggie_trike": NO_WHEELS, "inmate_on_foot": NO_WHEELS, "highway": SEDAN_WHEELS, "tow_truck": TOW_WHEELS, "golf_cart": NO_WHEELS,
	"old_patrol": SEDAN_WHEELS, "bike": NO_WHEELS, "clown_car": NO_WHEELS, "traffic_0": SEDAN_WHEELS, "traffic_1": SEDAN_WHEELS,
	"traffic_2": SEDAN_WHEELS, "traffic_3": SEDAN_WHEELS, "choir_van": SEDAN_WHEELS, "manager_car": SEDAN_WHEELS, "fruit_truck": SEDAN_WHEELS,
	"toy_helicopter": NO_WHEELS}

## He drove through a corner: `turned` if he changed direction there (where the moving truck loses furniture).
signal corner_passed(turned: bool)

## The crowded car control's runaway, packed with the gang: slower (HEAVY_SPEED).
var heavy := false
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
var _rotor: Node3D


func _ready() -> void:
	add_to_group("suspect_car")
	if kind == "wheelchair" or kind == WALKER or kind == TOW or kind == BEAR_ON_FOOT or kind == KICK_SCOOTER \
			or kind == FOOD_CART or kind == VEGGIE_TRIKE or kind == INMATE_ON_FOOT:
		set_collision_mask_value(COPS_LAYER, true)
	var shape := CollisionShape3D.new()
	var body := BoxShape3D.new()
	body.size = SIZES.get(kind, Vector3(2.2, 2.3, 5.2))
	shape.shape = body
	shape.position.y = body.size.y / 2 + 0.2
	add_child(shape)
	var model: Node3D = (MODELS[kind] as PackedScene).instantiate()
	add_child(model)
	if kind == TOY_HELICOPTER:
		_fly(model)
	var riders: Array = RIDERS.get(kind, [])
	for k in riders.size():
		var rider: Node3D = (riders[k][0] as PackedScene).instantiate()
		rider.name = "Rider" if k == 0 else "Rider%d" % (k + 1)
		rider.position = riders[k][1]
		rider.scale = Vector3.ONE * float(riders[k][2])
		add_child(rider)
	var passengers: Array = PASSENGERS.get(kind, [])
	for k in passengers.size():
		var passenger: Node3D = (passengers[k][0] as PackedScene).instantiate()
		passenger.name = "Passenger%d" % (k + 1)
		passenger.position = passengers[k][1]
		passenger.scale = Vector3.ONE * float(passengers[k][2])
		add_child(passenger)
	if kind == CHOIR_VAN:
		var song := AudioStreamPlayer3D.new()
		song.name = "Song"
		song.stream = ChoirSinging.choir_stream()
		song.max_distance = 40.0
		song.autoplay = true
		add_child(song)
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


## The toy helicopter: up in the air with its rope hanging, out of everyone's way.
func _fly(model: Node3D) -> void:
	model.position.y = AIR_AT
	_rotor = model.find_child("rotor", true, false) as Node3D
	collision_layer = 0
	collision_mask = 0
	var rope := MeshInstance3D.new()
	rope.name = "Rope"
	var line := CylinderMesh.new()
	line.top_radius = 0.025
	line.bottom_radius = 0.025
	line.height = AIR_AT - ROPE_FROM
	rope.mesh = line
	rope.position.y = (AIR_AT + ROPE_FROM) / 2
	add_child(rope)


func _process(delta: float) -> void:
	if _rotor:
		_rotor.rotate_y(ToyHelicopter.FLY_SPIN * delta)


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


## His speed on the straight here: the sports car's depends on whether he's on the highway; a packed car's is less.
func top_speed() -> float:
	if kind != HIGHWAY:
		return SPEEDS.get(kind, SPEED) * (HEAVY_SPEED if heavy else 1.0)
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


## He gives up and gets off: whoever rode on top isn't there anymore, and the choir in the van stops singing.
## Puts `model` on it in place of its first rider, where they ride (the rally's heckler, with their own look).
func set_rider(model: PackedScene) -> void:
	var old := get_node_or_null("Rider") as Node3D
	if not old:
		return
	var rider: Node3D = model.instantiate()
	rider.transform = old.transform
	rider.visible = old.visible
	old.free()
	rider.name = "Rider"
	add_child(rider)


func get_off() -> void:
	for rider in [get_node_or_null("Rider"), get_node_or_null("Rider2"), get_node_or_null("Rope")]:
		if rider:
			(rider as Node3D).hide()
	var song := get_node_or_null("Song") as AudioStreamPlayer3D
	if song:
		song.stop()


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
	# In the air it neither falls nor touches anything.
	velocity.y = 0.0 if is_on_floor() or kind == TOY_HELICOPTER else velocity.y - GameScale.GRAVITY * delta
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
