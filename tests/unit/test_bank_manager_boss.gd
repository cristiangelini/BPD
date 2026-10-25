extends GutTest

## The manager who is the gang's boss (robo-banco-gerente.md, step 2, decision 124): the key he gives doesn't fit the
## back door, his walkie hurries the drill when no cop is near him, and his car's trunk waits open with empty sacks.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var cop: Cop


func _bank(want: String) -> BankLevel:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != want:
		seed_ += 1
	var bank: BankLevel = LEVEL.instantiate()
	bank.case_seed = seed_
	cop = bank.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(bank)
	return bank


func test_the_boss_gives_a_key_that_does_not_fit() -> void:
	var bank := _bank("manager")
	await wait_physics_frames(2)
	bank.manager.use(cop)
	assert_true(cop.has_key)
	bank.back_door.use(cop)
	assert_true(bank.back_door.locked)
	assert_false(bank.back_door.is_open)


func test_the_honest_one_has_no_walkie_nor_open_trunk() -> void:
	var bank := _bank("base")
	await wait_physics_frames(2)
	assert_false(bank.back_door.wrong_key)
	assert_null(bank.manager_trunk)
	assert_null(bank.manager_car.get_node_or_null("Trunk"))


func test_the_walkie_hurries_the_drill_with_no_cop_near() -> void:
	var bank := _bank("manager")
	await wait_physics_frames(2)
	cop.global_position = bank.car.global_position + Vector3(3, 0.1, 0)
	assert_gt(cop.global_position.distance_to(bank.manager.global_position), BankLevel.WALKIE_NEAR)
	watch_signals(bank.manager)
	bank.manager.radio()
	assert_signal_emitted(bank.manager, "radioed")
	assert_true(bank.manager.walkie_showing(), "the antenna shows")
	assert_string_starts_with(bank.manager.said(), "MANAGER_WALKIE_")
	assert_gt(bank.drill.nervous_left, 0.0)
	await wait_seconds(BankManager.WALKIE_TIME + 0.5)
	assert_false(bank.manager.walkie_showing(), "back in the pocket")


func test_a_cop_by_his_side_keeps_the_drill_calm() -> void:
	var bank := _bank("manager")
	await wait_physics_frames(2)
	cop.global_position = bank.manager.global_position + Vector3(0, 0.1, 2.0)
	await wait_physics_frames(1)
	bank.manager.radio()
	assert_eq(bank.drill.nervous_left, 0.0)


func test_he_uses_the_walkie_on_his_own() -> void:
	var bank := _bank("manager")
	await wait_physics_frames(2)
	watch_signals(bank.manager)
	assert_between(bank.manager._walkie_in, BankManager.WALKIE_EVERY.x - 0.1, BankManager.WALKIE_EVERY.y)
	bank.manager._walkie_in = 0.5
	await wait_seconds(1.0)
	assert_signal_emitted(bank.manager, "radioed")


func test_the_trunk_waits_open_and_he_opens_it_again() -> void:
	var bank := _bank("manager")
	await wait_physics_frames(2)
	var trunk := bank.manager_trunk
	assert_true(trunk.is_open)
	assert_eq(trunk.get_children().filter(func(n: Node) -> bool: return n.name.begins_with("EmptyBag")).size(), 2)
	assert_eq(trunk.prompt_key(cop), "PROMPT_CLOSE_TRUNK")
	trunk.use(cop)
	assert_false(trunk.is_open)
	assert_eq(trunk.prompt_key(cop), "")
	await wait_seconds(ManagerTrunk.REOPEN + 0.5)
	assert_true(trunk.is_open)
	assert_eq(bank.manager.said(), "MANAGER_TRUNK")


func test_the_boss_gives_himself_away_now_and_then() -> void:
	var bank := _bank("manager")
	await wait_physics_frames(2)
	var lines: Array[String] = []
	for i in BankManager.BOSS_LINE_EVERY:
		bank.manager._complain()
		lines.append(bank.manager.said())
	assert_true(lines.any(func(line: String) -> bool: return line.begins_with("MANAGER_BOSS_")))
