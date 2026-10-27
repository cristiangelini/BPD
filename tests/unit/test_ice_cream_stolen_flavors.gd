extends GutTest

## The ice cream shop as a raid with the stolen flavors' story (allanamiento-heladeria.md, step 5): the suspicions, the
## recipe box and its extras hidden with the seed, the "Igualito al de Enfrente" sign, doña Nieve offering the new
## flavor, what she lets slip and what Lucho saw, and the box in the trunk solving the case.

const SCENE := preload("res://scenes/levels/ice_cream_shop.tscn")


func _shop(case_seed := 5) -> IceCreamShop:
	var shop: IceCreamShop = SCENE.instantiate()
	shop.story_id = "stolen_flavors"
	shop.case_seed = case_seed
	shop.get_node("Cop").input_enabled = false
	shop.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(shop)
	return shop


func test_three_suspicions_and_the_true_one_among_them() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	assert_eq(shop.raid.suspicions.size(), 3)
	assert_has(shop.raid.suspicions, "stolen_flavors")
	for id: String in shop.raid.suspicions:
		assert_has(IceCreamShop.SUSPICION_POOL, id)
	assert_eq(shop.raid.owner_npc, shop.nieve)


func test_the_recipe_box_is_hidden_in_a_heavy_spot_with_its_extras() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	assert_eq(shop.main, shop.hidden[0])
	assert_almost_eq((shop.main as RigidBody3D).mass, 4.0, 0.01)
	assert_true(IceCreamShop.SPOTS[shop.hidden_spots[0]].heavy, "the box in a spot it fits")
	assert_eq(shop.extras.size(), 2, "the secret jar and the rival's photo")
	var other := _shop(6)
	await wait_physics_frames(2)
	assert_ne(shop.hidden_spots, other.hidden_spots, "another seed, other spots")


func test_the_sign_is_a_clue_and_she_offers_the_new_flavor() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	var rig := shop.rig as StolenFlavorsRig
	rig.flavor_sign.use(shop.get_node("Cop"))
	assert_has(shop.raid.clues_found, tr("CLUE_SAME_AS_ACROSS"))
	rig.offer()
	assert_eq(rig.offers, 1)
	assert_eq(shop.nieve.complaint, 0.0, "offering costs no complaint")


func test_nieve_slips_and_lucho_saw_where() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	assert_eq(shop.nieve.slips.size(), 3)
	assert_true(shop.nieve.ask(shop.get_node("Cop")))
	assert_eq(shop.raid.clues_found.size(), 1)
	var where := tr("LOC_" + IceCreamShop.SPOTS[shop.hidden_spots[5 % 3]].id)
	assert_eq(shop.lucho.clue, tr("CLUE_LUCHO") % where)
	assert_eq(shop.lucho.clue_speech, tr("LUCHO_CLUE_stolen_flavors") % where)
	shop.lucho.told.emit(shop.lucho.clue)
	assert_has(shop.raid.clues_found, shop.lucho.clue, "on the checklist")


func test_the_lawyer_loses_the_case() -> void:
	var shop := _shop()
	await wait_physics_frames(2)
	shop.nieve.scold(FloorBoss.MAX_COMPLAINT, "NIEVE_NOTICED")
	assert_true(shop.raid.case_failed)


func test_the_box_in_the_trunk_solves_the_case() -> void:
	var shop := _shop()
	await wait_physics_frames(10)
	var box := shop.main
	box.global_position = shop.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(shop.car.is_delivered(box))
	assert_true(shop.raid.mark(shop.raid.suspicions.find("stolen_flavors")))
	assert_eq(shop.raid.objective_facts().extras.size(), 2)
	shop.car.enter(shop.get_node("Cop"))
	assert_true(shop.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	var keys: Array[String] = ["BRIEF_ICE_TIP_B", "BRIEF_ICE_TIP_D", "BRIEF_ICE_TIP_E", "BRIEF_STOLEN_FLAVORS_B",
		"BRIEF_STOLEN_FLAVORS_C", "BRIEF_STOLEN_FLAVORS_D", "OBJ_FIND_RECIPE_BOX", "OBJ_EXTRA_SECRET_JAR",
		"OBJ_EXTRA_RIVAL_PHOTO", "OBJ_ENTER_ICE", "OBJ_GUESS_ICE", "OBJ_BROKEN_ICE", "OBJ_COMPLAINT_ICE", "NIEVE_SLIP",
		"CLUE_LUCHO", "LUCHO_CLUE_stolen_flavors", "ICE_SAME_AS_ACROSS", "CLUE_SAME_AS_ACROSS", "NIEVE_NEW_FLAVOR",
		"HINT_ESCAPE_nieve", "CRIME_owner_nieve", "CONFESS_owner_nieve", "CASE_FAILED_LAWYER_ICE"]
	for id: String in IceCreamShop.SUSPICION_POOL:
		keys.append("SUSPECT_" + id)
		keys.append("CLUE_SUSPECT_" + id)
	for key: String in keys:
		assert_ne(tr(key), key)
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_nieve"))
	assert_true(ChaseSuspect.MODELS.has("nieve"))
	assert_true(RaidEscape.PLACES.has("nieve"))


func test_dona_nieve_gets_away_in_a_car() -> void:
	var shop := _shop(7)
	await wait_physics_frames(30)
	shop.raid.escape.flee()
	var chase := shop.raid.escape.chase
	assert_eq(chase.suspect_id, "night", "the getaway car")
	chase.pull_over()
	assert_eq(chase.suspect.kind, "nieve")
