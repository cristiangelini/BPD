extends GutTest

## The cake lab with the sleepy cakes' story (docs/diseno/laboratorio.md, step 5): the jar of sleeping powder and its
## extras hidden with the seed, Pocha's sample that makes you yawn, and the free slices on the showcase that put a cop
## to sleep.

const LAB_SCENE := preload("res://scenes/levels/cake_lab.tscn")


func _lab(case_seed := 5) -> CakeLab:
	var lab: CakeLab = LAB_SCENE.instantiate()
	lab.story_id = "sleepy_cakes"
	lab.case_seed = case_seed
	lab.get_node("Cop").input_enabled = false
	lab.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(lab)
	return lab


func test_the_jar_is_hidden_with_its_extras() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	assert_eq(lab.main, lab.hidden[0])
	assert_almost_eq((lab.main as RigidBody3D).mass, 1.0, 0.01)
	assert_eq(lab.extras.size(), 2, "the list and the spoon")
	assert_eq(lab.hidden_spots.size(), 3)
	assert_eq(lab.hidden_spots.filter(func(s: int) -> bool: return lab.hidden_spots.count(s) == 1).size(), 3,
		"each in its own spot")


func test_pochas_sample_makes_you_yawn_and_is_a_clue_once() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	assert_eq(lab.pocha.sample_hint, "HINT_SAMPLE_YAWN")
	lab.pocha.use(lab.get_node("Cop"))
	assert_has(lab.raid.clues_found, tr("CLUE_YAWN"))


func test_a_free_slice_puts_the_cop_to_sleep() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	var rig := lab.rig as SleepyCakesRig
	var cop: Cop = lab.get_node("Cop")
	assert_eq(rig.plate.prompt_key(cop), "PROMPT_EAT_SLICE")
	rig.plate.use(cop)
	assert_eq(rig.dozes, 1)
	assert_true(cop.is_staggered(), "can't move")
	assert_true(cop.is_eating(), "can't grab")
	var zzz := cop.get_children().filter(func(n: Node) -> bool: return n is Label3D and n.text == "Zzz")
	assert_eq(zzz.size(), 1, "the Zzz over the head")
	cop.step(SleepyCakesRig.SLEEP_TIME + 0.1, Vector2.ZERO, false, false, false)
	assert_false(cop.is_staggered(), "awake again")


func test_the_jar_in_the_trunk_solves_the_case() -> void:
	var lab := _lab()
	await wait_physics_frames(10)
	lab.main.global_position = lab.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(lab.car.is_delivered(lab.main))
	assert_true(lab.raid.mark(lab.raid.suspicions.find("sleepy_cakes")))
	lab.car.enter(lab.get_node("Cop"))
	assert_true(lab.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_SLEEPY_CAKES_B", "BRIEF_SLEEPY_CAKES_C", "BRIEF_SLEEPY_CAKES_D", "OBJ_FIND_SLEEP_POWDER",
			"OBJ_EXTRA_SLEEPERS_LIST", "OBJ_EXTRA_MEASURING_SPOON", "POCHA_CLUE_sleepy_cakes", "HINT_SAMPLE_YAWN",
			"CLUE_YAWN", "PROMPT_EAT_SLICE", "HINT_SLEEPY_CAKE"]:
		assert_ne(tr(key), key)
