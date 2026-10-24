class_name BankCase
extends Node

## The bank robbery case (robo-banco.md, step 6b, decision 102). It's live: the comisario gives it over the radio as
## the shift starts (no visit to his office), with the drill already running. Q opens the planilla. El Oso walked into
## the patrol car (inside the bank, or caught at the end of the getaway) solves it; the cops then drive back to the
## station and the shift ends there, so they can still lead the last hostages out. El Oso getting away in the chase
## loses it. The pay is SALARY, less PER_HOSTAGE for each hostage still inside and PER_BAG for each sack of money the
## robbers took; quota of its own, like the chase (decision 91). Solved, El Oso is in custody and the next shift is
## his interrogation (decision 93). Online the host's case decides and a guest's follows it (CaseSync, snapshot),
## with its bank, drill and phone. At the party (robo-banco-rehenes.md, step 5) the comisario's radio tells about the
## hostages who don't want to leave, the first fan who warns the gang shows a hint to everyone, and the planilla counts
## the croissants left on the tray. Every number here is (propuesta).

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
## At the party: a fan of the gang already warned them once (the hint goes out only the first time).
var fans_heard := false
## Online (docs/diseno/online.md): a guest's case, and its bank, only follow the host's; `online` is that sync.
var follower := false:
	set(value):
		follower = value
		if bank:
			bank.follower = value
			bank.drill.follower = value
			bank.phone.follower = value
var online: CaseSync
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
	for hostage in bank.hostages:
		hostage.snitched.connect(_on_snitched)
	bank.drill.opened.connect(_on_vault_opened)
	if shift_screen:
		shift_screen.play_again.connect(_play_again)
		shift_screen.back_to_menu.connect(func() -> void: get_tree().change_scene_to_file(MENU_SCENE))
	# Over the radio, right away: the robbery is happening now.
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).input_enabled:
			briefing.start(brief())
			break
	checklist.show_rows(rows())


## What the comisario says over the radio: the base robbery's, or the party's.
func brief() -> PackedStringArray:
	if bank.party:
		return PackedStringArray(["BRIEF_BANK_PARTY_A", "BRIEF_BANK_PARTY_B", "BRIEF_BANK_PARTY_C"])
	return PackedStringArray(["BRIEF_BANK_A", "BRIEF_BANK_B", "BRIEF_BANK_C"])


func _on_snitched(_hostage: BankHostage, _cop: Node3D) -> void:
	if follower or fans_heard:
		return
	_hear_fans()


func _hear_fans() -> void:
	fans_heard = true
	_hint_all("HINT_BANK_FANS")


func _play_again() -> void:
	if online:
		online.play_again()
	else:
		PlaceDraw.start(get_tree())


func _on_vault_opened() -> void:
	_watch_getaway()
	checklist.show_rows(rows())


func _watch_getaway() -> void:
	if bank.chase and not bank.chase.ended.is_connected(_on_getaway_ended):
		bank.chase.ended.connect(_on_getaway_ended)


func _on_getaway_ended(was_caught: bool) -> void:
	if follower:
		return
	if was_caught:
		_on_boss_jailed()
		return
	escaped = true
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


func _on_boss_jailed() -> void:
	if follower:
		return
	_jail_boss()


func _jail_boss() -> void:
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
	shift_screen.get_node("%AgainButton").visible = not over and not follower


## Back at the station with El Oso in the car.
func car_home() -> bool:
	return bank.car.global_position.distance_to(bank.station_parking.origin) < ChaseCase.STATION_RADIUS


func _physics_process(delta: float) -> void:
	if shift_over:
		return
	if boss_jailed and not follower and car_home():
		finish_shift()
		return
	_refresh_left -= delta
	if checklist.is_open() and _refresh_left <= 0.0:
		_refresh_left = REFRESH
		checklist.show_rows(rows())


## What every guest's case shows (CaseSync): the drill, the phone, the sacks taken, El Oso jailed or gone, his
## getaway and the end of shift.
func snapshot() -> Dictionary:
	var state := {"drill": bank.drill.net_state(), "phone": bank.phone.net_state(), "bags": bank.bags_taken,
		"jailed": boss_jailed, "escaped": escaped, "result": _result, "fans": fans_heard}
	if bank.croissant_tray:
		state.tray = bank.croissant_tray.left
	if bank.chase:
		state.getaway = bank.chase.suspect_id
		state.chase = bank.chase.snapshot()
	return state


func apply_snapshot(state: Dictionary) -> void:
	bank.drill.apply_net_state(state.drill)
	bank.phone.apply_net_state(state.phone)
	bank.bags_taken = state.bags
	if state.has("getaway"):
		bank.start_getaway(state.getaway)
		_watch_getaway()
		bank.chase.apply_snapshot(state.chase)
	if state.jailed:
		_jail_boss()
	escaped = state.escaped
	if state.get("fans", false) and not fans_heard:
		_hear_fans()
	if bank.croissant_tray and state.has("tray") and state.tray != bank.croissant_tray.left:
		bank.croissant_tray.set_left(state.tray)
	checklist.show_rows(rows())
	if not state.result.is_empty() and not shift_over:
		_show_result(state.result)


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
	if bank.party:
		list.append({"text": "OBJ_BANK_FANS", "done": false, "optional": false, "status": true})
		if bank.croissant_tray:
			list.append({"text": tr("OBJ_BANK_CROISSANTS") % bank.croissant_tray.left, "done": false,
				"optional": false, "status": true})
	return list


func _row(text: String, done: bool) -> Dictionary:
	return {"text": text, "done": done, "optional": false, "status": false}


func _hint_all(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(key)
