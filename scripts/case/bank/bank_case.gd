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
## the croissants left on the tray. With the grandpa robbers (robo-banco-abuelos.md, step 5) the radio warns that
## they're slow but clever, the first one who passes for a hostage shows a hint to everyone, the planilla counts the
## hostages cuffed by mistake and each one costs PER_WRONG_CUFF. With the sorry robber (robo-banco-arrepentido.md,
## step 5) the radio tells about the robber who called crying, everyone hears it the first time he's turned and the
## first time the gang ties him, the planilla counts his helps and each one done adds PER_HELP to the pay. When the
## manager is the gang's boss (robo-banco-gerente.md, step 4) the radio sends the cops to look after him, the case is
## solved with him in the patrol car (El Oso alone isn't enough) and lost if he gets away in his car; caught before the
## vault opens it pays EARLY_MANAGER more, and he goes to the next shift's interrogation. In every robbery, the honest
## manager cuffed costs PER_WRONG_MANAGER once. In the flooding bank (robo-banco-inundado.md, step 4, decision 125) the
## radio warns about the water, the planilla shows how deep it is and asks for the valve, and shutting it before the
## water gets to the top pays EARLY_VALVE more. Every number here is (propuesta).

const REFRESH := 0.5
const SHIFT_DELAY := 3.0
const SALARY := 700
const PER_HOSTAGE := 100
const PER_BAG := 50
const PER_WRONG_CUFF := 50
const PER_HELP := 50
const PER_WRONG_MANAGER := 200
const EARLY_MANAGER := 100
const EARLY_VALVE := 100
const QUOTA := 400
const STORY := "bank_robbery"
const SLIPS := "BEAR_SLIP_%d"
const MANAGER_SLIPS := "MANAGER_SLIP_%d"
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
## With the grandpa robbers: one already passed for a hostage (the hint goes out once), and the true hostages cuffed.
var grandpa_hid := false
var wrong_cuffs := 0
## With the sorry robber: everyone already heard he's on their side, and that the gang tied him (each hint once).
var sorry_turned := false
var sorry_tied := false
## The boss manager in the patrol car (or caught at the end of his getaway), whether he was cuffed before the vault
## opened, and whether the honest manager was cuffed.
var manager_jailed := false
var manager_early := false
var wrong_manager := false
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
		hostage.wrongly_cuffed.connect(_on_wrongly_cuffed)
	for robber in bank.robbers:
		robber.spotted.connect(_on_robber_spotted)
	if bank.sorry:
		bank.sorry.turned_now.connect(func(_robber: BankRobber) -> void:
			if not follower and not sorry_turned:
				_hear_sorry_turned())
		bank.sorry.tied_up.connect(func(_robber: BankRobber) -> void:
			if not follower and not sorry_tied:
				_hear_sorry_tied())
		bank.sorry.helped.connect(func(_robber: BankRobber, _help: String) -> void: checklist.show_rows(rows()))
	bank.manager.wrongly_cuffed.connect(func(_manager: BankManager) -> void:
		if not follower:
			wrong_manager = true
			checklist.show_rows(rows()))
	if bank.manager.boss:
		OwnerEscort.of(bank.manager).boarded.connect(func() -> void:
			if not follower:
				_jail_manager())
		bank.manager.caught_now.connect(func(_manager: BankManager) -> void:
			if not follower and not bank.drill.is_open:
				manager_early = true)
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


## What the comisario says over the radio: the base robbery's, the party's, the grandpas', the sorry robber's or the
## manager's, or the flood's.
func brief() -> PackedStringArray:
	if bank.water:
		return PackedStringArray(["BRIEF_BANK_FLOOD_A", "BRIEF_BANK_FLOOD_B", "BRIEF_BANK_FLOOD_C"])
	if bank.manager.boss:
		return PackedStringArray(["BRIEF_BANK_MANAGER_A", "BRIEF_BANK_MANAGER_B", "BRIEF_BANK_MANAGER_C"])
	if bank.sorry:
		return PackedStringArray(["BRIEF_BANK_SORRY_A", "BRIEF_BANK_SORRY_B", "BRIEF_BANK_SORRY_C"])
	if bank.grandpas:
		return PackedStringArray(["BRIEF_BANK_GRANDPAS_A", "BRIEF_BANK_GRANDPAS_B", "BRIEF_BANK_GRANDPAS_C"])
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


## A grandpa robber who saw a cop goes to pass for a hostage: everyone hears it, once.
func _on_robber_spotted(robber: BankRobber, _cop: Node3D) -> void:
	if follower or grandpa_hid or not robber.unmasked:
		return
	_grandpa_hides()


func _grandpa_hides() -> void:
	grandpa_hid = true
	_hint_all("HINT_BANK_GRANDPA_HID")


func _hear_sorry_turned() -> void:
	sorry_turned = true
	_hint_all("HINT_BANK_SORRY_TURNED")
	checklist.show_rows(rows())


func _hear_sorry_tied() -> void:
	sorry_tied = true
	_hint_all("HINT_BANK_SORRY_TIED")


## The sorry robber's helps done (0 without him).
func helps() -> int:
	return bank.sorry.helps_done.size() if bank.sorry else 0


## A true hostage cuffed: with the grandpa robbers it's a mistake that costs.
func _on_wrongly_cuffed(_hostage: BankHostage) -> void:
	if follower or not bank.grandpas:
		return
	wrong_cuffs += 1
	checklist.show_rows(rows())


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
	var manager_ran := bank.chase.who == "manager"
	if was_caught:
		if manager_ran:
			_jail_manager()
		else:
			_on_boss_jailed()
		return
	escaped = true
	checklist.show_rows(rows())
	# With the boss manager already cuffed, El Oso getting away doesn't end it: the manager is who counts.
	if manager_ran or not bank.manager.boss:
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


## The boss manager is in the patrol car: the case is solved.
func _jail_manager() -> void:
	if manager_jailed or shift_over:
		return
	manager_jailed = true
	checklist.show_rows(rows())


func solved() -> bool:
	return manager_jailed if bank.manager.boss else boss_jailed


func hostages_left() -> int:
	return bank.hostages.size() - bank.hostages_freed


## What the robbery cost: the hostages left inside, the sacks the robbers took and the true hostages cuffed.
func missed() -> int:
	return PER_HOSTAGE * hostages_left() + PER_BAG * bank.bags_taken + PER_WRONG_CUFF * wrong_cuffs \
		+ (PER_WRONG_MANAGER if wrong_manager else 0)


func report() -> Dictionary:
	var bonus := PER_HELP * helps() + (EARLY_MANAGER if manager_early else 0) \
		+ (EARLY_VALVE if bank.water and bank.water.shut_early() else 0)
	var salary := maxi(SALARY - missed() + bonus, 0) if solved() else 0
	return {"salary": salary, "evidence": 0, "fines": 0, "total": salary, "quota": QUOTA, "approved": salary >= QUOTA}


## El Oso for the next shift's interrogation (decision 93), like a raid's owner (RaidCase.custody). Empty if he
## wasn't caught.
func custody() -> Dictionary:
	if not solved():
		return {}
	var slips: Array[String] = []
	for i in InterrogationCase.OWNER_SLIPS.size():
		slips.append((MANAGER_SLIPS if bank.manager.boss else SLIPS) % (i + 1))
	return {"owner": "manager" if bank.manager.boss else "oso", "story": STORY, "slips": slips, "missed": missed()}


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
	if solved() and not follower and car_home():
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
		"jailed": boss_jailed, "escaped": escaped, "result": _result, "fans": fans_heard, "hid": grandpa_hid,
		"wrong_cuffs": wrong_cuffs, "marbles": bank.marbles != null, "back_door": bank.back_door.is_open}
	if bank.sorry:
		state.sorry = [sorry_turned, sorry_tied, bank.sorry.helps_done]
	state.manager = [manager_jailed, manager_early, wrong_manager]
	if bank.manager_trunk and is_instance_valid(bank.manager_trunk):
		state.trunk = bank.manager_trunk.is_open
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
	if state.get("hid", false) and not grandpa_hid:
		_grandpa_hides()
	wrong_cuffs = state.get("wrong_cuffs", 0)
	if state.get("marbles", false):
		bank.spill_marbles()
	if state.get("back_door", false) and not bank.back_door.is_open:
		bank.back_door.open_from_inside()
	if bank.sorry and state.has("sorry"):
		if state.sorry[0] and not sorry_turned:
			_hear_sorry_turned()
		if state.sorry[1] and not sorry_tied:
			_hear_sorry_tied()
		bank.sorry.helps_done.assign(state.sorry[2])
	if state.has("manager"):
		if state.manager[0]:
			_jail_manager()
		manager_early = state.manager[1]
		wrong_manager = state.manager[2]
	if state.has("trunk") and bank.manager_trunk and is_instance_valid(bank.manager_trunk) \
			and state.trunk != bank.manager_trunk.is_open:
		bank.manager_trunk.set_open(state.trunk)
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
	if bank.manager.boss:
		list.append(_row("OBJ_BANK_CUFF_BOSS", manager_jailed))
		if bank.chase:
			list.append(_row("OBJ_BANK_CATCH_MANAGER", manager_jailed))
	else:
		list.append(_row("OBJ_BANK_CUFF_OSO", boss_jailed))
		if bank.chase:
			list.append(_row("OBJ_BANK_CATCH_OSO", boss_jailed))
	list.append(_row("OBJ_BANK_BACK_MANAGER" if bank.manager.boss else "OBJ_BANK_BACK", shift_over and solved()))
	var drill := "OBJ_BANK_VAULT_OPEN" if bank.drill.is_open else "OBJ_BANK_DRILL"
	list.append({"text": drill, "done": false, "optional": false, "status": true})
	if bank.grandpas:
		list.append({"text": "OBJ_BANK_GRANDPAS", "done": false, "optional": false, "status": true})
		if wrong_cuffs > 0:
			list.append({"text": tr("OBJ_BANK_WRONG_CUFFS") % wrong_cuffs, "done": false, "optional": false,
				"status": true})
	if bank.sorry:
		list.append(_row("OBJ_BANK_SORRY", bank.sorry.turned))
		list.append({"text": tr("OBJ_BANK_SORRY_HELPS") % [helps(), BankRobber.HELPS.size()], "done": false,
			"optional": false, "status": true})
	if wrong_manager:
		list.append({"text": "OBJ_BANK_WRONG_MANAGER", "done": false, "optional": false, "status": true})
	if bank.water:
		list.append(_row("OBJ_BANK_VALVE", bank.water.shut_early()))
		list.append({"text": tr("OBJ_BANK_WATER") % roundi(bank.water.level * 100.0), "done": false,
			"optional": false, "status": true})
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
