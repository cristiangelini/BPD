class_name SchoolTour
extends Node

## Deputy Lustre's visit to the Los Girasoles school (politico-escuela.md, step 3, decision 210), the clock of the
## case. He waits on the sidewalk for his guard and starts when the first cop gets within START_REACH of him. Then:
## the talk at the blackboard (TALK_TIME, a line every LINE_EVERY), recess in the playground (RECESS_TIME, the pupils
## run out and he goes from one to another for a selfie), the questions back in the classroom (QUESTIONS_TIME; every
## QUESTION_EVERY `question_time` goes off, for step 4 to pick who asks) and the group photo on the sidewalk, after
## which `finished` goes off. The talk, the questions and the photo count from when he gets to his place; recess counts
## from the bell. A bar at the top of the screen shows how much of the visit is done. Every number here is (propuesta).

signal started
signal phase_changed(phase: Phase)
## Time for the next question (step 4 picks a raised hand).
signal question_time
signal finished

enum Phase { WAITING, TALK, RECESS, QUESTIONS, PHOTO, OVER }

const START_REACH := 25.0
const WAIT_EVERY := 15.0
const SPEED := 1.0
const ARRIVED := 0.4
const TALK_TIME := 120.0
const RECESS_TIME := 120.0
const QUESTIONS_TIME := 180.0
const PHOTO_TIME := 5.0
const LINE_EVERY := 12.0
const QUESTION_EVERY := 15.0
## At recess, a selfie with another pupil this often.
const SELFIE_EVERY := 12.0
## The pupils leave their desk one after another, this far apart.
const FILE_GAP := 0.5
const TALK_LINES := 8
const RECESS_LINES := 6

var politician: Politician
var school: SchoolVisitLevel
var phase := Phase.WAITING
## Seconds left of the phase; it only runs once he's in place (`placed`), but recess's runs from the bell.
var phase_left := 0.0
var placed := false
## Seconds he stays where he is no matter what (later steps).
var hold_left := 0.0
var bar: ProgressBar
## The box at the top of the screen with the bar; the questions add their gaffe count under it (step 4).
var hud_box: VBoxContainer
## Online, a guest's tour: the host's decides where he is (later step).
var follower := false
var _path: Array[Vector3] = []
var _wait_left := 0.0
var _line_left := 0.0
var _question_left := 0.0
var _selfie_left := 0.0
var _next_line := 0
var _rng := RandomNumberGenerator.new()
var _state: Label


func setup(the_school: SchoolVisitLevel, speaker: Politician, case_seed: int) -> void:
	school = the_school
	politician = speaker
	_rng.seed = hash(["school tour", case_seed])
	_next_line = _rng.randi_range(0, TALK_LINES - 1)


func _ready() -> void:
	_build_hud()


func start() -> void:
	if phase != Phase.WAITING:
		return
	politician.say("SCHOOL_LUSTRE_START")
	started.emit()
	_enter(Phase.TALK, school.deputy_in())


## Stops him where he is for `seconds`; the clock waits too.
func hold(seconds: float) -> void:
	hold_left = maxf(hold_left, seconds)


## He leaves for good (too many gaffes, step 4): the visit ends without the photo.
func abort() -> void:
	phase = Phase.OVER
	_path.clear()


func walking() -> bool:
	return not _path.is_empty()


## How much of the visit is done, from 0 to 1 (the talk, recess and the questions).
func progress() -> float:
	var total := TALK_TIME + RECESS_TIME + QUESTIONS_TIME
	match phase:
		Phase.WAITING:
			return 0.0
		Phase.TALK:
			return (TALK_TIME - phase_left) / total
		Phase.RECESS:
			return (TALK_TIME + RECESS_TIME - phase_left) / total
		Phase.QUESTIONS:
			return (total - phase_left) / total
	return 1.0


func _physics_process(delta: float) -> void:
	if follower:
		_show()
		return
	if hold_left > 0.0:
		hold_left -= delta
		_move(Vector3.ZERO, delta)
		_show()
		return
	if phase == Phase.WAITING:
		_wait(delta)
		_show()
		return
	if phase == Phase.OVER:
		_move(Vector3.ZERO, delta)
		_show()
		return
	if not _path.is_empty():
		if _follow_path(delta):
			_arrived()
	else:
		_move(Vector3.ZERO, delta)
	if (placed and not (phase == Phase.PHOTO and _pupils_walking())) or phase == Phase.RECESS:
		phase_left -= delta
		_during(delta)
		if phase_left <= 0.0:
			_next()
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


## A new phase: he walks `path` and its clock is set (it starts now for recess, once he's there for the rest).
func _enter(next: Phase, path: Array[Vector3]) -> void:
	phase = next
	_path = path
	placed = false
	phase_left = {Phase.TALK: TALK_TIME, Phase.RECESS: RECESS_TIME, Phase.QUESTIONS: QUESTIONS_TIME,
		Phase.PHOTO: PHOTO_TIME}.get(next, 0.0)
	_line_left = 0.0
	_question_left = QUESTION_EVERY
	_selfie_left = SELFIE_EVERY
	phase_changed.emit(phase)


## He got where the phase wanted him.
func _arrived() -> void:
	if placed:
		return
	placed = true
	match phase:
		Phase.TALK, Phase.QUESTIONS:
			_face(school.to_global(SchoolVisitLevel.STAGE + Vector3.BACK))
			if phase == Phase.QUESTIONS:
				politician.say("SCHOOL_LUSTRE_QUESTIONS")
		Phase.RECESS:
			politician.say("SCHOOL_LUSTRE_YARD")
		Phase.PHOTO:
			_face(school.to_global(SchoolVisitLevel.PHOTO_DEPUTY + Vector3.BACK))
			politician.say("SCHOOL_LUSTRE_PHOTO")


func _during(delta: float) -> void:
	match phase:
		Phase.TALK:
			_line_left -= delta
			if _line_left <= 0.0:
				_line_left = LINE_EVERY
				politician.say("SCHOOL_LUSTRE_TALK_%d" % (_next_line % TALK_LINES + 1), LINE_EVERY - 1.0)
				_next_line += 1
		Phase.RECESS:
			if not placed:
				return
			_selfie_left -= delta
			if _selfie_left <= 0.0 and _path.is_empty():
				_selfie_left = SELFIE_EVERY
				_selfie()
		Phase.QUESTIONS:
			_question_left -= delta
			if _question_left <= 0.0:
				_question_left = QUESTION_EVERY
				question_time.emit()


## At recess he walks up to a pupil in the playground and takes a selfie with them.
func _selfie() -> void:
	var near: Array[SchoolPupil] = []
	for pupil in school.pupils:
		if not pupil.walking() and school.in_yard(pupil.global_position):
			near.append(pupil)
	if near.is_empty():
		return
	var pupil := near[_rng.randi() % near.size()]
	var side := (politician.global_position - pupil.global_position)
	side.y = 0.0
	_path = [pupil.global_position + (side.normalized() if side.length() > 0.01 else Vector3.RIGHT) * 0.9]
	politician.say("SCHOOL_LUSTRE_RECESS_%d" % _rng.randi_range(1, RECESS_LINES))


## The phase is over: on to the next, with the pupils.
func _next() -> void:
	match phase:
		Phase.TALK:
			politician.say("SCHOOL_LUSTRE_BELL")
			for pupil in school.pupils:
				pupil.walk(school.route_to_yard(pupil.desk, school.recess_spot(pupil.desk)), pupil.desk * FILE_GAP)
			_enter(Phase.RECESS, school.deputy_to_yard())
		Phase.RECESS:
			var facing := -school.global_basis.z
			var order := _by_distance_to(school.to_global(SchoolVisitLevel.YARD_IN))
			for i in order.size():
				order[i].walk(school.route_to_desk(order[i].desk), i * FILE_GAP, facing)
			_enter(Phase.QUESTIONS, school.deputy_to_class())
		Phase.QUESTIONS:
			var facing := school.global_basis.z
			for pupil in school.pupils:
				pupil.walk(school.route_out_front(pupil.desk, school.photo_spot(pupil.desk)), pupil.desk * FILE_GAP,
					facing)
			_enter(Phase.PHOTO, school.deputy_out())
		Phase.PHOTO:
			phase = Phase.OVER
			politician.say("SCHOOL_LUSTRE_END")
			phase_changed.emit(phase)
			finished.emit()


## The photo waits for the last pupil to get in line.
func _pupils_walking() -> bool:
	return school.pupils.any(func(p: SchoolPupil) -> bool: return p.walking())


func _by_distance_to(at: Vector3) -> Array[SchoolPupil]:
	var order: Array[SchoolPupil] = school.pupils.duplicate()
	order.sort_custom(func(a: SchoolPupil, b: SchoolPupil) -> bool:
		return a.global_position.distance_to(at) < b.global_position.distance_to(at))
	return order


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
	hud_box = box
	box.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	box.offset_top = 12.0
	var title := Label.new()
	title.text = "HUD_SCHOOL"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_constant_override("outline_size", 6)
	box.add_child(title)
	bar = ProgressBar.new()
	bar.custom_minimum_size = Vector2(320, 18)
	bar.max_value = 1.0
	bar.step = 0.0
	bar.show_percentage = false
	bar.modulate = Color(0.95, 0.8, 0.3)
	box.add_child(bar)
	_state = Label.new()
	_state.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_state.add_theme_constant_override("outline_size", 6)
	box.add_child(_state)
	hud.add_child(box)
	add_child(hud)


func _show() -> void:
	if school == null:
		return
	bar.value = progress()
	var key: String = ["HUD_SCHOOL_WAITING", "HUD_SCHOOL_TALK", "HUD_SCHOOL_RECESS", "HUD_SCHOOL_QUESTIONS",
		"HUD_SCHOOL_PHOTO", "HUD_SCHOOL_OVER"][phase]
	if phase in [Phase.TALK, Phase.RECESS, Phase.QUESTIONS] and (placed or phase == Phase.RECESS):
		var left := ceili(maxf(phase_left, 0.0))
		_state.text = tr(key) + " %d:%02d" % [left / 60, left % 60]
	else:
		_state.text = key
