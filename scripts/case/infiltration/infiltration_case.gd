class_name InfiltrationCase
extends Node

## The infiltration case (infiltracion.md, step 6), the same for every place (InfiltrationPlace): the comisario
## tells it in his office, Q opens the planilla, the cops go in disguised, gather the evidence (`found`) and cuff the
## boss (Doña Chela at the club). Cuffed, the case is solved and pays SALARY, a third less for each piece of evidence
## missing; quota of its own, like the chase (decision 91). Found out (ClubSuspicion), the boss runs off in their
## getaway and the chase starts in the middle of the case (decision 96): caught, it counts as solved with the evidence
## they have; got away, it's lost. Solved, the boss is in custody and the next shift is their interrogation (decision
## 93, `custody`). The place's `variant` picks the texts and the getaway (VARIANTS). Online the host's
## case decides and the guests' follow it (CaseSync). Every number here is (propuesta).

const REFRESH := 0.5
const SHIFT_DELAY := 3.0
const SALARY := 600
const EVIDENCE := 3
## Two pieces of evidence of three pass the shift.
const QUOTA := 400
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"
## What changes from one place to the other: the campaign's story, the comisario's briefing, the hints, the
## planilla's rows (`rows` + GET_IN, EVIDENCE, CAREFUL and FOUND_OUT), the evidence's names (`evidence` + kind), and
## the boss: who it is for the chase, what it runs off in, its own hint and rows, and what slips out of them in the
## interrogation (`slips` % 1 to 3).
const VARIANTS := {
	"club": {
		"story": "infiltration_club",
		"brief": ["BRIEF_CLUB_A", "BRIEF_CLUB_B", "BRIEF_CLUB_C"],
		"go": "HINT_GO_CLUB", "in": "HINT_CLUB_IN", "found": "HINT_CLUB_EVIDENCE",
		"rows": "OBJ_CLUB_", "evidence": "EVIDENCE_CLUB_",
		"boss": "chela", "getaway": SuspectCar.WALKER,
		"boss_cuffed": "HINT_CHELA_CUFFED", "cuff_row": "OBJ_CLUB_CUFF_CHELA", "catch_row": "OBJ_CLUB_CATCH_CHELA",
		"slips": "CHELA_SLIP_%d",
	},
	# The church choir (infiltracion-coro.md, decision 101): Ernesto runs off in the choir van, with the choir inside.
	"choir": {
		"story": "infiltration_choir",
		"brief": ["BRIEF_CHOIR_A", "BRIEF_CHOIR_B", "BRIEF_CHOIR_C"],
		"go": "HINT_GO_CHOIR", "in": "HINT_CHOIR_IN", "found": "HINT_CLUB_EVIDENCE",
		"rows": "OBJ_CHOIR_", "evidence": "EVIDENCE_CHOIR_",
		"boss": "ernesto", "getaway": SuspectCar.CHOIR_VAN,
		"boss_cuffed": "HINT_ERNESTO_CUFFED", "cuff_row": "OBJ_CHOIR_CUFF_ERNESTO",
		"catch_row": "OBJ_CHOIR_CATCH_ERNESTO",
		"slips": "ERNESTO_SLIP_%d",
	},
	# The mime troupe (infiltracion-mimos.md, decision 170): Pausa runs off "driving" an invisible car.
	"mime": {
		"story": "infiltration_mime",
		"brief": ["BRIEF_MIME_A", "BRIEF_MIME_B", "BRIEF_MIME_C"],
		"go": "HINT_GO_MIME", "in": "HINT_MIME_IN", "found": "HINT_CLUB_EVIDENCE",
		"rows": "OBJ_MIME_", "evidence": "EVIDENCE_MIME_",
		"boss": "pausa", "getaway": SuspectCar.INVISIBLE_CAR,
		"boss_cuffed": "HINT_PAUSA_CUFFED", "cuff_row": "OBJ_MIME_CUFF_PAUSA",
		"catch_row": "OBJ_MIME_CATCH_PAUSA",
		"slips": "PAUSA_SLIP_%d",
	},
	# The costume party (infiltracion-fiesta.md, decision 171): the Sargento Trucho is found by his costume, and a wrong
	# guest cuffed gets a second chance (`second_chance`). He runs off in the party patrol car.
	"party": {
		"story": "infiltration_party",
		"brief": ["BRIEF_PARTY_A", "BRIEF_PARTY_B", "BRIEF_PARTY_C"],
		"go": "HINT_GO_PARTY", "in": "HINT_PARTY_IN", "found": "HINT_PARTY_CLUE",
		"rows": "OBJ_PARTY_", "evidence": "EVIDENCE_PARTY_",
		"boss": "trucho", "getaway": SuspectCar.PARTY_PATROL,
		"boss_cuffed": "HINT_TRUCHO_CUFFED", "cuff_row": "OBJ_PARTY_CUFF_TRUCHO",
		"catch_row": "OBJ_PARTY_CATCH_TRUCHO",
		"slips": "TRUCHO_SLIP_%d", "second_chance": true,
	},
	# The gym (infiltracion-gimnasio.md, decision 172): el Toro jogs off on foot.
	"gym": {
		"story": "infiltration_gym",
		"brief": ["BRIEF_GYM_A", "BRIEF_GYM_B", "BRIEF_GYM_C"],
		"go": "HINT_GO_GYM", "in": "HINT_GYM_IN", "found": "HINT_CLUB_EVIDENCE",
		"rows": "OBJ_GYM_", "evidence": "EVIDENCE_GYM_",
		"boss": "toro", "getaway": SuspectCar.TORO_JOG,
		"boss_cuffed": "HINT_TORO_CUFFED", "cuff_row": "OBJ_GYM_CUFF_TORO", "catch_row": "OBJ_GYM_CATCH_TORO",
		"slips": "TORO_SLIP_%d",
	},
	# The thieves' school (infiltracion-escuela.md): the Director only shows up at the graduation, and drives off in
	# the school's learner car, stalling it.
	"school": {
		"story": "infiltration_school",
		"brief": ["BRIEF_SCHOOL_A", "BRIEF_SCHOOL_B", "BRIEF_SCHOOL_C"],
		"go": "HINT_GO_SCHOOL", "in": "HINT_SCHOOL_IN", "found": "HINT_CLUB_EVIDENCE",
		"rows": "OBJ_SCHOOL_", "evidence": "EVIDENCE_SCHOOL_",
		"boss": "director", "getaway": SuspectCar.LEARNER_CAR,
		"boss_cuffed": "HINT_DIRECTOR_CUFFED", "cuff_row": "OBJ_SCHOOL_CUFF_DIRECTOR",
		"catch_row": "OBJ_SCHOOL_CATCH_DIRECTOR", "slips": "DIRECTOR_SLIP_%d",
	},
	# The restaurant La Cuchara de Oro (infiltracion-restaurante.md, decision 174): the Chef Flambé rides off on the
	# delivery scooter, losing pizzas in the curves.
	"restaurant": {
		"story": "infiltration_restaurant",
		"brief": ["BRIEF_RESTAURANT_A", "BRIEF_RESTAURANT_B", "BRIEF_RESTAURANT_C"],
		"go": "HINT_GO_RESTAURANT", "in": "HINT_RESTAURANT_IN", "found": "HINT_CLUB_EVIDENCE",
		"rows": "OBJ_RESTAURANT_", "evidence": "EVIDENCE_RESTAURANT_",
		"boss": "flambe", "getaway": SuspectCar.PIZZA_SCOOTER,
		"boss_cuffed": "HINT_FLAMBE_CUFFED", "cuff_row": "OBJ_RESTAURANT_CUFF_FLAMBE",
		"catch_row": "OBJ_RESTAURANT_CATCH_FLAMBE", "slips": "FLAMBE_SLIP_%d",
	},
	# The chess club El Peón Dormido (infiltracion-ajedrez.md, decision 175): the Gran Maestro Alfil rides off on a
	# motorized carousel horse that hops at every corner.
	"chess": {
		"story": "infiltration_chess",
		"brief": ["BRIEF_CHESS_A", "BRIEF_CHESS_B", "BRIEF_CHESS_C"],
		"go": "HINT_GO_CHESS", "in": "HINT_CHESS_IN", "found": "HINT_CLUB_EVIDENCE",
		"rows": "OBJ_CHESS_", "evidence": "EVIDENCE_CHESS_",
		"boss": "alfil", "getaway": SuspectCar.CAROUSEL_HORSE,
		"boss_cuffed": "HINT_ALFIL_CUFFED", "cuff_row": "OBJ_CHESS_CUFF_ALFIL",
		"catch_row": "OBJ_CHESS_CATCH_ALFIL", "slips": "ALFIL_SLIP_%d",
	},
}
## With `second_chance`, the first wrong person cuffed only raises everyone's suspicion this much.
const WRONG_CUFF := 50.0

var case_seed := 0
var place: InfiltrationPlace
var briefing: CaseBriefing
var checklist: CaseChecklist
var shift_screen: ShiftScreen
var tip_given := false
## A disguised cop got inside the place.
var got_in := false
var evidence_found: Array[String] = []
var boss_cuffed := false
## Wrong people cuffed (with `second_chance`), and the clue the cops got on their own (the party's boss seen).
var wrong_cuffs := 0
var bonus_clue := false
var found_out := false
## Found out, Doña Chela's run on the walker, and whether she got away.
var chase: ChaseCase
var escaped := false
var caught := false
var shift_over := false
var follower := false
var online: CaseSync
var _result := {}
var _refresh_left := 0.0


func start(comisario: Comisario = null) -> void:
	add_to_group("infiltration")
	briefing = CaseBriefing.new()
	add_child(briefing)
	checklist = CaseChecklist.new()
	add_child(checklist)
	briefing.finished.connect(checklist.set_open.bind(true))
	briefing.finished.connect(_hint_all.bind(texts().go))
	if place:
		place.suspicion.discovered.connect(_on_discovered.unbind(1))
		place.boss.cuffed_now.connect(_on_boss_cuffed.unbind(1))
		for member in place.members:
			member.cuffed_now.connect(_on_grandparent_cuffed)
	if comisario:
		comisario.spoke.connect(give_tip.unbind(1))
		_hint_all("HINT_SEE_COMISARIO")
	else:
		give_tip()
	if shift_screen:
		shift_screen.play_again.connect(_play_again)
		shift_screen.back_to_menu.connect(func() -> void: get_tree().change_scene_to_file(MENU_SCENE))


func _play_again() -> void:
	if online:
		online.play_again()
	else:
		PlaceDraw.start(get_tree())


func give_tip() -> void:
	if tip_given:
		return
	tip_given = true
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).input_enabled:
			briefing.start(PackedStringArray(texts().brief))
			break
	checklist.show_rows(rows())


## The texts and the getaway of the place's variant (the club's without a place, as in the tests).
func texts() -> Dictionary:
	return VARIANTS[place.variant if place and VARIANTS.has(place.variant) else "club"]


## The cops found a piece of evidence (step 6b). Returns whether it's new.
func found(kind: String) -> bool:
	if follower or evidence_found.has(kind) or evidence_found.size() >= EVIDENCE:
		return false
	evidence_found.append(kind)
	_hint_all(texts().found)
	checklist.show_rows(rows())
	return true


func _on_boss_cuffed() -> void:
	if follower or boss_cuffed or shift_over or chase:
		return
	boss_cuffed = true
	_hint_all(texts().boss_cuffed)
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


## Cuffing anyone else gives the cops away at once; with `second_chance`, the first time only raises everyone's
## suspicion WRONG_CUFF (the guest complains and the cuffs run out on their own).
func _on_grandparent_cuffed(member: ClubMember) -> void:
	if follower or not place or place.suspicion.found_out or member == place.boss:
		return
	wrong_cuffs += 1
	if texts().get("second_chance", false) and wrong_cuffs == 1:
		_hint_all("HINT_WRONG_GUEST")
		for other in place.members:
			place.suspicion.raise(other, WRONG_CUFF)
		return
	place.suspicion.raise(member, 100.0)


## The cops got a clue on their own (the party's boss seen in the office): the planilla shows it.
func give_bonus() -> void:
	if follower or bonus_clue:
		return
	bonus_clue = true
	checklist.show_rows(rows())


func _on_discovered() -> void:
	found_out = true
	if not follower and not boss_cuffed and not shift_over:
		_run_off()
	checklist.show_rows(rows())


## The boss leaves and runs off in their getaway, from where the place says: the chase is on.
func _run_off() -> void:
	if chase or not place:
		return
	var boss := place.boss
	boss.hide()
	boss.collision_layer = 0
	boss.process_mode = Node.PROCESS_MODE_DISABLED
	chase = ChaseCase.begin(place, texts().getaway, place.getaway_at(), place.car, place.city, case_seed)
	chase.who = texts().boss
	chase.online = online
	chase.follower = follower
	chase.ended.connect(_on_chase_ended)
	_hint_all("HINT_ESCAPE_" + texts().boss)


## Caught and in the patrol car, the case counts as solved with the evidence they have; got away, it's lost.
func _on_chase_ended(was_caught: bool) -> void:
	caught = was_caught
	escaped = not was_caught
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


func solved() -> bool:
	return boss_cuffed or caught


## The boss the cops took away, for the next shift's interrogation (decision 93), like a raid's owner
## (RaidCase.custody): who they are, what slips out of them and what the evidence left behind was worth (the third of
## the salary each missing piece took off). Empty if it isn't solved.
func custody() -> Dictionary:
	if not solved():
		return {}
	var slips: Array[String] = []
	for i in InterrogationCase.OWNER_SLIPS.size():
		slips.append(texts().slips % (i + 1))
	return {"owner": texts().boss, "story": texts().story, "slips": slips,
		"missed": SALARY * (EVIDENCE - evidence_found.size()) / EVIDENCE}


## The pay: SALARY with all the evidence, a third less for each piece missing.
func report() -> Dictionary:
	var salary := SALARY * evidence_found.size() / EVIDENCE if solved() else 0
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
		campaign.finish_shift(texts().story, solved(), pay, QUOTA)
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


## What every guest's case shows (CaseSync).
func snapshot() -> Dictionary:
	var state := {"tip": tip_given, "in": got_in, "found": evidence_found.duplicate(), "cuffed": boss_cuffed,
		"found_out": found_out, "bonus": bonus_clue, "caught": caught, "escaped": escaped, "result": _result}
	if chase:
		state.chase = chase.snapshot()
	return state


func apply_snapshot(state: Dictionary) -> void:
	if state.tip:
		give_tip()
	got_in = state["in"]
	evidence_found.assign(state.found)
	if state.cuffed and not boss_cuffed:
		boss_cuffed = true
		_hint_all(texts().boss_cuffed)
	found_out = state.found_out
	bonus_clue = state.get("bonus", false)
	caught = state.caught
	escaped = state.escaped
	if state.has("chase"):
		_run_off()
		chase.apply_snapshot(state.chase)
	checklist.show_rows(rows())
	if not state.result.is_empty() and not shift_over:
		_show_result(state.result)


## The planilla's rows, in the shape CaseChecklist takes.
func rows() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	var keys := texts()
	list.append(_row(keys.rows + "GET_IN", got_in))
	list.append(_row(tr(keys.rows + "EVIDENCE") % [evidence_found.size(), EVIDENCE], evidence_found.size() >= EVIDENCE))
	for kind in evidence_found:
		list.append({"text": "- " + tr(keys.evidence + kind), "done": false, "optional": false, "status": true,
			"clue": true})
	var clue := place.clue_row(evidence_found, bonus_clue) if place else ""
	if not clue.is_empty():
		list.append({"text": clue, "done": false, "optional": false, "status": true, "clue": true})
	list.append(_row(keys.cuff_row, boss_cuffed))
	if chase:
		list.append(_row(keys.catch_row, caught))
	list.append({"text": keys.rows + ("FOUND_OUT" if found_out else "CAREFUL"), "done": false, "optional": false,
		"status": true})
	return list


func _physics_process(delta: float) -> void:
	if not tip_given or not place:
		return
	if not got_in and not follower:
		for cop: Cop in get_tree().get_nodes_in_group("cops"):
			if cop.is_disguised(place.suspicion.disguise_look) and place.suspicion.inside.call(cop.global_position):
				got_in = true
				_hint_all(texts()["in"])
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
