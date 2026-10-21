class_name CrimeSceneCase
extends Node

## The pastry contest's case (escena-del-crimen.md, step 2): the comisario tells it in his office, the seed picks the
## culprit and his 4 clues (CrimePlan), and Q opens the planilla with what's left to do. The clues go in the tent
## (the carried ones in `items`); `found` notes one and `ruin` loses it. The cooks fill their files (`file_part`); the board
## comes next and sets `accused`.

## How often the open planilla redraws, in seconds.
const REFRESH := 0.5
## A second wrong accusation loses the case (propuesta, like the raid's suspicions).
const MAX_WRONG := 2
const COFFEE_SCENE := preload("res://scenes/props/coffee_cup.tscn")
## Where the carried clues go by a cook's table: the plate and the slice on top, the recipe on the floor at its front,
## half under the cloth, with a coffee on the table's edge just above (propuesta).
const ON_TABLE := {"hair": Vector3(0.6, 0.9, 0), "bite": Vector3(-0.6, 0.9, 0.1), "recipe": Vector3(0.3, 0.05, -0.55)}
const COFFEE_ON_TABLE := Vector3(0.3, 0.9, -0.3)

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
	if wrong_guesses > 0:
		list.append({"text": tr("OBJ_CRIME_WRONG") % [wrong_guesses, MAX_WRONG], "done": false, "optional": false,
			"status": true})
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
