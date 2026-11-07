extends GutTest

## The pizzeria raid with the plastic cheese story (allanamiento-pizzeria.md, step 6): the plastic cheese mold and its
## extras hidden with the seed, the sample pizza whose cheese stretches 3 m and snaps back, and the slices that bounce
## like balls.

const RAID_SCENE := preload("res://scenes/levels/pizza_raid.tscn")


func _pizzeria() -> PizzaRaid:
	var pizzeria: PizzaRaid = RAID_SCENE.instantiate()
	pizzeria.story_id = "plastic_cheese"
	pizzeria.case_seed = 5
	pizzeria.get_node("Cop").input_enabled = false
	pizzeria.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(pizzeria)
	return pizzeria


func test_the_mold_is_hidden_in_a_heavy_spot_with_its_extras() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	assert_has(pizzeria.raid.suspicions, "plastic_cheese")
	assert_almost_eq((pizzeria.main as RigidBody3D).mass, 8.0, 0.01)
	assert_true(PizzaRaid.SPOTS[pizzeria.hidden_spots[0]].heavy)
	assert_eq(pizzeria.extras.size(), 2, "the pellets and the labels")


func test_the_sample_pizza_is_a_clue() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	var sample := (pizzeria.rig as PlasticCheeseRig).sample
	sample.use(pizzeria.get_node("Cop"))
	assert_has(pizzeria.raid.clues_found, tr("CLUE_SAMPLE_PIZZA"))


func test_the_cheese_stretches_and_past_three_meters_snaps_back() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	var rig := pizzeria.rig as PlasticCheeseRig
	var sample := rig.sample
	sample.freeze = true
	sample.global_position = pizzeria.to_global(PlasticCheeseRig.SAMPLE_AT + Vector3(0, 0.2, 2.0))
	await wait_physics_frames(2)
	assert_true(rig.strand.visible, "a string of cheese")
	assert_almost_eq(rig.strand.scale.y, 2.0, 0.05, "two meters long")
	assert_eq(rig.snaps, 0)
	sample.global_position = pizzeria.to_global(PlasticCheeseRig.SAMPLE_AT + Vector3(0, 0.2, 3.3))
	await wait_physics_frames(2)
	assert_eq(rig.snaps, 1, "too far: it snapped back")
	assert_lt(pizzeria.to_local(sample.global_position).distance_to(PlasticCheeseRig.SAMPLE_AT), 0.1, "on its board")


func test_a_held_sample_pizza_is_pulled_out_of_the_hands() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	var rig := pizzeria.rig as PlasticCheeseRig
	var grabber := pizzeria.get_node("Cop/Grabber")
	grabber.grab(rig.sample)
	rig.snap_back()
	assert_null(grabber.held)


func test_a_dropped_slice_bounces() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	var slice: Grabbable = pizzeria.slices[0]
	var drop := Vector3(0.0, 2.0, 3.0)
	slice.global_position = pizzeria.to_global(drop)
	slice.linear_velocity = Vector3.ZERO
	var lowest := 10.0
	var highest_after := -10.0
	for i in 90:
		await wait_physics_frames(1)
		var y := pizzeria.to_local(slice.global_position).y
		if y < lowest:
			lowest = y
		elif lowest < 0.3:
			highest_after = maxf(highest_after, y)
	assert_lt(lowest, 0.3, "it hit the floor")
	assert_gt(highest_after, 0.6, "and jumped back up like a ball")


func test_the_storys_texts_exist() -> void:
	for key: String in ["BRIEF_PLASTIC_CHEESE_B", "BRIEF_PLASTIC_CHEESE_C", "BRIEF_PLASTIC_CHEESE_D",
			"OBJ_FIND_CHEESE_MOLD", "OBJ_EXTRA_PLASTIC_PELLETS", "OBJ_EXTRA_MUZZARELLA_LABELS", "TITO_CLUE_plastic_cheese",
			"PROMPT_SAMPLE_PIZZA", "CLUE_SAMPLE_PIZZA", "HINT_CHEESE_SNAP", "CHEESE_BOING"]:
		assert_ne(tr(key), key)
