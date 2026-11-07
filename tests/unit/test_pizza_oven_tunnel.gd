extends GutTest

## The pizzeria raid with the oven tunnel story (allanamiento-pizzeria.md, step 6): the bank's silver bag at the far
## end of a tunnel under the oven, soot prints from the oven to the office, the extinguisher that puts the oven out and
## the crawl in and back out.

const RAID_SCENE := preload("res://scenes/levels/pizza_raid.tscn")


func _pizzeria() -> PizzaRaid:
	var pizzeria: PizzaRaid = RAID_SCENE.instantiate()
	pizzeria.story_id = "oven_tunnel"
	pizzeria.case_seed = 5
	pizzeria.get_node("Cop").input_enabled = false
	pizzeria.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(pizzeria)
	return pizzeria


func test_the_bag_waits_at_the_tunnels_end_and_the_extras_in_spots() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(10)
	assert_has(pizzeria.raid.suspicions, "oven_tunnel")
	assert_almost_eq((pizzeria.main as RigidBody3D).mass, 6.0, 0.01)
	var bag := pizzeria.to_local(pizzeria.main.global_position)
	assert_lt(bag.y, PizzaRaid.FLOOR_TOP - 2.0, "under the floor")
	assert_lt(bag.distance_to(OvenTunnelRig.BAG_AT), 0.3, "lying on the tunnel's floor, at its end")
	assert_eq(pizzeria.hidden_spots[0], -1)
	assert_eq(pizzeria.extras.size(), 2, "the helmet and the plan")
	for i in [1, 2]:
		assert_gte(pizzeria.hidden_spots[i], 0)
	assert_eq(pizzeria.where_is(0), tr("LOC_pizza_oven_tunnel"))


func test_soot_prints_go_from_the_oven_to_the_office_and_the_first_is_a_clue() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	var rig := pizzeria.rig as OvenTunnelRig
	assert_gt(rig.prints.size(), 10)
	var first := pizzeria.to_local(rig.prints[0].global_position)
	var last := pizzeria.to_local(rig.prints[-1].global_position)
	assert_lt(first.distance_to(PizzaRaid.OVEN_MOUTH * Vector3(1, 0, 1)), 1.0, "start at the oven")
	assert_gt(last.x, PizzaRaid.KITCHEN_X, "end in the office")
	assert_lt(last.z, PizzaRaid.DINING_Z)
	rig.first_print.use(pizzeria.get_node("Cop"))
	assert_has(pizzeria.raid.clues_found, tr("CLUE_SOOT_PRINTS"))


func test_lit_the_oven_burns_out_it_lets_a_cop_crawl_in_and_back() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	var rig := pizzeria.rig as OvenTunnelRig
	var cop: Cop = pizzeria.get_node("Cop")
	cop.global_position = pizzeria.to_global(OvenTunnelRig.OUT_AT)
	pizzeria.oven.button.pressed.emit(cop)
	assert_gt(pizzeria.to_local(cop.global_position).y, 0.0, "a hand in a lit oven, not a cop")
	rig.extinguisher.pressed.emit(cop)
	assert_false(pizzeria.oven.lit)
	assert_true(rig.put_out)
	pizzeria.oven.button.pressed.emit(cop)
	await wait_physics_frames(2)
	assert_lt(pizzeria.to_local(cop.global_position).y, PizzaRaid.FLOOR_TOP - 2.0, "in the tunnel")
	assert_true(cop.crawling, "crawling, as in the duct")
	assert_true(cop.is_crouching)
	rig.exit_button.pressed.emit(cop)
	await wait_physics_frames(2)
	assert_lt(pizzeria.to_local(cop.global_position).distance_to(OvenTunnelRig.OUT_AT), 0.5, "back by the oven")
	assert_false(cop.crawling)


func test_what_a_cop_carries_comes_out_of_the_tunnel_with_them() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	var rig := pizzeria.rig as OvenTunnelRig
	var cop: Cop = pizzeria.get_node("Cop")
	rig.put_out_oven()
	rig.crawl_in(cop)
	await wait_physics_frames(2)
	var grabber := cop.get_node("Grabber")
	pizzeria.main.global_position = cop.global_position + Vector3.UP * 0.5
	grabber.grab(pizzeria.main)
	rig.crawl_out(cop)
	assert_eq(grabber.held, pizzeria.main, "still holding the bag")
	assert_gt(pizzeria.to_local(pizzeria.main.global_position).y, 0.0, "out of the tunnel too")


func test_put_out_nothing_burns() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	(pizzeria.rig as OvenTunnelRig).put_out_oven()
	var plan: Evidence = pizzeria.extras[1]
	plan.global_position = pizzeria.oven.global_position
	await wait_seconds(PizzaOven.BURN_TIME + 0.5)
	assert_almost_eq(plan.value, 200.0, 0.01, "a cold oven doesn't burn paper")


func test_the_storys_texts_exist() -> void:
	for key: String in ["BRIEF_OVEN_TUNNEL_B", "BRIEF_OVEN_TUNNEL_C", "BRIEF_OVEN_TUNNEL_D", "OBJ_FIND_SILVER_BAG",
			"OBJ_EXTRA_MINER_HELMET", "OBJ_EXTRA_BANK_PLAN", "TITO_CLUE_oven_tunnel", "LOC_pizza_oven_tunnel",
			"PROMPT_SOOT_PRINTS", "CLUE_SOOT_PRINTS", "PROMPT_EXTINGUISHER", "PROMPT_OVEN_CRAWL", "PROMPT_TUNNEL_OUT",
			"OVEN_FSSH", "HINT_TUNNEL_CRAWL"]:
		assert_ne(tr(key), key)
