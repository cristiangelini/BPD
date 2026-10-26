class_name CountPlan
extends Node3D

## The prison's count (carcel-recuento.md, step 2): LIST inmates on the list, each with a number on his jumpsuit
## (front and back), and the board with all their numbers in the yard. HIDDEN of them (by the seed) are not in the yard;
## the others are out in it from the start (YardInmate: most wander, some go round the ring, two play at the hoop and
## two lean on the east wall in the sun) and start moving when the first cop walks through the gate. The cook and the
## plumber, in clothes almost like the jumpsuit and with no number, wander among them. Step 3: E chalks a cross on one
## (CountInmate) and his number is crossed off the list; chalking the cook or the plumber is `wrong`: he's offended and
## wipes it off WIPE_AFTER seconds later. Every number here is (propuesta).

signal counted_one(number: int)
signal wrong_one(worker: CountInmate)

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
	for model in [COOK, PLUMBER]:
		workers.append(_inmate("Cook" if model == COOK else "Plumber", YardInmate.Activity.WANDER, 0, model))


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
func _number(inmate: CountInmate, number: int) -> void:
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


func _physics_process(_delta: float) -> void:
	if follower or started:
		return
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if prison.inside_walls(cop.global_position):
			start()
			return


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


## Every number on the list crossed off at once.
func all_counted() -> bool:
	return board.counted() == LIST
