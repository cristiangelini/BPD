extends GutTest

## The ghosts' files (escena-teatro.md, step 3): the culprit's deep voice (GhostTraits), TheaterGhost's parts, the
## sheet and the note, and CrimeSceneCase's theater variant (guard_part, file_text).

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func test_the_culprit_always_sings_deep() -> void:
	for seed_value in range(1, 30):
		var ghosts := GhostTraits.draw(seed_value)
		var plan := CrimePlan.draw(ghosts, seed_value, CrimeSceneCase.VARIANTS.theater.clues)
		assert_eq(plan.culprit, CrimePlan.culprit_of(GhostTraits.COUNT, seed_value))
		assert_true(ghosts[plan.culprit].deep, "seed %d: the culprit is hoarse" % seed_value)
		var deep := ghosts.filter(func(g: Dictionary) -> bool: return g.deep).size()
		assert_between(deep, GhostTraits.DEEP.x, GhostTraits.DEEP.y)
		assert_eq(CrimePlan.suspects_left(ghosts, ghosts[plan.culprit], plan.clues, plan.traits).size(), 1,
			"the clues leave only them")


## A theater with its case set up, and a cop at hand.
func _theater_case(seed_value: int) -> Array:
	var theater := Theater.new()
	theater.case_seed = seed_value
	add_child_autofree(theater)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = theater
	add_child_autofree(case)
	case.start()
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	return [theater, case, cop]


func _not_shy(theater: Theater) -> TheaterGhost:
	for ghost in theater.ghosts:
		if not ghost.shy:
			return ghost
	return null


func test_empty_hands_get_the_embroidery_the_sheet_then_a_note() -> void:
	var made := _theater_case(4)
	var theater: Theater = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	assert_eq(case.cooks, GhostTraits.draw(4), "the case's suspects are the ghosts")
	var ghost := _not_shy(theater)
	assert_eq(ghost.prompt_key(cop), "PROMPT_GHOST_TALK")
	ghost.use(cop)
	assert_eq(case.file_traits(ghost.index).embroidery, ghost.traits.embroidery, "the embroidery is in the file")
	assert_eq(ghost.prompt_key(cop), "PROMPT_GHOST_SHEET")
	ghost.use(cop)
	assert_false(ghost.part("sheet").visible, "the sheet comes off")
	assert_eq(case.file_traits(ghost.index).hair, ghost.traits.hair)
	assert_eq(ghost.prompt_key(cop), "PROMPT_GHOST_SING")
	ghost.use(cop)
	assert_eq(ghost.said(), "GHOST_SING_DEEP" if ghost.traits.deep else "GHOST_SING_HIGH")
	assert_eq(case.file_traits(ghost.index).deep, ghost.traits.deep, "the voice is in the file")
	assert_eq(ghost.prompt_key(cop), "PROMPT_GHOST_TALK", "then they talk about their embroidery again")


func test_the_shy_ghost_keeps_the_sheet_until_they_eat() -> void:
	var made := _theater_case(6)
	var theater: Theater = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var shy := theater.ghosts.filter(func(g: TheaterGhost) -> bool: return g.shy)
	assert_eq(shy.size(), 1, "one shy ghost")
	var ghost: TheaterGhost = shy[0]
	ghost.use(cop)
	ghost.use(cop)
	assert_eq(ghost.said(), "GHOST_SHEET_NO")
	assert_true(ghost.sheet_on)
	var bread := Bread.new()
	add_child_autofree(bread)
	ghost.feed(bread)
	assert_true(ghost.part("teeth").visible, "they show their teeth biting")
	assert_false(ghost.sheet_on, "fed, they take it off")
	assert_true(case.file_parts[ghost.index].teeth and case.file_parts[ghost.index].hair)


func test_a_donut_in_hand_goes_to_the_ghost() -> void:
	var made := _theater_case(3)
	var theater: Theater = made[0]
	var cop: Cop = made[2]
	var box := DonutBox.new()
	cop.add_child(box)
	cop.get_node("Grabber").held = box
	var ghost := _not_shy(theater)
	assert_eq(ghost.prompt_key(cop), "PROMPT_GHOST_FEED")
	ghost.use(cop)
	assert_eq(ghost.said(), "GHOST_BITES")
	cop.get_node("Grabber").held = null


func test_a_full_file_and_what_its_card_says() -> void:
	TranslationServer.set_locale("es")
	var made := _theater_case(8)
	var theater: Theater = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var ghost := theater.ghosts[2]
	assert_false(case.file_parts.has(2), "no file yet")
	ghost.photographed(cop)
	assert_eq(ghost.said(), "GHOST_FLASH")
	var text := case.file_text(2)
	assert_string_contains(text, ghost.traits.name)
	assert_string_contains(text, tr("FILE_SHOE") % ghost.traits.shoe, "the photo shows the shoes")
	assert_string_contains(text, tr("FILE_VOICE_UNKNOWN"))
	assert_eq(ghost.dusted(cop), tr("PRINTS_COOK") % ghost.traits.name)
	assert_false(ghost.part("glove_right").visible, "a glove comes off for the prints")
	ghost.shy = false
	ghost.use(cop)
	ghost.use(cop)
	ghost.use(cop)
	var bread := Bread.new()
	add_child_autofree(bread)
	ghost.feed(bread)
	assert_true(case.files.has(2), "photo, prints, teeth, hair, voice and embroidery: done")
	text = case.file_text(2)
	assert_string_contains(text, tr("FILE_EMBROIDERY") % tr("EMBROIDERY_" + ghost.traits.embroidery))
	assert_string_contains(text, tr("FILE_VOICE_DEEP") if ghost.traits.deep else tr("FILE_VOICE_HIGH"))
	for key in ["PROMPT_GHOST_SING", "GHOST_SHEET_NO", "FILE_VOICE_CLEARED", "BRIEF_THEATER_A", "HINT_GHOST_LEFT",
			"HINT_FILE_voice", "FILE_PART_embroidery", "OBJ_THEATER_FILES", "HINT_GO_THEATER"]:
		assert_ne(tr(key), key, "%s is translated" % key)
