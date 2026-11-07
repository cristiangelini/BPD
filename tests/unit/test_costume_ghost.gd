extends GutTest

## The costume shop's neighborhood ghost (allanamiento-disfraces.md, step 6): the ghost costume is hidden with the howl
## recorder and the list of houses, the light switch by the counter turns the lamps off and a white costume on the
## monsters rack glows (looking at it is the clue), and the customers talk about the ghost.

const SCENE := preload("res://scenes/levels/costume_shop.tscn")


func _shop(seed := 5) -> CostumeShop:
	var place: CostumeShop = SCENE.instantiate()
	place.case_seed = seed
	place.story_id = "neighborhood_ghost"
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	place._turn_left = 1000.0
	return place


func test_the_ghost_costume_is_hidden_with_the_extras() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	assert_eq(place.main, place.hidden[0], "the ghost costume is the main evidence")
	assert_almost_eq(place.main.mass, 6.0, 0.01)
	assert_eq(place.extras.size(), 2, "the recorder and the list")


func test_the_glowing_costume_only_shows_in_the_dark() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	var rig := place.rig as NeighborhoodGhostRig
	var cop: Cop = place.get_node("Cop")
	assert_eq(rig.lamps.size(), 16, "the shop's ceiling lamps")
	assert_eq(rig.switch.prompt_key(cop), "PROMPT_LIGHTS_OFF")
	rig.glow.use(cop)
	assert_false(place.raid.clues_found.has(tr("CLUE_GHOST_GLOW")), "with the lights on it's one more costume")
	var before := place.owner_boss.complaint
	rig.switch.use(cop)
	assert_true(rig.dark)
	assert_false(rig.lamps[0].visible)
	assert_gt(place.owner_boss.complaint, before, "Don Fantoche doesn't like the dark")
	assert_eq(rig.glow.prompt_key(cop), "PROMPT_GLOW_COSTUME")
	rig.glow.use(cop)
	assert_true(place.raid.clues_found.has(tr("CLUE_GHOST_GLOW")))
	rig.switch.use(cop)
	assert_false(rig.dark)
	assert_true(rig.lamps[0].visible, "lights on again")


func test_the_customers_talk_about_the_ghost() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	var customer := place.customers[0]
	customer.trying = true
	customer.try_left = 0.05
	await wait_physics_frames(6)
	assert_eq(customer.said(), "CUSTOMER_GHOST_1")
	for key: String in ["BRIEF_NEIGHBOR_GHOST_B", "BRIEF_NEIGHBOR_GHOST_C", "BRIEF_NEIGHBOR_GHOST_D", "OBJ_FIND_GHOST",
			"OBJ_EXTRA_HOWL_RECORDER", "OBJ_EXTRA_HOUSE_LIST", "PROMPT_LIGHTS_OFF", "PROMPT_LIGHTS_ON",
			"PROMPT_GLOW_COSTUME", "CLUE_GHOST_GLOW", "FANTOCHE_LIGHTS", "CUSTOMER_GHOST_1", "CUSTOMER_GHOST_2",
			"CUSTOMER_GHOST_3", "MIMI_CLUE_neighborhood_ghost"]:
		assert_ne(tr(key), key, key)
