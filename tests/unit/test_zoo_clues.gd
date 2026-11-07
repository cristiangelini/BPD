extends GutTest

## The zoo's clues (escena-zoo.md, step 6): ZooClues, ZooBlanket, the glass's prints, the peck and Don Pico as the
## witness, and what spoils each one.

const COP_SCENE := preload("res://scenes/player/cop.tscn")


## A seed whose case has the clue `kind` among its four.
func _seed_with(kind: String) -> int:
	for seed_value in range(1, 300):
		var plan := CrimePlan.draw(KeeperTraits.draw(seed_value), seed_value, CrimeSceneCase.VARIANTS.zoo.clues)
		if plan.clues.has(kind):
			return seed_value
	return 0


func _zoo_case(seed_value: int) -> Array:
	var zoo := Zoo.new()
	zoo.case_seed = seed_value
	add_child_autofree(zoo)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = zoo
	add_child_autofree(case)
	case.start()
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	cop.global_position = zoo.to_global(Vector3(0, 0.1, 18))
	return [zoo, case, cop]


func _hint(cop: Cop) -> String:
	return cop.get_node("Hud/Hint").text


func test_every_clue_comes_up_and_has_its_line() -> void:
	TranslationServer.set_locale("es")
	for kind: String in CrimeSceneCase.VARIANTS.zoo.clues:
		var seed_value := _seed_with(kind)
		assert_ne(seed_value, 0, "%s comes up" % kind)
		var made := _zoo_case(seed_value)
		var case: CrimeSceneCase = made[1]
		assert_eq(case.plan.clues.size(), 4)
		assert_false(case.clue_line(kind).begins_with("CLUE_"), "%s has its line" % kind)
		assert_ne(tr("CLUE_ZOO_RUINED_" + kind), "CLUE_ZOO_RUINED_" + kind)
		assert_ne(tr("HINT_ZOO_RUINED_" + kind), "HINT_ZOO_RUINED_" + kind)


func test_the_glass_prints_are_taken_or_cleaned() -> void:
	var made := _zoo_case(_seed_with("prints"))
	var zoo: Zoo = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	assert_eq(zoo.room(zoo.clues.glass.global_position), "grounds", "on the visitors' side of the glass")
	assert_eq(zoo.clues.glass.dusted(cop), "PRINTS_GLASS")
	assert_true(case.clues_found.has("prints"))
	made = _zoo_case(_seed_with("prints"))
	zoo = made[0]
	case = made[1]
	zoo.clues.clock = ZooClues.GLASS_CLEANED_AT - 0.05
	await wait_physics_frames(10)
	assert_true(zoo.clues.glass_cleaned)
	assert_true(case.ruined.has("prints"), "a keeper cleaned the glass")


func test_the_boot_print_in_the_mud_and_the_ostrich() -> void:
	var made := _zoo_case(_seed_with("footprint"))
	var zoo: Zoo = made[0]
	var case: CrimeSceneCase = made[1]
	var mud := zoo.clues.footprint
	assert_eq(zoo.room(mud.global_position), "penguins", "by the pool")
	assert_eq(mud.shoe, case.culprit().shoe)
	assert_eq(mud.photo_clues().size(), 1, "a photo catches it")
	var ostrich := zoo.animals.ostrich as ZooAnimal
	ostrich.release()
	ostrich.set_process(false)
	ostrich.global_position = mud.global_position
	await wait_physics_frames(3)
	assert_true(mud.wiped, "the ostrich ran over it")
	assert_true(case.ruined.has("footprint"))


func test_the_blanket_smells_of_the_culprit_until_its_soaked() -> void:
	TranslationServer.set_locale("es")
	var made := _zoo_case(_seed_with("blanket"))
	var zoo: Zoo = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var blanket := zoo.clues.blanket
	assert_true(zoo.on_floe(blanket.global_position), "on Copito's floe")
	blanket.use(cop)
	assert_eq(_hint(cop), tr("HINT_ZOO_BLANKET") % tr("SMELL_" + str(case.culprit().smell)))
	assert_true(case.clues_found.has("blanket"))
	made = _zoo_case(_seed_with("blanket"))
	zoo = made[0]
	case = made[1]
	cop = made[2]
	zoo.spray(zoo.clues.blanket.global_position, 2.0)
	assert_true(case.ruined.has("blanket"), "the elephant soaked it")
	zoo.clues.blanket.use(cop)
	assert_eq(_hint(cop), "HINT_ZOO_BLANKET_WET")


func test_the_cap_and_the_cookie_are_lost_to_the_animals() -> void:
	var seed_value := 0
	for s in range(1, 300):
		var plan := CrimePlan.draw(KeeperTraits.draw(s), s, CrimeSceneCase.VARIANTS.zoo.clues)
		if plan.clues.has("hair") and plan.clues.has("bite"):
			seed_value = s
			break
	assert_ne(seed_value, 0)
	var made := _zoo_case(seed_value)
	var zoo: Zoo = made[0]
	var case: CrimeSceneCase = made[1]
	var cap := case.items.hair as CrimeClueItem
	var cookie := case.items.bite as CrimeClueItem
	assert_eq(cap.look, "zoo")
	assert_eq(zoo.room(cookie.global_position), "entrance", "on the ticket booth's counter")
	zoo.spray(cap.global_position, 1.0)
	assert_true(case.ruined.has("hair"), "soaked, the hair is gone")
	var monkey := zoo.animals.monkey as ZooAnimal
	monkey.release()
	monkey.global_position = cookie.global_position + Vector3(0.3, -cookie.global_position.y, 0)
	await wait_frames(5)
	assert_eq(monkey.carried, cookie, "the monkey took it")
	assert_true(case.ruined.has("bite"), "and ate it")


func test_the_peck_is_found_on_a_band_aid() -> void:
	var made := _zoo_case(_seed_with("peck"))
	var zoo: Zoo = made[0]
	var case: CrimeSceneCase = made[1]
	var clean: ZooKeeper
	for keeper in zoo.keepers:
		if not keeper.traits.pecked:
			clean = keeper
	clean.show_hands()
	assert_false(case.clues_found.has("peck"), "no band-aid, nothing")
	zoo.keepers[case.plan.culprit].show_hands()
	assert_true(case.clues_found.has("peck"))


func test_don_pico_tells_for_peanuts_until_a_flash() -> void:
	TranslationServer.set_locale("es")
	var made := _zoo_case(_seed_with("witness"))
	var zoo: Zoo = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var pico := zoo.parrot
	assert_true(pico.knows)
	assert_eq(pico.prompt_key(cop), "PROMPT_ZOO_PARROT")
	pico.feed()
	var smell := tr("SMELL_" + str(case.culprit().smell)).to_upper()
	assert_eq(pico.said(), tr("PARROT_SAW") % [smell, smell])
	assert_true(case.clues_found.has("witness"))
	made = _zoo_case(_seed_with("witness"))
	zoo = made[0]
	case = made[1]
	cop = made[2]
	zoo.parrot.photographed(cop)
	assert_true(case.ruined.has("witness"), "flash: he only says that now")
	zoo.parrot.feed()
	assert_eq(zoo.parrot.said(), "PARROT_FLASH")
