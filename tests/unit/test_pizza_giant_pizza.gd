extends GutTest

## The pizzeria raid with the giant pizza story (allanamiento-pizzeria.md, step 6): the fake bills in the safe behind
## the giant pizza on the dining room's wall, the lock in a pepperoni slice, and the pizza that turns like a door when
## pushed hard.

const RAID_SCENE := preload("res://scenes/levels/pizza_raid.tscn")


func _pizzeria(story := "giant_pizza") -> PizzaRaid:
	var pizzeria: PizzaRaid = RAID_SCENE.instantiate()
	pizzeria.story_id = story
	pizzeria.case_seed = 5
	pizzeria.get_node("Cop").input_enabled = false
	pizzeria.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(pizzeria)
	return pizzeria


func _thrown_box(pizzeria: PizzaRaid, speed: float) -> RigidBody3D:
	var box := ClubEvidence.make_item("Thrown", PizzaRaid.BOX_MODEL, Vector3(0.3, 0.1, 0.3), 1.0)
	pizzeria.add_child(box)
	box.global_position = pizzeria.giant_pizza.to_global(Vector3(GiantPizzaDoor.DIAMETER / 2, 0.0, 1.2))
	box.linear_velocity = -pizzeria.giant_pizza.global_basis.z * speed
	return box


func test_the_bills_wait_in_the_safe_and_the_extras_in_spots() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(10)
	assert_has(pizzeria.raid.suspicions, "giant_pizza")
	assert_almost_eq((pizzeria.main as RigidBody3D).mass, 3.0, 0.01)
	var bills := pizzeria.to_local(pizzeria.main.global_position)
	assert_almost_eq(bills.x, PizzaRaid.SAFE_X, 0.3, "in the safe")
	assert_lt(bills.z, PizzaRaid.DINING_Z, "behind the wall")
	assert_gt(bills.y, PizzaRaid.SAFE_BOTTOM, "on the safe's floor, not the kitchen's")
	assert_eq(pizzeria.extras.size(), 2, "the plate and the napkin")
	assert_eq(pizzeria.where_is(0), tr("LOC_pizza_safe"))


func test_the_pepperoni_lock_is_a_clue_on_the_pizza() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	var lock := (pizzeria.rig as GiantPizzaRig).lock
	assert_eq(lock.get_parent(), pizzeria.giant_pizza.panel, "it turns with the pizza")
	lock.use(pizzeria.get_node("Cop"))
	assert_has(pizzeria.raid.clues_found, tr("CLUE_PEPPERONI_LOCK"))


func test_the_pizza_hides_the_safe_until_something_hits_it_hard() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	var space := pizzeria.get_world_3d().direct_space_state
	var from := pizzeria.to_global(Vector3(PizzaRaid.SAFE_X, 1.16, PizzaRaid.DINING_Z + 1.0))
	var to := pizzeria.to_global(Vector3(PizzaRaid.SAFE_X, 1.16, PizzaRaid.DINING_Z - 0.3))
	var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(from, to, 1))
	assert_eq(hit.get("collider"), pizzeria.giant_pizza.panel, "the pizza covers the safe's window")
	_thrown_box(pizzeria, 2.0)
	await wait_physics_frames(30)
	assert_false(pizzeria.giant_pizza.is_open, "a soft toss doesn't move it")
	_thrown_box(pizzeria, 8.0)
	await wait_physics_frames(30)
	assert_true(pizzeria.giant_pizza.is_open, "a hard throw swings it")
	await wait_seconds(GiantPizzaDoor.SWING_TIME + 0.2)
	hit = space.intersect_ray(PhysicsRayQueryParameters3D.create(from, to, 1))
	assert_ne(hit.get("collider"), pizzeria.giant_pizza.panel, "the safe is open to the dining room")


func test_a_running_cop_swings_it_and_a_walking_one_doesnt() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	var cop: Cop = pizzeria.get_node("Cop")
	var door := pizzeria.giant_pizza
	cop.velocity = -door.global_basis.z * GameScale.WALK_SPEED
	door._on_hit(cop)
	assert_false(door.is_open)
	cop.velocity = door.global_basis.x * GameScale.RUN_SPEED
	door._on_hit(cop)
	assert_false(door.is_open, "running along the wall doesn't count")
	cop.velocity = -door.global_basis.z * GameScale.RUN_SPEED
	door._on_hit(cop)
	assert_true(door.is_open)


func test_in_other_stories_the_pizza_stays_on_the_wall() -> void:
	var pizzeria := _pizzeria("jewels")
	await wait_physics_frames(2)
	pizzeria.giant_pizza.swing_open()
	assert_false(pizzeria.giant_pizza.is_open)


func test_the_storys_texts_exist() -> void:
	for key: String in ["BRIEF_GIANT_PIZZA_B", "BRIEF_GIANT_PIZZA_C", "BRIEF_GIANT_PIZZA_D", "OBJ_FIND_FAKE_BILLS",
			"OBJ_EXTRA_PRINTING_PLATE", "OBJ_EXTRA_COMBO_NAPKIN", "TITO_CLUE_giant_pizza", "LOC_pizza_safe",
			"GIANT_PIZZA_SIGN", "PROMPT_PEPPERONI_LOCK", "CLUE_PEPPERONI_LOCK", "GIANT_PIZZA_CREAK"]:
		assert_ne(tr(key), key)
