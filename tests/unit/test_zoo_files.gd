extends GutTest

## The keepers' files (escena-zoo.md, step 3): KeeperTraits' pecked culprit, ZooKeeper's parts and
## CrimeSceneCase.guard_part at the zoo.

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func test_the_culprit_is_always_pecked_and_the_clues_leave_only_them() -> void:
	for seed_value in range(1, 30):
		var keepers := KeeperTraits.draw(seed_value)
		var culprit := CrimePlan.culprit_of(KeeperTraits.COUNT, seed_value)
		var plan := CrimePlan.draw(keepers, seed_value, CrimeSceneCase.VARIANTS.zoo.clues)
		assert_eq(plan.culprit, culprit, "culprit_of is the plan's culprit")
		assert_true(keepers[culprit].pecked, "seed %d: Copito pecked the culprit" % seed_value)
		var pecked := keepers.filter(func(k: Dictionary) -> bool: return k.pecked).size()
		assert_between(pecked, KeeperTraits.PECKED.x, KeeperTraits.PECKED.y)
		assert_eq(CrimePlan.suspects_left(keepers, keepers[culprit], plan.clues, plan.traits).size(), 1,
			"the clues leave only them")


## A zoo with its case set up, and a cop at hand.
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
	return [zoo, case, cop]


func test_the_case_reaches_the_keepers_with_one_shy() -> void:
	var made := _zoo_case(3)
	var zoo: Zoo = made[0]
	var case: CrimeSceneCase = made[1]
	assert_eq(case.cooks.size(), zoo.keepers.size())
	for keeper in zoo.keepers:
		assert_eq(keeper.case, case)
		assert_eq(keeper.traits, case.cooks[keeper.index], "the keeper is the case's suspect")
	assert_eq(zoo.keepers.filter(func(k: ZooKeeper) -> bool: return k.shy).size(), 1, "one shy keeper")


func test_empty_hands_get_the_smell_then_the_cap_then_the_hands() -> void:
	var made := _zoo_case(4)
	var zoo: Zoo = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var keeper: ZooKeeper = zoo.keepers.filter(func(k: ZooKeeper) -> bool: return not k.shy)[0]
	assert_eq(keeper.prompt_key(cop), "PROMPT_KEEPER_TALK")
	keeper.use(cop)
	assert_eq(keeper.said(), tr("KEEPER_SMELL_" + str(keeper.traits.smell)))
	assert_eq(case.file_traits(keeper.index).smell, keeper.traits.smell, "the smell is in the file")
	assert_eq(keeper.prompt_key(cop), "PROMPT_KEEPER_CAP")
	keeper.use(cop)
	assert_false(keeper.part("cap").visible, "the cap comes off")
	assert_eq(case.file_traits(keeper.index).hair, keeper.traits.hair)
	assert_eq(keeper.prompt_key(cop), "PROMPT_KEEPER_HANDS")
	keeper.use(cop)
	assert_eq(keeper.said(), "KEEPER_HANDS_PECKED" if keeper.traits.pecked else "KEEPER_HANDS_CLEAN")
	assert_eq(case.file_traits(keeper.index).pecked, keeper.traits.pecked)
	assert_eq(keeper.prompt_key(cop), "PROMPT_KEEPER_TALK", "then the smell again")


func test_the_gloves_hide_the_hands() -> void:
	var made := _zoo_case(5)
	var zoo: Zoo = made[0]
	var case: CrimeSceneCase = made[1]
	var keeper: ZooKeeper = zoo.keepers[0]
	keeper.wear_gloves(true)
	keeper.show_hands()
	assert_eq(keeper.said(), "KEEPER_HANDS_GLOVES")
	assert_false(case.file_traits(0).has("pecked"), "nothing for the file with the gloves on")
	keeper.wear_gloves(false)
	keeper.show_hands()
	assert_true(case.file_traits(0).has("pecked"), "bare hands, it goes in")


func test_the_shy_keeper_keeps_the_cap_until_they_eat() -> void:
	var made := _zoo_case(6)
	var zoo: Zoo = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var keeper: ZooKeeper = zoo.keepers.filter(func(k: ZooKeeper) -> bool: return k.shy)[0]
	keeper.use(cop)
	keeper.use(cop)
	assert_eq(keeper.said(), "KEEPER_CAP_NO")
	assert_true(keeper.cap_on)
	var bread := Bread.new()
	add_child_autofree(bread)
	keeper.feed(bread)
	assert_false(keeper.cap_on, "fed, they take it off")
	assert_true(keeper.part("teeth").visible, "and their teeth show")
	assert_true(case.file_parts[keeper.index].teeth and case.file_parts[keeper.index].hair)


func test_a_full_file_and_what_its_card_says() -> void:
	TranslationServer.set_locale("es")
	var made := _zoo_case(8)
	var zoo: Zoo = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var keeper := zoo.keepers[1]
	assert_false(case.file_parts.has(1), "no file yet")
	keeper.photographed(cop)
	assert_eq(keeper.said(), "KEEPER_FLASH")
	var text := case.file_text(1)
	assert_string_contains(text, keeper.traits.name)
	assert_string_contains(text, tr("FILE_SHOE") % keeper.traits.shoe, "the photo shows their boots")
	assert_string_contains(text, tr("FILE_PECK_UNKNOWN"))
	assert_eq(keeper.dusted(cop), tr("PRINTS_COOK") % keeper.traits.name)
	var bread := Bread.new()
	add_child_autofree(bread)
	keeper.feed(bread)
	keeper.shy = false
	keeper.use(cop)
	keeper.use(cop)
	keeper.use(cop)
	assert_true(case.files.has(1), "photo, prints, teeth, smell, hair and hands: done")
	text = case.file_text(1)
	assert_string_contains(text, tr("FILE_SMELL") % tr("SMELL_" + str(keeper.traits.smell)))
	assert_string_contains(text, tr("FILE_PECKED") if keeper.traits.pecked else tr("FILE_NOT_PECKED"))
	assert_string_contains(text, tr("FILE_PRINTS"))
