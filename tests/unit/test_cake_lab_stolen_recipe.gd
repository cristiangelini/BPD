extends GutTest

## The cake lab with the stolen recipe's story (docs/diseno/laboratorio.md, step 5): the recipe book baked inside one
## of the cold room's order cakes, the cakes that squash when opened, the copied recipe on the formula board and the
## photo and the cap hidden with the seed.

const LAB_SCENE := preload("res://scenes/levels/cake_lab.tscn")


func _lab(case_seed := 5) -> CakeLab:
	var lab: CakeLab = LAB_SCENE.instantiate()
	lab.story_id = "stolen_recipe"
	lab.case_seed = case_seed
	lab.get_node("Cop").input_enabled = false
	lab.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(lab)
	return lab


func test_the_book_waits_inside_a_cold_room_cake_and_the_extras_are_hidden() -> void:
	var lab := _lab()
	await wait_physics_frames(10)
	var rig := lab.rig as StolenRecipeRig
	assert_eq(lab.main, rig.book)
	assert_almost_eq(rig.book.mass, 0.5, 0.01)
	assert_false(rig.is_found(), "not out yet")
	assert_eq(rig.book.collision_layer, 0, "nobody can grab it inside the cake")
	assert_eq(rig.cakes.size(), StolenRecipeRig.CAKES)
	assert_eq(rig.stuffed, 5 % StolenRecipeRig.CAKES)
	for cake: Ornament in rig.cakes:
		assert_false(cake.is_broken, "the order cakes stand still")
		assert_gt(cake.global_position.x, CakeLab.COLD_X, "in the cold room")
		assert_lt(cake.global_position.z, CakeLab.BACK_Z)
	assert_eq(lab.extras.size(), 2, "the photo and the cap")
	assert_eq(lab.hidden.size(), 2)


func test_opening_a_wrong_cake_is_a_fine_and_the_right_one_gives_the_book() -> void:
	var lab := _lab()
	await wait_physics_frames(10)
	var rig := lab.rig as StolenRecipeRig
	var wrong := (rig.stuffed + 1) % StolenRecipeRig.CAKES
	rig.cakes[wrong].hit(Ornament.BREAK_SPEED + 1.0)
	assert_false(rig.is_found())
	assert_eq(lab.fines, Ornament.FINE, "a squashed order cake")
	var at := rig.cakes[rig.stuffed].global_position
	rig.cakes[rig.stuffed].hit(Ornament.BREAK_SPEED + 1.0)
	assert_true(rig.is_found())
	assert_eq(lab.fines, Ornament.FINE * 2)
	assert_lt(rig.book.global_position.distance_to(at), 0.3, "out where the cake was")
	assert_eq(rig.book.collision_layer, StolenRecipeRig.BOOK_LAYER, "it can be grabbed now")


func test_the_copied_recipe_on_the_board_is_a_clue() -> void:
	var lab := _lab()
	await wait_physics_frames(2)
	var rig := lab.rig as StolenRecipeRig
	rig.recipe.use(lab.get_node("Cop"))
	assert_has(lab.raid.clues_found, tr("CLUE_COPIED_RECIPE"))
	assert_eq(lab.pocha.sample_hint, "HINT_SAMPLE_RECIPE")


func test_the_book_in_the_trunk_solves_the_case() -> void:
	var lab := _lab()
	await wait_physics_frames(10)
	var rig := lab.rig as StolenRecipeRig
	rig.cakes[rig.stuffed].hit(Ornament.BREAK_SPEED + 1.0)
	rig.book.global_position = lab.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(lab.car.is_delivered(rig.book))
	assert_true(lab.raid.mark(lab.raid.suspicions.find("stolen_recipe")))
	lab.car.enter(lab.get_node("Cop"))
	assert_true(lab.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_STOLEN_RECIPE_B", "BRIEF_STOLEN_RECIPE_C", "BRIEF_STOLEN_RECIPE_D",
			"OBJ_FIND_RECIPE_BOOK", "OBJ_EXTRA_DISGUISE_PHOTO", "OBJ_EXTRA_DELIVERY_CAP", "POCHA_CLUE_stolen_recipe",
			"HINT_SAMPLE_RECIPE", "CLUE_COPIED_RECIPE", "PROMPT_COPIED_RECIPE"]:
		assert_ne(tr(key), key)
