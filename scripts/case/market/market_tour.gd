class_name MarketTour
extends Node

## Deputy Lustre's walk through the market (politico-mercado.md, step 2, decision 120), the clock of the case: he waits
## outside the way in for his guard and starts when the first cop gets within START_REACH of him. Then he walks the
## U-shaped aisle stall by stall (MarketLevel.stalls, in order) and stops STOP_TIME at each: he greets, the vendor
## offers a sample and, at the end of the stop, he tastes it (`tasting`; the plate and what he says: MarketSamples).
## After the last stall he walks to the ribbon at the way out, has his photo taken and `finished` goes off: the shift ends
## there (step 6). A bar at the top of the screen shows how many stalls are done. `hold` stops him where he is (the
## toilet run, step 4). Every number here is (propuesta).

signal started
## He's at stall `index` and the vendor offers him a sample.
signal arrived(index: int)
## The stop at stall `index` is over and he eats what's in his hand.
signal tasting(index: int)
signal finished

enum State { WAITING, WALKING, STOPPED, PHOTO, OVER }

const START_REACH := 25.0
const WAIT_EVERY := 15.0
const SPEED := 1.0
const ARRIVED := 0.4
const STOP_TIME := 30.0
## He greets this long into a stop, then the vendor offers.
const OFFER_AT := 6.5
const PHOTO_TIME := 5.0
const GREETS := 6
const YUMS := 4

var politician: Politician
var market: MarketLevel
var state := State.WAITING
## The stall he's at or walking to (MarketLevel.stalls index); stalls.size() means the ribbon.
var stall := 0
## Seconds he still stays at the stall (or at the ribbon).
var stop_left := 0.0
## Seconds he stays where he is no matter what (the toilet run, step 4).
var hold_left := 0.0
var bar: ProgressBar
## Online, a guest's tour: the host's decides where he is (later step).
var follower := false
var _path: Array[Vector3] = []
var _wait_left := 0.0
var _offered := false
var _rng := RandomNumberGenerator.new()
var _state: Label


func setup(the_market: MarketLevel, speaker: Politician, case_seed: int) -> void:
	market = the_market
	politician = speaker
	_rng.seed = hash(["market tour", case_seed])


func _ready() -> void:
	_build_hud()


func start() -> void:
	if state != State.WAITING:
		return
	politician.say("MARKET_LUSTRE_START")
	_walk_to(market.to_global(Vector3(MarketLevel.ENTRANCE_X, 0, MarketLevel.HALF_Z - 1.5)))
	_path.append(_stop_point(0))
	started.emit()


## Stops him where he is for `seconds` (the toilet run); the stall's clock waits too.
func hold(seconds: float) -> void:
	hold_left = maxf(hold_left, seconds)


func walking() -> bool:
	return state == State.WALKING


## How many stalls he's done.
func done() -> int:
	return mini(stall, market.stalls.size())


func _physics_process(delta: float) -> void:
	if follower:
		_show()
		return
	if hold_left > 0.0:
		hold_left -= delta
		_move(Vector3.ZERO, delta)
		_show()
		return
	match state:
		State.WAITING:
			_wait(delta)
		State.WALKING:
			if _follow_path(delta):
				_arrive()
		State.STOPPED:
			_stopped(delta)
		State.PHOTO:
			stop_left -= delta
			if stop_left <= 0.0:
				state = State.OVER
				politician.say("MARKET_LUSTRE_END")
				finished.emit()
	_show()


func _wait(delta: float) -> void:
	for cop: Node3D in get_tree().get_nodes_in_group("cops"):
		if cop.global_position.distance_to(politician.global_position) < START_REACH:
			start()
			return
	_wait_left -= delta
	if _wait_left <= 0.0:
		_wait_left = WAIT_EVERY
		politician.say("POLITICIAN_WAITING")
	_move(Vector3.ZERO, delta)


func _arrive() -> void:
	if stall >= market.stalls.size():
		state = State.PHOTO
		stop_left = PHOTO_TIME
		_face(politician.global_position + market.global_basis.z)
		politician.say("MARKET_LUSTRE_PHOTO")
		return
	state = State.STOPPED
	stop_left = STOP_TIME
	_offered = false
	_face(market.to_global(market.stalls[stall].at))
	politician.say("MARKET_LUSTRE_GREET_%d" % _rng.randi_range(1, GREETS))


func _stopped(delta: float) -> void:
	stop_left -= delta
	_move(Vector3.ZERO, delta)
	if not _offered and STOP_TIME - stop_left >= OFFER_AT:
		_offered = true
		(market.stalls[stall].vendor as MarketVendor).say("VENDOR_OFFER")
		arrived.emit(stall)
	if stop_left > 0.0:
		return
	tasting.emit(stall)
	stall += 1
	if stall < market.stalls.size():
		_walk_to(_stop_point(stall))
	else:
		_walk_to(market.to_global(market.photo_spot()))


## Where he stands at stall `index`, in world space.
func _stop_point(index: int) -> Vector3:
	return market.to_global(market.stalls[index].stop)


func _walk_to(at: Vector3) -> void:
	state = State.WALKING
	_path = [at]


## Walks along _path; true once at its end.
func _follow_path(delta: float) -> bool:
	var to := _path[0] - politician.global_position
	to.y = 0.0
	if to.length() < ARRIVED:
		_path.remove_at(0)
		if _path.is_empty():
			_move(Vector3.ZERO, delta)
			return true
		return false
	_move(to.normalized() * SPEED, delta)
	return false


func _face(at: Vector3) -> void:
	var flat := Vector3(at.x, politician.global_position.y, at.z)
	if flat.distance_to(politician.global_position) > 0.05:
		politician.look_at(flat, Vector3.UP)


func _move(wish: Vector3, delta: float) -> void:
	if wish.length() > 0.05:
		politician.look_at(politician.global_position + wish, Vector3.UP)
	politician.velocity.x = wish.x
	politician.velocity.z = wish.z
	politician.velocity.y = 0.0 if politician.is_on_floor() else politician.velocity.y - GameScale.GRAVITY * delta
	politician.move_and_slide()


func _build_hud() -> void:
	var hud := CanvasLayer.new()
	hud.name = "TourHud"
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	box.offset_top = 12.0
	var title := Label.new()
	title.text = "HUD_TOUR"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_constant_override("outline_size", 6)
	box.add_child(title)
	bar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(320, 18)
	bar.max_value = MarketLevel.STALLS.size()
	bar.show_percentage = false
	bar.modulate = Color(0.45, 0.65, 1)
	box.add_child(bar)
	_state = Label.new()
	_state.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_state.add_theme_constant_override("outline_size", 6)
	box.add_child(_state)
	hud.add_child(box)
	add_child(hud)


func _show() -> void:
	if market == null:
		return
	bar.value = done()
	match state:
		State.WAITING:
			_state.text = "HUD_TOUR_WAITING"
		State.PHOTO:
			_state.text = "HUD_TOUR_PHOTO"
		State.OVER:
			_state.text = "HUD_TOUR_OVER"
		_:
			_state.text = tr("HUD_TOUR_STALL") % [mini(stall + 1, market.stalls.size()), market.stalls.size()]
