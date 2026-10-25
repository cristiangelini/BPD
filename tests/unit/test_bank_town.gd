extends GutTest

## The town bank (robo-banco-pueblo.md, step 1, decision 127): an eighth of the seeds, a wall of shelves cuts the hall
## down to a small one, don Plácido sleeps on his stool behind the counter with the back door's key in his pocket, El
## Conejo robs it alone at the drill, and there are no hostages on the floor and no manager outside.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel


func _bank(want := "town") -> void:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != want:
		seed_ += 1
	bank = LEVEL.instantiate()
	bank.case_seed = seed_
	bank.get_node("Cop").input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)


func test_an_eighth_of_the_seeds_and_the_arg_forces_it() -> void:
	var towns := 0
	for seed_ in range(1, 801):
		if BankLevel.variant(seed_, PackedStringArray()) == "town":
			towns += 1
	assert_between(towns, 70, 140)
	for seed_ in range(1, 20):
		assert_eq(BankLevel.variant(seed_, PackedStringArray(["--bank=town"])), "town")
	for seed_ in [1, 2, 3, 4]:
		assert_ne(BankLevel.variant(seed_, PackedStringArray()), "town", "the old test seeds stay the same")


func test_the_others_have_no_clerk() -> void:
	await _bank("base")
	assert_false(bank.town)
	assert_null(bank.clerk)
	assert_eq(bank.robbers.size(), 4)


func test_el_conejo_robs_it_alone_at_the_drill() -> void:
	await _bank()
	assert_eq(bank.robbers.size(), 1)
	assert_eq(bank.robbers[0].animal, "conejo")
	assert_true(bank.robbers[0].is_boss(), "alone, he's the boss")
	assert_eq(bank.boss, bank.robbers[0])
	var at := bank.to_local(bank.boss.global_position)
	assert_lt(Vector2(at.x, at.z).distance_to(Vector2(BankLevel.DRILL_AT.x, BankLevel.DRILL_AT.z)), 2.0, "by the drill")


func test_no_hostages_and_no_manager() -> void:
	await _bank()
	assert_eq(bank.hostages.size(), 0)
	assert_false(bank.manager.visible)
	assert_eq(bank.manager.collision_layer, 0)
	assert_false(bank.manager_car.visible)
	assert_eq(bank.manager_car.collision_layer, 0, "the patrol car doesn't bump into a car that isn't there")


func test_don_placido_sleeps_on_his_stool_with_the_key() -> void:
	await _bank()
	assert_not_null(bank.clerk)
	await wait_physics_frames(20)
	var at := bank.to_local(bank.clerk.global_position)
	assert_almost_eq(at, BankLevel.CLERK_AT + Vector3.UP * (BankLevel.FLOOR_TOP + BankLevel.STOOL_TOP), Vector3.ONE * 0.05,
		"still on his stool")
	assert_true(bank.clerk.asleep)
	assert_true(bank.clerk.has_key())
	assert_eq(bank.clerk.get_node("Bubble").text, "CLERK_SNORE")
	assert_eq(bank.clerk.mass, BankClerk.KG)
	assert_gt(BankClerk.KG, GameScale.COP_CARRY_KG, "one cop alone only drags him")


func test_taken_hold_of_he_comes_off_his_stool() -> void:
	await _bank()
	assert_true(bank.clerk.freeze)
	bank.clerk.hold(1, bank.clerk.global_position + Vector3.UP)
	assert_false(bank.clerk.freeze)
	bank.clerk.let_go(1)


func test_the_shelves_close_the_hall_west_side_off() -> void:
	await _bank()
	var space := bank.get_world_3d().direct_space_state
	for z: float in [3.0, 8.0, -2.5]:
		var ray := PhysicsRayQueryParameters3D.create(bank.to_global(Vector3(3.0, 1.0, z)),
			bank.to_global(Vector3(-5.0, 1.0, z)))
		var hit := space.intersect_ray(ray)
		assert_false(hit.is_empty(), "a wall at z %.1f" % z)
		assert_almost_eq(bank.to_local(hit.position).x, BankLevel.TOWN_WALL_X, 0.2)
