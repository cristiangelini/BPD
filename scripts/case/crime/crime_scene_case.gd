class_name CrimeSceneCase
extends Node

## The pastry contest's case (escena-del-crimen.md, step 2): the comisario tells it in his office, the seed picks the
## culprit and his 4 clues (CrimePlan), and Q opens the planilla with what's left to do. The clues go in the tent
## (the carried ones in `items`); `found` notes one and `ruin` loses it. The cooks fill their files (`file_part`); the board
## sets `accused`, and then the culprit gives up or runs off on his bike (`runs_off`).

## How often the open planilla redraws, in seconds.
const REFRESH := 0.5
## A second wrong accusation loses the case (propuesta, like the raid's suspicions).
const MAX_WRONG := 2
## The cooks get tired (Cristian, 21/10): from this many seconds after the tip, one goes home every LEAVE_EVERY.
const LEAVE_FROM := 480.0
const LEAVE_EVERY := 120.0
## Seconds between the verdict and the end of shift screen.
const SHIFT_DELAY := 3.0
## Its own quota, like the interrogation and the chase (decision 91).
const QUOTA := ShiftReport.SALARY
const MENU_SCENE := "res://scenes/ui/main_menu.tscn"
const COFFEE_SCENE := preload("res://scenes/props/coffee_cup.tscn")
## Where the carried clues go by a cook's table: the plate and the slice on top, the recipe on the floor at its front,
## half under the cloth, with a coffee on the table's edge just above (propuesta).
const ON_TABLE := {"hair": Vector3(0.6, 0.9, 0), "bite": Vector3(-0.6, 0.9, 0.1), "recipe": Vector3(0.3, 0.05, -0.55)}
const COFFEE_ON_TABLE := Vector3(0.3, 0.9, -0.3)
## Accused, half the culprits (by the seed) run off on the delivery bike instead of giving up (Cristian, 21/10:
## "que algunos corran y que otros pasen a interrogatorio"; half and half is a propuesta).
const RUNS_EVERY := 2
## The bike waits this far (m) out of the tent's open front, and rides straight out of the plaza before its route.
const BIKE_OUT := 1.5

## The comisario's verdict at the board: right, or wrong (and whether that lost the case).
signal verdict(right: bool, lost: bool)

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
## Clues the cops spoiled before finding them.
var ruined: Array[String] = []
var flour_print: FlourPrint
## The clues the cops carry and bag (CrimeClueItem), by kind.
var items := {}
## Indexes of the cooks whose file is done: photo, prints, teeth and hair.
var files: Array[int] = []
## What each cook's file has so far: index -> {"photo", "prints", "teeth", "hair": bool}.
var file_parts := {}
var accused := false
var wrong_guesses := 0
var lost := false
## The station's board (CrimeBoard), where the files show up and the cops accuse.
var board: CrimeBoard
var shift_screen: ShiftScreen
var shift_over := false
## Seconds since the tip, while the case is on.
var elapsed := 0.0
## Indexes of the cooks who went home, in the order they left.
var gone: Array[int] = []
## The culprit, caught, for the next shift's interrogation (decision 93), like the raid's owner.
var custody := {}
## The culprit runs off on his bike (runs_off), and the chase once he did; whether he got away.
var chase: ChaseCase
var escaped := false
var _refresh_left := 0.0


## Starts the case: the tip waits for a cop to talk to the comisario (right away without one).
func start(comisario: Comisario = null) -> void:
	add_to_group("crime_scene")
	cooks = CookTraits.draw(case_seed)
	plan = CrimePlan.draw(cooks, case_seed)
	if contest:
		_place_clues()
		_meet_cooks()
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
	if shift_screen:
		shift_screen.play_again.connect(func() -> void: PlaceDraw.start(get_tree()))
		shift_screen.back_to_menu.connect(func() -> void: get_tree().change_scene_to_file(MENU_SCENE))


func give_tip() -> void:
	if tip_given:
		return
	tip_given = true
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).input_enabled:
			briefing.start(PackedStringArray(["BRIEF_CRIME_A", "BRIEF_CRIME_B", "BRIEF_CRIME_C"]))
			break
	checklist.show_rows(rows())


## Puts this case's clues in the tent.
func _place_clues() -> void:
	contest.display_case.case = self
	contest.display_case.has_prints = plan.clues.has("prints")
	contest.lady.case = self
	contest.lady.knows = plan.clues.has("witness")
	if plan.clues.has("footprint"):
		flour_print = FlourPrint.new()
		flour_print.name = "FlourPrint"
		flour_print.case = self
		flour_print.shoe = culprit().shoe
		var spots := PastryContest.FLOUR_SPOTS
		flour_print.position = spots[hash("flour spot %d" % case_seed) % spots.size()]
		contest.add_child(flour_print)
	# Each carried clue on its own table, drawn with the seed.
	var tables := range(PastryContest.TABLES.size())
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("clue tables %d" % case_seed)
	for kind: String in ["hair", "bite", "recipe"]:
		if not plan.clues.has(kind):
			continue
		var table: Vector3 = PastryContest.TABLES[tables.pop_at(rng.randi_range(0, tables.size() - 1))]
		var item := CrimeClueItem.new()
		item.name = "Clue_" + kind
		item.kind = kind
		item.case = self
		item.hair_color = CookTraits.HAIRS[culprit().hair]
		item.position = table + ON_TABLE[kind]
		contest.add_child(item)
		items[kind] = item
		if kind == "recipe":
			var coffee: Node3D = COFFEE_SCENE.instantiate()
			coffee.position = table + COFFEE_ON_TABLE
			contest.add_child(coffee)


## The cooks know the case; one of them (by the seed) won't take off his hat for nothing.
func _meet_cooks() -> void:
	var stubborn := hash("stubborn cook %d" % case_seed) % cooks.size()
	for cook in contest.cooks:
		cook.case = self
		cook.stubborn = cook.index == stubborn


## One part of a cook's file is done; with the four, his file is.
func file_part(index: int, part: String) -> void:
	var parts: Dictionary = file_parts.get_or_add(index, {"photo": false, "prints": false, "teeth": false, "hair": false})
	if parts[part]:
		return
	parts[part] = true
	_hint_all(tr("HINT_FILE_" + part) % cooks[index].name)
	if parts.values().all(func(done: bool) -> bool: return done) and not files.has(index):
		files.append(index)
		_hint_all(tr("HINT_FILE_DONE") % cooks[index].name)
	if board:
		board.refresh()
	checklist.show_rows(rows())


## The cops accused a cook at the board; the comisario looks.
func accuse(index: int) -> void:
	if accused or lost:
		return
	if index == plan.culprit:
		accused = true
		_comisario_says("BOARD_RIGHT")
	else:
		wrong_guesses += 1
		lost = wrong_guesses >= MAX_WRONG
		_comisario_says("BOARD_WRONG_LOST" if lost else "BOARD_WRONG")
	checklist.show_rows(rows())
	verdict.emit(accused, lost)
	if accused and runs_off() and _run_off():
		return
	if accused:
		_take_culprit()
	if accused or lost:
		get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


## Whether this case's culprit runs off when accused, from the seed. One who already went home can't.
func runs_off() -> bool:
	return hash(["crime runs", case_seed]) % RUNS_EVERY == 0 and not gone.has(plan.culprit)


## The culprit gets on his delivery bike by the tent and the chase starts (decision 96). Returns false when the level
## has no city or patrol car to chase him with (he gives up instead).
func _run_off() -> bool:
	var level := get_parent()
	var city := level.get_node_or_null("City") as Node3D
	var car := level.get_node_or_null("PatrolCar") as PatrolCar
	if not contest or not city or not car:
		return false
	var cook := contest.cooks[plan.culprit]
	_send_off(cook)
	var out := contest.to_global(Vector3(contest.to_local(cook.global_position).x, 0, PastryContest.SIZE.y / 2 + BIKE_OUT))
	var at := Transform3D(contest.global_basis, out)
	chase = ChaseCase.begin(level, SuspectCar.BIKE, at, car, city, case_seed)
	chase.who = "cook"
	var plaza := city.global_transform * CityLayout.block_center(CityLayout.PLAZA)
	var ahead := contest.global_basis.z
	var edge := out + ahead * maxf(CityLayout.BLOCK / 2 - 1.0 - (out - plaza).dot(ahead), 0.0)
	chase.truck.points.insert(1, edge)
	chase.ended.connect(_on_chase_ended)
	_hint_all(tr("HINT_ESCAPE_cook") % culprit().name)
	return true


## Caught and in the patrol car, he's in custody for the next interrogation; got away, the case is lost.
func _on_chase_ended(caught: bool) -> void:
	escaped = not caught
	if caught:
		custody = {"owner": "cook", "story": "pastry", "slips": [], "missed": 0}
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


## Accused, the culprit gives up and goes to a cell: next shift is his interrogation. One who already went home is
## picked up there.
func _take_culprit() -> void:
	custody = {"owner": "cook", "story": "pastry", "slips": [], "missed": 0}
	_hint_all(tr("HINT_CULPRIT_GIVES_UP") % culprit().name)
	if contest and not gone.has(plan.culprit):
		_send_off(contest.cooks[plan.culprit])


## Solved: the right cook accused and, if he ran off, caught.
func solved() -> bool:
	return accused and not escaped


## The end of shift screen: the salary if solved, halved by a wrong accusation (ShiftReport). A campaign moves on.
func finish_shift() -> void:
	if shift_over:
		return
	shift_over = true
	var stats := []
	for cop in get_tree().get_nodes_in_group("cops"):
		stats.append((cop as Cop).stats)
	var report := ShiftReport.pay(solved(), [], 0, wrong_guesses)
	var campaign := Campaign.current
	var played := 0
	if campaign and not campaign.is_over():
		played = campaign.shift
		campaign.finish_shift("crime_pastry", solved(), report, QUOTA)
		campaign.custody = custody
		campaign.save()
	else:
		PlaceDraw.custody = custody
	if not shift_screen:
		return
	for cop in get_tree().get_nodes_in_group("cops"):
		cop.input_enabled = false
		cop.get_node("Grabber").input_enabled = false
		cop.get_node("Hud").hide()
	var awards: Array[Dictionary] = []
	awards.assign(ShiftReport.awards(stats))
	shift_screen.show_report(solved(), report, 0, awards)
	var over := false
	if campaign and played > 0:
		shift_screen.show_campaign(played, Campaign.SHIFTS, campaign.money, campaign.is_over(), campaign.is_promoted())
		over = campaign.is_over()
	shift_screen.get_node("%AgainButton").visible = not over


## One more cook is tired and goes home; his file stays as it is. They leave in an order drawn with the seed.
func _tire() -> void:
	var order := range(cooks.size())
	var rng := RandomNumberGenerator.new()
	rng.seed = hash("cooks leave %d" % case_seed)
	for i in range(order.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap: int = order[i]
		order[i] = order[j]
		order[j] = swap
	for index: int in order:
		if not gone.has(index):
			gone.append(index)
			_hint_all(tr("HINT_COOK_LEFT") % cooks[index].name)
			if contest:
				_send_off(contest.cooks[index])
			checklist.show_rows(rows())
			return


## A cook leaves the tent: out of sight and out of the way.
func _send_off(cook: PastryCook) -> void:
	cook.hide()
	cook.collision_layer = 0
	cook.process_mode = Node.PROCESS_MODE_DISABLED

## The comisario comes to the board and says it (with a player at the keys).
func _comisario_says(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).input_enabled:
			briefing.start(PackedStringArray([key]))
			return
	_hint_all(key)


## The cops found one of the case's clues. Returns whether it's new.
func found(kind: String) -> bool:
	if not plan.clues.has(kind) or clues_found.has(kind) or ruined.has(kind):
		return false
	clues_found.append(kind)
	_hint_all("HINT_CRIME_CLUE")
	checklist.show_rows(rows())
	return true


## The cops spoiled one of the case's clues before finding it.
func ruin(kind: String) -> void:
	if not plan.clues.has(kind) or clues_found.has(kind) or ruined.has(kind):
		return
	ruined.append(kind)
	_hint_all("HINT_CRIME_RUINED_" + kind)
	checklist.show_rows(rows())


## A clue's line on the planilla: what it says about the culprit.
func clue_line(kind: String) -> String:
	match kind:
		"footprint":
			return tr("CLUE_CRIME_footprint") % culprit().shoe
		"witness":
			return tr("CLUE_CRIME_witness") % tr("APRON_" + str(culprit().apron))
		"hair":
			return tr("CLUE_CRIME_hair") % tr("HAIR_" + str(culprit().hair))
		"bite":
			return tr("CLUE_CRIME_bite") % tr("TEETH_" + str(culprit().teeth))
		"recipe":
			return tr("CLUE_CRIME_recipe_left" if culprit().left else "CLUE_CRIME_recipe_right")
	return tr("CLUE_CRIME_" + kind)


## A cop shouted (VoiceChat): the jury's lady may take offense.
func shouted_by(cop: Cop) -> void:
	if contest:
		contest.lady.shouted_by(cop)


## The culprit's traits.
func culprit() -> Dictionary:
	return cooks[plan.culprit]


## The planilla's rows, in the shape CaseChecklist takes.
func rows() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	list.append(_row("OBJ_CRIME_GO", at_tent))
	list.append(_row(tr("OBJ_CRIME_CLUES") % [clues_found.size(), plan.clues.size()],
		clues_found.size() + ruined.size() >= plan.clues.size()))
	for kind in clues_found:
		list.append({"text": "- " + clue_line(kind), "done": false, "optional": false, "status": true, "clue": true})
	for kind in ruined:
		list.append({"text": "- " + tr("CLUE_CRIME_RUINED_" + kind), "done": false, "optional": false, "status": true})
	list.append(_row(tr("OBJ_CRIME_FILES") % [files.size(), cooks.size()], files.size() >= cooks.size()))
	for index: int in file_parts:
		if not files.has(index):
			list.append({"text": "- " + _missing(index), "done": false, "optional": false, "status": true})
	list.append(_row("OBJ_CRIME_ACCUSE", accused))
	if chase:
		list.append(_row("OBJ_CRIME_CATCH", chase.case_solved))
	if not gone.is_empty():
		var names := gone.map(func(index: int) -> String: return cooks[index].name)
		list.append({"text": tr("OBJ_CRIME_GONE") % ", ".join(names), "done": false, "optional": false, "status": true})
	if wrong_guesses > 0:
		list.append({"text": tr("OBJ_CRIME_WRONG") % [wrong_guesses, MAX_WRONG], "done": false, "optional": false,
			"status": true})
	list.append({"text": "OBJ_CRIME_CAREFUL", "done": false, "optional": false, "status": true})
	return list


func _physics_process(delta: float) -> void:
	if not tip_given or not contest:
		return
	if not accused and not lost:
		elapsed += delta
		if gone.size() < cooks.size() and elapsed >= LEAVE_FROM + gone.size() * LEAVE_EVERY:
			_tire()
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


## "Clara: falta foto, dientes", for a file begun but not done.
func _missing(index: int) -> String:
	var parts: Dictionary = file_parts[index]
	var missing: PackedStringArray = []
	for part: String in parts:
		if not parts[part]:
			missing.append(tr("FILE_PART_" + part))
	return tr("OBJ_FILE_MISSING") % [cooks[index].name, ", ".join(missing)]


func _row(text: String, done: bool) -> Dictionary:
	return {"text": text, "done": done, "optional": false, "status": false}


func _hint_all(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(key)
