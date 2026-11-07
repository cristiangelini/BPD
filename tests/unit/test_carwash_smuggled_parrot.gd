extends GutTest

## The car wash raid with the smuggled parrot (allanamiento-lavadero.md, step 6): the cage with the parrot solves the
## case, and the parrot squawking "¡Lavado premium!" and Don Chorro's lines near a cop is the clue.

const SCENE := preload("res://scenes/levels/car_wash.tscn")


func _car_wash(case_seed := 5) -> CarWash:
	var car_wash: CarWash = SCENE.instantiate()
	car_wash.story_id = "smuggled_parrot"
	car_wash.case_seed = case_seed
	car_wash.get_node("Cop").input_enabled = false
	car_wash.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(car_wash)
	return car_wash


func test_the_cage_with_the_parrot_solves_the_case() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(10)
	assert_has(car_wash.raid.suspicions, "smuggled_parrot")
	assert_eq(car_wash.main.scene_file_path, "res://scenes/props/carwash_parrot_cage.tscn")
	assert_eq(car_wash.extras.size(), 2, "the permit and the birdseed")
	car_wash.main.global_position = car_wash.car.to_global(Vector3(0, 0.9, -1.7))
	await wait_physics_frames(10)
	assert_true(car_wash.car.is_delivered(car_wash.main))
	assert_true(car_wash.raid.mark(car_wash.raid.suspicions.find("smuggled_parrot")))
	car_wash.car.enter(car_wash.get_node("Cop"))
	assert_true(car_wash.raid.case_solved)


func test_the_parrot_squawks_and_a_cop_near_it_gets_the_clue() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	var rig := car_wash.rig as SmuggledParrotRig
	rig.squawk()
	assert_eq(rig.squawks, 1)
	assert_false(rig.heard, "nobody near it")
	car_wash.get_node("Cop").global_position = car_wash.main.global_position + Vector3(2.0, 0.2, 0)
	await wait_physics_frames(2)
	rig._since = SmuggledParrotRig.SQUAWK_EVERY
	await wait_physics_frames(2)
	assert_eq(rig.squawks, 2, "on its own every 15 s")
	assert_true(rig.heard)
	assert_eq(car_wash.raid.clues_found.count(tr("CLUE_PARROT_PREMIUM")), 1, "one clue")


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_SMUGGLED_PARROT_B", "BRIEF_SMUGGLED_PARROT_C", "BRIEF_SMUGGLED_PARROT_D",
			"OBJ_FIND_PARROT_CAGE", "OBJ_EXTRA_EXPORT_PERMIT", "OBJ_EXTRA_BIRDSEED", "POMPITA_CLUE_smuggled_parrot",
			"PARROT_PREMIUM", "PARROT_SAYS", "CLUE_PARROT_PREMIUM"]:
		assert_ne(tr(key), key, key)
	for id: String in CarWash.SUSPICION_POOL:
		assert_true(CarWash.STORIES.has(id), "%s is a story" % id)
