class_name PrisonCase
extends Node

## The prison riot case (carcel-motin.md, step 5, decision 104): the comisario tells it in his office, Q opens the
## planilla. It's solved once the RINGLEADERS are in the punishment cell and fewer than CALM_ENOUGH inmates are still
## angry, and pays SALARY, PER_STAIN less for each food stain the cops took and NO_ESCAPE more when no ringleader got
## away; quota of its own, like the politician's (decision 91). With OVERFLOW inmates angry at once the riot overflows:
## they break the kitchen door down, the cook runs off with the secret stew recipe and the case is lost there. No time
## limit (decision 66). Step 5b: with the other ringleaders in the cell, the last one still loose gets RUN_DELAY
## seconds; not cuffed by then, they roll off on the kitchen's food cart out the gate and the chase starts there
## (decision 96), the canteen holding still to watch it. Caught, they count as jailed; got away, the case is solved all
## the same, without the NO_ESCAPE extra. Every number here is (propuesta).

const REFRESH := 0.5
const SHIFT_DELAY := 4.0
const SALARY := 600
const PER_STAIN := 20
const NO_ESCAPE := 100
const QUOTA := 400
const CALM_ENOUGH := 3
const OVERFLOW := 15
const RUN_DELAY := 3.0
## Where the cart comes out: just past the gate, heading out (level space).
const CART_OUT := Vector3(0, 0, PrisonLevel.HALF_Z + 2.5)
const STORY := "prison_riot"
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"

var prison: PrisonLevel
var briefing: CaseBriefing
var checklist: CaseChecklist
var shift_screen: ShiftScreen
var tip_given := false
var calmed := false
var overflowed := false
var shift_over := false
## Ringleaders who got away (step 5b: the food cart).
var escaped := 0
## The last ringleader's run on the food cart, who it is and whether they were caught.
var chase: ChaseCase
var runner: PrisonInmate
var caught := false
var _result := {}
var _refresh_left := 0.0


func start(comisario: Comisario = null) -> void:
	add_to_group("prison_case")
	briefing = CaseBriefing.new()
	add_child(briefing)
	checklist = CaseChecklist.new()
	add_child(checklist)
	briefing.finished.connect(checklist.set_open.bind(true))
	briefing.finished.connect(_hint_all.bind("HINT_GO_PRISON"))
	prison.riot.angry_changed.connect(_on_angry_changed.unbind(1))
	prison.riot.ringleader_jailed.connect(_on_angry_changed.unbind(1))
	if comisario:
		comisario.spoke.connect(give_tip.unbind(1))
		_hint_all("HINT_SEE_COMISARIO")
	else:
		give_tip()
	if shift_screen:
		shift_screen.play_again.connect(PlaceDraw.start.bind(get_tree()))
		shift_screen.back_to_menu.connect(func() -> void: get_tree().change_scene_to_file(MENU_SCENE))


func give_tip() -> void:
	if tip_given:
		return
	tip_given = true
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).input_enabled:
			briefing.start(PackedStringArray(["BRIEF_PRISON_A", "BRIEF_PRISON_B", "BRIEF_PRISON_C"]))
			break
	checklist.show_rows(rows())


## Every ringleader in the cell (or gone) and the canteen quiet enough: solved. OVERFLOW angry: lost.
func _on_angry_changed() -> void:
	if calmed or overflowed or not prison.riot.running:
		return
	var riot := prison.riot
	if riot.angry >= OVERFLOW:
		overflow()
	elif not chase and riot.jailed == riot.ringleaders.size() - 1:
		get_tree().create_timer(RUN_DELAY).timeout.connect(_run_off)
	elif ringleaders_done() and riot.angry < CALM_ENOUGH and (not chase or caught or escaped > 0):
		calmed = true
		_hint_all("HINT_RIOT_CALMED")
		get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)
	checklist.show_rows(rows())


## The kitchen door comes down and the cook runs off with the recipe: the shift is over.
func overflow() -> void:
	if overflowed or calmed:
		return
	overflowed = true
	while not prison.kitchen_door.is_broken:
		prison.kitchen_door.ram_hit()
	_hint_all("HINT_RIOT_OVERFLOW")
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


## Every ringleader in the cell, caught on the cart or gone.
func ringleaders_done() -> bool:
	return prison.riot.jailed + escaped + (1 if caught else 0) >= prison.riot.ringleaders.size()


## The last loose ringleader, if any: not cuffed, not walked by a cop, not in the cell.
func loose_ringleader() -> PrisonInmate:
	for leader in prison.riot.ringleaders:
		var escort := OwnerEscort.of(leader)
		if not leader.is_cuffed() and not leader.is_jailed() and not (escort and escort.escorted_by):
			return leader
	return null


## Out the gate on the food cart: the canteen holds still and the chase is on.
func _run_off() -> void:
	if chase or calmed or overflowed:
		return
	runner = loose_ringleader()
	if not runner or prison.riot.jailed != prison.riot.ringleaders.size() - 1:
		return
	runner.hide()
	runner.collision_layer = 0
	runner.process_mode = Node.PROCESS_MODE_DISABLED
	_hold_canteen(true)
	var out := prison.global_transform * Transform3D(Basis.IDENTITY, CART_OUT)
	chase = ChaseCase.begin(prison, SuspectCar.FOOD_CART, out, prison.car, prison.city, prison.case_seed)
	chase.who = "ringleader"
	chase.ended.connect(_on_chase_ended)
	_hint_all("HINT_ESCAPE_RINGLEADER")
	checklist.show_rows(rows())


func _on_chase_ended(was_caught: bool) -> void:
	caught = was_caught
	escaped = 0 if was_caught else 1
	_hold_canteen(false)
	_on_angry_changed()


## While the cart runs off the inmates stop to watch (anger stays where it is).
func _hold_canteen(hold: bool) -> void:
	for inmate in prison.riot.inmates:
		if inmate != runner:
			inmate.active = not hold


func solved() -> bool:
	return calmed and not overflowed


## Food stains the cops took (the trays' don't count).
func stains() -> int:
	var hits := 0
	for cop in get_tree().get_nodes_in_group("cops"):
		hits += (cop as Cop).stats.get("food_hits", 0)
	return hits


## SALARY, less PER_STAIN for each stain on the cops and plus NO_ESCAPE if every ringleader ended up in the cell.
func report() -> Dictionary:
	var salary := 0
	if solved():
		salary = maxi(SALARY - PER_STAIN * stains() + (NO_ESCAPE if escaped == 0 else 0), 0)
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
	var riot := prison.riot
	var list: Array[Dictionary] = []
	list.append(_row("OBJ_PRISON_GO", riot.running))
	list.append(_row(tr("OBJ_PRISON_RINGLEADERS") % [riot.jailed, riot.ringleaders.size()],
		ringleaders_done()))
	if chase:
		list.append(_row("OBJ_PRISON_CATCH_CART", caught))
	list.append(_row(tr("OBJ_PRISON_ANGRY") % [riot.angry, CALM_ENOUGH], riot.running and riot.angry < CALM_ENOUGH))
	var state := "OBJ_PRISON_OVERFLOWED" if overflowed else ("OBJ_PRISON_CALMED" if calmed else "OBJ_PRISON_OVERFLOW")
	list.append({"text": tr(state) % OVERFLOW if state == "OBJ_PRISON_OVERFLOW" else state, "done": false,
		"optional": false, "status": true})
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
