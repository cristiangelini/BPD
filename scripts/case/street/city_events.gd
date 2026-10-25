class_name CityEvents
extends Node3D

## The street events' director (ciudad-viva.md, "Los eventos"): one sequence at a time, never chaos. Every GAP_MIN to
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

var active: CityEvent
## Money the events paid this shift.
var earned := 0
var gap_left := 0.0
var _rng := RandomNumberGenerator.new()
var _toast: Label
var _toast_left := 0.0


func _ready() -> void:
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
func pay(money: int) -> void:
	earned += money
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
	if not start_snatch():
		gap_left = RETRY


## A walker for an event: NEAR_MIN to NEAR_MAX from the nearest cop, out of every cop's sight, walking.
func pick_walker() -> CityWalker:
	var cops := get_tree().get_nodes_in_group("cops")
	if cops.is_empty():
		return null
	var options: Array[CityWalker] = []
	for node in get_tree().get_nodes_in_group("city_walkers"):
		var walker := node as CityWalker
		if walker.is_stopped():
			continue
		var nearest := INF
		var seen := false
		for cop: Node3D in cops:
			var to := walker.global_position - cop.global_position
			nearest = minf(nearest, to.length())
			var facing := Vector2(-cop.global_basis.z.x, -cop.global_basis.z.z).normalized()
			seen = seen or facing.dot(Vector2(to.x, to.z).normalized()) > cos(deg_to_rad(LOOKING))
		if nearest >= NEAR_MIN and nearest <= NEAR_MAX and not seen:
			options.append(walker)
	return options[_rng.randi() % options.size()] if not options.is_empty() else null


## The alley nearest to `at`.
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
	snatch.begin(walker, nearest_alley(walker.global_position))
	_run(snatch)
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
