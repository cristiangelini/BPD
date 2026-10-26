class_name SchoolCase
extends Node

## The deputy's school visit as a case (politico-escuela.md, step 7, decision 210): the comisario tells it in his
## office, Q opens the planilla, and the clock is Lustre's visit. When he gets the group photo the case is solved and
## pays SALARY, PER_GAFFE less for each gaffe, PER_CRY less for each pupil who cried CRY_TIME without a candy and
## JANITOR more if the janitor is detained; quota of its own, like the plaza (decision 103). With MAX_GAFFES he leaves
## ashamed and the case is lost. If the janitor is still loose at the photo he rides off on his floor polisher along
## the sidewalk, waxing it slippery, and the chase starts there (decision 96): caught, he counts as detained; got away,
## the case is solved all the same. Online comes in step 8. Every number here is (propuesta).

const REFRESH := 0.5
const SHIFT_DELAY := 4.0
const SALARY := 600
const PER_GAFFE := 50
const PER_CRY := 25
const JANITOR := 100
const QUOTA := 400
const STORY := "politician_school"
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"
## Where the floor polisher waits, in the school's space: on the sidewalk east of the front door, facing the street.
const POLISHER_AT := Vector3(6.0, 0.05, SchoolVisitLevel.FRONT_Z + 2.0)

var school: SchoolVisitLevel
var briefing: CaseBriefing
var checklist: CaseChecklist
var shift_screen: ShiftScreen
var tip_given := false
var shamed := false
var photo_done := false
var shift_over := false
## Pupils who cried long enough to count.
var cried := 0
var jailed := false
## The janitor's ride on the floor polisher and how it ended.
var chase: ChaseCase
var caught := false
var escaped := false
var follower := false
var _result := {}
var _refresh_left := 0.0


func start(comisario: Comisario = null) -> void:
	add_to_group("school_case")
	briefing = CaseBriefing.new()
	add_child(briefing)
	checklist = CaseChecklist.new()
	add_child(checklist)
	briefing.finished.connect(checklist.set_open.bind(true))
	briefing.finished.connect(_hint_all.bind("HINT_GO_SCHOOL_VISIT"))
	school.tour.finished.connect(_on_photo)
	school.questions.shamed.connect(_on_shamed)
	for pupil in school.pupils:
		pupil.cried.connect(_on_cried.unbind(1))
	OwnerEscort.of(school.janitor).boarded.connect(_on_jailed)
	if comisario:
		comisario.spoke.connect(give_tip.unbind(1))
		_hint_all("HINT_SEE_COMISARIO")
	else:
		give_tip()
	if shift_screen:
		shift_screen.play_again.connect(func() -> void: PlaceDraw.start(get_tree()))
		shift_screen.back_to_menu.connect(func() -> void: get_tree().change_scene_to_file(MENU_SCENE))


func give_tip() -> void:
	if tip_given:
		return
	tip_given = true
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).input_enabled:
			briefing.start(PackedStringArray(["BRIEF_SCHOOL_VISIT_A", "BRIEF_SCHOOL_VISIT_B", "BRIEF_SCHOOL_VISIT_C"]))
			break
	checklist.show_rows(rows())


func _on_cried() -> void:
	cried += 1
	checklist.show_rows(rows())


func _on_jailed() -> void:
	jailed = true
	checklist.show_rows(rows())


## Too many gaffes: he left ashamed and the case is lost.
func _on_shamed() -> void:
	if follower or photo_done or shamed:
		return
	shamed = true
	_hint_all("HINT_SCHOOL_SHAMED")
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


## The group photo: the case is solved, and a loose janitor runs for his floor polisher.
func _on_photo() -> void:
	if follower or shamed or photo_done:
		return
	photo_done = true
	_hint_all("HINT_SCHOOL_PHOTO")
	if janitor_loose():
		_run_off()
	else:
		get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)
	checklist.show_rows(rows())


## Neither cuffed, nor being walked to the patrol car, nor in it.
func janitor_loose() -> bool:
	return not school.janitor.caught()


## The janitor gets on his floor polisher on the sidewalk: the chase is on.
func _run_off() -> void:
	if chase:
		return
	var janitor := school.janitor
	janitor.hide()
	janitor.collision_layer = 0
	janitor.process_mode = Node.PROCESS_MODE_DISABLED
	var at := school.global_transform * Transform3D(Basis.IDENTITY, POLISHER_AT)
	chase = ChaseCase.begin(school, SuspectCar.FLOOR_POLISHER, at, school.car, school.city, school.case_seed)
	chase.who = "janitor"
	chase.follower = follower
	chase.ended.connect(_on_chase_ended)
	_hint_all("HINT_ESCAPE_JANITOR")


func _on_chase_ended(was_caught: bool) -> void:
	caught = was_caught
	escaped = not was_caught
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


func solved() -> bool:
	return photo_done and not shamed


## The janitor in the patrol car, from the school or caught off the polisher.
func janitor_detained() -> bool:
	return jailed or caught


## SALARY, less PER_GAFFE for each gaffe and PER_CRY for each pupil who cried, plus JANITOR if he's detained; nothing
## if the deputy left ashamed.
func report() -> Dictionary:
	var salary := 0
	if solved():
		salary = SALARY - PER_GAFFE * school.questions.gaffes - PER_CRY * cried
		salary = maxi(salary + (JANITOR if janitor_detained() else 0), 0)
	return {"salary": salary, "evidence": 0, "fines": 0, "total": salary, "quota": QUOTA, "approved": salary >= QUOTA}


func finish_shift() -> void:
	if shift_over or follower:
		return
	var stats := []
	for cop in get_tree().get_nodes_in_group("cops"):
		stats.append((cop as Cop).stats)
	var pay := report()
	var result := {"solved": solved(), "report": pay, "awards": ShiftReport.awards(stats)}
	var campaign := Campaign.current
	if campaign and not campaign.is_over():
		var played := campaign.shift
		campaign.finish_shift(STORY, solved(), pay, QUOTA)
		campaign.save()
		result.campaign = {"shift": played, "money": campaign.money, "over": campaign.is_over(),
			"promoted": campaign.is_promoted()}
	_show_result(result)


func _show_result(result: Dictionary) -> void:
	shift_over = true
	_result = result
	if not shift_screen:
		return
	for cop in get_tree().get_nodes_in_group("cops"):
		cop.input_enabled = false
		cop.get_node("Grabber").input_enabled = false
		cop.get_node("Hud").hide()
	var awards: Array[Dictionary] = []
	awards.assign(result.awards)
	shift_screen.show_report(result.solved, result.report, 0, awards)
	var over := false
	if result.has("campaign"):
		shift_screen.show_campaign(result.campaign.shift, Campaign.SHIFTS, result.campaign.money, result.campaign.over,
			result.campaign.promoted)
		over = result.campaign.over
	shift_screen.get_node("%AgainButton").visible = not over and not follower


## The planilla's rows, in the shape CaseChecklist takes.
func rows() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	list.append(_row("OBJ_SCHOOL_GUARD", school.tour.phase != SchoolTour.Phase.WAITING))
	list.append(_row(tr("OBJ_SCHOOL_GAFFES") % [school.questions.gaffes, SchoolQuestions.MAX_GAFFES], false))
	list.append(_row(tr("OBJ_SCHOOL_CRIED") % cried, false))
	list.append(_row("OBJ_SCHOOL_JANITOR", janitor_detained()))
	if chase:
		list.append(_row("OBJ_SCHOOL_CATCH_POLISHER", caught))
	var state := "OBJ_SCHOOL_SHAMED" if shamed else ("OBJ_SCHOOL_OVER" if photo_done else "OBJ_SCHOOL_KEEP_SAFE")
	list.append({"text": state, "done": false, "optional": false, "status": true})
	return list


func _physics_process(delta: float) -> void:
	if shift_over or not tip_given:
		return
	_refresh_left -= delta
	if checklist.is_open() and _refresh_left <= 0.0:
		_refresh_left = REFRESH
		checklist.show_rows(rows())


func _row(text: String, done: bool) -> Dictionary:
	return {"text": text, "done": done, "optional": false, "status": false}


func _hint_all(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(key)
