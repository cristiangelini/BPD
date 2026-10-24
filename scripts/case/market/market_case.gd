class_name MarketCase
extends Node

## The politician's market walk as a case (politico-mercado.md, step 6, decision 120): the comisario tells it in his
## office, Q opens the planilla, and the clock is deputy Lustre's walk along the stalls. When he cuts the ribbon for the
## photo the case is solved and pays SALARY, PER_POINT less for each point of image lost, TOILET_RUN less if he had to
## run to the toilet and VENDOR more if the spiteful vendor is detained; quota of its own, like the plaza (decision
## 103). The second bad sample sends him home and the case is lost there (Cristian, 24/10). If the spiteful vendor is
## still loose at the photo, he pedals off on his vegetable trike from the way out, losing veggies in the curves, and
## the chase starts there (decision 96): caught, he counts as detained; got away, the case is solved all the same. The
## online part comes in the next step. Every number here is (propuesta).

const REFRESH := 0.5
const SHIFT_DELAY := 4.0
const SALARY := 600
const PER_POINT := 4
const TOILET_RUN := 200
const VENDOR := 100
const QUOTA := 400
const STORY := "politician_market"
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"
## Where the trike waits, in the market's space: on the sidewalk past the way out, facing the street.
const TRIKE_AT := Vector3(MarketLevel.EXIT_X + 3.0, 0.05, MarketLevel.HALF_Z + 2.0)

var market: MarketLevel
var briefing: CaseBriefing
var checklist: CaseChecklist
var shift_screen: ShiftScreen
var tip_given := false
var went_home := false
var photo_done := false
var shift_over := false
## The deputy ran to the toilet once.
var toilet_run := false
var jailed := false
## The spiteful vendor's run on the trike and how it ended.
var chase: ChaseCase
var caught := false
var escaped := false
var _result := {}
var _refresh_left := 0.0


func start(comisario: Comisario = null) -> void:
	add_to_group("market_case")
	briefing = CaseBriefing.new()
	add_child(briefing)
	checklist = CaseChecklist.new()
	add_child(checklist)
	briefing.finished.connect(checklist.set_open.bind(true))
	briefing.finished.connect(_hint_all.bind("HINT_GO_MARKET"))
	market.tour.finished.connect(_on_photo)
	market.toilet_run.ran.connect(_on_ran)
	market.toilet_run.went_home.connect(_on_went_home)
	market.spite.jailed.connect(_on_jailed)
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
			briefing.start(PackedStringArray(["BRIEF_MARKET_A", "BRIEF_MARKET_B", "BRIEF_MARKET_C"]))
			break
	checklist.show_rows(rows())


func _on_ran(count: int) -> void:
	if count == 1:
		toilet_run = true
	checklist.show_rows(rows())


func _on_went_home() -> void:
	if photo_done or went_home:
		return
	went_home = true
	_hint_all("HINT_MARKET_WENT_HOME")
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


func _on_jailed() -> void:
	jailed = true
	checklist.show_rows(rows())


## He cut the ribbon: the case is solved, and a loose spiteful vendor runs for his trike.
func _on_photo() -> void:
	if went_home or photo_done:
		return
	photo_done = true
	_hint_all("HINT_MARKET_PHOTO")
	if vendor_loose():
		_run_off()
	else:
		get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)
	checklist.show_rows(rows())


## Neither cuffed, nor being walked to the patrol car, nor in it.
func vendor_loose() -> bool:
	var vendor := market.spite.spiteful
	var escort := OwnerEscort.of(vendor)
	return not vendor.is_cuffed() and not (escort and (escort.escorted_by or escort.in_car))


## The spiteful vendor gets on his trike past the way out: the chase is on.
func _run_off() -> void:
	if chase:
		return
	var vendor := market.spite.spiteful
	vendor.hide()
	vendor.collision_layer = 0
	vendor.process_mode = Node.PROCESS_MODE_DISABLED
	var at := market.global_transform * Transform3D(Basis.IDENTITY, TRIKE_AT)
	chase = ChaseCase.begin(market, SuspectCar.VEGGIE_TRIKE, at, market.car, market.city, market.case_seed)
	chase.who = "vendor"
	chase.ended.connect(_on_chase_ended)
	_hint_all("HINT_ESCAPE_VENDOR")


func _on_chase_ended(was_caught: bool) -> void:
	caught = was_caught
	escaped = not was_caught
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


func solved() -> bool:
	return photo_done and not went_home


## The spiteful vendor in the patrol car, from the market or caught off the trike.
func vendor_detained() -> bool:
	return jailed or caught


## SALARY, less PER_POINT for each point of image lost and TOILET_RUN for the run, plus VENDOR if he's detained;
## nothing if the deputy went home.
func report() -> Dictionary:
	var salary := 0
	if solved():
		salary = SALARY - PER_POINT * roundi(market.image.lost()) - (TOILET_RUN if toilet_run else 0)
		salary = maxi(salary + (VENDOR if vendor_detained() else 0), 0)
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
	var tour := market.tour
	var list: Array[Dictionary] = []
	list.append(_row("OBJ_MARKET_GUARD", tour.state != MarketTour.State.WAITING))
	var stalls := market.stalls.size()
	var walked := stalls if photo_done else mini(tour.stall, stalls)
	list.append(_row(tr("OBJ_MARKET_STALLS") % [walked, stalls], photo_done))
	list.append(_row(tr("OBJ_MARKET_IMAGE") % roundi(market.image.value), false))
	list.append(_row("OBJ_MARKET_VENDOR", vendor_detained()))
	if chase:
		list.append(_row("OBJ_MARKET_CATCH_TRIKE", caught))
	var state := "OBJ_MARKET_WENT_HOME" if went_home else ("OBJ_MARKET_OVER" if photo_done else "OBJ_MARKET_KEEP_SAFE")
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
