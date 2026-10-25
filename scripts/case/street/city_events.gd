class_name CityEvents
extends Node3D

## The street events' director (ciudad-viva.md, "Los eventos"), a child of the City at its origin, so its local space is
## the city's: one sequence at a time, never chaos. Every GAP_MIN to
## GAP_MAX seconds it picks an event and has it happen NEAR_MIN to NEAR_MAX meters from a cop, somewhere they're not
## looking. A finished event pays its money to the shift and the next one waits its gap. For now only in the test
## city, with the purse snatching. Every number here is (propuesta).

signal paid(money: int)

const GAP_MIN := 120.0
const GAP_MAX := 240.0
const NEAR_MIN := 30.0
const NEAR_MAX := 90.0
## A cop "looks" at a spot within this many degrees of where they face.
const LOOKING := 60.0
## No spot this time: try again in this many seconds.
const RETRY := 5.0
## A finished event stays this long (the cuffed thief, the thanks) before it goes.
const LINGER := 20.0
## Someone stopped and caught with something forbidden (CityWalker.busted).
const BUSTED_MONEY := 40

## Money the street events paid this shift, for the end of shift report (add_to); a new city starts it over.
static var shift_earned := 0

var active: CityEvent
## Money the events paid this shift.
var earned := 0
var gap_left := 0.0
var _rng := RandomNumberGenerator.new()
var _toast: Label
var _toast_left := 0.0


func _ready() -> void:
	shift_earned = 0
	_rng.randomize()
	gap_left = _rng.randf_range(GAP_MIN, GAP_MAX)
	var layer := CanvasLayer.new()
	layer.layer = 3
	add_child(layer)
	_toast = Label.new()
	_toast.anchor_left = 0.5
	_toast.anchor_right = 0.5
	_toast.offset_left = -200
	_toast.offset_right = 200
	_toast.offset_top = 80
	_toast.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_toast.add_theme_font_size_override("font_size", 32)
	_toast.add_theme_constant_override("outline_size", 8)
	_toast.add_theme_color_override("font_color", Color(0.45, 1, 0.5))
	_toast.hide()
	layer.add_child(_toast)


	for walker in get_tree().get_nodes_in_group("city_walkers"):
		watch(walker)


## Pays when `walker` is caught with something forbidden.
func watch(walker: CityWalker) -> void:
	if not walker.busted.is_connected(_on_busted):
		walker.busted.connect(_on_busted)


func _on_busted(_walker: CityWalker) -> void:
	pay(BUSTED_MONEY)


## Adds `money` to the shift and shows it.
## Adds the street events' money to an end of shift report, once (the campaign and the shift screen both ask),
## and starts it over.
static func add_to(report: Dictionary) -> void:
	if report.has("street"):
		return
	report.street = shift_earned
	report.total = int(report.get("total", 0)) + shift_earned
	if report.has("quota"):
		report.approved = report.total >= report.quota
	shift_earned = 0


func pay(money: int) -> void:
	earned += money
	shift_earned += money
	paid.emit(money)
	_toast.text = tr("EVENT_PAID") % money
	_toast_left = 3.0


func _process(delta: float) -> void:
	_toast_left = maxf(_toast_left - delta, 0.0)
	_toast.visible = _toast_left > 0.0


func _physics_process(delta: float) -> void:
	if active:
		return
	gap_left -= delta
	if gap_left > 0.0:
		return
	var roll := _rng.randi() % 3
	var started := start_snatch() if roll == 0 else (start_crash() if roll == 1 else start_flee())
	if not started:
		gap_left = RETRY


## Whether a cop sees `at` (within LOOKING of where they face) and how far the nearest cop is.
static func sight(at: Vector3, cops: Array) -> Dictionary:
	var nearest := INF
	var seen := false
	for cop: Node3D in cops:
		var to := at - cop.global_position
		nearest = minf(nearest, to.length())
		var facing := Vector2(-cop.global_basis.z.x, -cop.global_basis.z.z).normalized()
		seen = seen or facing.dot(Vector2(to.x, to.z).normalized()) > cos(deg_to_rad(LOOKING))
	return {"nearest": nearest, "seen": seen}


## Whether `at` is a good spot for an event: near a cop but out of everyone's sight.
func good_spot(at: Vector3) -> bool:
	var cops := get_tree().get_nodes_in_group("cops")
	if cops.is_empty():
		return false
	var look := sight(at, cops)
	return look.nearest >= NEAR_MIN and look.nearest <= NEAR_MAX and not look.seen


## A walker for an event: NEAR_MIN to NEAR_MAX from the nearest cop, out of every cop's sight, walking.
func pick_walker() -> CityWalker:
	var options: Array[CityWalker] = []
	for node in get_tree().get_nodes_in_group("city_walkers"):
		var walker := node as CityWalker
		if walker is CrashDriver or walker.is_stopped():
			continue
		if good_spot(walker.global_position):
			options.append(walker)
	return options[_rng.randi() % options.size()] if not options.is_empty() else null


## The alley nearest to `at`, in the city's space.
static func nearest_alley(at: Vector3) -> Array:
	var best: Array = CityLife.ALLEYS[0]
	for alley: Array in CityLife.ALLEYS:
		var mouth := CityLayout.block_center(alley[0])
		var old := CityLayout.block_center(best[0])
		if mouth.distance_to(at) < old.distance_to(at):
			best = alley
	return best


func start_snatch(walker: CityWalker = null) -> bool:
	walker = walker if walker else pick_walker()
	if not walker:
		return false
	var snatch := PurseSnatch.new()
	add_child(snatch)
	snatch.begin(walker, nearest_alley(to_local(walker.global_position)))
	_run(snatch)
	return true


## A crash at a crossing near a cop but out of sight, or at `at` (in the city's space). Returns false when there's no such crossing.
func start_crash(at := Vector3.INF) -> bool:
	if at == Vector3.INF:
		var options: Array[Vector3] = []
		for i in range(1, CityLayout.COLUMNS):
			for j in range(1, CityLayout.ROWS):
				var crossing := Vector3(CityLayout.street_x(i), 0, CityLayout.street_z(j))
				if good_spot(to_global(crossing)):
					options.append(crossing)
		if options.is_empty():
			return false
		at = options[_rng.randi() % options.size()]
	var crash := CityCrash.new()
	add_child(crash)
	crash.begin(at)
	_run(crash)
	return true


## A car running a red light from a crossing near a cop but out of sight, or from `at` (street column and row).
func start_flee(at := Vector2i(-1, -1)) -> bool:
	if at.x < 0:
		var options: Array[Vector2i] = []
		for i in range(1, CityLayout.COLUMNS):
			for j in range(1, CityLayout.ROWS):
				if good_spot(to_global(Vector3(CityLayout.street_x(i), 0, CityLayout.street_z(j)))):
					options.append(Vector2i(i, j))
		if options.is_empty():
			return false
		at = options[_rng.randi() % options.size()]
	var flee := FleeingCar.new()
	add_child(flee)
	flee.begin(at, _rng)
	_run(flee)
	return true


func _run(event: CityEvent) -> void:
	active = event
	event.finished.connect(_on_finished.bind(event))


func _on_finished(money: int, event: CityEvent) -> void:
	if money > 0:
		pay(money)
	active = null
	gap_left = _rng.randf_range(GAP_MIN, GAP_MAX)
	get_tree().create_timer(LINGER).timeout.connect(event.queue_free)
