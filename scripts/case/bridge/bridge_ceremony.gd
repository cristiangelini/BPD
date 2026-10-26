class_name BridgeCeremony
extends Node

## Deputy Lustre opens the bridge (politico-puente.md, step 2, decision 178), the clock of the case: he waits at the
## foot of the west ramp for his guard and starts when the first cop gets within START_REACH of him. Then he walks up
## onto the deck and across it with PHOTOS stops for the photo (BridgePark.STOPS), PHOTO_TIME each: he greets, poses
## and, JUMP_AT into the stop, jumps for the photo ("¡Firme como mis promesas!"; `jumped`, which step 3 makes break the
## weakest piece near him). After the last stop he walks to the ribbon at the east end, cuts it and `finished` goes
## off: the shift ends there (step 5). A bar at the top of the screen shows how far he is. `hold` leaves him to
## someone else (his dip in the canal, step 3) and stops the clock. Every number here is (propuesta).

signal started
## He's at photo stop `index`.
signal arrived(index: int)
## He jumped for the photo at stop `index`, over the deck at `at` (world space).
signal jumped(index: int, at: Vector3)
signal finished

enum State { WAITING, WALKING, POSING, RIBBON, OVER }

const START_REACH := 25.0
const WAIT_EVERY := 15.0
const SPEED := 1.0
const ARRIVED := 0.3
const PHOTO_TIME := 50.0
## He greets this long into a stop and jumps this long into it.
const JUMP_AT := 30.0
const JUMP_SPEED := 3.0
const RIBBON_TIME := 6.0
const POSES := 4

var politician: Politician
var park: BridgePark
var state := State.WAITING
## The stop he's at or walking to (BridgePark.STOPS index); STOPS.size() means the ribbon.
var stop := 0
## Seconds he still stays at the stop (or at the ribbon).
var stop_left := 0.0
## Seconds he stays where he is no matter what (his dip, step 3).
var hold_left := 0.0
var bar: ProgressBar
## Online, a guest's ceremony: the host's decides where he is (step 6).
var follower := false
var _path: Array[Vector3] = []
var _wait_left := 0.0
var _jumped := false
var _jump_now := false
var _state: Label


func setup(the_park: BridgePark, speaker: Politician) -> void:
	park = the_park
	politician = speaker


func _ready() -> void:
	_build_hud()


func start() -> void:
	if state != State.WAITING:
		return
	politician.say("BRIDGE_LUSTRE_START")
	_walk_to(_stop_point(0))
	_path.push_front(park.to_global(BridgePark.RAMP_TOP_WEST))
	started.emit()


## Stops him where he is for `seconds` (his dip); the stop's clock waits too.
func hold(seconds: float) -> void:
	hold_left = maxf(hold_left, seconds)


func release() -> void:
	hold_left = 0.0


## He's back on the deck at `at` after his dip (step 3): he walks again to where he was going, and poses again
## from the start if he was at a stop.
func back_on(at: Vector3) -> void:
	politician.global_position = at
	politician.velocity = Vector3.ZERO
	hold_left = 0.0
	if state == State.POSING or state == State.WALKING:
		if stop < BridgePark.STOPS.size():
			_walk_to(_stop_point(stop))
		else:
			_walk_to(park.to_global(Vector3(BridgePark.RIBBON_X - 0.6, BridgePark.DECK_TOP, 0)))


## He leaves for good: the ceremony ends without the ribbon.
func abort() -> void:
	state = State.OVER
	hold_left = 0.0


## How many photos he's had taken (the ribbon counts as one more).
func done() -> int:
	return mini(stop, BridgePark.STOPS.size() + 1)


func _physics_process(delta: float) -> void:
	if follower:
		_show()
		return
	if hold_left > 0.0:
		hold_left -= delta
		_show()
		return
	match state:
		State.WAITING:
			_wait(delta)
		State.WALKING:
			if _follow_path(delta):
				_arrive()
		State.POSING:
			_posing(delta)
		State.RIBBON:
			stop_left -= delta
			_move(Vector3.ZERO, delta)
			if stop_left <= 0.0:
				state = State.OVER
				stop += 1
				politician.say("BRIDGE_LUSTRE_END")
				finished.emit()
		State.OVER:
			_move(Vector3.ZERO, delta)
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
	if stop >= BridgePark.STOPS.size():
		state = State.RIBBON
		stop_left = RIBBON_TIME
		_face(park.to_global(Vector3(BridgePark.RIBBON_X + 1.0, 0, 0)))
		politician.say("BRIDGE_LUSTRE_RIBBON")
		return
	state = State.POSING
	stop_left = PHOTO_TIME
	_jumped = false
	# For the photo, he faces the crowd on the west bank's side of the canal (+Z, the street).
	_face(politician.global_position + park.global_basis.z)
	politician.say("BRIDGE_LUSTRE_POSE_%d" % (stop % POSES + 1))
	arrived.emit(stop)


func _posing(delta: float) -> void:
	stop_left -= delta
	if not _jumped and PHOTO_TIME - stop_left >= JUMP_AT:
		_jumped = true
		_jump_now = true
		politician.say("BRIDGE_LUSTRE_JUMP")
		jumped.emit(stop, politician.global_position)
	_move(Vector3.ZERO, delta)
	if stop_left > 0.0:
		return
	stop += 1
	if stop < BridgePark.STOPS.size():
		_walk_to(_stop_point(stop))
	else:
		_walk_to(park.to_global(Vector3(BridgePark.RIBBON_X - 0.6, BridgePark.DECK_TOP, 0)))


## Where he stands at stop `index`, in world space.
func _stop_point(index: int) -> Vector3:
	return park.to_global(Vector3(BridgePark.STOPS[index], BridgePark.DECK_TOP, 0))


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
	if _jump_now:
		_jump_now = false
		politician.velocity.y = JUMP_SPEED
	elif politician.is_on_floor():
		politician.velocity.y = 0.0
	else:
		politician.velocity.y -= GameScale.GRAVITY * delta
	politician.move_and_slide()


func _build_hud() -> void:
	var hud := CanvasLayer.new()
	hud.name = "CeremonyHud"
	var box := VBoxContainer.new()
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	box.offset_top = 12.0
	var title := Label.new()
	title.text = "HUD_BRIDGE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_constant_override("outline_size", 6)
	box.add_child(title)
	bar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(320, 18)
	bar.max_value = BridgePark.STOPS.size() + 1
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
	if park == null:
		return
	bar.value = done()
	match state:
		State.WAITING:
			_state.text = "HUD_BRIDGE_WAITING"
		State.RIBBON:
			_state.text = "HUD_BRIDGE_RIBBON"
		State.OVER:
			_state.text = "HUD_BRIDGE_OVER"
		_:
			_state.text = tr("HUD_BRIDGE_PHOTO") % [mini(stop + 1, BridgePark.STOPS.size()), BridgePark.STOPS.size()]
