extends GutTest

## The doll factory's ghost workers (docs/diseno/fabrica.md, step 6): ten mannequins stand at the belt and never
## answer, the time clock's cards are the story's clue, and the payroll book in the trunk solves the case.

const FACTORY_SCENE := preload("res://scenes/levels/doll_factory.tscn")


func _factory(case_seed := 5) -> DollFactory:
	var factory: DollFactory = FACTORY_SCENE.instantiate()
	factory.story_id = "ghost_workers"
	factory.case_seed = case_seed
	factory.get_node("Cop").input_enabled = false
	factory.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(factory)
	return factory


func test_ten_mannequins_at_the_belt_never_answer() -> void:
	var factory := _factory()
	await wait_physics_frames(2)
	var rig := factory.rig as GhostWorkersRig
	assert_eq(rig.mannequins.size(), 10)
	for mannequin: Mannequin in rig.mannequins:
		var at := mannequin.position
		assert_between(at.x, DollFactory.BELT_CORNERS[0].x + 0.5, DollFactory.BELT_CORNERS[3].x - 0.5, "inside the U")
		assert_between(at.z, DollFactory.BELT_CORNERS[1].z + 0.5, DollFactory.BELT_CORNERS[0].z, "inside the U")
		assert_gt(at.distance_to(DollFactory.NILDA_AT), 1.5, "clear of Nilda")
	var mannequin := rig.mannequins[0]
	watch_signals(mannequin)
	assert_eq(mannequin.prompt_key(factory.get_node("Cop")), "PROMPT_ASK_WORKER")
	mannequin.use(factory.get_node("Cop"))
	assert_signal_emitted(mannequin, "asked")
	assert_true((mannequin.get_node("Bubble") as Label3D).visible)


func test_the_time_clock_is_the_clue() -> void:
	var factory := _factory()
	await wait_physics_frames(2)
	var clock := (factory.rig as GhostWorkersRig).clock
	clock.use(factory.get_node("Cop"))
	clock.use(factory.get_node("Cop"))
	assert_eq(factory.raid.clues_found, [tr("CLUE_TIME_CARDS")] as Array[String])


func test_the_book_in_the_trunk_solves_the_case() -> void:
	var factory := _factory()
	await wait_physics_frames(10)
	assert_eq(factory.extras.size(), 2, "the cards and the wig")
	factory.main.global_position = factory.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(factory.car.is_delivered(factory.main))
	assert_true(factory.raid.mark(factory.raid.suspicions.find("ghost_workers")))
	factory.car.enter(factory.get_node("Cop"))
	assert_true(factory.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_GHOST_WORKERS_B", "BRIEF_GHOST_WORKERS_C", "BRIEF_GHOST_WORKERS_D",
			"OBJ_FIND_PAYROLL_BOOK", "OBJ_EXTRA_TIME_CARDS", "OBJ_EXTRA_FOREMAN_WIG", "NILDA_CLUE_ghost_workers",
			"CLUE_TIME_CARDS", "PROMPT_TIME_CLOCK", "PROMPT_ASK_WORKER", "HINT_MANNEQUIN"]:
		assert_ne(tr(key), key)
