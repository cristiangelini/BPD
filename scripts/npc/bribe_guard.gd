class_name BribeGuard
extends NightGuard

## The night guard of the bribe jailbreak (docs/diseno/fuga-soborno.md, step 1): awake at his desk, the cells' key on
## his belt, no donuts, and a face that says he sells himself. E on a locked cell's bars calls him ("¡Psst!"): he walks
## over to that door and says his price. A wad of bills in hand, E on the bars pays it to him; he counts it (COUNT_TIME)
## and keeps it, and what he's paid adds up, wad by wad and cop by cop. Paid in full, he "drops" the key, kicking it
## under the door into the cell, and goes back to his desk to read the paper, his back to the cells. Left waiting at the
## bars with nothing for WAIT_TIME, he goes back too.
## Step 2: the corridor's camera (CorridorCamera). If it looks at the cell while he counts, he gives the wad back and
## gets suspicious ("¿Con la cámara? ¿Estás loco?"). With empty hands at the bars, E haggles: the price drops
## HAGGLE_DROP, up to HAGGLES times, and each time his suspicion rises HAGGLE_SUSPICION.
## Step 3: the paper. Paid, he reads a page (PAGE_MIN to PAGE_MAX seconds, from the seed) with his back to the cells:
## he doesn't look, but he hears (something thrown landing, NOISE_SUSPICION; a cop running out of the cells near him,
## RUN_SUSPICION a second). When the page is over he turns around, and a cop he sees out of the cells is a catch. A
## catch doesn't give the money back ("La plata no se devuelve"): it counts for the next try, but the price rises
## PRICE_RISE. Every number here is (propuesta).

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
## Haggling (step 2) and the camera catching him counting.
const HAGGLES := 3
const HAGGLE_DROP := 50
const HAGGLE_SUSPICION := 15.0
const CAMERA_SUSPICION := 10.0
## Where he holds the wad he counts, in his own space.
const HAND := Vector3(0.25, 1.0, 0.35)
## The paper (step 3) and what he hears behind it.
const PAGE_MIN := 25.0
const PAGE_MAX := 35.0
const NOISE_SUSPICION := 15.0
const RUN_SUSPICION := 20.0
const QUIET_SPEED := (GameScale.WALK_SPEED + GameScale.RUN_SPEED) / 2.0
const PRICE_RISE := 100
const HEARD_LINES := 3
## The paper he holds up while he reads, in his own space (placeholder: a grey sheet).
const PAPER_AT := Vector3(0, 1.55, 0.3)
const PAPER_SIZE := Vector2(1.1, 0.7)
const COMING_LINES := 3
const HAGGLE_LINES := 3
const CAMERA_LINES := 3
const BORED_LINES := 2
const DEAL_LINES := 3

## The station's lot and the cell doors (the level sets them).
var station_lot: Transform3D
var cell_doors: Array[CellDoor] = []
## The corridor's camera (the level sets it; none, no camera).
var camera: CorridorCamera
## Times they haggled.
var haggles := 0
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
var _wad: BillWad
## How long a page takes him, and how long he has left of this one.
var page := PAGE_MIN
var reading_left := 0.0
var _paper: MeshInstance3D
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
	page = snappedf(_rng.randf_range(PAGE_MIN, PAGE_MAX), 0.5)
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
	if held:
		return ""
	if stage == "at_bars" and cell_doors.find(door) == at_cell:
		return "PROMPT_HAGGLE" if haggles < HAGGLES else ""
	return "PROMPT_CALL_GUARD" if stage == "" else ""


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
	elif stage == "at_bars":
		haggle()
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


## A wad through the bars: he counts it in his hand.
func take(wad: BillWad) -> void:
	if stage != "at_bars":
		return
	_counting = wad.amount
	_wad = wad
	wad.freeze = true
	wad.global_position = global_transform * HAND
	counting_left = COUNT_TIME
	stage = "counting"
	_say("BRIBE_GUARD_COUNTING")


## "Come on, we're colleagues": the price drops, and he likes being rushed less each time. Down to what he's been paid,
## it's a deal.
func haggle() -> void:
	if stage != "at_bars" or haggles >= HAGGLES:
		return
	haggles += 1
	price = maxi(price - HAGGLE_DROP, HAGGLE_DROP)
	suspicion = minf(suspicion + HAGGLE_SUSPICION, 100.0)
	_wait_left = WAIT_TIME
	if is_paid():
		_deal()
		return
	_say("BRIBE_GUARD_HAGGLE_%d" % _rng.randi_range(0, HAGGLE_LINES - 1), 5.0, price - paid)
	if suspicion >= 100.0:
		catch()


## The camera on the cell while he counts: the wad back through the bars, and he's suspicious.
func _refuse() -> void:
	if is_instance_valid(_wad):
		_wad.freeze = false
		_wad.global_position = _at(Vector3(_door_x(at_cell), 0.3, StationRooms.CELL_FRONT_Z - KEY_IN))
	_wad = null
	_counting = 0
	stage = "at_bars"
	_wait_left = WAIT_TIME
	suspicion = minf(suspicion + CAMERA_SUSPICION, 100.0)
	_say("BRIBE_GUARD_CAMERA_%d" % _rng.randi_range(0, CAMERA_LINES - 1), 5.0)
	if suspicion >= 100.0:
		catch()


func _ready() -> void:
	super()
	_paper = MeshInstance3D.new()
	_paper.name = "Paper"
	var sheet := BoxMesh.new()
	sheet.size = Vector3(PAPER_SIZE.x, PAPER_SIZE.y, 0.02)
	_paper.mesh = sheet
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.85, 0.84, 0.78)
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	# Lit by his desk lamp: it shows in the dark from the cells.
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_paper.material_override = material
	_paper.position = PAPER_AT
	_paper.visible = false
	add_child(_paper)


func _physics_process(delta: float) -> void:
	_paper.visible = stage == "reading"
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
			if camera and camera.watching(at_cell):
				_refuse()
			elif counting_left <= 0.0:
				_counted()
		"reading":
			# His back to the cells, the paper up: he doesn't look, but he hears.
			_tick_bubble(delta)
			_listen(delta)
			_hear_running(delta)
			reading_left -= delta
			if suspicion >= 100.0:
				catch()
			elif reading_left <= 0.0:
				look_back()
		_:
			super(delta)


## The wad counted: it adds up, and paid in full he drops the key; short, he says how much is missing and waits.
func _counted() -> void:
	paid += _counting
	_counting = 0
	if is_instance_valid(_wad):
		_wad.queue_free()
	_wad = null
	if is_paid():
		_deal()
		return
	stage = "at_bars"
	_wait_left = WAIT_TIME
	_say("BRIBE_GUARD_SHORT", 5.0, price - paid)


func _deal() -> void:
	_drop_key()
	_say("BRIBE_GUARD_DEAL_%d" % _rng.randi_range(0, DEAL_LINES - 1), 5.0)
	_go_back()


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
		reading_left = page
		return
	global_transform = _desk_spot
	stage = ""
	at_cell = -1


## Something landed (heard_throw): behind the paper he doesn't turn his head, but he gets suspicious.
func look_at_noise(at: Vector3, seconds: float, text: String) -> void:
	if stage != "reading":
		super(at, seconds, text)
		return
	suspicion = minf(suspicion + NOISE_SUSPICION, 100.0)
	_say("BRIBE_GUARD_HEARD_%d" % _rng.randi_range(0, HEARD_LINES - 1))


## A cop running out of the cells within earshot, while he reads.
func _hear_running(delta: float) -> void:
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		var body := cop as CharacterBody3D
		if not body or not outside_cells.call(cop.global_position) or _flat(cop.global_position).length() > HEAR_RANGE:
			continue
		if Vector2(body.velocity.x, body.velocity.z).length() > QUIET_SPEED:
			suspicion = minf(suspicion + RUN_SUSPICION * delta, 100.0)


## The page is over: he turns around to the cells, and anyone he sees out of them is a catch. Then he's an ordinary
## guard at his desk, watching.
func look_back() -> void:
	global_transform = _desk_spot
	stage = ""
	reading_left = 0.0
	look = 0.0
	_model.rotation.y = 0.0
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if outside_cells.call(cop.global_position) and sees(cop.global_position + Vector3.UP, cop as CollisionObject3D):
			catch()
			_say("BRIBE_GUARD_LOOKED_BACK", 5.0)
			return
	_say("BRIBE_GUARD_PAGE_OVER")


## After a catch (the level puts everyone back): at his desk with the key on his belt again, the money he got still
## his, and a higher price.
func after_catch() -> void:
	global_transform = _desk_spot
	stage = ""
	at_cell = -1
	reading_left = 0.0
	_path.clear()
	if is_instance_valid(_wad):
		_wad.freeze = false
	_wad = null
	_counting = 0
	key_on_belt = true
	price += PRICE_RISE
	_say("BRIBE_GUARD_KEEPS_IT", 5.0)


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
	state.append_array([stage, at_cell, price, paid, global_transform, line, line_number, haggles, reading_left])
	return state


func apply_net_state(state: Variant) -> void:
	super(state)
	var base: int = state.size() - 9
	haggles = state[base + 7]
	reading_left = state[base + 8]
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
