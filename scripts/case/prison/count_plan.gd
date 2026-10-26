class_name CountPlan
extends Node3D

## The prison's count (carcel-recuento.md, step 2): LIST inmates on the list, each with a number on his jumpsuit
## (front and back), and the board with all their numbers in the yard. HIDDEN of them (by the seed) are not in the yard;
## the others are out in it from the start (YardInmate: most wander, some go round the ring, two play at the hoop and
## two lean on the east wall in the sun) and start moving when the first cop walks through the gate. The cook and the
## plumber, in clothes almost like the jumpsuit and with no number, wander among them. Step 3: E chalks a cross on one
## (CountInmate) and his number is crossed off the list; chalking the cook or the plumber is `wrong`: he's offended and
## wipes it off WIPE_AFTER seconds later. Step 4: CHEATERS of the wanderers (by the seed) rub their cross off on a
## wall now and then (CountInmate.cheater), and their numbers go back on the list (`rubbed`). Every number here is
## (propuesta). Step 5: the HIDDEN ones are each in one of the 8 hideouts (CountHideout, by the seed). E on the right
## one finds him (`found`): out he comes, chalked and counted, to wander the yard. Unfound, each runs for the gate in
## turn (RUN_FIRST seconds into the count, then RUN_EVERY apart; BlackoutInmate): cuffed and walked into a cell he's
## `caught`, and counted; at the gate he's `escaped`, crossed off as gone. Step 6: the count lasts TIME seconds
## (`ended`, the time is up) and is done when the whole list is crossed off at once (`completed`).

signal counted_one(number: int)
signal wrong_one(worker: CountInmate)
signal rubbed_one(number: int)
signal found_one(number: int)
signal escaped_one(count: int)
signal caught_one(count: int)
signal completed
signal ended

const LIST := 20
const HIDDEN := 3
const WANDERERS := 9
const RING := 4
const HOOP := 2
const SUN := 2
## Where the board stands (level space x, z), against the building's front, west of its doors.
const BOARD_AT := Vector2(-7.0, PrisonLevel.BUILDING_FRONT + 0.3)
const SUN_X := PrisonLevel.HALF_X - 0.6
const SUN_ZS: Array[float] = [11.0, 13.5]
const HOOP_SPOTS: Array[Vector2] = [Vector2(-10.0, 12.0), Vector2(-11.5, 11.5)]
const COOK := preload("res://assets/models/npc_cocinero.glb")
const PLUMBER := preload("res://assets/models/npc_plomero.glb")
## The number on the jumpsuit: on the chest and on the back.
const NUMBER_HEIGHT := 0.95
const NUMBER_OUT := 0.36
const WIPE_AFTER := 3.0
const CHEATERS := 2
## The hideouts: kind, where (level space x, z) and which way its front faces (radians about Y).
const HIDEOUTS := [
	[CountHideout.Kind.BIN, Vector2(-11.3, 6.8), PI / 2], [CountHideout.Kind.CART, Vector2(-11.0, 2.0), PI / 2],
	[CountHideout.Kind.MACHINE, Vector2(-11.5, -1.5), PI / 2], [CountHideout.Kind.BOXES, Vector2(-6.0, -6.4), 0.0],
	[CountHideout.Kind.SKIP, Vector2(12.6, 9.4), -PI / 2], [CountHideout.Kind.BALLS, Vector2(-12.9, 15.5), PI / 2],
	[CountHideout.Kind.KENNEL, Vector2(12.5, 17.5), -PI / 2], [CountHideout.Kind.MATTRESS, Vector2(6.0, 19.3), PI],
]
const RUN_FIRST := 90.0
const RUN_EVERY := 60.0
## Out of the canteen, the runners go through its nearest door.
const DOOR_IN := 6.5
const DOOR_OUT := 9.5
const GATE := Vector2(0.0, PrisonLevel.HALF_Z + 0.5)
const TIME := 360.0
const CHALK_LINES := 3

var prison: PrisonLevel
var board: CountBoard
## The inmates out in the yard, and each one's number (inmate -> number).
var inmates: Array[CountInmate] = []
var number_of := {}
## The numbers of the ones hidden somewhere in the prison (step 5).
var hidden: Array[int] = []
## The cook and the plumber.
var workers: Array[CountInmate] = []
var started := false
## Step 3: the workers chalked by mistake.
var wrong := 0
## Step 4: the two who rub their cross off, and how many times they did.
var cheaters: Array[CountInmate] = []
var rubbed := 0
## Step 5: the hideouts, the one each hidden number is in (number -> hideout), and how the hidden ones are doing.
var hideouts: Array[CountHideout] = []
var hidden_in := {}
var runners: Array[BlackoutInmate] = []
var found := 0
var caught := 0
var escaped := 0
var time := 0.0
var over := false
var _runs := 0
## A guest's copy (step 7): the host's one decides.
var follower := false
var _rng := RandomNumberGenerator.new()


func setup(level: PrisonLevel, case_seed: int) -> void:
	prison = level
	_rng.seed = hash(["prison count", case_seed])
	var list: Array[int] = []
	for i in LIST:
		list.append(i + 1)
	board = CountBoard.new()
	board.name = "CountBoard"
	board.position = Vector3(BOARD_AT.x, PrisonLevel.FLOOR_TOP, BOARD_AT.y)
	add_child(board)
	board.build(list)
	var shuffled := list.duplicate()
	_shuffle(shuffled)
	for number: int in shuffled.slice(0, HIDDEN):
		hidden.append(number)
	hidden.sort()
	var out: Array = shuffled.slice(HIDDEN)
	var activities: Array[int] = []
	for pair in [[YardInmate.Activity.WANDER, WANDERERS], [YardInmate.Activity.RING, RING],
			[YardInmate.Activity.HOOP, HOOP], [YardInmate.Activity.SUN, SUN]]:
		for i in pair[1]:
			activities.append(pair[0])
	var counts := {}
	for i in out.size():
		var activity: int = activities[i]
		var nth: int = counts.get(activity, 0)
		counts[activity] = nth + 1
		var inmate := _inmate("Inmate%02d" % out[i], activity, nth, YardInmate.MODEL)
		inmate.number = out[i]
		_number(inmate, out[i])
		number_of[inmate] = out[i]
		inmates.append(inmate)
	var wanderers := inmates.filter(func(inmate: CountInmate) -> bool:
		return inmate.activity == YardInmate.Activity.WANDER)
	_shuffle(wanderers)
	for i in CHEATERS:
		var cheater: CountInmate = wanderers[i]
		cheater.cheater = true
		# Not both at once.
		cheater.rub_left = CountInmate.RUB_EVERY * (1.0 + 0.5 * i)
		cheater.rubbed_off.connect(_on_rubbed_off)
		cheaters.append(cheater)
	for model in [COOK, PLUMBER]:
		workers.append(_inmate("Cook" if model == COOK else "Plumber", YardInmate.Activity.WANDER, 0, model))
	for i in HIDEOUTS.size():
		var hideout := CountHideout.new()
		hideout.name = "Hideout%d" % i
		hideout.kind = HIDEOUTS[i][0]
		hideout.position = Vector3(HIDEOUTS[i][1].x, PrisonLevel.FLOOR_TOP, HIDEOUTS[i][1].y)
		hideout.rotation.y = HIDEOUTS[i][2]
		add_child(hideout)
		hideout.searched.connect(_on_searched)
		hideouts.append(hideout)
	var spots := hideouts.duplicate()
	_shuffle(spots)
	for i in hidden.size():
		var hideout: CountHideout = spots[i]
		hideout.occupant = hidden[i]
		hidden_in[hidden[i]] = hideout


func _shuffle(list: Array) -> void:
	for i in range(list.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var swap: Variant = list[i]
		list[i] = list[j]
		list[j] = swap


## One of the people in the yard, standing where `activity` (its `nth` one) starts.
func _inmate(named: String, activity: int, nth: int, model: PackedScene) -> CountInmate:
	var inmate := CountInmate.new()
	inmate.name = named
	inmate.prison = prison
	inmate.model = model
	inmate.activity = activity as YardInmate.Activity
	inmate.wander_seed = _rng.randi()
	match activity:
		YardInmate.Activity.WANDER:
			var area := YardInmate.WANDER_AREA
			inmate.spot = Vector2(_rng.randf_range(area.position.x, area.end.x),
				_rng.randf_range(area.position.y, area.end.y))
			inmate.face = inmate.spot + Vector2(_rng.randf_range(-1, 1), _rng.randf_range(-1, 1))
		YardInmate.Activity.RING:
			inmate.ring_from = nth * YardInmate.RING_POINTS / RING
			inmate.spot = YardInmate.ring_point(inmate.ring_from)
			inmate.face = YardInmate.ring_point(inmate.ring_from + 1)
		YardInmate.Activity.HOOP:
			inmate.spot = HOOP_SPOTS[nth]
			inmate.face = Vector2(PrisonLevel.HOOP_AT.x, PrisonLevel.HOOP_AT.z)
		YardInmate.Activity.SUN:
			inmate.spot = Vector2(SUN_X, SUN_ZS[nth])
			inmate.face = inmate.spot - Vector2(1, 0)
	add_child(inmate)
	inmate.place()
	inmate.chalked.connect(_on_chalked)
	return inmate


## The inmate's number on his chest and his back.
func _number(inmate: Node3D, number: int) -> void:
	for side in [1, -1]:
		var label := Label3D.new()
		label.name = "Number" if side == 1 else "NumberBack"
		label.text = "%02d" % number
		label.font_size = 64
		label.pixel_size = 0.004
		label.modulate = Color.BLACK
		label.outline_modulate = Color.WHITE
		label.outline_size = 18
		label.position = Vector3(0, NUMBER_HEIGHT, side * NUMBER_OUT)
		label.rotation.y = 0.0 if side == 1 else PI
		label.double_sided = false
		inmate.add_child(label)


## The inmate wearing `number` out in the yard (null: hidden, or no such number).
func inmate_with(number: int) -> CountInmate:
	for inmate: CountInmate in number_of:
		if number_of[inmate] == number:
			return inmate
	return null


func _physics_process(delta: float) -> void:
	if follower:
		return
	if not started:
		for cop: Node3D in get_tree().get_nodes_in_group("cops"):
			if prison.inside_walls(cop.global_position):
				start()
				return
		return
	if over:
		return
	if all_counted():
		over = true
		completed.emit()
		return
	time += delta
	if time >= TIME:
		over = true
		ended.emit()
		return
	if _runs < hidden.size() and time >= RUN_FIRST + _runs * RUN_EVERY:
		var number := hidden[_runs]
		_runs += 1
		if hidden_in[number].occupant == number:
			run(number)


## Count time: everybody off to what they do.
func start() -> void:
	if started:
		return
	started = true
	var everybody: Array[CountInmate] = inmates + workers
	for i in everybody.size():
		everybody[i].start(i * 0.3)


## E on someone in the yard (on every PC; the host decides).
func _on_chalked(inmate: CountInmate, cop: Cop) -> void:
	if follower or inmate.marked:
		return
	inmate.set_marked(true)
	if inmate.is_worker():
		wrong += 1
		inmate.say("COUNT_COOK_OFFENDED" if inmate == workers[0] else "COUNT_PLUMBER_OFFENDED")
		cop.show_hint("HINT_COUNT_WORKER")
		get_tree().create_timer(WIPE_AFTER).timeout.connect(_wipe.bind(inmate))
		wrong_one.emit(inmate)
		return
	board.set_marked(inmate.number, true)
	inmate.say("COUNT_CHALKED_%d" % (inmate.number % CHALK_LINES))
	counted_one.emit(inmate.number)


## The offended worker wipes the cross off his back.
func _wipe(worker: CountInmate) -> void:
	if is_instance_valid(worker):
		worker.set_marked(false)


## A cheater rubbed his cross off: his number is back on the list.
func _on_rubbed_off(inmate: CountInmate) -> void:
	inmate.set_marked(false)
	board.set_marked(inmate.number, false)
	rubbed += 1
	rubbed_one.emit(inmate.number)


## E on a hideout (on every PC; the host decides): the one hiding in it comes out, counted.
func _on_searched(hideout: CountHideout, cop: Cop) -> void:
	if follower:
		return
	if hideout.occupant == 0:
		cop.show_hint("HINT_COUNT_EMPTY")
		return
	var number := hideout.occupant
	hideout.occupant = 0
	var inmate := _inmate("Inmate%02d" % number, YardInmate.Activity.WANDER, 0, YardInmate.MODEL)
	inmate.number = number
	_number(inmate, number)
	number_of[inmate] = number
	inmates.append(inmate)
	inmate.global_position = hideout.global_position + hideout.global_basis.z * 1.0
	inmate.start(0.0)
	inmate.set_marked(true)
	board.set_marked(number, true)
	inmate.say("COUNT_FOUND")
	found += 1
	for each: Cop in get_tree().get_nodes_in_group("cops"):
		each.show_hint("HINT_COUNT_FOUND")
	found_one.emit(number)


## The one hiding with `number` runs for the gate from his hideout.
func run(number: int) -> BlackoutInmate:
	var hideout: CountHideout = hidden_in[number]
	hideout.occupant = 0
	var at := hideout.global_position + hideout.global_basis.z * 1.0
	var local := prison.global_transform.affine_inverse() * at
	var way: Array[Vector2] = []
	if prison.in_canteen(at):
		var door := PrisonLevel.ENTRANCES[0] if local.x < 0.0 else PrisonLevel.ENTRANCES[1]
		way = [Vector2(door, DOOR_IN), Vector2(door, DOOR_OUT)]
	way.append(GATE)
	var runner := BlackoutInmate.new()
	runner.name = "Runner%02d" % number
	runner.role = BlackoutInmate.Role.GATE
	runner.glow_eyes = false
	runner.prison = prison
	runner.route = way
	runner.set_meta("number", number)
	add_child(runner)
	_number(runner, number)
	runner.global_position = at
	runner.active = true
	runner.say("COUNT_RUNNER")
	runner.escaped.connect(_on_runner_escaped)
	BlackoutEscort.to_block(runner, prison).boarded.connect(_on_caught.bind(runner))
	runners.append(runner)
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		cop.show_hint("HINT_COUNT_RUNNER")
	return runner


func _on_runner_escaped(runner: BlackoutInmate) -> void:
	escaped += 1
	board.set_escaped(runner.get_meta("number"))
	for cop: Cop in get_tree().get_nodes_in_group("cops"):
		cop.show_hint("HINT_COUNT_ESCAPED")
	escaped_one.emit(escaped)


func _on_caught(runner: BlackoutInmate) -> void:
	if runner.has_meta("caught"):
		return
	runner.set_meta("caught", true)
	caught += 1
	board.set_marked(runner.get_meta("number"), true)
	caught_one.emit(caught)


func time_left() -> float:
	return maxf(TIME - time, 0.0) if started else TIME


## Every number on the list crossed off at once (counted, or gone through the gate).
func all_counted() -> bool:
	return board.accounted() == LIST
