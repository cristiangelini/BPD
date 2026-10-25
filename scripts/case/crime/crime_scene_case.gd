class_name CrimeSceneCase
extends Node

## The crime scene's case (escena-del-crimen.md, step 2), the same for every place (CrimeScenePlace): the comisario
## tells it in his office, the seed picks the suspects' traits, the culprit and his 4 clues (CrimePlan), and Q opens the
## planilla with what's left to do. The place puts the clues (the carried ones in `items`); `found` notes one and `ruin`
## loses it. The suspects fill their files (`file_part`); the board sets `accused`, and then the culprit gives up or runs
## off in his getaway (`runs_off`). The place's `variant` picks the texts, the traits and the getaway (VARIANTS).

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
## Accused, half the culprits (by the seed) run off on the delivery bike instead of giving up (Cristian, 21/10:
## "que algunos corran y que otros pasen a interrogatorio"; half and half is a propuesta).
const RUNS_EVERY := 2
## At the circus, the trait each part of a clown's file tells.
const PART_TRAITS := {"photo": "glasses", "prints": "name", "teeth": "teeth", "hair": "hair", "shoe": "shoe",
	"honk": "honk"}
## What changes from one place to the other: the campaign's case id and the interrogation's story, the comisario's
## briefing, the hint to go there, who the culprit is for the chase and what he runs off in, which trait each clue
## tells (CrimePlan) and the parts of a suspect's file.
const VARIANTS := {
	"pastry": {
		"shift": "crime_pastry", "story": "pastry",
		"brief": ["BRIEF_CRIME_A", "BRIEF_CRIME_B", "BRIEF_CRIME_C"], "go": "HINT_GO_CONTEST",
		"go_row": "OBJ_CRIME_GO", "look": "HINT_CRIME_LOOK", "files_row": "OBJ_CRIME_FILES",
		"who": "cook", "getaway": SuspectCar.BIKE, "clues": CrimePlan.CLUES,
		"parts": ["photo", "prints", "teeth", "hair"],
	},
	# The circus (escena-circo.md, decision 130): six clowns alike; what hides them comes off for the file.
	"circus": {
		"shift": "crime_circus", "story": "circus",
		"brief": ["BRIEF_CIRCUS_A_", "BRIEF_CIRCUS_B", "BRIEF_CIRCUS_C"], "go": "HINT_GO_CIRCUS",
		"go_row": "OBJ_CIRCUS_GO", "look": "HINT_CIRCUS_LOOK", "files_row": "OBJ_CIRCUS_FILES",
		"who": "clown", "getaway": SuspectCar.BIKE,
		"clues": {"prints": "name", "footprint": "shoe", "hair": "hair", "bite": "teeth", "recording": "honk",
			"witness": "glasses"},
		"parts": ["photo", "prints", "teeth", "hair", "shoe", "honk"],
	},
}

## The comisario's verdict at the board: right, or wrong (and whether that lost the case).
signal verdict(right: bool, lost: bool)

var case_seed := 0
## The scene where it happened (null in some tests: then it plays the pastry case without a place).
var place: CrimeScenePlace
var plan: CrimePlan
## The suspects' traits, in the place's order (CookTraits.draw for the cooks).
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
## The files whose parts are all done (the pastry's: photo, prints, teeth and hair). A file's id is the cook's index,
## or at the circus the number of the sign on a clown's back.
var files: Array[int] = []
## What each file has so far: id -> {part: bool}, with the variant's parts.
var file_parts := {}
## At the circus, what each file says about whoever gave each part: id -> {trait: value}. A file follows its sign,
## so a sign that changed backs mixes two clowns in one file.
var captured := {}
var accused := false
## At the circus, the cops found what was stolen.
var loot_found := false
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
## Online (docs/diseno/online.md): the host's case decides and a guest's follows it (CaseSync); `online` is that sync.
var follower := false
var online: CaseSync
## The end of shift numbers, once it's over (sent to the guests).
var _result := {}
var _refresh_left := 0.0


## Starts the case: the tip waits for a cop to talk to the comisario (right away without one).
func start(comisario: Comisario = null) -> void:
	add_to_group("crime_scene")
	cooks = _draw_suspects()
	plan = CrimePlan.draw(cooks, case_seed, texts().clues)
	if place:
		place.set_up_case(self)
	briefing = CaseBriefing.new()
	add_child(briefing)
	checklist = CaseChecklist.new()
	add_child(checklist)
	briefing.finished.connect(checklist.set_open.bind(true))
	briefing.finished.connect(_hint_all.bind(texts().go))
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
			briefing.start(briefing_lines())
			break
	checklist.show_rows(rows())


## The texts, the traits and the getaway of the place's variant (the pastry's without a place, as in the tests).
func texts() -> Dictionary:
	return VARIANTS[place.variant if place and VARIANTS.has(place.variant) else "pastry"]


## The suspects' traits for this seed, by variant.
func _draw_suspects() -> Array[Dictionary]:
	return ClownTraits.draw(case_seed) if texts() == VARIANTS.circus else CookTraits.draw(case_seed)


## One part of a cook's file is done; with the four, his file is.
func file_part(index: int, part: String) -> void:
	if follower:
		return
	var blank := {}
	for name: String in texts().parts:
		blank[name] = false
	var parts: Dictionary = file_parts.get_or_add(index, blank)
	if parts.get(part, true):
		return
	parts[part] = true
	_hint_all(tr("HINT_FILE_" + part) % file_name(index))
	if parts.values().all(func(done: bool) -> bool: return done) and not files.has(index):
		files.append(index)
		_hint_all(tr("HINT_FILE_DONE") % file_name(index))
	if board:
		board.refresh()
	checklist.show_rows(rows())


## A clown gave a part of his file (escena-circo.md): it goes to the file of the sign on his back, with what it says
## about him. Without a sign it goes nowhere. Returns whether it went to a file.
func clown_part(clown_index: int, part: String) -> bool:
	if follower or not place:
		return false
	var id: int = place.sign_of(clown_index)
	if id < 0:
		_hint_all("HINT_CLOWN_NO_SIGN")
		return false
	var trait_name: String = PART_TRAITS[part]
	(captured.get_or_add(id, {}) as Dictionary)[trait_name] = cooks[clown_index][trait_name]
	file_part(id, part)
	return true


## What a file says about each trait: the cook's own traits, or at the circus what the cops got from whoever wore its
## sign.
func file_traits(id: int) -> Dictionary:
	if texts() == VARIANTS.circus:
		return captured.get(id, {})
	return cooks[id]


## A file's title: the cook's name, or the number of the clown's sign.
func file_name(id: int) -> String:
	if texts() == VARIANTS.circus:
		return tr("FILE_SIGN") % (id + 1)
	return cooks[id].name


## Who a file's accusation points at: the cook, or the clown wearing its sign now (or the last one who did).
func accused_index(id: int) -> int:
	if texts() == VARIANTS.circus and place:
		return place.wearer(id)
	return id


## The cops accused a file at the board; the comisario looks.
func accuse(id: int) -> void:
	if accused or lost or follower:
		return
	if accused_index(id) == plan.culprit:
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


## The culprit gets in his getaway by the scene (the pastry cook's delivery bike) and the chase starts (decision 96).
## Returns false when the level has no place, city or patrol car to chase him with (he gives up instead).
func _run_off() -> bool:
	var level := get_parent()
	var city := level.get_node_or_null("City") as Node3D
	var car := level.get_node_or_null("PatrolCar") as PatrolCar
	if not place or not city or not car:
		return false
	_send_off(place.suspect(plan.culprit))
	var getaway := place.getaway(plan.culprit, city)
	chase = ChaseCase.begin(level, texts().getaway, getaway.at, car, city, case_seed)
	chase.who = texts().who
	chase.online = online
	chase.follower = follower
	var via: Array = getaway.via
	for i in via.size():
		chase.truck.points.insert(1 + i, via[i])
	chase.ended.connect(_on_chase_ended)
	_hint_all(tr("HINT_ESCAPE_" + texts().who) % culprit().name)
	return true


## Caught and in the patrol car, he's in custody for the next interrogation; got away, the case is lost.
func _on_chase_ended(caught: bool) -> void:
	escaped = not caught
	if caught:
		custody = _custody()
	checklist.show_rows(rows())
	get_tree().create_timer(SHIFT_DELAY).timeout.connect(finish_shift)


## Accused, the culprit gives up and goes to a cell: next shift is his interrogation. One who already went home is
## picked up there.
func _take_culprit() -> void:
	custody = _custody()
	_hint_all(tr("HINT_CULPRIT_GIVES_UP") % culprit().name)
	if place and not gone.has(plan.culprit):
		_send_off(place.suspect(plan.culprit))


## The culprit in custody, for the next shift's interrogation.
func _custody() -> Dictionary:
	return {"owner": texts().who, "story": texts().story, "slips": [], "missed": 0}


## Solved: the right cook accused and, if he ran off, caught.
func solved() -> bool:
	return accused and not escaped


## The end of shift screen: the salary if solved, halved by a wrong accusation (ShiftReport). A campaign moves on.
func finish_shift() -> void:
	if shift_over or follower:
		return
	var stats := []
	for cop in get_tree().get_nodes_in_group("cops"):
		stats.append((cop as Cop).stats)
	var report := ShiftReport.pay(solved(), [], 0, wrong_guesses)
	var result := {"solved": solved(), "report": report, "awards": ShiftReport.awards(stats)}
	var campaign := Campaign.current
	if campaign and not campaign.is_over():
		var played := campaign.shift
		campaign.finish_shift(texts().shift, solved(), report, QUOTA)
		campaign.custody = custody
		campaign.save()
		result.campaign = {"shift": played, "money": campaign.money, "over": campaign.is_over(),
			"promoted": campaign.is_promoted()}
	else:
		PlaceDraw.custody = custody
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
	# Online only the host starts the next case.
	shift_screen.get_node("%AgainButton").visible = not over and not follower


## What every guest's case shows (CaseSync, 5 times a second when it changes).
func snapshot() -> Dictionary:
	# Copies: CaseSync keeps the last one sent to see what changed, and these change in place.
	var state := {"tip": tip_given, "at_tent": at_tent, "found": clues_found.duplicate(), "ruined": ruined.duplicate(),
		"parts": file_parts.duplicate(true), "files": files.duplicate(), "accused": accused, "wrong": wrong_guesses,
		"lost": lost, "gone": gone.duplicate(), "escaped": escaped, "loot": loot_found,
		"offended": place != null and place.witness_offended(), "result": _result}
	# The culprit who ran off on his bike, and the chase after him.
	if chase:
		state.chase = chase.snapshot()
	return state


## A guest's case takes the host's: the planilla, the board's files, who went home, the verdict and the end of shift.
func apply_snapshot(state: Dictionary) -> void:
	if state.tip:
		give_tip()
	at_tent = state.at_tent
	clues_found.assign(state.found)
	ruined.assign(state.ruined)
	file_parts = state.parts.duplicate(true)
	files.assign(state.files)
	# The comisario's verdict at the board, said here too.
	if state.wrong > wrong_guesses:
		_comisario_says("BOARD_WRONG_LOST" if state.lost else "BOARD_WRONG")
	elif state.accused and not accused:
		_comisario_says("BOARD_RIGHT")
	wrong_guesses = state.wrong
	lost = state.lost
	escaped = state.escaped
	for index: int in state.gone:
		if not gone.has(index):
			gone.append(index)
			if place:
				_send_off(place.suspect(index))
	if place and state.get("loot", false) and texts() == VARIANTS.circus and not place.loot_found:
		place.reveal_loot()
	if place and state.offended and not place.witness_offended():
		place.offend_witness()
	if state.accused and not accused:
		accused = true
		if state.has("chase"):
			_run_off()
		elif place and not gone.has(plan.culprit):
			_send_off(place.suspect(plan.culprit))
	if chase and state.has("chase"):
		chase.apply_snapshot(state.chase)
	if board:
		board.refresh()
	checklist.show_rows(rows())
	if not state.result.is_empty() and not shift_over:
		_show_result(state.result)


## One more cook is tired and goes home; his file stays as it is. They leave in an order drawn with the seed.
func _tire() -> void:
	if follower:
		return
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
			if place:
				_send_off(place.suspect(index))
			checklist.show_rows(rows())
			return


## A suspect leaves the scene: out of sight and out of the way.
func _send_off(suspect: CollisionObject3D) -> void:
	suspect.hide()
	suspect.collision_layer = 0
	suspect.process_mode = Node.PROCESS_MODE_DISABLED

## The comisario comes to the board and says it (with a player at the keys).
func _comisario_says(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		if (cop as Cop).input_enabled:
			briefing.start(PackedStringArray([key]))
			return
	_hint_all(key)


## The cops found one of the case's clues. Returns whether it's new.
func found(kind: String) -> bool:
	if follower:
		return false
	if not plan.clues.has(kind) or clues_found.has(kind) or ruined.has(kind):
		return false
	clues_found.append(kind)
	_hint_all("HINT_CRIME_CLUE")
	checklist.show_rows(rows())
	return true


## The cops spoiled one of the case's clues before finding it.
func ruin(kind: String) -> void:
	if follower:
		return
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


## What a file card on the board says: what the photo shows, and the rest as the cops got it.
func file_text(index: int) -> String:
	var who := file_traits(index)
	var parts: Dictionary = file_parts[index]
	if texts() == VARIANTS.circus:
		var lines := PackedStringArray([file_name(index)])
		if who.has("glasses"):
			lines.append(tr("FILE_GLASSES") if who.glasses else tr("FILE_NO_GLASSES"))
		else:
			lines.append(tr("FILE_GLASSES_UNKNOWN"))
		lines.append(tr("FILE_SHOE") % who.shoe if who.has("shoe") else tr("FILE_SHOE_UNKNOWN"))
		lines.append(tr("FILE_HONK") % (tr("HONK_" + str(who.honk)) if who.has("honk") else "?"))
		lines.append(tr("FILE_HAIR") % (tr("HAIR_" + str(who.hair)) if who.has("hair") else "?"))
		lines.append(tr("FILE_TEETH") % (tr("TEETH_" + str(who.teeth)) if who.has("teeth") else "?"))
		lines.append(tr("FILE_PRINTS") if who.has("name") else tr("FILE_NO_PRINTS"))
		return "\n".join(lines)
	var lines := PackedStringArray(["%d. %s" % [index + 1, who.name]])
	lines.append(tr("FILE_APRON") % tr("APRON_" + str(who.apron)))
	lines.append(tr("FILE_GLASSES") if who.glasses else tr("FILE_NO_GLASSES"))
	lines.append(tr("FILE_LEFT") if who.left else tr("FILE_RIGHT"))
	lines.append(tr("FILE_SHOE") % who.shoe)
	lines.append(tr("FILE_HAIR") % (tr("HAIR_" + str(who.hair)) if parts.hair else "?"))
	lines.append(tr("FILE_TEETH") % (tr("TEETH_" + str(who.teeth)) if parts.teeth else "?"))
	lines.append(tr("FILE_PRINTS") if parts.prints else tr("FILE_NO_PRINTS"))
	return "\n".join(lines)


## The comisario's briefing: at the circus, the first line says what was stolen (the place drew it).
func briefing_lines() -> PackedStringArray:
	var lines := PackedStringArray(texts().brief)
	if texts() == VARIANTS.circus:
		lines[0] += place.loot if place else "seal"
	return lines


## At the circus, the cops found what was stolen (Circus.search).
func found_loot() -> void:
	if loot_found:
		return
	loot_found = true
	_hint_all("HINT_LOOT_FOUND_" + (place.loot as String))
	checklist.show_rows(rows())


## A cop shouted (VoiceChat): the place's witness may take offense.
func shouted_by(cop: Cop) -> void:
	if follower:
		if online:
			online.request_shout()
		return
	if place:
		place.shouted_by(cop)


## The culprit's traits.
func culprit() -> Dictionary:
	return cooks[plan.culprit]


## The planilla's rows, in the shape CaseChecklist takes.
func rows() -> Array[Dictionary]:
	var list: Array[Dictionary] = []
	list.append(_row(texts().go_row, at_tent))
	list.append(_row(tr("OBJ_CRIME_CLUES") % [clues_found.size(), plan.clues.size()],
		clues_found.size() + ruined.size() >= plan.clues.size()))
	for kind in clues_found:
		list.append({"text": "- " + clue_line(kind), "done": false, "optional": false, "status": true, "clue": true})
	for kind in ruined:
		list.append({"text": "- " + tr("CLUE_CRIME_RUINED_" + kind), "done": false, "optional": false, "status": true})
	list.append(_row(tr(texts().files_row) % [files.size(), cooks.size()], files.size() >= cooks.size()))
	for index: int in file_parts:
		if not files.has(index):
			list.append({"text": "- " + _missing(index), "done": false, "optional": false, "status": true})
	list.append(_row("OBJ_CRIME_ACCUSE", accused))
	if texts() == VARIANTS.circus and place:
		list.append({"text": "OBJ_CIRCUS_LOOT_" + (place.loot as String), "done": loot_found, "optional": true,
			"status": false})
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
	if not tip_given or not place:
		return
	if not accused and not lost:
		elapsed += delta
		if gone.size() < cooks.size() and elapsed >= LEAVE_FROM + gone.size() * LEAVE_EVERY:
			_tire()
	if not at_tent and not follower:
		for cop in get_tree().get_nodes_in_group("cops"):
			if place.at_scene((cop as Node3D).global_position):
				at_tent = true
				_hint_all(texts().look)
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
	return tr("OBJ_FILE_MISSING") % [file_name(index), ", ".join(missing)]


func _row(text: String, done: bool) -> Dictionary:
	return {"text": text, "done": done, "optional": false, "status": false}


func _hint_all(key: String) -> void:
	for cop in get_tree().get_nodes_in_group("cops"):
		(cop as Cop).show_hint(key)
