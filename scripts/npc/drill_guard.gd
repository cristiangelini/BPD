class_name DrillGuard
extends NightGuard

## The day guard of the fire drill jailbreak (docs/diseno/fuga-simulacro.md, step 1): at his desk watching the cells,
## with the cells' key on his belt and no donuts. Smoke he sees coming out of a cell's heater (CellHeater) raises his
## suspicion SMOKE_SUSPICION a second ("¿Qué están quemando ahí?"). Step 2: the drill (start_drill, end_drill).
## Step 3: in the drill a prisoner is an orange vest. He counts the vests every COUNT_EVERY seconds and, short of
## them, walks among the people looking at faces; he knows a cop in uniform at a glance and one in a coat or a hat
## only from close up; a vest on the floor is a clue, and a vest getting into the patrol car is a catch.
## Every number here is (propuesta).

const SMOKE_SUSPICION := 20.0
const SMOKE_LINES := 3
## The smoke is a cloud over the heater: he sees it if he sees any of these points of it (the cell's bars hide some).
const SMOKE_CLOUD: Array[Vector3] = [Vector3(0, 0.85, 0), Vector3(0, 1.4, 0), Vector3(0, 2.0, 0), Vector3(0.3, 1.4, 0.3),
	Vector3(-0.3, 1.4, 0.3)]

## His way in the drill, in the station's lot space: in front of each cell's door, out through the guard room and the
## front door, and the meeting point on the sidewalk.
const WALK_SPEED := 1.6
const DOOR_FRONT_Z := 5.3
const TO_STREET: Array[Vector3] = [Vector3(6.6, 0, 6.4), Vector3(5.2, 0, 6.4), Vector3(0, 0, 7.5), Vector3(0, 0, 10.0)]
const MEETING_AT := Vector3(2.5, 0, 11.4)

## The count (step 3): how often, the suspicion when vests are missing, and the people he stops by looking at faces.
const COUNT_EVERY := 20.0
const COUNT_SHORT := 25.0
const SEARCH_STOPS := 3
## He knows a cop in a coat or a hat this close (m) after this long (s).
const KNOW_REACH := 2.0
const KNOW_TIME := 3.0
## A suspicion rate that catches at once.
const CATCH_NOW := 1.0e9
const COUNT_OK_LINES := 2
const COUNT_SHORT_LINES := 3
const KNOW_LINES := 3

## The station's lot and the cell doors (the level sets them).
var station_lot: Transform3D
var cell_doors: Array[CellDoor] = []
## "" (at his desk), "opening" (the cells), "leading" (everyone out), "at_point", "searching" (looking at faces) or
## "back".
var stage := ""
var _desk_spot: Transform3D
var _path: Array[Vector3] = []
var _saw_smoke := false
## The patrol car the cops escape in (the level sets it).
var patrol_car: PatrolCar
var _count_left := COUNT_EVERY
## Disguised cop -> seconds he's had them close in sight.
var _close := {}
var _saw_vest := false
## What he says when he catches someone at once (in the car, or knowing a face).
var _catch_line := ""
## The tick being watched (s), for how long he's had a face close up.
var _tick := 0.0


## The guard for this jailbreak's seed, the key on his belt.
func stand_guard(case_seed: int) -> void:
	_rng.seed = hash(["drill guard", case_seed])
	key_on_belt = true


## No donuts on duty.
func eat() -> void:
	eat_left = EAT_EVERY


## What he sees, plus the smoke of a heater with a blanket on it. In the drill, what a prisoner looks like then.
func alarm() -> float:
	if drill_on():
		return _drill_alarm()
	var rate := super()
	var smoke := false
	for heater: CellHeater in get_tree().get_nodes_in_group("cell_heaters"):
		if heater.is_smoking() and _sees_smoke(heater):
			smoke = true
	if smoke and not _saw_smoke:
		say("DRILL_GUARD_SMOKE_%d" % _rng.randi_range(0, SMOKE_LINES - 1))
	_saw_smoke = smoke
	return rate + (SMOKE_SUSPICION if smoke else 0.0)


## A vest is fine, except getting into the patrol car where he sees it; a cop in uniform he sees is a cop out of
## his cell; one in a coat or a hat he only knows from KNOW_REACH, after KNOW_TIME. A vest on the floor is a clue.
func _drill_alarm() -> float:
	var rate := 0.0
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		var in_car := patrol_car != null and patrol_car.seat_of(cop) >= 0
		var chest := cop.global_position + Vector3.UP
		if not cop.visible or not (sees(chest, cop) or (in_car and sees(chest, patrol_car))):
			_close.erase(cop)
			continue
		if cop.disguise.has("prison_vest"):
			if in_car:
				_catch_line = "DRILL_GUARD_CAR"
				return CATCH_NOW
			continue
		if not cop.is_disguised("public"):
			rate += SUSPICION_COP
			continue
		if _flat(cop.global_position).length() > KNOW_REACH:
			_close.erase(cop)
			continue
		_close[cop] = _close.get(cop, 0.0) + _tick
		if _close[cop] >= KNOW_TIME:
			_catch_line = "DRILL_GUARD_KNOW_YOU_%d" % _rng.randi_range(0, KNOW_LINES - 1)
			return CATCH_NOW
	var vest := false
	for clue: Node in get_tree().get_nodes_in_group("guard_clues"):
		if clue is DisguisePiece and sees((clue as Node3D).global_position + Vector3.UP * 0.05, clue as CollisionObject3D):
			vest = true
	if vest and not _saw_vest:
		say("DRILL_GUARD_VEST_FLOOR")
	_saw_vest = vest
	return rate + (SUSPICION_CLUE if vest else 0.0)


## The count at the meeting point: every orange vest he sees is a prisoner. Short of them, he gets suspicious and
## walks among the people looking at faces.
func count() -> void:
	var cops := get_tree().get_nodes_in_group("cops")
	var vests := cops.filter(func(cop: Cop) -> bool:
		return cop.disguise.has("prison_vest") and sees(cop.global_position + Vector3.UP, cop)).size()
	if vests >= cops.size():
		say("DRILL_GUARD_COUNT_OK_%d" % _rng.randi_range(0, COUNT_OK_LINES - 1))
		return
	say("DRILL_GUARD_COUNT_SHORT_%d" % _rng.randi_range(0, COUNT_SHORT_LINES - 1), 5.0)
	suspicion = minf(suspicion + COUNT_SHORT, 100.0)
	if suspicion >= 100.0:
		catch()
		return
	stage = "searching"
	_path.clear()
	var people := get_tree().get_nodes_in_group("waiting_people")
	for i in mini(SEARCH_STOPS, people.size()):
		# Right in front of someone, on the street's side.
		var person: Node3D = people[_rng.randi_range(0, people.size() - 1)]
		var at := person.global_position + station_lot.basis * Vector3(0, 0, 0.9)
		_path.append(Vector3(at.x, global_position.y, at.z))
	_path.append(_at(MEETING_AT))


func _watch(delta: float) -> void:
	_tick = delta
	super(delta)


func _sees_smoke(heater: CellHeater) -> bool:
	return SMOKE_CLOUD.any(func(at: Vector3) -> bool: return sees(heater.global_transform * at))


## The drill (step 2): he blows the whistle, opens both cells and leads everyone out to the meeting point on the
## sidewalk, where he stands with his list facing the station; at the end he walks back to his desk.
func start_drill() -> void:
	_desk_spot = global_transform
	stage = "opening"
	_path = [_at(Vector3(_door_x(0), 0, DOOR_FRONT_Z))]
	_count_left = COUNT_EVERY
	_close.clear()
	_saw_vest = false
	say("DRILL_GUARD_WHISTLE", 5.0)


func end_drill() -> void:
	stage = "back"
	var back := TO_STREET.duplicate()
	back.reverse()
	_path.assign(back.map(_at))
	_path.append(_desk_spot.origin)
	say("DRILL_GUARD_ALL_IN", 5.0)


func is_drilling() -> bool:
	return stage != ""


## The drill is on: from the whistle until he says "todos adentro" (walking back he's the day guard again).
func drill_on() -> bool:
	return stage != "" and stage != "back"


func _physics_process(delta: float) -> void:
	if not is_drilling():
		super(delta)
		return
	_tick_bubble(delta)
	_walk(delta)
	if stage == "at_point" or stage == "searching":
		_count_left -= delta
		if _count_left <= 0.0:
			_count_left = COUNT_EVERY
			count()
	if is_drilling():
		_watch(delta)


func _walk(delta: float) -> void:
	if _path.is_empty():
		return
	var to := _path[0] - global_position
	to.y = 0.0
	var step := WALK_SPEED * delta
	if to.length() > 0.01:
		global_basis = Basis.looking_at(-to.normalized())
	look = 0.0
	_model.rotation.y = 0.0
	if to.length() > step:
		global_position += to.normalized() * step
		return
	global_position = Vector3(_path[0].x, global_position.y, _path[0].z)
	_path.pop_front()
	if _path.is_empty():
		_arrived()


func _arrived() -> void:
	match stage:
		"opening":
			# At a cell's door: open it, and on to the other one, then out.
			var cell := 0 if (station_lot.affine_inverse() * global_position).x < StationRooms.CELL_SPLIT_X else 1
			cell_doors[cell].unlock()
			cell_doors[cell].set_open(true)
			if cell == 0:
				_path = [_at(Vector3(_door_x(1), 0, DOOR_FRONT_Z))]
			else:
				stage = "leading"
				say("DRILL_GUARD_LINE_UP", 5.0)
				_path.assign(TO_STREET.map(_at))
				_path.append(_at(MEETING_AT))
		"leading", "searching":
			stage = "at_point"
			# Facing the station and everyone in front of it.
			global_basis = Basis.looking_at(station_lot.basis * Vector3(0, 0, 1))
		"back":
			global_transform = _desk_spot
			stage = ""


func _door_x(cell: int) -> float:
	var door := StationRooms.CELL_DOORS[cell]
	return (door.x + door.y) / 2.0


func _at(local: Vector3) -> Vector3:
	return station_lot * Vector3(local.x, (station_lot.affine_inverse() * _desk_spot.origin).y, local.z)


## Online (NpcSync): on top of the night guard's, where he is in the drill and the cell doors he opened.
func net_state() -> Variant:
	var state: Array = super()
	state.append(stage)
	for door in cell_doors:
		state.append_array([door.locked, door.is_open])
	return state


func apply_net_state(state: Variant) -> void:
	super(state)
	var base: int = state.size() - 1 - cell_doors.size() * 2
	stage = state[base]
	for i in cell_doors.size():
		var door := cell_doors[i]
		door.locked = state[base + 1 + i * 2]
		if door.is_open != bool(state[base + 2 + i * 2]):
			door.set_open(state[base + 2 + i * 2])


## Caught someone in the drill: it's over, and he's back at his desk (the level puts everyone back).
func catch() -> void:
	if is_drilling():
		_path.clear()
		global_transform = _desk_spot
		stage = ""
	super()
	if _catch_line != "":
		say(_catch_line, 5.0)
		_catch_line = ""
	_close.clear()
