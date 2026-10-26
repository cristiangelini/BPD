class_name GarbageTruck
extends Node3D

## Don Ruperto's garbage truck in the garbage truck jailbreak (docs/diseno/fuga-basura.md, step 3). At FIRST_AT and
## then every EVERY seconds (the seed moves both by up to SHIFT) it comes down the side street, turns into the station's
## street and stops with its hopper at the dumpster. Don Ruperto empties it (EMPTY seconds): the bags go, and so does
## every cop in the dumpster, in a bag or not. Then it backs up to the corner, turns and, around it, drops them on the
## sidewalk (DROP_AT): out. A cop he sees moving in the dumpster (MOVED metres in WATCH seconds) gives it away: he tells
## the guard, a catch. Every number here is (propuesta).
## Online the host drives it; the guests follow it (NpcSync) and seat the same riders (net_state).

signal emptied(riders: Array[Cop])
signal dropped(riders: Array[Cop])

const MODEL := preload("res://assets/models/garbage_truck.glb")
const DRIVER := preload("res://assets/models/npc_mudancero.glb")
const FIRST_AT := 180.0
const EVERY := 240.0
const SHIFT := 30.0
const SPEED := 6.0
const EMPTY := 4.0
const WATCH := 1.5
const MOVED := 0.25
const LINES := 4
## The station's lot space: the side street's lane, the station street's lane, out of sight down the side street,
## and the sidewalk around the corner where the riders land.
const SIDE_X := -36.0
const LANE_Z := 15.5
const AWAY_Z := 90.0
const DROP_AT: Array[Vector3] = [Vector3(-27.5, 0, 26.0), Vector3(-27.5, 0, 27.2), Vector3(-27.5, 0, 28.4),
	Vector3(-27.5, 0, 29.6)]
## Where the dumpster's contents ride, in the truck's space (the hopper, at the back).
const HOPPER := Vector3(0, 1.0, 2.9)

var station_lot: Transform3D
var dumpster: Dumpster
var guard: GarbageGuard
## Seconds to its next visit; "" (away), "coming", "emptying", "backing" (to the corner), "dropping" (around it) or
## "going".
var next_left := FIRST_AT
var stage := ""
var riders: Array[Cop] = []
var _path: Array[Vector3] = []
## Driving backwards (out of the station's street to the corner).
var _reverse := false
var _empty_left := 0.0
var _watched := {}
var _rng := RandomNumberGenerator.new()
var _bubble: Label3D
var _bubble_left := 0.0


func _ready() -> void:
	add_child(MODEL.instantiate())
	var driver := DRIVER.instantiate() as Node3D
	driver.position = Vector3(-0.55, 0.75, -3.0)
	driver.scale = Vector3.ONE * 0.9
	add_child(driver)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.position = Vector3(-1.4, 3.2, -3.0)
	_bubble.font_size = 48
	_bubble.outline_size = 12
	_bubble.visible = false
	add_child(_bubble)


## Its timetable for the case's seed; it waits out of sight.
func set_up(case_seed: int) -> void:
	_rng.seed = hash(["garbage truck", case_seed])
	next_left = FIRST_AT + _rng.randf_range(-SHIFT, SHIFT)
	_park_away()


func _park_away() -> void:
	stage = ""
	_path.clear()
	_reverse = false
	global_position = _at(Vector3(SIDE_X, 0, AWAY_Z))
	visible = false


func _at(local: Vector3) -> Vector3:
	return station_lot * local


## Where it stops: its hopper right at the dumpster.
func _stop_at() -> Vector3:
	var local := station_lot.affine_inverse() * dumpster.global_position
	return _at(Vector3(local.x + HOPPER.z, 0, LANE_Z))


func _physics_process(delta: float) -> void:
	if _bubble_left > 0.0:
		_bubble_left -= delta
		_bubble.visible = _bubble_left > 0.0
	match stage:
		"":
			next_left -= delta
			if next_left <= 0.0:
				come()
		"coming", "backing", "dropping", "going":
			_drive(delta)
		"emptying":
			_empty(delta)
	for cop in riders:
		if is_instance_valid(cop):
			cop.global_position = hold_point(cop)


## Comes now (also the debug panel's "the truck now").
func come() -> void:
	stage = "coming"
	visible = true
	_path = [_at(Vector3(SIDE_X, 0, LANE_Z)), _stop_at()]


func _drive(delta: float) -> void:
	if _path.is_empty():
		_arrived()
		return
	var to := _path[0] - global_position
	to.y = 0.0
	var step := SPEED * delta
	if to.length() > 0.01:
		global_basis = Basis.looking_at(-to.normalized() if _reverse else to.normalized())
	if to.length() > step:
		global_position += to.normalized() * step
		return
	global_position = _path.pop_front()
	if _path.is_empty():
		_arrived()


func _arrived() -> void:
	match stage:
		"coming":
			stage = "emptying"
			_empty_left = EMPTY
			_watched.clear()
			for cop in _in_dumpster():
				if cop.visible:
					_watched[cop] = cop.global_position
			say("GARBAGE_RUPERTO_%d" % _rng.randi_range(0, LINES - 1))
		"backing":
			# At the corner: forward down the side street, and the riders out around it.
			stage = "dropping"
			_reverse = false
			_path = [_at(Vector3(SIDE_X, 0, DROP_AT[0].z))]
		"dropping":
			_drop()
			stage = "going"
			_path = [_at(Vector3(SIDE_X, 0, AWAY_Z))]
		"going":
			_park_away()
			next_left = EVERY + _rng.randf_range(-SHIFT, SHIFT)


## Don Ruperto empties the dumpster. Anyone seen moving in it in the first WATCH seconds is caught.
func _empty(delta: float) -> void:
	_empty_left -= delta
	if EMPTY - _empty_left >= WATCH and not _watched.is_empty():
		for cop: Cop in _watched:
			if is_instance_valid(cop) and cop.global_position.distance_to(_watched[cop]) > MOVED:
				_watched.clear()
				say("GARBAGE_RUPERTO_MOVED", 5.0)
				if guard:
					guard.catch()
				_leave()
				return
		_watched.clear()
	if _empty_left <= 0.0:
		_take_it_all()
		_leave()


## Everything in the dumpster into the truck: the bags back to the guard's roll, and the cops ride along.
func _take_it_all() -> void:
	var got: Array[Cop] = []
	for cop in _in_dumpster():
		got.append(cop)
	for bag: GarbageBag in get_tree().get_nodes_in_group("garbage_bags"):
		if dumpster.contents.has(bag):
			if bag.hider and not got.has(bag.hider):
				got.append(bag.hider)
			bag.let_out(false)
			bag.put_away()
	dumpster.empty()
	for cop in got:
		seat(cop)
	emptied.emit(got)


func _in_dumpster() -> Array[Cop]:
	var found: Array[Cop] = []
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		var bag := cop.seated_in as GarbageBag
		if dumpster.contains(cop.global_position) or (bag and dumpster.contents.has(bag)):
			found.append(cop)
	return found


func _leave() -> void:
	stage = "backing"
	_reverse = true
	_path = [_at(Vector3(SIDE_X, 0, LANE_Z))]


## Around the corner: the riders land on the sidewalk, dirty but out.
func _drop() -> void:
	var out: Array[Cop] = riders.duplicate()
	for i in out.size():
		var cop: Cop = out[i]
		release(cop)
		cop.warp(Transform3D(station_lot.basis, _at(DROP_AT[i % DROP_AT.size()]) + Vector3.UP * 0.1))
		cop.show_hint("HINT_GARBAGE_CORNER", true)
	dropped.emit(out)


func seat(cop: Cop) -> void:
	if riders.has(cop):
		return
	riders.append(cop)
	cop.seated_in = self
	cop.tuck_away(true)


func release(cop: Cop) -> void:
	riders.erase(cop)
	if cop.seated_in == self:
		cop.seated_in = null
	cop.tuck_away(false)


## The riders, everyone (a catch).
func release_all() -> void:
	for cop in riders.duplicate():
		release(cop)


func hold_point(_cop: Cop) -> Vector3:
	return global_transform * HOPPER


## Riding in the back there's nothing to do but wait.
func prompt_key(_cop: Cop) -> String:
	return "PROMPT_TRUCK_RIDING"


func stand_up() -> void:
	pass


func say(key: String, seconds := 4.0) -> void:
	_bubble.text = key
	_bubble.visible = true
	_bubble_left = seconds


## Online: its stage and who rides it (NpcSync).
func net_state() -> Variant:
	return [stage, visible, riders.map(func(cop: Cop) -> String: return cop.net_id())]


func apply_net_state(state: Variant) -> void:
	stage = state[0]
	visible = state[1]
	var names: Array = state[2]
	for cop in riders.duplicate():
		if not names.has(cop.net_id()):
			release(cop)
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		if names.has(cop.net_id()):
			seat(cop)
