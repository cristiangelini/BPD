extends GutTest

## The insurance office's coffee machine safe (docs/diseno/seguros.md, step 5): the kitchen's machine is the main
## evidence, E on it gives coins (the clue), the cups hold coins, and the machine in the trunk solves the case.

const OFFICE_SCENE := preload("res://scenes/levels/insurance_office.tscn")


func _office(case_seed := 5) -> InsuranceOffice:
	var office: InsuranceOffice = OFFICE_SCENE.instantiate()
	office.story_id = "coffee_safe"
	office.case_seed = case_seed
	office.get_node("Cop").input_enabled = false
	office.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(office)
	return office


func test_the_coffee_machine_is_the_main_evidence() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as CoffeeSafeRig
	assert_eq(office.main, rig.safe)
	assert_null(office.coffee, "the plain machine is gone")
	assert_almost_eq((rig.safe as RigidBody3D).mass, 30.0, 0.01)
	assert_gt(rig.safe.mass, GameScale.COP_CARRY_KG, "it takes two")
	assert_lt(rig.safe.position.distance_to(InsuranceOffice.COFFEE_AT), 0.01, "in the kitchen")
	assert_eq(office.extras.size(), 2, "the post-it and the account book")
	assert_eq(rig.cups.size(), 12, "a cup of coins on every desk")


func test_e_on_it_gives_coins_instead_of_coffee() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var rig := office.rig as CoffeeSafeRig
	assert_eq(rig.safe.prompt_key(office.get_node("Cop")), "PROMPT_COFFEE")
	rig.safe.use(office.get_node("Cop"))
	assert_has(office.raid.clues_found, tr("CLUE_COFFEE_COINS"))
	rig.safe.use(office.get_node("Cop"))
	assert_eq(office.raid.clues_found.count(tr("CLUE_COFFEE_COINS")), 1, "once")


func test_the_machine_in_the_trunk_solves_the_case() -> void:
	var office := _office()
	await wait_physics_frames(10)
	var safe := office.main
	safe.global_position = office.car.to_global(Vector3(0, 0.3, -1.7))
	await wait_physics_frames(10)
	assert_true(office.car.is_delivered(safe))
	assert_true(office.raid.mark(office.raid.suspicions.find("coffee_safe")))
	office.car.enter(office.get_node("Cop"))
	assert_true(office.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_COFFEE_SAFE_B", "BRIEF_COFFEE_SAFE_C", "BRIEF_COFFEE_SAFE_D", "OBJ_FIND_COFFEE_SAFE",
			"OBJ_EXTRA_CODE_POSTIT", "OBJ_EXTRA_ACCOUNT_BOOK", "COCA_CLUE_coffee_safe", "PROMPT_COFFEE",
			"CLUE_COFFEE_COINS", "HINT_COFFEE_SAFE"]:
		assert_ne(tr(key), key)
