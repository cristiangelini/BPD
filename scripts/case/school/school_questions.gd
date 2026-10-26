class_name SchoolQuestions
extends Node

## The cards and the questions of the school visit (politico-escuela.md, step 4, decision 210). Each pupil gets a card
## with a question for the deputy; TRAPS of them are the janitor's, questions that sink him, drawn by the seed. In the
## questions, every time the tour says so (`question_time`), the hands go up (a trap always, the rest RAISE_ODDS of
## the time) and he gives the floor to one of them at random, or to the one a cop pointed at (`point_at`, step 5). The
## pupil reads the card out (a card taken from them while they read is no gaffe); READ_DELAY later he answers, or, if it was a trap, he stammers: a gaffe. With MAX_GAFFES
## he leaves ashamed and the case is lost. Step 5: a cop standing within POINT_REACH of him clicks with empty hands on
## a pupil with their hand up (`try_point`), and the next question is theirs, once every POINT_EVERY. Every number here
## is (propuesta).

signal asked(pupil: SchoolPupil)
signal gaffe(count: int)
## Too many gaffes: he's gone and the case is lost.
signal shamed

const TRAPS := 5
const MAX_GAFFES := 8
const RAISE_ODDS := 1.0 / 3.0
## How long the pupil reads before he reacts.
const READ_DELAY := 3.0
const ASK_KEYS := 12
const TRAP_KEYS := 8
const ANSWERS := 5
const STAMMERS := 5
const POINT_REACH := 1.5
## How far across the classroom a cop can point.
const POINT_RANGE := 15.0
const POINT_EVERY := 15.0

var school: SchoolVisitLevel
var tour: SchoolTour
var gaffes := 0
## Who's reading now (null with no one), and how long until he reacts.
var reading: SchoolPupil
var _react_left := 0.0
## The one a cop pointed at, who gets the next question.
var _pointed: SchoolPupil
var _point_left := 0.0
var _rng := RandomNumberGenerator.new()
var _label: Label


func setup(the_school: SchoolVisitLevel, the_tour: SchoolTour, case_seed: int) -> void:
	school = the_school
	tour = the_tour
	_rng.seed = hash(["school questions", case_seed])
	tour.phase_changed.connect(_on_phase)
	tour.question_time.connect(ask)


func _ready() -> void:
	_build_hud()
	deal()


## Hands out the cards: TRAPS traps, the rest innocent ones, all by the seed.
func deal() -> void:
	var desks := range(school.pupils.size())
	for i in range(desks.size() - 1, 0, -1):
		var j := _rng.randi_range(0, i)
		var swap: int = desks[i]
		desks[i] = desks[j]
		desks[j] = swap
	var ask_from := _rng.randi_range(0, ASK_KEYS - 1)
	var trap_from := _rng.randi_range(0, TRAP_KEYS - 1)
	for k in desks.size():
		var pupil := school.pupils[desks[k]]
		if k < TRAPS:
			pupil.hold_card(trap_key(trap_from + k), true)
		else:
			pupil.hold_card("SCHOOL_CARD_%d" % ((ask_from + k) % ASK_KEYS))


static func trap_key(index: int) -> String:
	return "SCHOOL_TRAP_%d" % (index % TRAP_KEYS)


func traps_left() -> int:
	return school.pupils.filter(func(p: SchoolPupil) -> bool: return p.trap).size()


## Hands up: every trap at their desk, and the rest RAISE_ODDS of the time.
func raise_hands() -> void:
	if tour.phase != SchoolTour.Phase.QUESTIONS:
		return
	for pupil in school.pupils:
		pupil.raise_hand(pupil.trap or _rng.randf() < RAISE_ODDS)


## The next question goes to this pupil if their hand is up (a cop pointed, step 5).
func point_at(pupil: SchoolPupil) -> bool:
	if not pupil.hand_up:
		return false
	_pointed = pupil
	return true


## "¿A ver, quién pregunta?": he gives the floor to someone with their hand up.
func ask() -> void:
	if tour.phase != SchoolTour.Phase.QUESTIONS or reading != null:
		return
	var pupil := _pointed if _pointed != null and _pointed.hand_up else null
	_pointed = null
	raise_hands()
	if pupil == null:
		var up := school.pupils.filter(func(p: SchoolPupil) -> bool: return p.hand_up)
		if up.is_empty():
			return
		pupil = up[_rng.randi() % up.size()]
	tour.politician.say("SCHOOL_LUSTRE_ASK", 2.0)
	pupil.read_card()
	reading = pupil
	_react_left = READ_DELAY
	asked.emit(pupil)


## A cop next to him points at the pupil they look at: theirs is the next question.
func try_point(cop: Cop) -> bool:
	if tour.phase != SchoolTour.Phase.QUESTIONS or _point_left > 0.0 or cop.get_node("Grabber").held \
			or cop.global_position.distance_to(tour.politician.global_position) > POINT_REACH:
		return false
	var hit := cop.aim_hit(POINT_RANGE)
	if hit.is_empty() or not hit.collider is SchoolPupil or not point_at(hit.collider):
		return false
	_point_left = POINT_EVERY
	tour.politician.say("SCHOOL_LUSTRE_POINTED", 2.0)
	return true


func _physics_process(delta: float) -> void:
	_show()
	_point_left = maxf(_point_left - delta, 0.0)
	if Input.is_action_just_pressed("grab"):
		for cop: Cop in get_tree().get_nodes_in_group("cops"):
			if cop.input_enabled:
				try_point(cop)
	if reading == null:
		return
	_react_left -= delta
	if _react_left <= 0.0:
		_react()


## He answers the question, or stammers if it was a trap.
func _react() -> void:
	var pupil := reading
	reading = null
	if tour.phase == SchoolTour.Phase.OVER:
		return
	if not pupil.has_card():
		tour.politician.say("SCHOOL_LUSTRE_NO_CARD")
		return
	if not pupil.trap:
		tour.politician.say("SCHOOL_LUSTRE_ANSWER_%d" % _rng.randi_range(1, ANSWERS))
		return
	gaffes += 1
	gaffe.emit(gaffes)
	_show()
	if gaffes >= MAX_GAFFES:
		tour.politician.say("SCHOOL_LUSTRE_SHAMED", 8.0)
		tour.abort()
		_put_hands_down()
		shamed.emit()
		return
	tour.politician.say("SCHOOL_LUSTRE_STAMMER_%d" % _rng.randi_range(1, STAMMERS))
	tour.hold(2.0)


func _on_phase(phase: SchoolTour.Phase) -> void:
	if phase != SchoolTour.Phase.QUESTIONS:
		_put_hands_down()


func _put_hands_down() -> void:
	for pupil in school.pupils:
		pupil.raise_hand(false)


func _build_hud() -> void:
	_label = Label.new()
	_label.name = "Gaffes"
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.add_theme_constant_override("outline_size", 6)
	# Under the visit's bar (SchoolTour).
	tour.hud_box.add_child(_label)
	_show()


func _show() -> void:
	_label.text = tr("HUD_SCHOOL_GAFFES") % [gaffes, MAX_GAFFES]
