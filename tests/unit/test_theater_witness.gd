extends GutTest

## Don Susurro the witness and the honey lozenges (escena-teatro.md, step 6): a lozenge and he whispers the
## embroidery he saw; a shout or a flash and he closes his shell; a lozenge on a ghost before they sing clears their
## voice (HoneyLozenge, TheaterPrompter, TheaterGhost.take_lozenge).

const COP_SCENE := preload("res://scenes/player/cop.tscn")


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


func _with_witness(wanted: bool) -> Array:
	for seed_value in range(1, 200):
		var made := _theater_case(seed_value)
		if (made[1] as CrimeSceneCase).plan.clues.has("witness") == wanted:
			return made
	fail_test("no seed")
	return []


func test_the_lozenges_wait_by_the_booth() -> void:
	var theater: Theater = _theater_case(3)[0]
	assert_eq(theater.lozenges.size(), Theater.LOZENGES)
	for lozenge in theater.lozenges:
		assert_eq(theater.room(lozenge.global_position), "foyer")
	var cop: Cop = _theater_case(3)[2]
	assert_eq(theater.lozenges[0].held_prompt_key(cop), "PROMPT_HOLDING")


func test_a_lozenge_and_he_whispers_the_embroidery() -> void:
	TranslationServer.set_locale("es")
	var made := _with_witness(true)
	var theater: Theater = made[0]
	var case: CrimeSceneCase = made[1]
	var lozenge := theater.lozenges[0]
	theater.prompter.feed(lozenge)
	assert_true(lozenge.eaten)
	assert_false(lozenge.visible)
	assert_has(case.clues_found, "witness")
	var embroidery := tr("EMBROIDERY_" + str(case.culprit().embroidery))
	assert_string_contains(theater.prompter.said(), embroidery)
	assert_string_contains(case.clue_line("witness"), embroidery)
	made = _with_witness(false)
	theater = made[0]
	theater.prompter.feed(theater.lozenges[1])
	assert_eq(theater.prompter.said(), "PROMPTER_NOTHING", "he slept through it")
	assert_does_not_have((made[1] as CrimeSceneCase).clues_found, "witness")


func test_a_shout_or_a_flash_and_he_closes_his_shell() -> void:
	var made := _with_witness(true)
	var theater: Theater = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	cop.global_position = theater.prompter.global_position + Vector3(20, 0, 0)
	theater.shouted_by(cop)
	assert_false(theater.witness_offended(), "too far to hear it")
	cop.global_position = theater.prompter.global_position + Vector3(2, 0, 0)
	theater.shouted_by(cop)
	assert_true(theater.witness_offended())
	assert_true((theater.get_node("ShellLid") as Node3D).visible, "the lid comes down")
	assert_has(case.ruined, "witness")
	theater.prompter.feed(theater.lozenges[0])
	assert_eq(theater.prompter.said(), "PROMPTER_SHELL_CLOSED", "and not a word more")
	made = _with_witness(true)
	theater = made[0]
	theater.prompter.photographed(made[2])
	assert_true(theater.prompter.offended, "the flash too")
	theater.offend_witness()
	assert_true(theater.witness_offended())


func test_a_lozenge_before_singing_clears_the_voice() -> void:
	TranslationServer.set_locale("es")
	var made := _theater_case(5)
	var theater: Theater = made[0]
	var case: CrimeSceneCase = made[1]
	var culprit := theater.ghosts[case.plan.culprit]
	culprit.take_lozenge(theater.lozenges[0])
	assert_true(culprit.cleared)
	culprit.sing()
	assert_eq(culprit.said(), "GHOST_SING_CLEARED")
	assert_does_not_have(case.clues_found, "voice", "a cleared voice tells nothing")
	assert_string_contains(case.file_text(case.plan.culprit), tr("FILE_VOICE_CLEARED"))
	var other := theater.ghosts[(case.plan.culprit + 1) % theater.ghosts.size()]
	other.sing()
	other.take_lozenge(theater.lozenges[1])
	assert_eq(other.said(), "GHOST_LOZENGE_LATE", "too late once they sang")
	assert_false(other.cleared)
	for key in ["PROMPT_LOZENGE_PROMPTER", "PROMPT_LOZENGE_GHOST", "PROMPTER_SAW", "PROMPTER_NOTHING",
			"PROMPTER_SHELL_CLOSED", "GHOST_LOZENGE", "GHOST_LOZENGE_LATE", "GHOST_SING_CLEARED"]:
		assert_ne(tr(key), key, "%s is translated" % key)
