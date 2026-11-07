extends GutTest

## The pizzeria raid with the crazy yeast story (allanamiento-pizzeria.md, step 6): the drum of super yeast and its
## extras hidden with the seed, the dough oozing from under the cold room's door, and the dough balls that grow and
## burst, leaving the cops near them stuck.

const RAID_SCENE := preload("res://scenes/levels/pizza_raid.tscn")


func _pizzeria() -> PizzaRaid:
	var pizzeria: PizzaRaid = RAID_SCENE.instantiate()
	pizzeria.story_id = "crazy_yeast"
	pizzeria.case_seed = 5
	pizzeria.get_node("Cop").input_enabled = false
	pizzeria.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(pizzeria)
	return pizzeria


func test_the_drum_is_hidden_in_a_heavy_spot_with_its_extras() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	assert_has(pizzeria.raid.suspicions, "crazy_yeast")
	assert_almost_eq((pizzeria.main as RigidBody3D).mass, 20.0, 0.01)
	assert_true(PizzaRaid.SPOTS[pizzeria.hidden_spots[0]].heavy)
	assert_eq(pizzeria.extras.size(), 2, "the pills and the invoice")


func test_the_dough_under_the_cold_room_door_is_a_clue() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	var puddle := (pizzeria.rig as CrazyYeastRig).puddle
	var door := Vector3(PizzaRaid.COLD_DOOR_X, PizzaRaid.FLOOR_TOP, PizzaRaid.COLD_Z)
	assert_lt(pizzeria.to_local(puddle.global_position).distance_to(door), 0.6, "at the cold room's door")
	puddle.use(pizzeria.get_node("Cop"))
	assert_has(pizzeria.raid.clues_found, tr("CLUE_DOUGH_PUDDLE"))


func test_the_dough_balls_grow_and_then_burst() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	var rig := pizzeria.rig as CrazyYeastRig
	rig.since_grew = CrazyYeastRig.GROW_EVERY - 0.05
	await wait_physics_frames(6)
	assert_eq(rig.size, 1, "it grew after GROW_EVERY")
	assert_almost_eq(pizzeria.dough_balls[0].scale.x, CrazyYeastRig.SIZES[1], 0.01)
	for i in CrazyYeastRig.SIZES.size() - 1:
		rig.grow()
	assert_eq(rig.bursts, 1)
	assert_eq(rig.size, 0, "they start again")
	assert_almost_eq(pizzeria.dough_balls[0].scale.x, 1.0, 0.01)


func test_a_burst_leaves_a_near_cop_stuck_and_a_far_one_free() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	var cop: Cop = pizzeria.get_node("Cop")
	cop.global_position = pizzeria.to_global(PizzaRaid.DOUGH_TABLE_AT + Vector3(0, 0.1, 1.2))
	(pizzeria.rig as CrazyYeastRig).burst()
	assert_true(cop.is_staggered(), "stuck in the dough")
	cop.step(CrazyYeastRig.STICK_TIME + 0.1, Vector2.ZERO, false, false, false)
	cop.global_position = pizzeria.to_global(PizzaRaid.DOUGH_TABLE_AT + Vector3(2.5, 0.1, -1.5))
	await wait_physics_frames(2)
	assert_false(cop.is_staggered(), "free again")
	(pizzeria.rig as CrazyYeastRig).burst()
	assert_false(cop.is_staggered(), "too far to get stuck")


func test_the_storys_texts_exist() -> void:
	for key: String in ["BRIEF_YEAST_B", "BRIEF_YEAST_C", "BRIEF_YEAST_D", "OBJ_FIND_YEAST_DRUM", "OBJ_EXTRA_YEAST_PILLS",
			"OBJ_EXTRA_INFLATED_INVOICE", "TITO_CLUE_crazy_yeast", "PROMPT_DOUGH_PUDDLE", "CLUE_DOUGH_PUDDLE",
			"DOUGH_PLOF", "HINT_DOUGH_STUCK"]:
		assert_ne(tr(key), key)
