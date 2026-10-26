class_name GuiltyNeighbor
extends CharacterBody3D

## The guilty neighbor of the wrong house (docs/diseno/casa-equivocada.md, step 3): he waits by his front window,
## kindly. If he sees the cops go into doña Chola's house next door (noticed), every CARRY_EVERY seconds he takes the
## next thing in `loot` that is still in his house, carries it out the back door and down the side passage, and loads
## it on his station wagon's roof rack; the main evidence is the last one. When it's up there he drives off (fled: the
## case starts the chase). A cop within BLOCK of him outside his house stops him: he drops what he carries, goes back
## in and tries again RETRY seconds later. If the cops go into his house first, he never gets the chance (off guard).
## It runs on the host. Every number here is (propuesta).

signal loaded(item: Grabbable)
signal fled

enum State { HOME, FETCHING, CARRYING, BACK, GONE }

const CARRY_EVERY := 30.0
const RETRY := 15.0
const SPEED := 1.8
const CARRY_SPEED := 1.4
const REACH := 0.7
## Arm's length: what he takes can be on a table or a counter.
const ARM := 1.1
const BLOCK := 1.5
const REPATH := 0.5
const ABOVE_HEAD := 1.9
const LINE_EVERY := 6.0
const LINES := ["GUILTY_LINE_1", "GUILTY_LINE_2", "GUILTY_LINE_3"]

var state := State.HOME
var noticed := false
var off_guard := false
## In the order he takes them out; the main evidence last.
var loot: Array[Grabbable] = []
## Where he waits (by his window), where he stands to load the rack, the rack's middle, and his house's floor.
var home: Vector3
var rack_spot: Vector3
var rack: Vector3
var house_rect: Rect2
var carried: Grabbable
var target: Grabbable
var on_rack: Array[Grabbable] = []
var _wait_left := CARRY_EVERY
## How long he waits at home once he's back: CARRY_EVERY after loading something, RETRY after a cop stopped him.
var _next_wait := RETRY
var _path := PackedVector3Array()
var _goal := Vector3.ZERO
var _repath := 0.0
var _since_line := LINE_EVERY

@onready var _bubble: Label3D = $Bubble


func _ready() -> void:
	add_to_group("guilty_neighbors")
	_bubble.hide()


## He saw the cops go into the house next door.
func notice() -> void:
	if noticed or off_guard or state == State.GONE:
		return
	noticed = true
	_wait_left = CARRY_EVERY
	_say("GUILTY_NOTICED", 4.0)


## The cops came into his house first: no time to take anything out.
func caught_off_guard() -> void:
	if not noticed:
		off_guard = true


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		return
	velocity.y = 0.0 if is_on_floor() else velocity.y - GameScale.GRAVITY * delta
	_since_line += delta
	match state:
		State.HOME:
			_stand(delta)
			if noticed:
				_wait_left -= delta
				if _wait_left <= 0.0:
					target = next_loot()
					if target:
						state = State.FETCHING
						_say("GUILTY_GOING", 3.0)
					else:
						_wait_left = RETRY
		State.FETCHING:
			if not _still_there(target):
				target = null
				_go_back(RETRY)
			elif _walk_to(target.global_position, SPEED, delta, ARM):
				_pick_up(target)
		State.CARRYING:
			_carry()
			if not carried:
				_go_back(RETRY)
			elif _blocked():
				_drop()
				_say("GUILTY_BLOCKED", 4.0)
				_go_back(RETRY)
			elif _walk_to(rack_spot, CARRY_SPEED, delta):
				_load()
		State.BACK:
			if _walk_to(home, SPEED, delta):
				state = State.HOME
				_wait_left = _next_wait
		State.GONE:
			velocity = Vector3.ZERO


## The next thing in `loot` that he can take: not broken, not held, not on the rack, still in his house.
func next_loot() -> Grabbable:
	for item in loot:
		if _still_there(item):
			return item
	return null


func _still_there(item: Grabbable) -> bool:
	if not is_instance_valid(item) or item.is_held() or on_rack.has(item):
		return false
	if item is Evidence and (item as Evidence).is_broken:
		return false
	return house_rect.has_point(Vector2(item.global_position.x, item.global_position.z))


func _pick_up(item: Grabbable) -> void:
	carried = item
	target = null
	item.freeze = true
	add_collision_exception_with(item)
	state = State.CARRYING


## Keeps what he carries over his head; a cop grabbing it takes it away.
func _carry() -> void:
	if not carried or not is_instance_valid(carried):
		carried = null
		return
	if carried.is_held():
		_release()
		return
	carried.global_position = global_position + Vector3.UP * ABOVE_HEAD


## On the roof rack, where it rests (and a cop can take it back down).
func _load() -> void:
	var item := carried
	_release()
	item.global_position = rack + Vector3(0, 0, (on_rack.size() - 1) * 0.6)
	item.linear_velocity = Vector3.ZERO
	on_rack.append(item)
	loaded.emit(item)
	if next_loot() == null:
		state = State.GONE
		visible = false
		collision_layer = 0
		_say("GUILTY_FLEES", 3.0)
		fled.emit()
		return
	_go_back(CARRY_EVERY)


## Drops it where he stands.
func _drop() -> void:
	var item := carried
	_release()
	if item:
		item.global_position = global_position + Vector3.UP * 0.5 + -global_basis.z * 0.6


func _release() -> void:
	if carried and is_instance_valid(carried):
		remove_collision_exception_with(carried)
		carried.freeze = false
	carried = null


func _go_back(then_wait: float) -> void:
	state = State.BACK
	_next_wait = then_wait
	_repath = 0.0


## A cop close by while he's outside his house.
func _blocked() -> bool:
	if house_rect.has_point(Vector2(global_position.x, global_position.z)):
		return false
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		if Vector2(cop.global_position.x - global_position.x, cop.global_position.z - global_position.z).length() < BLOCK:
			return true
	return false


## Waits at his window, greeting the cops who pass by.
func _stand(_delta: float) -> void:
	velocity.x = 0.0
	velocity.z = 0.0
	move_and_slide()
	if _since_line >= LINE_EVERY and _nearest_cop(8.0):
		_say(LINES[randi() % LINES.size()])


## Walks the navigation path toward `to`; true once within `reach` of it.
func _walk_to(to: Vector3, speed: float, delta: float, reach := REACH) -> bool:
	if Vector2(to.x - global_position.x, to.z - global_position.z).length() < reach:
		velocity.x = 0.0
		velocity.z = 0.0
		move_and_slide()
		return true
	_repath -= delta
	if _repath <= 0.0 or to.distance_to(_goal) > 0.3:
		_repath = REPATH
		_goal = to
		_path = NavigationServer3D.map_get_path(get_world_3d().navigation_map, global_position, to, true)
	while _path.size() > 1 and Vector2(_path[0].x - global_position.x, _path[0].z - global_position.z).length() < 0.2:
		_path = _path.slice(1)
	var wish := (_path[0] if not _path.is_empty() else to) - global_position
	wish.y = 0.0
	wish = wish.normalized() * speed
	velocity.x = wish.x
	velocity.z = wish.z
	if wish.length() > 0.01:
		rotation.y = atan2(wish.x, wish.z)
	move_and_slide()
	return false


func _nearest_cop(within: float) -> Cop:
	var best: Cop
	var best_distance := within
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		var d := global_position.distance_to(cop.global_position)
		if d < best_distance:
			best = cop
			best_distance = d
	return best


func said() -> String:
	return _bubble.text if _bubble.visible else ""


func _say(key: String, seconds := 3.0) -> void:
	_since_line = 0.0
	_bubble.text = key
	_bubble.show()
	var said_key := key
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if _bubble.text == said_key:
			_bubble.hide())
