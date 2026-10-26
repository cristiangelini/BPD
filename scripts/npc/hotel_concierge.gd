class_name HotelConcierge
extends CharacterBody3D

## Don Bostezo, the Hotel Gran Siesta's concierge, as the raid's owner (hotel-allanamiento.md, "Don Bostezo y la
## mucama"). He spends the shift behind the desk answering everything with a yawn. Like Ramiro he fills the complaint
## meter (denuncia), calls his lawyer at 100 and lets two things slip when asked (R). His weak spot: a cop who tucks
## the little pillow on the desk under his head puts him to sleep for NAP seconds, and asleep he sees nothing. The bell
## wakes him at once, angry. After a nap he needs NAP_COOLDOWN seconds before he's sleepy again. He is innocent: he
## can't be knocked out or arrested. The model is the crime scene's (escena-hotel.md, step 2). Every number here is
## (propuesta).

signal complaint_changed(value: float)
signal lawyer_called
## A cop pushed him.
signal hurt
## He let slip where something is (asked with R): the line, already translated.
signal slipped(text: String)
signal fell_asleep
signal woke_up

const MODEL := preload("res://assets/models/npc_conserje.glb")
const MAX_COMPLAINT := 100.0
const STRUCK := 15.0
const DOOR_BROKEN := 5.0
## Seeing a vase or a lamp broken.
const SAW_BREAK := 10.0
## A cop took the master key from the board while he was awake.
const KEY_TAKEN := 5.0
## The bell woke him up.
const RUDE_BELL := 5.0
const ASKED := 5.0
const ASKS := 2
const CUFFED := 15.0
const ASK_COOLDOWN := 3.0
const NAP := 15.0
const NAP_COOLDOWN := 30.0
const SIGHT_RANGE := 10.0
const EYE := 1.4
const DECAY_EVERY := 5.0
const STRUCK_COOLDOWN := 1.0
const STRUCK_SPEED := 2.0
const TALK_RANGE := 6.0
const LINE_EVERY := 8.0
## His idle lines, the crime scene's (HOTEL_CONCIERGE_LINE_<n>).
const LINES := 4
## Asleep he slumps forward over the desk.
const SLUMP := 0.55

var complaint := 0.0
var has_called_lawyer := false
## What he lets slip when asked, in order (the case fills it, step 4).
var slips: Array[String] = []
var asked := 0
var _asleep_left := 0.0
var _nap_wait := 0.0
var _ask_wait := 0.0
var _quiet := 0.0
var _since_struck := STRUCK_COOLDOWN
var _since_line := 0.0
var _line := 0
## Cuffed by a cop: he stays at the desk until it runs out.
var _cuffed_left := 0.0
var _model: Node3D
var _bubble: Label3D


func _ready() -> void:
	collision_layer = 8
	collision_mask = 7
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.4
	capsule.height = 1.6
	shape.shape = capsule
	shape.position.y = 0.8
	add_child(shape)
	_model = MODEL.instantiate()
	add_child(_model)
	var bump := Area3D.new()
	bump.name = "Bump"
	bump.collision_layer = 0
	bump.collision_mask = 6
	var bump_shape := CollisionShape3D.new()
	var bump_capsule := CapsuleShape3D.new()
	bump_capsule.radius = 0.55
	bump_capsule.height = 1.4
	bump_shape.shape = bump_capsule
	bump_shape.position.y = 0.7
	bump.add_child(bump_shape)
	add_child(bump)
	bump.body_entered.connect(_on_bump)
	_bubble = Label3D.new()
	_bubble.name = "Bubble"
	_bubble.position = Vector3(0, 2.0, 0)
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.pixel_size = 0.004
	_bubble.outline_size = 10
	_bubble.font_size = 40
	_bubble.width = 600.0
	_bubble.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_bubble.hide()
	add_child(_bubble)


## E on him only does something while he's cuffed: a cop takes him away (OwnerEscort).
func prompt_key(cop: Cop) -> String:
	var escort := OwnerEscort.of(self)
	return escort.prompt_key(cop) if escort and escort.handles_use() else ""


func use(cop: Cop) -> void:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		escort.use(cop)


func cuffed(seconds: float) -> void:
	_wake()
	_cuffed_left = maxf(_cuffed_left, seconds)
	_raise(CUFFED)
	_say("NPC_POLICE_ABUSE")


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


func is_asleep() -> bool:
	return _asleep_left > 0.0


## A cop tucked the little pillow under his head: he sleeps NAP seconds, unless he napped too recently.
func tuck_pillow() -> bool:
	if is_asleep() or is_cuffed():
		return false
	if _nap_wait > 0.0:
		_say("HOTEL_CONCIERGE_NOT_SLEEPY")
		return false
	_asleep_left = NAP
	_model.rotation.x = SLUMP
	_say("HOTEL_CONCIERGE_ZZZ", NAP)
	fell_asleep.emit()
	return true


## Someone rang the bell on the desk: asleep, he wakes up angry; awake, he just yawns at it.
func ring_bell() -> void:
	if is_asleep():
		_wake()
		_raise(RUDE_BELL)
		_say("HOTEL_CONCIERGE_BELL_ANGRY")
	else:
		_say("HOTEL_CONCIERGE_BELL")


## R on him: a question. Asleep he only snores; awake he lets slip where something is, but only the first ASKS times.
func ask(_cop: Cop) -> bool:
	if _ask_wait > 0.0:
		return false
	if is_asleep():
		_say("HOTEL_CONCIERGE_ZZZ", 2.0)
		return false
	if slips.is_empty():
		_say("HOTEL_CONCIERGE_NOTHING")
		return false
	if asked >= ASKS or asked >= slips.size():
		_say("HOTEL_CONCIERGE_OFFENDED")
		return false
	_ask_wait = ASK_COOLDOWN
	_raise(ASKED)
	var line := slips[asked]
	asked += 1
	_say(line, 5.0)
	slipped.emit(line)
	return true


## The master key left the board: it counts only if he's awake.
func key_taken(_at: Vector3) -> bool:
	if is_asleep():
		return false
	_raise(KEY_TAKEN)
	_say("HOTEL_CONCIERGE_KEY")
	return true


## Pushed by a cop or hit by something thrown: that wakes him too.
func struck() -> bool:
	if _since_struck < STRUCK_COOLDOWN:
		return false
	_since_struck = 0.0
	_wake()
	_raise(STRUCK)
	_say("HOTEL_CONCIERGE_HURT")
	hurt.emit()
	return true


## A door came down with the ram: he hears it from anywhere in the hotel, and it wakes him.
func door_broken() -> void:
	_wake()
	_raise(DOOR_BROKEN)
	_say("HOTEL_CONCIERGE_DOOR")


## Something broke at `at`: it counts if he's awake and can see it.
func saw(at: Vector3, points: float) -> bool:
	if is_asleep():
		return false
	var eye := global_position + Vector3.UP * EYE
	if eye.distance_to(at) > SIGHT_RANGE:
		return false
	var query := PhysicsRayQueryParameters3D.create(eye, at, 1)
	query.exclude = [get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if not hit.is_empty() and (hit.position as Vector3).distance_to(at) > 0.4:
		return false
	_raise(points)
	_say("HOTEL_CONCIERGE_SAW")
	return true


func _physics_process(delta: float) -> void:
	_since_struck += delta
	_ask_wait -= delta
	_nap_wait -= delta
	_cuffed_left = maxf(_cuffed_left - delta, 0.0)
	_quiet += delta
	if _quiet >= DECAY_EVERY:
		_quiet = 0.0
		_set_complaint(complaint - 1.0)
	velocity.x = 0.0
	velocity.z = 0.0
	velocity.y = 0.0 if is_on_floor() else velocity.y - GameScale.GRAVITY * delta
	move_and_slide()
	if is_asleep():
		_asleep_left -= delta
		if _asleep_left <= 0.0:
			_end_nap()
			_say("HOTEL_CONCIERGE_WOKE")
		return
	var cop := _nearest_cop(TALK_RANGE)
	if cop:
		_face(cop.global_position)
	_since_line += delta
	if cop and _since_line >= LINE_EVERY:
		_say("HOTEL_CONCIERGE_LINE_%d" % (_line % LINES))
		_line += 1


func _wake() -> void:
	if is_asleep():
		_end_nap()


func _end_nap() -> void:
	_asleep_left = 0.0
	_nap_wait = NAP_COOLDOWN
	_model.rotation.x = 0.0
	_bubble.hide()
	woke_up.emit()


func _face(at: Vector3) -> void:
	var to := at - global_position
	to.y = 0.0
	if to.length() > 0.1:
		look_at(global_position + to, Vector3.UP, true)


func _nearest_cop(within: float) -> Cop:
	var best: Cop
	var best_distance := within
	for node in get_tree().get_nodes_in_group("cops"):
		var cop := node as Cop
		var d := global_position.distance_to(cop.global_position)
		if d < best_distance:
			best = cop
			best_distance = d
	return best


func _raise(points: float) -> void:
	_quiet = 0.0
	_set_complaint(complaint + points)


func _set_complaint(value: float) -> void:
	var clamped := clampf(value, 0.0, MAX_COMPLAINT)
	if clamped == complaint:
		return
	complaint = clamped
	complaint_changed.emit(complaint)
	if complaint >= MAX_COMPLAINT and not has_called_lawyer:
		has_called_lawyer = true
		_say("HOTEL_CONCIERGE_LAWYER")
		lawyer_called.emit()


func _on_bump(body: Node3D) -> void:
	var speed := 0.0
	if body is Cop:
		speed = (body as Cop).velocity.length()
	elif body is RigidBody3D:
		speed = (body as RigidBody3D).linear_velocity.length()
	if speed > STRUCK_SPEED:
		struck()


func _say(key: String, seconds := 3.0) -> void:
	_since_line = 0.0
	_bubble.text = key
	_bubble.show()
	var said := key
	get_tree().create_timer(seconds).timeout.connect(func() -> void:
		if _bubble.text == said:
			_bubble.hide())
