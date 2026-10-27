extends GutTest

## The nephews' files (escena-gato.md, step 4): the culprit's scratch (NephewTraits), MansionNephew's parts and
## CrimeSceneCase's cat variant (guard_part, file_text).

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func test_the_culprit_always_has_a_scratch() -> void:
	for seed_value in range(1, 30):
		var nephews := NephewTraits.draw(seed_value)
		var plan := CrimePlan.draw(nephews, seed_value, CrimeSceneCase.VARIANTS.cat.clues)
		assert_eq(plan.culprit, CrimePlan.culprit_of(NephewTraits.COUNT, seed_value))
		assert_ne(nephews[plan.culprit].scratch, "", "seed %d: Duquesa scratched the culprit" % seed_value)
		var scratched := nephews.filter(func(n: Dictionary) -> bool: return n.scratch != "").size()
		assert_between(scratched, NephewTraits.SCRATCHED.x, NephewTraits.SCRATCHED.y)
		assert_eq(CrimePlan.suspects_left(nephews, nephews[plan.culprit], plan.clues, plan.traits).size(), 1,
			"the clues leave only him")


## A mansion with its case set up, and a cop at hand.
func _mansion_case(seed_value: int) -> Array:
	var mansion := CatMansion.new()
	mansion.case_seed = seed_value
	add_child_autofree(mansion)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = mansion
	add_child_autofree(case)
	case.start()
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	return [mansion, case, cop]


func test_empty_hands_get_the_talk_then_the_beanie_then_the_sleeves() -> void:
	var made := _mansion_case(4)
	var mansion: CatMansion = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	assert_eq(case.cooks, NephewTraits.draw(4), "the case's suspects are the nephews")
	var nephew: MansionNephew
	for n in mansion.nephews:
		if not n.stubborn and n.traits.scratch != "":
			nephew = n
	assert_eq(nephew.prompt_key(cop), "PROMPT_NEPHEW_TALK")
	nephew.use(cop)
	assert_string_contains(nephew.said(), nephew.catchphrase())
	assert_true(case.file_parts[nephew.index].tic, "the catchphrase is in the file")
	assert_eq(case.file_traits(nephew.index).tic, nephew.traits.tic)
	assert_eq(nephew.prompt_key(cop), "PROMPT_NEPHEW_BEANIE")
	nephew.use(cop)
	assert_false(nephew.part("beanie").visible, "the beanie comes off")
	assert_eq(case.file_traits(nephew.index).hair, nephew.traits.hair)
	assert_eq(nephew.prompt_key(cop), "PROMPT_NEPHEW_SLEEVES")
	nephew.use(cop)
	var hand: String = nephew.traits.scratch
	assert_true(nephew.part("scratch_" + hand).visible, "the scratch shows on its hand")
	for other in NephewTraits.HANDS:
		assert_false(nephew.part("cuff_" + other).visible, "the sleeves are up")
		if other != hand:
			assert_false(nephew.part("scratch_" + other).visible)
	assert_eq(nephew.said(), "NEPHEW_SCRATCH_ROSES", "the rose bush did it, he says")
	assert_eq(case.file_traits(nephew.index).scratch, hand)
	assert_eq(nephew.prompt_key(cop), "PROMPT_NEPHEW_TALK", "then he talks again")


func test_the_stubborn_nephew_keeps_the_beanie_until_he_eats() -> void:
	var made := _mansion_case(6)
	var mansion: CatMansion = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var stubborn := mansion.nephews.filter(func(n: MansionNephew) -> bool: return n.stubborn)
	assert_eq(stubborn.size(), 1, "one stubborn nephew")
	var nephew: MansionNephew = stubborn[0]
	nephew.use(cop)
	nephew.use(cop)
	assert_eq(nephew.said(), "NEPHEW_BEANIE_NO")
	assert_true(nephew.beanie_on)
	var bread := Bread.new()
	add_child_autofree(bread)
	nephew.feed(bread)
	assert_true(nephew.part("teeth").visible, "he shows his teeth biting")
	assert_false(nephew.beanie_on, "fed, he takes it off")
	assert_true(case.file_parts[nephew.index].teeth and case.file_parts[nephew.index].hair)


func test_a_full_file_and_what_its_card_says() -> void:
	TranslationServer.set_locale("es")
	var made := _mansion_case(8)
	var mansion: CatMansion = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var nephew := mansion.nephews[2]
	assert_false(case.file_parts.has(2), "no file yet")
	nephew.photographed(cop)
	assert_eq(nephew.said(), "NEPHEW_NO_FLASH")
	var text := case.file_text(2)
	assert_string_contains(text, nephew.traits.name)
	assert_string_contains(text, tr("FILE_SHOE") % nephew.traits.shoe, "the photo shows the shoes")
	assert_string_contains(text, tr("FILE_SCRATCH_UNKNOWN"))
	assert_eq(nephew.dusted(cop), tr("PRINTS_COOK") % nephew.traits.name)
	var bread := Bread.new()
	add_child_autofree(bread)
	nephew.feed(bread)
	nephew.stubborn = false
	nephew.use(cop)
	nephew.use(cop)
	nephew.use(cop)
	assert_true(case.files.has(2), "photo, prints, teeth, hair, scratch and catchphrase: done")
	text = case.file_text(2)
	assert_string_contains(text, tr("FILE_TIC") % nephew.catchphrase())
	var scratch: String = nephew.traits.scratch
	assert_string_contains(text, tr("FILE_SCRATCH_" + (scratch.to_upper() if scratch != "" else "NONE")))
	for key in ["PROMPT_NEPHEW_BEANIE", "NEPHEW_BEANIE_NO", "FILE_SCRATCH_LEFT", "FILE_TIC", "NEPHEW_NO_FLASH"]:
		assert_ne(tr(key), key, "%s is translated" % key)
