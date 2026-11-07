extends GutTest

## The pizzeria as a raid with the jewels story (allanamiento-pizzeria.md, step 5): the suspicions, the frozen pizzas
## with the jewels and their extras hidden with the seed, the bitten slice in the bin, the tower's clinking boxes, what
## Don Muzza lets slip and what Tito saw, the lawyer failing the case and the box in the trunk solving it.

const RAID_SCENE := preload("res://scenes/levels/pizza_raid.tscn")


func _pizzeria(case_seed := 5) -> PizzaRaid:
	var pizzeria: PizzaRaid = RAID_SCENE.instantiate()
	pizzeria.story_id = "jewels"
	pizzeria.case_seed = case_seed
	pizzeria.get_node("Cop").input_enabled = false
	pizzeria.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(pizzeria)
	return pizzeria


func test_three_suspicions_and_the_true_one_among_them() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	assert_eq(pizzeria.raid.suspicions.size(), 3)
	assert_has(pizzeria.raid.suspicions, "jewels")
	for id: String in pizzeria.raid.suspicions:
		assert_has(PizzaRaid.SUSPICION_POOL, id)
	assert_eq(pizzeria.raid.owner_npc, pizzeria.muzza)


func test_the_jewels_are_hidden_in_a_heavy_spot_with_their_extras() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	assert_eq(pizzeria.main, pizzeria.hidden[0])
	assert_almost_eq((pizzeria.main as RigidBody3D).mass, 5.0, 0.01)
	assert_true(PizzaRaid.SPOTS[pizzeria.hidden_spots[0]].heavy)
	assert_eq(pizzeria.extras.size(), 2, "the loupe and the list")
	assert_true(pizzeria.extras[1].mass <= PizzaOven.PAPER_KG, "the list is paper: the oven burns it whole")
	var other := _pizzeria(6)
	await wait_physics_frames(2)
	assert_ne(pizzeria.hidden_spots, other.hidden_spots, "another seed, other spots")


func test_two_tower_boxes_clink_and_the_first_one_is_a_clue() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	var rig := pizzeria.rig as JewelsRig
	assert_eq(rig.clinking.size(), JewelsRig.CLINKING)
	assert_ne(rig.clinking[0], rig.clinking[1])
	var cop: Cop = pizzeria.get_node("Cop")
	var first: int = rig.clinking.min()
	for i in first:
		rig.button.use(cop)
	assert_false(rig.heard_coins, "the boxes above it are just boxes")
	rig.button.use(cop)
	assert_true(rig.heard_coins)
	assert_has(pizzeria.raid.clues_found, tr("CLUE_TOWER_COINS"))
	var clues: int = pizzeria.raid.clues_found.size()
	for i in PizzaRaid.TOWER_BOXES:
		rig.lift_next()
	assert_eq(pizzeria.raid.clues_found.size(), clues, "the clue only once")


func test_the_bitten_slice_in_the_bin_is_a_clue() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	var slice := (pizzeria.rig as JewelsRig).bitten_slice
	assert_lt(pizzeria.to_local(slice.global_position).distance_to(PizzaRaid.BIN_AT), 0.6, "in the bin")
	slice.use(pizzeria.get_node("Cop"))
	assert_has(pizzeria.raid.clues_found, tr("CLUE_BITTEN_SLICE"))


func test_muzza_slips_and_tito_saw_where() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	assert_eq(pizzeria.muzza.slips.size(), 3)
	assert_true(pizzeria.muzza.ask(pizzeria.get_node("Cop")))
	assert_eq(pizzeria.raid.clues_found.size(), 1)
	var where := tr("LOC_" + PizzaRaid.SPOTS[pizzeria.hidden_spots[5 % 3]].id)
	assert_eq(pizzeria.tito.clue, tr("CLUE_TITO") % where)
	var cop: Cop = pizzeria.get_node("Cop")
	cop.get_node("Grabber").grab(pizzeria.slices[0])
	pizzeria.tito.use(cop)
	assert_has(pizzeria.raid.clues_found, pizzeria.tito.clue, "on the checklist")


func test_his_lawyer_fails_the_case() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	pizzeria.muzza.praise(-FloorBoss.MAX_COMPLAINT, "MUZZA_SAW")
	assert_true(pizzeria.raid.case_failed)


func test_the_jewels_in_the_trunk_solve_the_case() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(10)
	var box := pizzeria.main
	box.global_position = pizzeria.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(pizzeria.car.is_delivered(box))
	assert_true(pizzeria.raid.mark(pizzeria.raid.suspicions.find("jewels")))
	assert_eq(pizzeria.raid.objective_facts().extras.size(), 2)
	pizzeria.car.enter(pizzeria.get_node("Cop"))
	assert_true(pizzeria.raid.case_solved)


func test_the_stories_texts_exist() -> void:
	var keys: Array[String] = ["BRIEF_PIZZA_TIP_B", "BRIEF_PIZZA_TIP_D", "BRIEF_PIZZA_TIP_E", "BRIEF_JEWELS_B",
		"BRIEF_JEWELS_C", "BRIEF_JEWELS_D", "OBJ_FIND_FROZEN_JEWELS", "OBJ_EXTRA_JEWELER_LOUPE",
		"OBJ_EXTRA_SPECIAL_CLIENTS", "OBJ_ENTER_PIZZA", "OBJ_GUESS_PIZZA", "OBJ_BROKEN_PIZZA", "OBJ_COMPLAINT_PIZZA",
		"MUZZA_SLIP", "CLUE_TITO", "TITO_CLUE_jewels", "PROMPT_BITTEN_SLICE", "CLUE_BITTEN_SLICE", "PROMPT_TOWER_LIFT",
		"TOWER_COINS", "CLUE_TOWER_COINS"]
	for id: String in PizzaRaid.SUSPICION_POOL:
		keys.append("SUSPECT_" + id)
		keys.append("CLUE_SUSPECT_" + id)
	for key: String in keys:
		assert_ne(tr(key), key)
