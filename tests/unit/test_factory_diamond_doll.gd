extends GutTest

## The doll factory as a raid with the diamond doll's story (docs/diseno/fabrica.md, step 5): the suspicions, the bin
## of finished dolls with the heavy one drawn with the seed, the quality control sheet and the scale as its clues, what
## Fermín lets slip and what Nilda saw, the office key in the till and the doll in the trunk solving the case.

const FACTORY_SCENE := preload("res://scenes/levels/doll_factory.tscn")


func _factory(case_seed := 5) -> DollFactory:
	var factory: DollFactory = FACTORY_SCENE.instantiate()
	factory.story_id = "diamond_doll"
	factory.case_seed = case_seed
	factory.get_node("Cop").input_enabled = false
	factory.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(factory)
	return factory


func test_three_suspicions_and_the_true_one_among_them() -> void:
	var factory := _factory()
	await wait_physics_frames(2)
	assert_eq(factory.raid.suspicions.size(), 3)
	assert_has(factory.raid.suspicions, "diamond_doll")
	for id: String in factory.raid.suspicions:
		assert_has(DollFactory.SUSPICION_POOL, id)
	assert_eq(factory.raid.owner_npc, factory.fermin)


func test_one_doll_of_the_bin_is_the_heavy_one() -> void:
	var factory := _factory()
	await wait_physics_frames(2)
	var rig := factory.rig as DiamondDollRig
	assert_eq(factory.pile.size(), DollFactory.PILE.x * DollFactory.PILE.y)
	assert_eq(factory.main, rig.doll)
	assert_eq(factory.pile[5 % factory.pile.size()], rig.doll, "drawn with the seed")
	assert_almost_eq((rig.doll as RigidBody3D).mass, 2.0, 0.01)
	assert_true(rig.doll.value_hidden)
	assert_eq(factory.extras.size(), 2, "the loupe and the list")
	var other := _factory(6)
	await wait_physics_frames(2)
	assert_ne(factory.pile.find(factory.main), other.pile.find(other.main), "another seed, another doll")


func test_the_scale_tells_the_heavy_doll_apart() -> void:
	var factory := _factory()
	await wait_physics_frames(2)
	var plate := factory.scale_.global_position + Vector3(0, WeighScale.SIZE.y + 0.15, 0)
	var plain: Node3D = factory.pile[0] if factory.pile[0] != factory.main else factory.pile[1]
	plain.global_position = plate
	await wait_physics_frames(30)
	assert_almost_eq(factory.scale_.reading, 0.5, 0.01, "a doll from the belt")
	plain.global_position = Vector3(0, 5, 20)
	factory.main.global_position = plate
	await wait_physics_frames(30)
	assert_almost_eq(factory.scale_.reading, 2.0, 0.01, "the diamond one")


func test_the_quality_sheet_is_a_clue() -> void:
	var factory := _factory()
	await wait_physics_frames(2)
	var sheet := (factory.rig as DiamondDollRig).sheet
	sheet.use(factory.get_node("Cop"))
	assert_has(factory.raid.clues_found, tr("CLUE_QUALITY_SHEET"))


func test_fermin_slips_and_nilda_saw_where() -> void:
	var factory := _factory()
	await wait_physics_frames(2)
	assert_eq(factory.fermin.slips.size(), 2)
	assert_true(factory.fermin.ask(factory.get_node("Cop")))
	assert_eq(factory.raid.clues_found.size(), 1)
	var where := tr("LOC_" + DollFactory.SPOTS[factory.hidden_spots[5 % 2]].id)
	assert_eq(factory.nilda.clue, tr("CLUE_NILDA") % where)


func test_the_till_has_the_office_key_and_fermin_minds_it() -> void:
	var factory := _factory()
	await wait_physics_frames(2)
	assert_eq(factory.till.key_hint, "HINT_TILL_KEY_FACTORY")
	var before := factory.fermin.complaint
	factory.fermin.global_position = Vector3(-4.5, DollFactory.FLOOR_TOP, 10.0) # in the reception, by the desk
	await wait_physics_frames(2)
	factory.till.opened.emit(factory.till.global_position)
	assert_gt(factory.fermin.complaint, before)


func test_the_doll_in_the_trunk_solves_the_case() -> void:
	var factory := _factory()
	await wait_physics_frames(10)
	var doll := factory.main
	doll.global_position = factory.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(factory.car.is_delivered(doll))
	assert_true(factory.raid.mark(factory.raid.suspicions.find("diamond_doll")))
	assert_eq(factory.raid.objective_facts().extras.size(), 2)
	factory.car.enter(factory.get_node("Cop"))
	assert_true(factory.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	var keys: Array[String] = ["BRIEF_FACTORY_TIP_B", "BRIEF_FACTORY_TIP_D", "BRIEF_FACTORY_TIP_E",
		"BRIEF_DIAMOND_DOLL_B", "BRIEF_DIAMOND_DOLL_C", "BRIEF_DIAMOND_DOLL_D", "OBJ_FIND_DIAMOND_DOLL",
		"OBJ_EXTRA_JEWELER_LOUPE", "OBJ_EXTRA_DELIVERY_LIST", "OBJ_ENTER_FACTORY", "OBJ_GUESS_FACTORY",
		"OBJ_BROKEN_FACTORY", "OBJ_COMPLAINT_FACTORY", "FOREMAN_SLIP", "CLUE_NILDA", "NILDA_CLUE_diamond_doll",
		"HINT_TILL_KEY_FACTORY", "HINT_ESCAPE_factory", "CRIME_owner_factory", "CONFESS_owner_factory",
		"CASE_FAILED_LAWYER_FACTORY", "CLUE_QUALITY_SHEET", "PROMPT_QUALITY_SHEET", "HINT_DIAMOND_DOLL"]
	for id: String in DollFactory.SUSPICION_POOL:
		keys.append("SUSPECT_" + id)
		keys.append("CLUE_SUSPECT_" + id)
	for key: String in keys:
		assert_ne(tr(key), key)
