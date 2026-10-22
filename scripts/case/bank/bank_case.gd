class_name BankCase
extends Node

## The bank robbery case (robo-banco.md, step 6b, decision 102). It's live: the comisario gives it over the radio as
## the shift starts (no visit to his office), with the drill already running. Q opens the planilla. El Oso walked into
## the patrol car (inside the bank, or caught at the end of the getaway) solves it; the cops then drive back to the
## station and the shift ends there, so they can still lead the last hostages out. El Oso getting away in the chase
## loses it. The pay is SALARY, less PER_HOSTAGE for each hostage still inside and PER_BAG for each sack of money the
## robbers took; quota of its own, like the chase (decision 91). Solved, El Oso is in custody and the next shift is
## his interrogation (decision 93). It runs on the host; online comes later. Every number here is (propuesta).

const REFRESH := 0.5
const SHIFT_DELAY := 3.0
const SALARY := 700
const PER_HOSTAGE := 100
const PER_BAG := 50
const QUOTA := 400
const STORY := "bank_robbery"
const SLIPS := "BEAR_SLIP_%d"
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"

var bank: BankLevel
var briefing: CaseBriefing
var checklist: CaseChecklist
var shift_screen: ShiftScreen
## El Oso is in the patrol car, and the chase (if there was one) caught him.
var boss_jailed := false
var escaped := false
var shift_over := false
var _result := {}
var _refresh_left := 0.0


func start() -> void:
	add_to_group("bank_case")
	briefing = CaseBriefing.new()
	add_child(briefing)
	checklist = CaseChecklist.new()
	add_child(checklist)
	briefing.finished.connect(checklist.set_open.bind(true))
	briefing.finished.connect(_hint_all.bind("HINT_GO_BANK"))
	OwnerEscort.of(bank.boss).boarded.connect(_on_boss_jailed)
	bank.drill.opened.connect(_on_vault_opened)
	if shift_screen:
		shift_screen.play_again.connect(func() -> void: PlaceDraw.start(get_tree()))
		shift_screen.back_to_menu.connect(func() -> void: get_tree().change_scene_to_file(MENU_SCENE))
	# Over the radio, right away: the robbery is happening now.
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).input_enabled:
			briefing.start(PackedStringArray(["BRIEF_BANK_A", "BRIEF_BANK_B", "BRIEF_BANK_C"]))
			break
	checklist.show_rows(rows())


func _on_vault_opened() -> void:
	if bank.chase:
		bank.chase.ended.connect(_on_getaway_ended)
	checklist.show_rows(rows())


func _on_getaway_ended(was_caught: bool) -> void:
	if was_caught:
		_on_boss_jailed()
		return
	escaped = true
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


func _on_boss_jailed() -> void:
	if boss_jailed or shift_over:
		return
	boss_jailed = true
	_hint_all("HINT_BANK_OSO_JAILED")
	checklist.show_rows(rows())


func solved() -> bool:
	return boss_jailed


func hostages_left() -> int:
	return bank.hostages.size() - bank.hostages_freed


## What the robbery cost: the hostages left inside and the sacks the robbers took.
func missed() -> int:
	return PER_HOSTAGE * hostages_left() + PER_BAG * bank.bags_taken


func report() -> Dictionary:
	var salary := maxi(SALARY - missed(), 0) if solved() else 0
	return {"salary": salary, "evidence": 0, "fines": 0, "total": salary, "quota": QUOTA, "approved": salary >= QUOTA}


## El Oso for the next shift's interrogation (decision 93), like a raid's owner (RaidCase.custody). Empty if he
## wasn't caught.
func custody() -> Dictionary:
	if not solved():
		return {}
	var slips: Array[String] = []
	for i in InterrogationCase.OWNER_SLIPS.size():
		slips.append(SLIPS % (i + 1))
	return {"owner": "oso", "story": STORY, "slips": slips, "missed": missed()}


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
		campaign.custody = custody()
		campaign.save()
		result.campaign = {"shift": played, "money": campaign.money, "over": campaign.is_over(),
			"promoted": campaign.is_promoted()}
	else:
		PlaceDraw.custody = custody()
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


## Back at the station with El Oso in the car.
func car_home() -> bool:
	return bank.car.global_position.distance_to(bank.station_parking.origin) < ChaseCase.STATION_RADIUS


func _physics_process(delta: float) -> void:
	if shift_over:
		return
	if boss_jailed and car_home():
		finish_shift()
		return
	_refresh_left -= delta
	if checklist.is_open() and _refresh_left <= 0.0:
		_refresh_left = REFRESH
		checklist.show_rows(rows())


## The planilla's rows, in the shape CaseChecklist takes.
func rows() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	var all := bank.hostages.size()
	list.append(_row(tr("OBJ_BANK_HOSTAGES") % [bank.hostages_freed, all], bank.hostages_freed >= all))
	list.append(_row("OBJ_BANK_CUFF_OSO", boss_jailed))
	if bank.chase:
		list.append(_row("OBJ_BANK_CATCH_OSO", boss_jailed))
	list.append(_row("OBJ_BANK_BACK", shift_over and solved()))
	var drill := "OBJ_BANK_VAULT_OPEN" if bank.drill.is_open else "OBJ_BANK_DRILL"
	list.append({"text": drill, "done": false, "optional": false, "status": true})
	return list


func _row(text: String, done: bool) -> Dictionary:
	return {"text": text, "done": done, "optional": false, "status": false}


func _hint_all(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(key)
