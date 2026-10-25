class_name TransferCase
extends Node

## The prisoner transfer case (traslado-presos.md, step 5, decision 105): the comisario tells it in his office and Q
## opens the planilla; until then the bus stays locked. Driven into the prison's yard and stopped, with nobody out
## running, the warden by the gate counts the inmates on the bus one by one (COUNT_STEP each) and the case is solved:
## SALARY, PER_MISSING less for each inmate who got away and PER_CRASH less for each hard crash of the bus
## (ChaseDamages, like a chase's fines); quota of its own, like the riot's. With LOSE_AT inmates escaped, or the bus on
## its side for TIPPED_SECONDS, the case is lost. No time limit (decision 66). Every number here is (propuesta).

const REFRESH := 0.5
const SHIFT_DELAY := 4.0
const SALARY := 600
const PER_MISSING := 75
const PER_CRASH := 50
const QUOTA := 400
const LOSE_AT := 4
## The bus counts as tipped over when its up axis leans past this (its y share), for this long.
const TIPPED_UP := 0.35
const TIPPED_SECONDS := 3.0
## Stopped in the yard below this speed (m/s), the count starts; the warden says a number every COUNT_STEP.
const STOPPED := 1.0
const COUNT_STEP := 0.8
## Where the warden waits, in the prison's space: in the yard, just inside the gate.
const WARDEN_AT := Vector3(PrisonLevel.GATE_HALF + 1.5, 0, PrisonLevel.HALF_Z - 3.0)
const WARDEN_MODEL := preload("res://assets/models/npc_carcelero.glb")
const STORY := "prisoner_transfer"
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"

var prison: PrisonLevel
var briefing: CaseBriefing
var checklist: CaseChecklist
var shift_screen: ShiftScreen
var damages: ChaseDamages
var warden: Node3D
var tip_given := false
## The warden is counting, and how many he has counted so far.
var counting := false
var counted := 0
var delivered := false
var failed_reason := ""
var shift_over := false
var _bubble: Label3D
var _count_left := 0.0
var _tipped_for := 0.0
var _told_loose := false
var _result := {}
var _refresh_left := 0.0


func start(comisario: Comisario = null) -> void:
	add_to_group("transfer_case")
	briefing = CaseBriefing.new()
	add_child(briefing)
	checklist = CaseChecklist.new()
	add_child(checklist)
	briefing.finished.connect(checklist.set_open.bind(true))
	briefing.finished.connect(_hint_all.bind("HINT_GO_TRANSFER"))
	damages = ChaseDamages.new()
	damages.car = prison.bus
	add_child(damages)
	_make_warden()
	prison.escape.chase_over.connect(_on_chase_over.unbind(2))
	if comisario:
		comisario.spoke.connect(give_tip.unbind(1))
		prison.bus.locked_hint = "HINT_COMISARIO_FIRST"
		_hint_all("HINT_SEE_COMISARIO")
	else:
		give_tip()
	if shift_screen:
		shift_screen.play_again.connect(_play_again)
		shift_screen.back_to_menu.connect(func() -> void: get_tree().change_scene_to_file(MENU_SCENE))


func _play_again() -> void:
	PlaceDraw.start(get_tree())


func give_tip() -> void:
	if tip_given:
		return
	tip_given = true
	prison.bus.locked_hint = ""
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).input_enabled:
			briefing.start(PackedStringArray(["BRIEF_TRANSFER_A", "BRIEF_TRANSFER_B", "BRIEF_TRANSFER_C"]))
			break
	checklist.show_rows(rows())


## Inmates who got away.
func escaped() -> int:
	return prison.escape.escaped.size()


## Inmates on the bus: all but the ones who got away (the count waits for anyone still running).
func on_board() -> int:
	return TransferPlan.INMATES - escaped()


func solved() -> bool:
	return delivered and failed_reason == ""


## SALARY, less PER_MISSING for each inmate who got away and PER_CRASH for each hard crash of the bus.
func report() -> Dictionary:
	var salary := 0
	if solved():
		salary = maxi(SALARY - PER_MISSING * escaped() - PER_CRASH * damages.crashes, 0)
	return {"salary": salary, "evidence": 0, "fines": 0, "total": salary, "quota": QUOTA, "approved": salary >= QUOTA}


func _physics_process(delta: float) -> void:
	if shift_over or not tip_given or failed_reason != "" or delivered:
		return
	var bus := prison.bus
	_tipped_for = _tipped_for + delta if bus.global_basis.y.y < TIPPED_UP else 0.0
	if _tipped_for >= TIPPED_SECONDS:
		lose("CASE_FAILED_BUS_TIPPED")
		return
	if counting:
		_count(delta)
	elif prison.inside_walls(bus.global_position) and absf(bus.forward_speed()) < STOPPED:
		if prison.escape.chase or not prison.escape.waiting.is_empty():
			if not _told_loose:
				_told_loose = true
				_hint_all("HINT_TRANSFER_ONE_LOOSE")
		else:
			_start_count()
	_refresh_left -= delta
	if checklist.is_open() and _refresh_left <= 0.0:
		_refresh_left = REFRESH
		checklist.show_rows(rows())


func _on_chase_over() -> void:
	if escaped() >= LOSE_AT:
		lose("CASE_FAILED_TRANSFER_ESCAPED")
	checklist.show_rows(rows())


## In the yard: the inmates stop planning and the warden counts them through the bus's windows.
func _start_count() -> void:
	counting = true
	counted = 0
	_count_left = COUNT_STEP
	prison.transfer.process_mode = Node.PROCESS_MODE_DISABLED
	prison.tricks.process_mode = Node.PROCESS_MODE_DISABLED
	_say("TRANSFER_COUNT_START")


func _count(delta: float) -> void:
	_count_left -= delta
	if _count_left > 0.0:
		return
	_count_left = COUNT_STEP
	if counted < on_board():
		counted += 1
		_say(tr("TRANSFER_COUNT") % counted)
		return
	counting = false
	delivered = true
	_say("TRANSFER_COUNT_ALL" if escaped() == 0 else tr("TRANSFER_COUNT_MISSING") % escaped())
	_hint_all("HINT_TRANSFER_DELIVERED")
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


## Too many got away, or the bus is on its side: the shift is over.
func lose(reason: String) -> void:
	if failed_reason != "" or delivered:
		return
	failed_reason = reason
	_hint_all(reason)
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


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
	var list: Array[Dictionary] = []
	list.append(_row("OBJ_TRANSFER_DRIVE", delivered))
	list.append(_row(tr("OBJ_TRANSFER_ON_BOARD") % [on_board(), TransferPlan.INMATES], escaped() == 0))
	list.append({"text": tr("OBJ_TRANSFER_ESCAPED") % [escaped(), LOSE_AT], "done": false, "optional": false,
		"status": true})
	list.append({"text": tr("OBJ_TRANSFER_CRASHES") % damages.crashes, "done": false, "optional": false,
		"status": true})
	if failed_reason != "":
		list.append({"text": failed_reason, "done": false, "optional": false, "status": true})
	return list


## The warden at the gate, with his bubble for the count.
func _make_warden() -> void:
	warden = Node3D.new()
	warden.name = "Warden"
	prison.add_child(warden)
	warden.position = WARDEN_AT
	warden.rotation.y = PI
	warden.add_child(WARDEN_MODEL.instantiate())
	_bubble = Label3D.new()
	_bubble.position.y = 2.0
	_bubble.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_bubble.pixel_size = 0.005
	_bubble.outline_size = 12
	_bubble.font_size = 56
	_bubble.hide()
	warden.add_child(_bubble)


func _say(text: String) -> void:
	_bubble.text = text
	_bubble.show()


func _row(text: String, done: bool) -> Dictionary:
	return {"text": text, "done": done, "optional": false, "status": false}


func _hint_all(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(key)
