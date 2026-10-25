class_name BribeGuard
extends NightGuard

## The night guard of the bribe jailbreak (docs/diseno/fuga-soborno.md, step 1): awake at his desk, the cells' key on
## his belt, no donuts, and a face that says he sells himself. E on a locked cell's bars calls him ("¡Psst!"): he walks
## over to that door and says his price. A wad of bills in hand, E on the bars pays it to him; he counts it (COUNT_TIME)
## and keeps it, and what he's paid adds up, wad by wad and cop by cop. Paid in full, he "drops" the key, kicking it
## under the door into the cell, and goes back to his desk to read the paper, his back to the cells. Left waiting at the
## bars with nothing for WAIT_TIME, he goes back too. Every number here is (propuesta).

## His price, in steps of PRICE_STEP, never more than the money they have.
const PRICE_MIN := 200
const PRICE_MAX := 500
const PRICE_STEP := 50
const WALK_SPEED := 1.6
## Seconds he counts a wad, and waits at the bars for one.
const COUNT_TIME := 2.0
const WAIT_TIME := 15.0
## Where he stands at each cell's door and the way there around the desk, in the station's lot space.
const DOOR_FRONT_Z := 5.3
const DESK_SIDE_Z := 8.4
const DESK_SIDE: Array[float] = [8.8, 12.2]
## Where the key lands, just inside the door.
const KEY_IN := 0.5
const COMING_LINES := 3
const BORED_LINES := 2
const DEAL_LINES := 3

## The station's lot and the cell doors (the level sets them).
var station_lot: Transform3D
var cell_doors: Array[CellDoor] = []
var price := 0
## What he's been paid so far (it stays his).
var paid := 0
## "" (at his desk), "coming" (to a cell's door), "at_bars", "counting", "back" (to his desk) or "reading" (paid).
var stage := ""
## The cell whose door he's going to or standing at (-1: none).
var at_cell := -1
## The wad he's counting and how long he has left, and how long he's been waiting at the bars.
var counting_left := 0.0
var _counting := 0
var _wait_left := 0.0
## The last thing he said, as its text key and the number in it, so a guest shows the same.
var line := ""
var line_number := 0
var _desk_spot: Transform3D
var _path: Array[Vector3] = []


## The guard for this jailbreak's seed, with `money` among the cops: his price, the key on his belt, and where he
## stands now is his desk.
func stand_guard(case_seed: int, money: int) -> void:
	_rng.seed = hash(["bribe guard", case_seed])
	key_on_belt = true
	price = price_for(case_seed, money)
	_desk_spot = global_transform


## His price for `case_seed`: PRICE_MIN to PRICE_MAX, in steps of PRICE_STEP, but no more than `money` rounded down.
static func price_for(case_seed: int, money: int) -> int:
	var steps := (PRICE_MAX - PRICE_MIN) / PRICE_STEP
	var asked := PRICE_MIN + PRICE_STEP * (hash(["bribe price", case_seed]) % (steps + 1))
	return maxi(PRICE_MIN, mini(asked, money / PRICE_STEP * PRICE_STEP))


## No donuts on duty.
func eat() -> void:
	eat_left = EAT_EVERY


## The key stays on his belt until he's paid: there's nothing to take from him.
func prompt_key(_cop: Cop) -> String:
	return ""


func use(_cop: Cop) -> void:
	pass


func is_paid() -> bool:
	return paid >= price


## What E on a locked cell's door does without the key, as a text key ("" for nothing): call him from his desk, or pay
## him with a wad in hand while he waits at that door.
func door_prompt(door: CellDoor, cop: Cop) -> String:
	if is_paid():
		return ""
	var held: Node = cop.get_node("Grabber").held
	if held is BillWad:
		return "PROMPT_PAY_GUARD" if stage == "at_bars" and cell_doors.find(door) == at_cell else ""
	return "PROMPT_CALL_GUARD" if stage == "" and not held else ""


## E on the door (every PC does it, and lets go of the wad; the host decides).
func door_use(door: CellDoor, cop: Cop) -> void:
	if door_prompt(door, cop) == "":
		return
	var held: Node = cop.get_node("Grabber").held
	if held is BillWad:
		cop.get_node("Grabber").release()
	if not multiplayer.is_server():
		return
	if held is BillWad:
		take(held as BillWad)
	else:
		called_from(cell_doors.find(door))


## Called from cell `cell`'s door: he walks over, around the desk.
func called_from(cell: int) -> void:
	if stage != "" or is_paid() or cell < 0:
		return
	at_cell = cell
	stage = "coming"
	_path = [_at(Vector3(DESK_SIDE[cell], 0, DESK_SIDE_Z)), _at(Vector3(_door_x(cell), 0, DOOR_FRONT_Z))]
	_say("BRIBE_GUARD_COMING_%d" % _rng.randi_range(0, COMING_LINES - 1))


## A wad through the bars: he keeps it and counts it.
func take(wad: BillWad) -> void:
	if stage != "at_bars":
		return
	_counting = wad.amount
	counting_left = COUNT_TIME
	stage = "counting"
	wad.queue_free()
	_say("BRIBE_GUARD_COUNTING")


func _physics_process(delta: float) -> void:
	if not multiplayer.is_server():
		_tick_bubble(delta)
		return
	match stage:
		"coming", "back":
			_tick_bubble(delta)
			_walk(delta)
			_watch(delta)
		"at_bars":
			_tick_bubble(delta)
			_wait_left -= delta
			if _wait_left <= 0.0:
				_say("BRIBE_GUARD_BORED_%d" % _rng.randi_range(0, BORED_LINES - 1))
				_go_back()
			_watch(delta)
		"counting":
			_tick_bubble(delta)
			counting_left -= delta
			if counting_left <= 0.0:
				_counted()
		"reading":
			# His back to the cells, the paper up: he doesn't look (step 3: until the page is over).
			_tick_bubble(delta)
		_:
			super(delta)


## The wad counted: it adds up, and paid in full he drops the key; short, he says how much is missing and waits.
func _counted() -> void:
	paid += _counting
	_counting = 0
	if is_paid():
		_drop_key()
		_say("BRIBE_GUARD_DEAL_%d" % _rng.randi_range(0, DEAL_LINES - 1), 5.0)
		_go_back()
		return
	stage = "at_bars"
	_wait_left = WAIT_TIME
	_say("BRIBE_GUARD_SHORT", 5.0, price - paid)


## "Oops, I dropped the key": kicked under the door, just inside the cell.
func _drop_key() -> void:
	key_on_belt = false
	var key: CellKey = KEY_SCENE.instantiate()
	get_parent().add_child(key)
	key.global_position = _at(Vector3(_door_x(at_cell), 0.1, StationRooms.CELL_FRONT_Z - KEY_IN))


func _go_back() -> void:
	stage = "back"
	_path = [_at(Vector3(DESK_SIDE[maxi(at_cell, 0)], 0, DESK_SIDE_Z)), _desk_spot.origin]


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
	if stage == "coming":
		# Facing the cell's door.
		global_basis = _desk_spot.basis
		stage = "at_bars"
		_wait_left = WAIT_TIME
		_say("BRIBE_GUARD_PRICE", 6.0, price - paid)
		return
	if is_paid():
		# Back at his desk with the paper, his back to the cells.
		global_transform = Transform3D(_desk_spot.basis.rotated(Vector3.UP, PI), _desk_spot.origin)
		stage = "reading"
		return
	global_transform = _desk_spot
	stage = ""
	at_cell = -1


## Says the text key `key`, with `number` in it when it has one (its translation has a %d).
func _say(key: String, seconds := BUBBLE_TIME, number := 0) -> void:
	line = key
	line_number = number
	say(tr(key) % number if number else key, seconds)


func _door_x(cell: int) -> float:
	var door := StationRooms.CELL_DOORS[cell]
	return (door.x + door.y) / 2.0


func _at(local: Vector3) -> Vector3:
	return station_lot * Vector3(local.x, (station_lot.affine_inverse() * _desk_spot.origin).y + local.y, local.z)


## Online (NpcSync): on top of the night guard's, where he is, what he's been paid and what he said.
func net_state() -> Variant:
	var state: Array = super()
	state.append_array([stage, at_cell, price, paid, global_transform, line, line_number])
	return state


func apply_net_state(state: Variant) -> void:
	super(state)
	var base: int = state.size() - 7
	stage = state[base]
	at_cell = state[base + 1]
	price = state[base + 2]
	paid = state[base + 3]
	global_transform = state[base + 4]
	if state[base + 5] != line or state[base + 6] != line_number:
		line = state[base + 5]
		line_number = state[base + 6]
		if line != "":
			say(tr(line) % line_number if line_number else line)
