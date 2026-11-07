extends GutTest

## The mansion's vases that break and the señora's tea (escena-gato.md, step 5, fourth part; MansionVase,
## MansionTeapot, TeaCup, CatPatience.serve_tea).


func _mansion_case(seed_value := 3) -> Array:
	var mansion := CatMansion.new()
	mansion.case_seed = seed_value
	add_child_autofree(mansion)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = mansion
	add_child_autofree(case)
	case.start()
	return [mansion, case]


func test_the_vases_rest_on_their_pedestals() -> void:
	var mansion: CatMansion = _mansion_case()[0]
	assert_eq(mansion.vases.size(), CatMansion.VASES.size())
	await wait_physics_frames(30)
	for i in mansion.vases.size():
		var vase := mansion.vases[i]
		assert_false(vase.broken, "vase %d stands" % i)
		assert_almost_eq(mansion.to_local(vase.global_position).y, CatMansion.PEDESTAL_SIZE.y, 0.05)


func test_a_vase_knocked_off_breaks_and_costs() -> void:
	var made := _mansion_case()
	var mansion: CatMansion = made[0]
	var case: CrimeSceneCase = made[1]
	var vase := mansion.vases[1]
	await wait_physics_frames(5)
	vase.linear_velocity = Vector3(2.5, 0.5, 0)
	await wait_seconds(1.0)
	assert_true(vase.broken, "off the pedestal and onto the floor")
	assert_eq(vase.collision_layer, 0)
	assert_eq(case.fines, CatMansion.VASE_FINE)
	assert_eq(mansion.patience.value, CatPatience.FULL - CatPatience.COSTS.vase)
	assert_eq(mansion.lady.said(), "MANSION_LADY_ANNOYED_vase")
	assert_almost_eq(mansion.to_local(vase.global_position).y, CatMansion.FLOOR_TOP, 0.1, "the pieces on the floor")


func test_holding_a_vase_doesnt_break_it() -> void:
	var mansion: CatMansion = _mansion_case()[0]
	var vase := mansion.vases[0]
	await wait_physics_frames(5)
	vase.hold(get_instance_id(), vase.global_position + Vector3.UP * 0.3)
	await wait_physics_frames(20)
	assert_false(vase.broken)


func test_a_cup_of_tea_gives_her_patience_once() -> void:
	var made := _mansion_case()
	var mansion: CatMansion = made[0]
	var patience := mansion.patience
	patience.lose("wrong_cat")
	assert_eq(mansion.teapot.prompt_key(null), "PROMPT_TEAPOT")
	mansion.teapot.use(null)
	var cup := mansion.teapot.cup
	assert_not_null(cup)
	assert_eq(mansion.room(cup.global_position), "kitchen")
	mansion.teapot.use(null)
	assert_eq(get_tree().get_nodes_in_group("tea_cups").size(), 1, "one cup at a time")
	cup.global_position = mansion.lady.global_position + Vector3(0.5, 1.0, 0.3)
	cup.hold(get_instance_id(), cup.global_position)
	await wait_physics_frames(2)
	assert_true(patience.had_tea)
	assert_eq(patience.value, CatPatience.FULL - CatPatience.COSTS.wrong_cat + CatPatience.TEA)
	assert_eq(mansion.lady.said(), "MANSION_LADY_TEA")
	await wait_physics_frames(1)
	mansion.teapot.use(null)
	var second := mansion.teapot.cup
	assert_ne(second, cup, "a new cup once the first is gone")
	second.global_position = mansion.lady.global_position + Vector3(0.5, 1.0, 0.3)
	second.hold(get_instance_id(), second.global_position)
	await wait_physics_frames(2)
	assert_eq(patience.value, CatPatience.FULL - CatPatience.COSTS.wrong_cat + CatPatience.TEA, "only once")
	assert_eq(mansion.lady.said(), "MANSION_LADY_TEA_AGAIN")
	TranslationServer.set_locale("es")
	for key in ["HINT_VASE_BROKEN", "PROMPT_TEAPOT", "MANSION_LADY_TEA", "PROMPT_HOLDING_TEA"]:
		assert_ne(tr(key), key, "%s is translated" % key)
