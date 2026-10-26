extends GutTest

## Pocha, the cake lab's assistant (laboratorio.md, step 3): she only talks to whoever tries her new cake, once per
## cop, and the sample keeps the cop's hands busy for a moment.

const LAB_SCENE := preload("res://scenes/levels/cake_lab.tscn")


func _lab() -> CakeLab:
	var lab: CakeLab = LAB_SCENE.instantiate()
	lab.get_node("Cop").input_enabled = false
	add_child_autofree(lab)
	return lab


func test_she_stands_behind_her_tray() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	assert_lt(lab.pocha.global_position.distance_to(CakeLab.POCHA_AT), 0.01)
	var cop: Cop = lab.get_node("Cop")
	assert_eq(lab.pocha.prompt_key(cop), "PROMPT_POCHA_SAMPLE")
	assert_ne(tr("PROMPT_POCHA_SAMPLE"), "PROMPT_POCHA_SAMPLE")


func test_a_sample_busies_the_hands_and_she_tells_once() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	lab.pocha.clue = "she saw it"
	lab.pocha.clue_speech = "I saw the chef hide something"
	var told := []
	lab.pocha.told.connect(func(text: String) -> void: told.append(text))
	var cop: Cop = lab.get_node("Cop")
	lab.pocha.use(cop)
	assert_true(cop.is_eating(), "chewing")
	assert_eq(told, ["she saw it"])
	assert_eq(lab.pocha.get_node("Bubble").text, "I saw the chef hide something")
	assert_eq(lab.pocha.prompt_key(cop), "PROMPT_POCHA_TASTED")
	lab.pocha.use(cop)
	assert_eq(told.size(), 1, "one sample per cop")
	assert_eq(lab.pocha.get_node("Bubble").text, "POCHA_AGAIN")
	# Its movement ticks drive the chewing (input is off in tests).
	cop.step(LabAssistant.TASTE_TIME + 0.1, Vector2.ZERO, false, false, false)
	assert_false(cop.is_eating(), "done chewing")


func test_with_nothing_seen_she_only_offers_more() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	# The story tells her what she saw; with nothing to tell:
	lab.pocha.clue = ""
	lab.pocha.clue_speech = ""
	var cop: Cop = lab.get_node("Cop")
	lab.pocha.use(cop)
	assert_true(cop.is_eating())
	assert_false(lab.pocha.has_told)
	assert_eq(lab.pocha.get_node("Bubble").text, "POCHA_NOTHING")


func test_a_story_can_flavour_the_sample() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	lab.pocha.sample_hint = "HINT_TEST"
	var cop: Cop = lab.get_node("Cop")
	var tasters := []
	lab.pocha.tasted.connect(func(who: Cop) -> void: tasters.append(who))
	lab.pocha.use(cop)
	assert_eq(tasters, [cop])
	assert_eq(cop.get_node("Hud/Hint").text, "HINT_TEST")
