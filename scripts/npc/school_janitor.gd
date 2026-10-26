class_name SchoolJanitor
extends CharacterBody3D

## Don Tito, the janitor of the Los Girasoles school (politico-escuela.md, step 6, decision 210). The deputy's rival paid
## him to hand out trap cards: while the deputy talks and answers questions he sweeps the hall and every SWEEP_EVERY
## goes into the classroom to "sweep" by a pupil's desk and swap their card for a trap; at recess he goes out to the
## playground and does the same every YARD_EVERY with a pupil playing there. His tells: the deck of cards sticking out
## of his overalls' pocket and violet ink on his fingers (a cop sees them within STAIN_REACH; the teacher's chalk and
## one pupil's violet paint can fool them), and the envelope from the rival in the shed's chest of drawers. Cuffed, he
## stops and E walks him to the patrol car (OwnerEscort). Online the host's janitor walks and swaps, and a guest's copy
## follows it (NpcSync). Every number here is (propuesta).

signal swapped(pupil: SchoolPupil)
signal cuffed_now(janitor: SchoolJanitor)

const MODEL := preload("res://assets/models/npc_conserje_escuela.glb")
const LINES := 4
const SAY_TIME := 4.0
const SPEED := 1.3
const ARRIVED := 0.3
const SWEEP_EVERY := 45.0
const YARD_EVERY := 20.0
## He swaps from this close.
const SWAP_REACH := 1.2
## A cop this close sees the ink on his fingers.
const STAIN_REACH := 2.0
const CUFFED_LINES := 3
## Stuck on something this long (a sandbox's edge), he skips to his next corner.
const STUCK_TIME := 3.0

var school: SchoolVisitLevel
var tour: SchoolTour
## Seconds until he goes for the next pupil.
var swap_left := SWEEP_EVERY
## The pupil he's going for, if any.
var target: SchoolPupil
var next_line := 0
var follower := false
var _path: Array[Vector3] = []
var _next_trap := 0
var _cuffed_left := 0.0
var _stuck_for := 0.0
var _rng := RandomNumberGenerator.new()
var _model: Node3D
var _bubble: Label3D
var _bubble_left := 0.0


func setup(the_school: SchoolVisitLevel, the_tour: SchoolTour, case_seed: int) -> void:
	school = the_school
	tour = the_tour
	_rng.seed = hash(["school janitor", case_seed])
	_next_trap = _rng.randi_range(0, SchoolQuestions.TRAP_KEYS - 1)
	tour.phase_changed.connect(_on_phase)


func _ready() -> void:
	add_to_group("school_adults")
	collision_layer = 8
	# Walls and floor only: he slips between the desks and the children.
	collision_mask = 1
	var shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.4
	shape.shape = capsule
	shape.position.y = 0.7
	add_child(shape)
	_model = MODEL.instantiate()
	_model.name = "Model"
	_model.rotation.y = PI
	add_child(_model)
	_bubble = MarketShopper.make_bubble()
	add_child(_bubble)
	add_child(stain_label("JANITOR_STAIN", 1.0))


## A line about someone's fingers, seen only up close (the janitor's ink, the teacher's chalk, a pupil's paint).
static func stain_label(key: String, height: float) -> CloseLabel:
	var label := CloseLabel.new()
	label.name = "Stain"
	label.text = key
	label.reach = STAIN_REACH
	label.font_size = 28
	label.outline_size = 6
	label.pixel_size = 0.003
	label.modulate = Color(0.75, 0.55, 1.0)
	label.position.y = height
	return label


## Whether a cop is within `reach` of `body`.
static func cop_within(body: Node3D, reach: float) -> bool:
	for cop: Node3D in body.get_tree().get_nodes_in_group("cops"):
		if cop.global_position.distance_to(body.global_position) < reach:
			return true
	return false


func is_janitor() -> bool:
	return true


func prompt_key(cop: Cop) -> String:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		return escort.prompt_key(cop)
	return "PROMPT_TALK_JANITOR"


func use(cop: Cop) -> void:
	var escort := OwnerEscort.of(self)
	if escort and escort.handles_use():
		escort.use(cop)
		return
	say("JANITOR_%d" % (next_line % LINES))
	next_line += 1


func cuffed(seconds: float) -> void:
	_cuffed_left = maxf(_cuffed_left, seconds)
	if follower:
		return
	_path.clear()
	target = null
	say("JANITOR_CUFFED_%d" % (next_line % CUFFED_LINES + 1))
	next_line += 1
	cuffed_now.emit(self)


func is_cuffed() -> bool:
	return _cuffed_left > 0.0


## Cuffed, walked away or in the car: he hands out nothing more.
func caught() -> bool:
	var escort := OwnerEscort.of(self)
	return is_cuffed() or (escort != null and (escort.in_car or escort.escorted_by != null))


## What a guest's copy needs besides where he is and what he says (NpcSync): cuffed.
func net_state() -> Array:
	return [is_cuffed()]


func apply_net_state(state: Variant) -> void:
	_cuffed_left = Handcuffs.SECONDS if state[0] else 0.0


func walking() -> bool:
	return not _path.is_empty()


## Swaps `pupil`'s card for a new trap (whatever they had, or nothing).
func swap(pupil: SchoolPupil) -> void:
	pupil.hold_card(SchoolQuestions.trap_key(_next_trap), true)
	_next_trap += 1
	pupil.say("PUPIL_NEW_CARD")
	swapped.emit(pupil)


func say(key: String, seconds := SAY_TIME) -> void:
	_bubble.text = key
	_bubble.show()
	_bubble_left = seconds


func said() -> String:
	return _bubble.text if _bubble.visible else ""


## What the escort calls (OwnerEscort): a line, and no complaint meter.
func _say(key: String, seconds := SAY_TIME) -> void:
	say(key, seconds)


func _raise(_points: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	_cuffed_left = maxf(_cuffed_left - delta, 0.0)
	if follower or caught():
		return
	if not _path.is_empty():
		_walk(delta)
		return
	_move(Vector3.ZERO, delta)
	if target:
		if target.global_position.distance_to(global_position) < SWAP_REACH + 0.5:
			swap(target)
		target = null
		_go_home()
		return
	if tour.phase in [SchoolTour.Phase.TALK, SchoolTour.Phase.RECESS, SchoolTour.Phase.QUESTIONS]:
		swap_left -= delta
		if swap_left <= 0.0:
			swap_left = YARD_EVERY if tour.phase == SchoolTour.Phase.RECESS else SWEEP_EVERY
			_go_for_a_pupil()


func _process(delta: float) -> void:
	var escort := OwnerEscort.of(self)
	_model.rotation.y = 0.0 if escort and (escort.escorted_by or escort.in_car) else PI
	if _bubble_left > 0.0:
		_bubble_left -= delta
		if _bubble_left <= 0.0:
			_bubble.hide()


## Picks a pupil without a trap where he is (the classroom, or the playground at recess) and walks up to them.
func _go_for_a_pupil() -> void:
	var yard := tour.phase == SchoolTour.Phase.RECESS
	var options: Array[SchoolPupil] = []
	for pupil in school.pupils:
		if not pupil.trap and not pupil.walking() and school.in_yard(pupil.global_position) == yard:
			options.append(pupil)
	if options.is_empty():
		return
	target = options[_rng.randi() % options.size()]
	var by := target.global_position + school.global_basis.x * SWAP_REACH
	if yard:
		_path = [by]
	else:
		_path = school.janitor_to_desk(target.desk)


## Back to where he waits: the hall, or the shed's door at recess and after the visit.
func _go_home() -> void:
	var in_yard := school.in_yard(global_position)
	var to_yard := tour.phase in [SchoolTour.Phase.RECESS, SchoolTour.Phase.PHOTO, SchoolTour.Phase.OVER]
	if in_yard and to_yard:
		_path = [school.to_global(SchoolVisitLevel.JANITOR_YARD)]
	elif in_yard:
		_path = school.janitor_to_hall()
	elif to_yard:
		_path = school.janitor_from_hall(global_position, true)
	else:
		_path = school.janitor_from_hall(global_position, false)


func _on_phase(_phase: SchoolTour.Phase) -> void:
	if caught() or follower:
		return
	target = null
	swap_left = YARD_EVERY if tour.phase == SchoolTour.Phase.RECESS else SWEEP_EVERY
	_go_home()


func _walk(delta: float) -> void:
	var to := _path[0] - global_position
	to.y = 0.0
	if to.length() < ARRIVED or _stuck_for > STUCK_TIME:
		_path.remove_at(0)
		_stuck_for = 0.0
		return
	var was := global_position
	_move(to.normalized() * SPEED, delta)
	_stuck_for = _stuck_for + delta if global_position.distance_to(was) < SPEED * delta * 0.2 else 0.0


func _move(wish: Vector3, delta: float) -> void:
	if wish.length() > 0.05:
		look_at(global_position + wish, Vector3.UP)
	velocity.x = wish.x
	velocity.z = wish.z
	velocity.y = 0.0 if is_on_floor() else velocity.y - GameScale.GRAVITY * delta
	move_and_slide()
