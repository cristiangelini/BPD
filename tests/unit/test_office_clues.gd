extends GutTest

## The office's clues (escena-oficina.md, step 4b): the thief's cup (prints, coffee, handle), the bitten cookie, the
## coffee footprint and Pelusa, who vacuums it unless flipped (OfficeClues, ThiefCup, RobotVacuum).

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func _office_case(seed_value: int) -> Array:
	var office := FormsOffice.new()
	office.case_seed = seed_value
	add_child_autofree(office)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = office
	add_child_autofree(case)
	case.start()
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	cop.global_position = office.to_global(Vector3(0, 0, 12))
	return [office, case, cop]


## A seed whose plan has all these clues.
func _seed_with(kinds: Array) -> int:
	for seed_value in range(1, 300):
		var plan := CrimePlan.draw(OfficeTraits.draw(seed_value), seed_value, CrimeSceneCase.VARIANTS.office.clues)
		if kinds.all(func(kind: String) -> bool: return plan.clues.has(kind)):
			return seed_value
	return -1


func test_the_clues_are_upstairs_as_the_plan_says() -> void:
	for seed_value in range(1, 12):
		var made := _office_case(seed_value)
		var office: FormsOffice = made[0]
		var case: CrimeSceneCase = made[1]
		var cup := office.clues.cup
		assert_eq(office.room_of(cup.global_position + Vector3.UP * 0.1), "manager", "the cup on the manager's desk")
		assert_eq(cup.left, case.culprit().left)
		assert_eq(case.items.has("bite"), case.plan.clues.has("bite"), "the cookie if the bite is a clue")
		assert_eq(office.clues.footprint != null, case.plan.clues.has("footprint"))
		if office.clues.footprint:
			assert_eq(office.floor_of(office.clues.footprint.global_position + Vector3.UP * 0.1), 1, "upstairs")
		assert_false(office.vacuum.running, "Pelusa waits for the cops")


func test_dust_and_photo_first_then_sip() -> void:
	var made := _office_case(_seed_with(["prints", "handle", "coffee"]))
	var office: FormsOffice = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var cup := office.clues.cup
	assert_eq(cup.dusted(cop), "PRINTS_CUP")
	assert_has(case.clues_found, "prints")
	var trails := cup.photo_clues()
	assert_eq(trails.keys(), [case.clue_line("handle")], "a photo catches the handle")
	cup.add_clue(trails.keys()[0])
	assert_has(case.clues_found, "handle")
	assert_eq(cup.prompt_key(cop), "PROMPT_THIEF_CUP")
	cup.use(cop)
	assert_has(case.clues_found, "coffee", "a sip tells the coffee")
	assert_string_contains(case.clue_line("coffee"), tr("COFFEE_" + case.culprit().coffee))
	cup.use(cop)
	cup.use(cop)
	assert_eq(cup.prompt_key(cop), "PROMPT_THIEF_CUP_EMPTY", "three sips and it's gone")
	assert_true(case.ruined.is_empty(), "nothing ruined in that order")


func test_sipping_first_ruins_the_prints_and_the_handle() -> void:
	var made := _office_case(_seed_with(["prints", "handle"]))
	var office: FormsOffice = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	office.clues.cup.use(cop)
	assert_has(case.ruined, "prints")
	assert_has(case.ruined, "handle")
	assert_eq(office.clues.cup.dusted(cop), "PRINTS_CUP_SMUDGED")
	assert_true(office.clues.cup.photo_clues().is_empty(), "the cup is off its ring")


## Runs Pelusa's round for this many seconds.
func _run_vacuum(office: FormsOffice, seconds: float) -> void:
	office.clues._physics_process(0.1)
	for _step in int(seconds / 0.1):
		office.vacuum._physics_process(0.1)


func test_pelusa_vacuums_the_footprint_unless_flipped() -> void:
	var seed_value := _seed_with(["footprint"])
	var made := _office_case(seed_value)
	var office: FormsOffice = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	_run_vacuum(office, 30.0)
	assert_false(office.vacuum.running, "no cop inside yet")
	cop.global_position = office.to_global(Vector3(0, 0, 3))
	_run_vacuum(office, 120.0)
	assert_true(office.vacuum.running, "a cop came in: Pelusa starts")
	assert_true(office.clues.footprint.wiped, "and vacuums the footprint")
	assert_has(case.ruined, "footprint")
	made = _office_case(seed_value)
	office = made[0]
	cop = made[2]
	cop.global_position = office.to_global(Vector3(0, 0, 3))
	assert_eq(office.vacuum.prompt_key(cop), "PROMPT_VACUUM_FLIP")
	office.vacuum.use(cop)
	_run_vacuum(office, 120.0)
	assert_false(office.clues.footprint.wiped, "flipped over, it can't")
	assert_eq(office.vacuum.prompt_key(cop), "PROMPT_VACUUM_UNFLIP")


func test_eating_the_cookie_ruins_the_bite_and_the_texts() -> void:
	var made := _office_case(_seed_with(["bite"]))
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	(case.items.bite as CrimeClueItem).eat(cop)
	assert_has(case.ruined, "bite")
	for kind: String in CrimeSceneCase.VARIANTS.office.clues:
		for key in ["CLUE_OFFICE_RUINED_", "HINT_OFFICE_RUINED_"]:
			assert_ne(tr(key + kind), key + kind)
		assert_false(case.clue_line(kind).begins_with("CLUE_OFFICE_"), "%s has its line" % kind)
	for key in ["PROMPT_THIEF_CUP", "HINT_CUP_SIP", "PRINTS_CUP", "PROMPT_VACUUM_FLIP", "HINT_CLUE_EATEN_bite_office"]:
		assert_ne(tr(key), key)
