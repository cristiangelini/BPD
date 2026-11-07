extends GutTest

## The costume shop's costumes that itch (allanamiento-disfraces.md, step 6): the drum of itching powder is hidden with
## the cream jars and the pharmacy's flyer, the bunny costume in the sale basket makes the cop who grabs it drop it and
## scratch (the clue), and the customers come out of the fitting rooms scratching.

const SCENE := preload("res://scenes/levels/costume_shop.tscn")


func _shop(seed := 5) -> CostumeShop:
	var place: CostumeShop = SCENE.instantiate()
	place.case_seed = seed
	place.story_id = "itchy_costumes"
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	place._turn_left = 1000.0
	return place


func test_the_drum_is_hidden_with_the_extras() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	assert_eq(place.hidden.size(), 3)
	assert_eq(place.main, place.hidden[0], "the drum is the main evidence")
	assert_almost_eq(place.main.mass, 10.0, 0.01)
	assert_true(CostumeShop.SPOTS[place.hidden_spots[0]].heavy, "in a spot where it fits")
	assert_eq(place.extras.size(), 2, "the cream jars and the flyer")
	var rig := place.rig as ItchyCostumesRig
	assert_lt(rig.costume.position.distance_to(ItchyCostumesRig.COSTUME_AT), 0.2, "in the sale basket")


func test_grabbing_the_bunny_costume_itches() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	var rig := place.rig as ItchyCostumesRig
	var cop: Cop = place.get_node("Cop")
	var grabber: Grabber = cop.get_node("Grabber")
	grabber.held = rig.costume
	rig.costume.hold(grabber.get_instance_id(), rig.costume.global_position + Vector3.UP * 0.3)
	assert_true(cop.is_staggered(), "scratching")
	assert_true(place.raid.clues_found.has(tr("CLUE_ITCHY_COSTUME")))
	await wait_physics_frames(2)
	assert_null(grabber.held, "and it's dropped")
	assert_false(rig.costume.is_held())


func test_the_customers_come_out_scratching() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	var customer := place.customers[0]
	customer.trying = true
	customer.try_left = 0.05
	await wait_physics_frames(6)
	assert_false(customer.trying)
	assert_eq(customer.said(), "CUSTOMER_ITCHY")
	for key: String in ["BRIEF_ITCHY_B", "BRIEF_ITCHY_C", "BRIEF_ITCHY_D", "OBJ_FIND_ITCHY", "OBJ_EXTRA_CREAM_JARS",
			"OBJ_EXTRA_PHARMACY_FLYER", "HINT_ITCHY", "CLUE_ITCHY_COSTUME", "CUSTOMER_ITCHY", "MIMI_CLUE_itchy_costumes"]:
		assert_ne(tr(key), key, key)
