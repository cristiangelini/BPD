extends GutTest

## The aquarium's clues (escena-acuario.md, step 5): AquariumClues puts the prints on the big tank's glass, the
## flipper print in the kitchen, the hair in the hood on the bench, the sandwich in the igloo and the ticket in the till
## (AquariumTill); the ink shows on the divers; and CrimeSceneCase says each one on the planilla.

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func _aquarium_case(seed_value: int) -> Array:
	var aquarium := Aquarium.new()
	aquarium.case_seed = seed_value
	add_child_autofree(aquarium)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = aquarium
	add_child_autofree(case)
	case.start()
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	cop.global_position = Vector3(0, 0, 40)
	return [aquarium, case, cop]


## The first seed whose case has (or hasn't) the clue.
func _seed_with(kind: String, has := true) -> int:
	for seed_value in range(1, 200):
		var divers := DiverTraits.draw(seed_value)
		var plan := CrimePlan.draw(divers, seed_value, CrimeSceneCase.VARIANTS.aquarium.clues)
		if plan.clues.has(kind) == has:
			return seed_value
	return -1


func test_each_clue_is_there_only_when_the_case_has_it() -> void:
	for seed_value in [1, 2, 3, 4, 5]:
		var made := _aquarium_case(seed_value)
		var aquarium: Aquarium = made[0]
		var case: CrimeSceneCase = made[1]
		var clues := case.plan.clues
		assert_eq(aquarium.clues.glass.has_prints, clues.has("prints"), "seed %d prints" % seed_value)
		assert_eq(aquarium.has_node("FlipperPrint"), clues.has("footprint"), "seed %d footprint" % seed_value)
		assert_eq(case.items.has("hair"), clues.has("hair"), "seed %d hair" % seed_value)
		assert_eq(aquarium.clues.has_bite, clues.has("bite"), "seed %d bite" % seed_value)
		assert_eq(aquarium.clues.till.has_ticket, clues.has("ticket"), "seed %d ticket" % seed_value)
		assert_true(aquarium.has_node("ForgottenHood"), "the hood is always on the bench")


func test_the_till_gives_the_ticket_and_jams_the_second_time() -> void:
	var made := _aquarium_case(_seed_with("ticket"))
	var aquarium: Aquarium = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var till := aquarium.clues.till
	assert_eq(aquarium.room(till.global_position), "shop")
	assert_eq(till.prompt_key(cop), "PROMPT_TILL_OPEN")
	till.use(cop)
	assert_eq(cop._hint.text, "HINT_TILL_TICKET")
	assert_eq(case.items.ticket, till.ticket)
	till.ticket.bag(cop)
	assert_has(case.clues_found, "ticket", "bagged, it's found")
	assert_string_contains(case.clue_line("ticket"), tr("CARE_" + str(case.culprit().tank)))
	till.use(cop)
	assert_true(till.jammed)
	assert_does_not_have(case.ruined, "ticket", "a bagged ticket is safe")
	var again := _aquarium_case(_seed_with("ticket"))
	var other: AquariumTill = (again[0] as Aquarium).clues.till
	other.use(again[2])
	other.use(again[2])
	assert_has((again[1] as CrimeSceneCase).ruined, "ticket", "shut on the ticket, it's lost")
	assert_eq(other.prompt_key(again[2]), "PROMPT_TILL_JAMMED")


func test_the_sandwich_turns_up_in_the_igloo_and_a_penguin_eats_it_later() -> void:
	var seed_value := _seed_with("bite")
	var made := _aquarium_case(seed_value)
	var aquarium: Aquarium = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	assert_null(aquarium.clues.sandwich, "hidden until someone looks in the igloo")
	aquarium.searched("igloo", cop)
	assert_not_null(aquarium.clues.sandwich)
	assert_eq(case.items.bite, aquarium.clues.sandwich)
	aquarium.clues.sandwich.bag(cop)
	assert_has(case.clues_found, "bite")
	aquarium.clues.penguin_lunch()
	assert_does_not_have(case.ruined, "bite", "bagged, the penguins can't have it")
	var late := _aquarium_case(seed_value)
	(late[0] as Aquarium).clues.penguin_lunch()
	assert_has((late[1] as CrimeSceneCase).ruined, "bite", "a penguin ate it in the igloo")
	(late[0] as Aquarium).searched("igloo", late[2])
	assert_null((late[0] as Aquarium).clues.sandwich, "nothing left to find")


func test_prints_on_the_tank_until_touched_or_wiped() -> void:
	var seed_value := _seed_with("prints")
	var made := _aquarium_case(seed_value)
	var aquarium: Aquarium = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	assert_eq(aquarium.clues.glass.prompt_key(cop), "PROMPT_EMPTY_TANK")
	assert_eq(aquarium.clues.glass.dusted(cop), "PRINTS_TANK")
	assert_has(case.clues_found, "prints")
	aquarium.clues.wipe_the_glass()
	assert_does_not_have(case.ruined, "prints", "found ones are safe")
	var touched := _aquarium_case(seed_value)
	(touched[0] as Aquarium).clues.glass.use(touched[2])
	assert_has((touched[1] as CrimeSceneCase).ruined, "prints")
	var wiped := _aquarium_case(seed_value)
	(wiped[0] as Aquarium).clues.wipe_the_glass()
	assert_has((wiped[1] as CrimeSceneCase).ruined, "prints", "a diver's rag")


func test_the_ink_on_a_hand_is_found() -> void:
	var made := _aquarium_case(_seed_with("ink"))
	var aquarium: Aquarium = made[0]
	var case: CrimeSceneCase = made[1]
	var inked: AquariumDiver
	for diver in aquarium.divers:
		if diver.traits.ink:
			inked = diver
	inked.take_off_glove()
	assert_has(case.clues_found, "ink")


func test_stepping_on_the_flipper_print_wipes_it() -> void:
	var made := _aquarium_case(_seed_with("footprint"))
	var aquarium: Aquarium = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var footprint: FlourPrint = aquarium.get_node("FlipperPrint")
	assert_eq(footprint.shoe, case.culprit().shoe)
	assert_eq(aquarium.room(footprint.global_position), "kitchen")
	cop.global_position = footprint.global_position
	await wait_physics_frames(3)
	assert_has(case.ruined, "footprint")


func test_every_clue_has_its_lines() -> void:
	var made := _aquarium_case(_seed_with("witness"))
	var case: CrimeSceneCase = made[1]
	for kind: String in CrimeSceneCase.VARIANTS.aquarium.clues:
		assert_false(case.clue_line(kind).begins_with("CLUE_"), kind)
		if kind != "ink":
			assert_ne(tr("CLUE_AQUARIUM_RUINED_" + kind), "CLUE_AQUARIUM_RUINED_" + kind)
			assert_ne(tr("HINT_AQUARIUM_RUINED_" + kind), "HINT_AQUARIUM_RUINED_" + kind)
	assert_string_contains(case.clue_line("footprint"), str(case.culprit().shoe))
	assert_string_contains(case.clue_line("witness"), tr("CARE_" + str(case.culprit().tank)))
