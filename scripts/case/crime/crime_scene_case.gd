class_name CrimeSceneCase
extends Node

## The pastry contest's case (escena-del-crimen.md, step 2): the comisario tells it in his office, the seed picks the
## culprit and his 4 clues (CrimePlan), and Q opens the planilla with what's left to do. Finding the clues, the
## suspects' files and the board come in the next steps; they fill `clues_found`, `files` and `accused`.

## How often the open planilla redraws, in seconds.
const REFRESH := 0.5

var case_seed := 0
var contest: PastryContest
var plan: CrimePlan
## The cooks' traits, in table order (CookTraits.draw).
var cooks: Array[Dictionary] = []
var briefing: CaseBriefing
var checklist: CaseChecklist
var tip_given := false
## A cop got to the tent.
var at_tent := false
var clues_found: Array[String] = []
## Indexes of the cooks whose file is done.
var files: Array[int] = []
var accused := false
var _refresh_left := 0.0


## Starts the case: the tip waits for a cop to talk to the comisario (right away without one).
func start(comisario: Comisario = null) -> void:
	add_to_group("crime_scene")
	cooks = CookTraits.draw(case_seed)
	plan = CrimePlan.draw(cooks, case_seed)
	briefing = CaseBriefing.new()
	add_child(briefing)
	checklist = CaseChecklist.new()
	add_child(checklist)
	briefing.finished.connect(checklist.set_open.bind(true))
	briefing.finished.connect(_hint_all.bind("HINT_GO_CONTEST"))
	if comisario:
		comisario.spoke.connect(give_tip.unbind(1))
		_hint_all("HINT_SEE_COMISARIO")
	else:
		give_tip()


func give_tip() -> void:
	if tip_given:
		return
	tip_given = true
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).input_enabled:
			briefing.start(PackedStringArray(["BRIEF_CRIME_A", "BRIEF_CRIME_B", "BRIEF_CRIME_C"]))
			break
	checklist.show_rows(rows())


## The culprit's traits.
func culprit() -> Dictionary:
	return cooks[plan.culprit]


## The planilla's rows, in the shape CaseChecklist takes.
func rows() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	list.append(_row("OBJ_CRIME_GO", at_tent))
	list.append(_row(tr("OBJ_CRIME_CLUES") % [clues_found.size(), plan.clues.size()],
		clues_found.size() >= plan.clues.size()))
	list.append(_row(tr("OBJ_CRIME_FILES") % [files.size(), cooks.size()], files.size() >= cooks.size()))
	list.append(_row("OBJ_CRIME_ACCUSE", accused))
	list.append({"text": "OBJ_CRIME_CAREFUL", "done": false, "optional": false, "status": true})
	return list


func _physics_process(delta: float) -> void:
	if not tip_given or not contest:
		return
	if not at_tent:
		for cop in get_tree().get_nodes_in_group("cops"):
			if contest.under_roof((cop as Node3D).global_position):
				at_tent = true
				_hint_all("HINT_CRIME_LOOK")
				checklist.show_rows(rows())
				break
	_refresh_left -= delta
	if checklist.is_open() and _refresh_left <= 0.0:
		_refresh_left = REFRESH
		checklist.show_rows(rows())


func _row(text: String, done: bool) -> Dictionary:
	return {"text": text, "done": done, "optional": false, "status": false}


func _hint_all(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(key)
