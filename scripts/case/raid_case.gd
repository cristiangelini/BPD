class_name RaidCase
extends Node

## What every raid shares, whatever the place (historias.md, "Resolver con las pruebas"; allanamiento.md, "Entrega"):
## the comisario's tip and briefing, the checklist (Q), the three suspicions and marking one, the clues found, the
## main evidence going into the trunk, the drive back to the station and the end of shift screen. The place builds
## itself, hides the story's things and adds its own checklist facts through `place_facts`.

## Seconds between solving or failing the case and the end of shift screen.
const SHIFT_DELAY := 2.5
## How close to its spot at the station the car has to stop to end the shift, in meters (propuesta).
const STATION_RADIUS := 12.0
## The open checklist redraws this often, in seconds.
const CHECKLIST_REFRESH := 0.2
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"

var case_seed := 0
## The true story: its id among the suspicions, what the comisario says once it's guessed and its "find it" row.
var story_id := ""
var story_briefing: PackedStringArray = []
var find_key := "OBJ_FIND"
## The evidence the case is about: delivered in the trunk it solves the case, broken it fails it.
var main_evidence: Evidence
var car: PatrolCar
## Where the patrol car parks at the station: the shift ends when everyone gets back there (decision 83).
var station_parking: Transform3D
## The place's own checklist facts (door_open, extras, broken, complaint...), merged over the shared ones.
var place_facts: Callable = func() -> Dictionary: return {}
## The case's labels on screen and the end of shift screen, from the place's scene.
var solved_label: Label
var failed_label: Label
var shift_screen: ShiftScreen

## The three suspicions on the checklist (CaseSuspicions), the true story among them.
var suspicions: Array[String] = []
## The suspicions marked wrong so far.
var wrong_marks: Array[String] = []
## The cops marked the true story: its evidence and extras show on the checklist and the case can be solved.
var story_known := false
## Some cop already picked up the main evidence (checklist row "find it").
var main_found := false
## The place's NPC called a lawyer, the main evidence broke or the guesses ran out: the case is lost.
var case_failed := false
## The main evidence is in the trunk and every cop drove back to the station (allanamiento.md, "Entrega").
var case_solved := false
## The end of shift screen is up.
var shift_over := false
## Clues the cops found, as checklist lines (already translated).
var clues_found: Array[String] = []
## Money taken off the case pay for broken things.
var fines := 0
## Whose fresh prints the fingerprint kit finds near the evidence (tr() key): the place's owner.
var prints_key := "PRINTS_OWNER"

## Online, what keeps this case the same on every PC (null solo).
var online: CaseSync
## A guest's case online: it shows what the host's case decides and decides nothing itself.
var follower := false
## The host's checklist facts, for a follower.
var _host_facts := {}
## The end of shift numbers, once the shift is over (sent to the guests online).
var _result := {}

var briefing: CaseBriefing
## The comisario has given the tip (at the station, or right away without one).
var tip_given := false
var _tip: PackedStringArray = []
var checklist: CaseChecklist
## Suspicion index being held down with the checklist open, and for how long.
var _marking := -1
var _mark_held := 0.0
var _refresh_left := 0.0


## Starts the case once the place has placed everything. With a comisario at the station, the tip waits until a cop
## talks to him in his office (give_tip), and the car stays locked until then; without one, he gives it right away.
## Only a cop with a player at the keys hears it (tests drive cops without input); the checklist opens after him.
func start(tip_briefing: PackedStringArray, pool: Array = CaseSuspicions.POOL, comisario: Comisario = null) -> void:
	add_to_group("raid")
	suspicions = CaseSuspicions.draw(case_seed, story_id, pool)
	main_evidence.broken.connect(fail.bind("CASE_FAILED_BROKEN"))
	car.evidence_delivered.connect(_on_evidence_delivered)
	car.evidence_delivered.connect(check_solved.unbind(1))
	car.seats_changed.connect(check_solved)
	checklist = CaseChecklist.new()
	add_child(checklist)
	briefing = CaseBriefing.new()
	add_child(briefing)
	briefing.finished.connect(checklist.set_open.bind(true))
	_tip = tip_briefing
	if comisario:
		comisario.spoke.connect(give_tip.unbind(1))
		car.locked_hint = "HINT_COMISARIO_FIRST"
		for cop in get_tree().get_nodes_in_group("cops"):
			(cop as Cop).show_hint("HINT_SEE_COMISARIO")
	else:
		give_tip()
	shift_screen.play_again.connect(_play_again)
	shift_screen.back_to_menu.connect(func() -> void: get_tree().change_scene_to_file(MENU_SCENE))


## The comisario gives the tip, once: the case is on and the patrol car opens.
func give_tip() -> void:
	if tip_given:
		return
	tip_given = true
	car.locked_hint = ""
	_tell(_tip)


func _tell(lines: PackedStringArray) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).input_enabled:
			briefing.start(lines)
			return


func _process(delta: float) -> void:
	if not checklist:
		return
	if not main_found and main_evidence.is_held():
		main_found = true
	_hold_to_mark(delta)
	_refresh_left -= delta
	if checklist.is_open() and _refresh_left <= 0.0:
		_refresh_left = CHECKLIST_REFRESH
		checklist.show_rows(CaseObjectives.rows(objective_facts()))


func _physics_process(_delta: float) -> void:
	# The car arriving at the station is what closes the case once everything else is done.
	if checklist:
		check_solved()


func _play_again() -> void:
	if online:
		online.play_again()
	else:
		PlaceDraw.start(get_tree())


## What the checklist needs to know about the case right now (a follower's comes from the host).
func objective_facts() -> Dictionary:
	if follower and not _host_facts.is_empty():
		return _host_facts
	var facts := {
		"door_open": true,
		"find": find_key if story_known else "OBJ_FIND_PROOF",
		"found": main_found,
		"delivered": car.is_delivered(main_evidence),
		"all_in_car": all_in_car(),
		"at_station": car_at_station(),
		"suspicions": suspicions.map(func(id: String) -> Dictionary: return {"name": "SUSPECT_" + id,
			"state": "right" if story_known and id == story_id else ("wrong" if wrong_marks.has(id) else "open")}),
		"story_known": story_known,
		"clues": clues_found,
		"broken": 0,
		"fines": fines,
		"complaint": 0.0,
	}
	facts.merge(place_facts.call(), true)
	return facts


func all_in_car() -> bool:
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).vehicle != car:
			return false
	return true


func car_at_station() -> bool:
	return car.global_position.distance_to(station_parking.origin) < STATION_RADIUS


## Adds a found clue to the checklist, once.
func add_clue(text: String) -> void:
	if not clues_found.has(text):
		clues_found.append(text)


## Marks suspicion `index` as the cops' guess. Right: the comisario tells the story. Wrong: half the salary, and the
## second wrong one fails the case. Returns whether it was right.
func mark(index: int) -> bool:
	if follower:
		online.request_mark(index)
		return false
	if story_known or case_failed or index < 0 or index >= suspicions.size() or wrong_marks.has(suspicions[index]):
		return false
	if suspicions[index] == story_id:
		story_known = true
		_tell(story_briefing)
		check_solved()
		return true
	wrong_marks.append(suspicions[index])
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint("HINT_SUSPECT_WRONG")
	if wrong_marks.size() >= CaseSuspicions.WRONG_TO_FAIL:
		fail("CASE_FAILED_WRONG")
	return false


## With the checklist open, holding 1, 2 or 3 for a moment marks that suspicion.
func _hold_to_mark(delta: float) -> void:
	var held := -1
	if checklist.is_open():
		for i in suspicions.size():
			if Input.is_action_pressed("slot_%d" % (i + 1)):
				held = i
	if held != _marking:
		_marking = held
		_mark_held = 0.0
	if held < 0:
		return
	_mark_held += delta
	if _mark_held >= CaseSuspicions.MARK_SECONDS:
		mark(held)
		# Holding on doesn't mark again until the key is let go.
		_mark_held = -INF


func check_solved() -> void:
	if follower or case_solved or case_failed or not story_known or not car.is_delivered(main_evidence) or not car_at_station():
		return
	if not all_in_car():
		return
	case_solved = true
	solved_label.show()
	_finish_soon()


func fail(reason: String) -> void:
	if follower or case_failed or case_solved:
		return
	case_failed = true
	failed_label.text = reason
	failed_label.show()
	_finish_soon()


func _finish_soon() -> void:
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


## Shows the end of shift screen with the pay and the awards, and stops everyone's controls.
func finish_shift() -> void:
	if shift_over or follower:
		return
	var values := car.delivered.map(func(item: Evidence) -> float: return item.value)
	var stats := []
	for cop in get_tree().get_nodes_in_group("cops"):
		stats.append((cop as Cop).stats)
	_show_result({"solved": case_solved, "report": ShiftReport.pay(case_solved, values, fines, wrong_marks.size()),
		"broken": objective_facts().broken, "awards": ShiftReport.awards(stats)})


func _show_result(result: Dictionary) -> void:
	shift_over = true
	_result = result
	for cop in get_tree().get_nodes_in_group("cops"):
		cop.input_enabled = false
		cop.get_node("Grabber").input_enabled = false
		cop.get_node("Hud").hide()
	solved_label.hide()
	failed_label.hide()
	checklist.set_open(false)
	var awards: Array[Dictionary] = []
	awards.assign(result.awards)
	shift_screen.show_report(result.solved, result.report, result.broken, awards)
	# Only the host plays the next case for everyone.
	shift_screen.get_node("%AgainButton").visible = not follower


## What a follower needs to show the same case (CaseSync).
func snapshot() -> Dictionary:
	return {"facts": objective_facts(), "story_known": story_known, "failed": case_failed,
		"reason": failed_label.text, "solved": case_solved, "result": _result}


## A follower takes the host's case: the checklist, the comisario's story once it's guessed, solved or failed, and
## the end of shift screen.
func apply_snapshot(state: Dictionary) -> void:
	_host_facts = state.facts
	if state.story_known and not story_known:
		story_known = true
		_tell(story_briefing)
	if state.failed and not case_failed:
		case_failed = true
		failed_label.text = state.reason
		failed_label.show()
	if state.solved and not case_solved:
		case_solved = true
		solved_label.show()
	if not (state.result as Dictionary).is_empty() and not shift_over:
		_show_result(state.result)


func _on_evidence_delivered(item: Evidence) -> void:
	float_label("+%d" % roundi(item.value), item.global_position, Color(0.4, 1, 0.45))


## Placeholder feedback until the HUD exists: money floats up where it happened.
func float_label(text: String, at: Vector3, color: Color) -> void:
	var label := Label3D.new()
	label.text = text
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.modulate = color
	label.outline_size = 8
	label.pixel_size = 0.005
	get_parent().add_child(label)
	label.global_position = at + Vector3.UP * 0.2
	var tween := label.create_tween()
	tween.tween_property(label, "global_position:y", at.y + 0.8, 1.2)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 1.2)
	tween.tween_callback(label.queue_free)
