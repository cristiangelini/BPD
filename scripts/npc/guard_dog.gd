class_name GuardDog
extends StaticBody3D

## Mordisco, the station's guard dog in the guard dog's jailbreak (docs/diseno/fuga-perro.md, step 1): a huge bulldog
## with the cells' key hanging from his collar. He walks his round between the guard room and the cells room, there and
## back (ROUND, in the station's own space), stopping at each stop for STOP_MIN to STOP_MAX seconds to sniff around;
## the seed draws where he starts and how long each stop lasts.
## Food (step 2, DogFood) lying on the floor within SMELL of him takes him off his round: he walks to it and eats it for
## EAT_TIME seconds, and what he thinks of it goes to the friendship of the cop who gave it (0 to FRIEND, one for each
## cop, by uniform). He can't get into the cells, so food in there is his only if it's within EAT_REACH of the bars.
## Lettuce he spits out; STUFFED_AFTER donuts and he lies down for STUFFED seconds. A cop who isn't his friend yet is
## forgotten little by little (FORGET a second); a friend stays a friend.
## He barks (step 3) at a cop out of the cells who isn't his friend and who he sees (SIGHT_ANGLE and SIGHT_RANGE, no
## walls in between), standing there facing him; every second of it brings the sleepy guard closer to waking up
## (SleepyGuard.heard_bark). Food on the floor comes first, though: throwing him some shuts him up. A stranger with
## food in hand within BEG of him isn't barked at: he sits and begs. A
## friend who whistles (sings or hums with H, which the guard passes on) has him follow for FOLLOW_TIME seconds, as
## far as the bars if the friend is in a cell; and a friend can pet him (E), which takes the key off his collar.
## If he's everyone's friend, he jumps into the patrol car with them once they're all in (step 4, the level calls
## ride) and rides in the back, between the back seats.
## Every number here is (propuesta).

const MODEL := preload("res://assets/models/guard_dog.glb")
const WALK_SPEED := 1.6
const STOP_MIN := 4.0
const STOP_MAX := 10.0
const BUBBLE_TIME := 3.0
const SNIFF_LINES := 4
## [where, which way he faces there (0: along his walk), whether he stops]: the guard room, the cells' door, and the
## corridor in front of both cells and beside the guard's desk. He walks it there and back, so he never cuts through
## the desk.
const ROUND := [
	[Vector3(2.5, 0, 5.5), 0.0, true],
	[Vector3(5.0, 0, 6.4), 0.0, false],
	[Vector3(7.5, 0, 5.5), PI, true],
	[Vector3(13.0, 0, 5.5), PI, true],
	[Vector3(13.0, 0, 8.3), 0.0, true],
]
const SMELL := 8.0
const EAT_REACH := 0.9
const EAT_TIME := 2.0
## Food counts as lying on the floor this close to it and this slow.
const FLOOR_BAND := 0.4
const STILL := 0.5
const FRIEND := 100.0
const FORGET := 2.0 / 60.0
const STUFFED_AFTER := 3
const STUFFED := 15.0
const EAT_LINES := 4
const SIGHT_ANGLE := deg_to_rad(120.0)
const SIGHT_RANGE := 8.0
const EYE_HEIGHT := 0.6
const BARK_EVERY := 1.0
const BARK_LINES := 4
const BEG := 3.0
const FOLLOW_TIME := 20.0
const KEEP := 1.2
const KEY_SCENE := preload("res://scenes/props/cell_key.tscn")
const WAG_SPEED := 14.0
const WAG := 0.04

## The station's lot, which ROUND is relative to.
var station := Transform3D.IDENTITY
## The stop he's walking to (or standing at) and which way along the round he goes (1 or -1).
var target := 0
var heading := 1
var wait_left := 0.0
var key_on_collar := true:
	set(value):
		key_on_collar = value
		if _key:
			_key.visible = value
## Each cop's friendship, by uniform (0 to FRIEND).
var friends := {}
var eating: DogFood
var eat_left := 0.0
var donuts := 0
var stuffed_left := 0.0
## Who he's barking at now (null: nobody), who he's begging and the friend he follows, for how long.
var barking_at: Cop
var begging: Cop
var following: Cop
var follow_left := 0.0
var _bark_left := 0.0
## In the patrol car with the cops (ride), on its back seat.
var riding := false
var car: PatrolCar
## The guard his barking wakes up (the level sets it).
var guard: SleepyGuard
## Whether a world position is out of the cells (the level sets it).
var outside_cells: Callable = func(_at: Vector3) -> bool: return true
var _model: Node3D
var _key: Node3D
var _tail: Node3D
var _wag := 0.0
var _bubble: Label3D
var _bubble_left := 0.0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	add_to_group("guard_dog")
	collision_layer = 8
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.1
	shape.shape = capsule
	shape.rotation.x = PI / 2
	shape.position = Vector3(0, 0.4, 0)
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	_key = _model.find_child("key", true, false)
	_tail = _model.find_child("tail", true, false)
	key_on_collar = key_on_collar
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 1.2, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.no_depth_test = true
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 8
	_bubble.font_size = 36
	_bubble.width = 700.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


## His round for this jailbreak's seed, on the station of `station_lot`: he starts at a stop drawn by the seed.
func setup_round(case_seed: int, station_lot: Transform3D) -> void:
	station = station_lot
	_rng.seed = hash(["guard dog", case_seed])
	var stops: Array[int] = []
	for i in ROUND.size():
		if ROUND[i][2]:
			stops.append(i)
	target = stops[_rng.randi_range(0, stops.size() - 1)]
	heading = 1 if target < ROUND.size() - 1 else -1
	global_transform = Transform3D(station.basis * Basis(Vector3.UP, ROUND[target][1]), station * ROUND[target][0])
	wait_left = _rng.randf_range(STOP_MIN, STOP_MAX)


func _physics_process(delta: float) -> void:
	_bubble_left -= delta
	if _bubble.visible and _bubble_left <= 0.0:
		_bubble.hide()
	if riding:
		if is_instance_valid(car):
			global_transform = car.prisoner_seat()
		_wag_tail(delta)
		return
	_forget(delta)
	if stuffed_left > 0.0:
		stuffed_left -= delta
		_model.rotation.z = 0.0 if stuffed_left <= 0.0 else PI / 2
		return
	if is_instance_valid(eating):
		_chew(delta)
		_wag_tail(delta)
		return
	eating = null
	# Food first: throwing him something shuts him up.
	var food := smell()
	if food:
		barking_at = null
		begging = null
		_go_eat(food, delta)
		_wag_tail(delta)
		return
	_watch(delta)
	if barking_at or begging:
		_face(barking_at.global_position if barking_at else begging.global_position)
		return
	if not _follow(delta):
		_walk(delta)
	_wag_tail(delta)


## Who he sees: strangers out of the cells get barked at, unless one is begging-close with food in hand.
func _watch(delta: float) -> void:
	barking_at = null
	begging = null
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if is_friend(cop) or not outside_cells.call(cop.global_position):
			continue
		if not sees(cop.global_position + Vector3.UP, cop):
			continue
		if cop.get_node("Grabber").held is DogFood and _flat(cop.global_position).length() <= BEG:
			begging = cop
		elif not barking_at:
			barking_at = cop
	if begging:
		barking_at = null
		if said() != "DOG_BEG":
			say("DOG_BEG")
		return
	if not barking_at:
		_bark_left = 0.0
		return
	if guard:
		guard.heard_bark(delta, barking_at.global_position)
	_bark_left -= delta
	if _bark_left <= 0.0:
		_bark_left = BARK_EVERY
		say("DOG_BARK_%d" % _rng.randi_range(0, BARK_LINES - 1), BARK_EVERY)


## Whether he sees `at`: inside his cone and with no wall in between (`body` itself doesn't count as one).
func sees(at: Vector3, body: CollisionObject3D = null) -> bool:
	var eye := global_position + Vector3.UP * EYE_HEIGHT
	var flat := Vector3(at.x - eye.x, 0, at.z - eye.z)
	if flat.length() > SIGHT_RANGE or flat.length() < 0.01:
		return false
	if global_basis.z.angle_to(flat.normalized()) > SIGHT_ANGLE / 2:
		return false
	var ray := PhysicsRayQueryParameters3D.create(eye, at, 1, [get_rid()])
	var hit := get_world_3d().direct_space_state.intersect_ray(ray)
	return hit.is_empty() or (body != null and hit.collider == body)


func _face(at: Vector3) -> void:
	var to := _flat(at)
	if to.length() > 0.01:
		global_rotation.y = atan2(to.x, to.z)


## A cop whistled (the guard passes the singing on): a friend has him follow.
func heard_whistle(cop: Cop) -> void:
	if not is_friend(cop):
		return
	if following != cop:
		say("DOG_COMING")
	following = cop
	follow_left = FOLLOW_TIME


## Walks after the friend he follows (to the bars, if the friend is in a cell), KEEP away: false once it's over.
func _follow(delta: float) -> bool:
	follow_left -= delta
	if not is_instance_valid(following) or follow_left <= 0.0:
		following = null
		return false
	var to_cop := _flat(following.global_position)
	var at := following.global_position
	if not outside_cells.call(at):
		var local := station.affine_inverse() * at
		at = station * Vector3(local.x, 0, StationRooms.CELL_FRONT_Z + 0.5)
	var to := _flat(at)
	if to_cop.length() > KEEP and to.length() > 0.1:
		global_position += to.normalized() * minf(WALK_SPEED * 1.3 * delta, to.length())
	_face(following.global_position)
	return true


## A friend can pet him (E), and takes the key if it's still on his collar.
func prompt_key(cop: Cop) -> String:
	if not is_friend(cop) or cop.get_node("Grabber").held:
		return ""
	return "PROMPT_PET_DOG_KEY" if key_on_collar else "PROMPT_PET_DOG"


func use(cop: Cop) -> void:
	if prompt_key(cop) == "":
		return
	if not key_on_collar:
		say("DOG_PETTED")
		return
	say("DOG_KEY_TAKEN", 4.0)
	var key := _take_key(cop.camera.global_position)
	if key:
		cop.handed(key)


## The key off his collar, now a CellKey at `at` (null on a guest: only the host makes it, PropSync copies it).
func _take_key(at: Vector3) -> CellKey:
	if not multiplayer.is_server():
		return null
	key_on_collar = false
	var key: CellKey = KEY_SCENE.instantiate()
	get_parent().add_child(key)
	key.global_position = at
	return key


## The nearest food he can get at, lying on the floor within SMELL, or null.
func smell() -> DogFood:
	var best: DogFood
	var best_distance := SMELL
	for food: DogFood in get_tree().get_nodes_in_group("dog_food"):
		var lying := not food.is_held() and food.linear_velocity.length() <= STILL \
			and food.global_position.y - global_position.y <= FLOOR_BAND
		if not lying or reach_point(food) == null:
			continue
		var distance := _flat(food.global_position).length()
		if distance < best_distance:
			best = food
			best_distance = distance
	return best


## Where he stands to eat `food`: right at it out of the cells, or at the bars if it's just behind them (null if it's
## too deep in a cell).
func reach_point(food: Node3D) -> Variant:
	if outside_cells.call(food.global_position):
		return food.global_position
	var local := station.affine_inverse() * food.global_position
	var bars := station * Vector3(local.x, 0, StationRooms.CELL_FRONT_Z + 0.35)
	if Vector2(bars.x - food.global_position.x, bars.z - food.global_position.z).length() > EAT_REACH:
		return null
	return bars


func _go_eat(food: DogFood, delta: float) -> void:
	var stand: Vector3 = reach_point(food)
	if _flat(food.global_position).length() <= EAT_REACH and _flat(stand).length() <= EAT_REACH:
		eating = food
		eat_left = EAT_TIME
		var to := _flat(food.global_position)
		if to.length() > 0.01:
			global_rotation.y = atan2(to.x, to.z)
		return
	var to := _flat(stand)
	var step := WALK_SPEED * delta
	global_position += to.normalized() * minf(step, to.length())
	if to.length() > 0.01:
		global_rotation.y = atan2(to.x, to.z)


func _chew(delta: float) -> void:
	if eating.is_held():
		eating = null
		return
	eat_left -= delta
	if eat_left > 0.0:
		return
	eat(eating)
	eating = null


## He eats `food` (or spits it, if it's lettuce): its friendship goes to the cop who gave it.
func eat(food: DogFood) -> void:
	var giver := food.giver()
	if giver:
		befriend(giver, food.friendship())
	if food.kind == "lettuce":
		say("DOG_SPIT")
	else:
		say("DOG_EAT_%d" % _rng.randi_range(0, EAT_LINES - 1))
	if food.kind == "donut":
		donuts += 1
		if donuts >= STUFFED_AFTER:
			donuts = 0
			stuffed_left = STUFFED
			_model.rotation.z = PI / 2
			say("DOG_STUFFED", 4.0)
	if multiplayer.is_server():
		food.queue_free()


func befriend(cop: Cop, amount: float) -> void:
	var was_friend := is_friend(cop)
	friends[cop.uniform] = clampf(friendship_of(cop) + amount, 0.0, FRIEND)
	if is_friend(cop) and not was_friend:
		say("DOG_FRIEND", 4.0)
		cop.show_hint("HINT_DOG_FRIEND")


func friendship_of(cop: Cop) -> float:
	return friends.get(cop.uniform, 0.0)


func is_friend(cop: Cop) -> bool:
	return friendship_of(cop) >= FRIEND


## Whether he's the friend of every cop in `cops`.
func friend_of_all(cops: Array) -> bool:
	return not cops.is_empty() and cops.all(func(cop: Node) -> bool: return cop is Cop and is_friend(cop))


## Into the patrol car with his friends.
func ride(patrol_car: PatrolCar) -> void:
	car = patrol_car
	riding = true
	eating = null
	following = null
	say("DOG_RIDE", 4.0)


func _forget(delta: float) -> void:
	for uniform: int in friends.keys():
		if friends[uniform] < FRIEND:
			friends[uniform] = maxf(friends[uniform] - FORGET * delta, 0.0)


func _flat(at: Vector3) -> Vector3:
	return Vector3(at.x - global_position.x, 0, at.z - global_position.z)


## Where he's going now, in the world.
func goal() -> Vector3:
	return station * (ROUND[target][0] as Vector3)


func is_walking() -> bool:
	return wait_left <= 0.0


func _walk(delta: float) -> void:
	if wait_left > 0.0:
		wait_left -= delta
		if wait_left <= 0.0:
			_next_stop()
		return
	var to := goal() - global_position
	to.y = 0.0
	var step := WALK_SPEED * delta
	if to.length() > step:
		global_position += to.normalized() * step
		global_rotation.y = atan2(to.x, to.z)
		return
	global_position = Vector3(goal().x, global_position.y, goal().z)
	if not ROUND[target][2]:
		_next_stop()
		return
	if ROUND[target][1] != 0.0:
		global_basis = station.basis * Basis(Vector3.UP, ROUND[target][1])
	wait_left = _rng.randf_range(STOP_MIN, STOP_MAX)
	say("DOG_SNIFF_%d" % _rng.randi_range(0, SNIFF_LINES - 1))


## The next stop along the round, turning back at either end.
func _next_stop() -> void:
	if target + heading < 0 or target + heading >= ROUND.size():
		heading = -heading
	target += heading


func _wag_tail(delta: float) -> void:
	if not _tail:
		return
	_wag += delta * WAG_SPEED
	_tail.position.x = sin(_wag) * WAG


## Where his collar's key hangs, in the world.
func collar() -> Vector3:
	return global_transform * Vector3(0, 0.3, 0.48)


func say(text: String, seconds := BUBBLE_TIME) -> void:
	_bubble.text = text
	_bubble.show()
	_bubble_left = seconds


func said() -> String:
	return _bubble.text if _bubble.visible else ""


## Online: where he is on his round, the key on his collar, his friends, his full belly and his ride (NpcSync).
func net_state() -> Variant:
	return [target, heading, wait_left, key_on_collar, friends, stuffed_left, riding]


func apply_net_state(state: Variant) -> void:
	target = state[0]
	heading = state[1]
	wait_left = state[2]
	key_on_collar = state[3]
	friends = state[4]
	stuffed_left = state[5]
	riding = state[6]
	_model.rotation.z = PI / 2 if stuffed_left > 0.0 else 0.0
