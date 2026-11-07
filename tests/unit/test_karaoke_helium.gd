extends GutTest

## The karaoke's juice of inspiration story (allanamiento-karaoke.md, step 6): the helium tank and its extras hidden
## with the seed, the glass of juice on the bar that makes a cop talk squeaky for a while (the clue, once), and the
## customers who sing squeaky and laugh.

const SCENE := preload("res://scenes/levels/karaoke.tscn")


func _karaoke(case_seed := 5) -> Karaoke:
	var place: Karaoke = SCENE.instantiate()
	place.story_id = "karaoke_helium"
	place.case_seed = case_seed
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	place._turn_left = 1000.0
	return place


func test_the_tank_and_its_extras_are_hidden() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	assert_has(place.raid.suspicions, "karaoke_helium")
	assert_eq(place.main, place.hidden[0])
	assert_almost_eq(place.main.full_value, 1000.0, 0.01)
	assert_eq(place.extras.size(), 2, "the balloons and the recipe")
	assert_true(Karaoke.SPOTS[place.hidden_spots[0]].heavy, "the tank is big")


func test_the_glass_of_juice_waits_on_the_bar() -> void:
	var place := _karaoke()
	await wait_physics_frames(30)
	var rig: HeliumRig = place.rig
	assert_lt(place.to_local(rig.glass.global_position).distance_to(HeliumRig.GLASS_AT), 0.05, "on the bar, not the floor")


func test_a_cop_with_the_glass_talks_squeaky_for_a_while() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	var rig: HeliumRig = place.rig
	var cop: Cop = place.get_node("Cop")
	var grabber := cop.get_node("Grabber")
	rig.glass.hold(grabber.get_instance_id(), rig.glass.global_position + Vector3.UP * 0.1)
	await wait_physics_frames(2)
	assert_true(rig.noticed)
	assert_true(cop.has_node("Squeak"), "«¡Hola, soy la ley!»")
	assert_has(place.raid.clues_found, tr("KARAOKE_SQUEAK_CLUE"))
	var clues: int = place.raid.clues_found.size()
	rig.glass.let_go(grabber.get_instance_id())
	await wait_physics_frames(2)
	rig.squeaky[cop] = 0.01
	await wait_physics_frames(2)
	assert_false(cop.has_node("Squeak"), "the voice comes back")
	rig.glass.hold(grabber.get_instance_id(), rig.glass.global_position + Vector3.UP * 0.1)
	await wait_physics_frames(2)
	assert_eq(place.raid.clues_found.size(), clues, "the clue is there once")


func test_the_customers_sing_squeaky() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	var rig: HeliumRig = place.rig
	place._turn_left = 0.0
	await wait_until(func() -> bool: return place.on_turn != null and place.on_turn.singing, 8.0)
	rig._giggle_left = 0.01
	await wait_physics_frames(2)
	assert_eq(place.on_turn.said(), "KARAOKE_HELIUM_SING")


func test_the_helium_texts_exist() -> void:
	for key: String in ["BRIEF_KARAOKE_HELIUM_B", "BRIEF_KARAOKE_HELIUM_C", "BRIEF_KARAOKE_HELIUM_D",
			"OBJ_FIND_HELIUM_TANK", "OBJ_EXTRA_BALLOON_BOX", "OBJ_EXTRA_JUICE_RECIPE", "TOTO_CLUE_karaoke_helium",
			"KARAOKE_SQUEAK", "KARAOKE_SQUEAK_CLUE", "KARAOKE_HELIUM_SING"]:
		assert_ne(tr(key), key, key)
