class_name BridgeCase
extends Node

## The bridge's opening as a case (politico-puente.md, step 5, decision 178): the comisario tells it in his office, Q
## opens the planilla, and the clock is deputy Lustre's walk across the bridge (BridgeCeremony). When he cuts the
## ribbon the case is solved and pays SALARY, DIP less for his dip in the canal, PLANK less for each plank left in the
## water and ENGINEER more if engineer Remache is in the patrol car; quota of its own, like the plaza (decision 103). His
## second dip sends him home and the case is lost there (BridgeDip). If Remache is still loose when the ribbon is cut,
## he runs for the cement mixer parked on the street and the chase starts there (decision 96), cement blobs in the
## curves (ChaseDrops): caught, he counts as detained; got away, the case is solved all the same (step 6). Every number
## here is (propuesta).

const REFRESH := 0.5
const SHIFT_DELAY := 4.0
const SALARY := 600
const DIP := 200
const PLANK := 10
const ENGINEER := 100
const QUOTA := 400
const STORY := "politician_bridge"
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"
## A plank's middle this far under where it floats still counts as in the water.
const FLOAT_SLACK := 0.3

var park: BridgePark
var briefing: CaseBriefing
var checklist: CaseChecklist
var shift_screen: ShiftScreen
var tip_given := false
var went_home := false
var ribbon_cut := false
var shift_over := false
## Times the deputy fell in the canal.
var dips := 0
var jailed := false
## The clues found at the pickup ("invoices", "beams").
var clues: Array[String] = []
## Remache's run in the cement mixer and how it ended.
var chase: ChaseCase
var caught := false
var escaped := false
var _result := {}
var _refresh_left := 0.0


func start(comisario: Comisario = null) -> void:
	add_to_group("bridge_case")
	briefing = CaseBriefing.new()
	add_child(briefing)
	checklist = CaseChecklist.new()
	add_child(checklist)
	briefing.finished.connect(checklist.set_open.bind(true))
	briefing.finished.connect(_hint_all.bind("HINT_GO_BRIDGE"))
	park.ceremony.finished.connect(_on_ribbon)
	park.dip.dipped.connect(_on_dipped)
	park.dip.went_home.connect(_on_went_home)
	park.remache.jailed.connect(_on_jailed)
	park.remache.found_clue.connect(_on_clue)
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
			briefing.start(PackedStringArray(["BRIEF_BRIDGE_A", "BRIEF_BRIDGE_B", "BRIEF_BRIDGE_C"]))
			break
	checklist.show_rows(rows())


func _on_dipped(count: int) -> void:
	dips = count
	checklist.show_rows(rows())


func _on_went_home() -> void:
	if ribbon_cut or went_home:
		return
	went_home = true
	_hint_all("HINT_BRIDGE_WENT_HOME")
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


func _on_jailed() -> void:
	jailed = true
	_hint_all("HINT_ENGINEER_IN_CAR")
	checklist.show_rows(rows())


func _on_clue(kind: String) -> void:
	if not clues.has(kind):
		clues.append(kind)
	checklist.show_rows(rows())


## He cut the ribbon: the case is solved, and a loose Remache runs for the cement mixer.
func _on_ribbon() -> void:
	if went_home or ribbon_cut:
		return
	ribbon_cut = true
	_hint_all("HINT_BRIDGE_RIBBON")
	if park.remache.loose():
		_run_off()
	else:
		get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)
	checklist.show_rows(rows())


## Remache leaves the crowd and drives off in the cement mixer: the chase is on.
func _run_off() -> void:
	if chase:
		return
	var engineer := park.remache.engineer
	engineer.hide()
	engineer.collision_layer = 0
	engineer.process_mode = Node.PROCESS_MODE_DISABLED
	park.mixer.get_node("Rider").show()
	park.mixer.driving = true
	chase = ChaseCase.begin(park, SuspectCar.CEMENT_MIXER, park.mixer.global_transform, park.car, park.city,
		park.case_seed, null, park.mixer)
	chase.who = "engineer"
	chase.ended.connect(_on_chase_ended)
	_hint_all("HINT_ESCAPE_ENGINEER")


func _on_chase_ended(was_caught: bool) -> void:
	caught = was_caught
	escaped = not was_caught
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


func solved() -> bool:
	return ribbon_cut and not went_home


## The loose planks floating in the canal (fallen ones and spares that went in).
func planks_in_water() -> int:
	var count := 0
	for plank in park.repairs.loose():
		if park.in_water(plank.global_position + Vector3.DOWN * FLOAT_SLACK):
			count += 1
	return count


## Remache in the patrol car, from the crowd or caught off the cement mixer.
func engineer_detained() -> bool:
	return jailed or caught


## SALARY, less DIP for each dip and PLANK for each plank in the water, plus ENGINEER if Remache is detained; nothing if
## the deputy went home.
func report() -> Dictionary:
	var salary := 0
	if solved():
		salary = SALARY - DIP * dips - PLANK * planks_in_water() + (ENGINEER if engineer_detained() else 0)
		salary = maxi(salary, 0)
	return {"salary": salary, "evidence": 0, "fines": 0, "total": salary, "quota": QUOTA, "approved": salary >= QUOTA}


func finish_shift() -> void:
	if shift_over:
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
	shift_screen.get_node("%AgainButton").visible = not over


## The planilla's rows, in the shape CaseChecklist takes.
func rows() -> Array[Dictionary]:
	var ceremony := park.ceremony
	var list: Array[Dictionary] = []
	list.append(_row("OBJ_BRIDGE_GUARD", ceremony.state != BridgeCeremony.State.WAITING))
	var stops := BridgePark.STOPS.size() + 1
	list.append(_row(tr("OBJ_BRIDGE_PHOTOS") % [stops if ribbon_cut else ceremony.done(), stops], ribbon_cut))
	list.append(_row(tr("OBJ_BRIDGE_PLANKS") % planks_in_water(), false))
	list.append(_row(tr("OBJ_BRIDGE_CLUES") % [clues.size(), 2], clues.size() >= 2))
	list.append(_row("OBJ_BRIDGE_ENGINEER", engineer_detained()))
	if chase:
		list.append(_row("OBJ_BRIDGE_CATCH_MIXER", caught))
	var state := "OBJ_BRIDGE_KEEP_DRY"
	if went_home:
		state = "OBJ_BRIDGE_WENT_HOME"
	elif ribbon_cut:
		state = "OBJ_BRIDGE_OVER"
	elif dips > 0:
		state = "OBJ_BRIDGE_WET"
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
