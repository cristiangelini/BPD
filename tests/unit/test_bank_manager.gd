extends GutTest

## Mr. Moneda, the bank's manager (robo-banco-gerente.md, step 1, decision 124): in every robbery he waits in pajamas
## on the sidewalk by his car, and gives the back door's key to the first cop who talks to him; a fifth of the seeds
## he's the gang's real boss.

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


func test_a_sixth_of_the_seeds_he_is_the_boss_and_the_arg_forces_it() -> void:
	var bosses := 0
	for seed_ in range(1, 401):
		if BankLevel.variant(seed_, PackedStringArray()) == "manager":
			bosses += 1
	assert_between(bosses, 25, 100)
	for seed_ in range(1, 20):
		assert_eq(BankLevel.variant(seed_, PackedStringArray(["--bank=manager"])), "manager")


func test_the_old_test_seeds_keep_their_robbery() -> void:
	assert_eq(BankLevel.variant(2, PackedStringArray()), "grandpas")
	assert_eq(BankLevel.variant(3, PackedStringArray()), "party")
	assert_eq(BankLevel.variant(4, PackedStringArray()), "base")
	assert_eq(BankLevel.variant(1, PackedStringArray()), "sorry")


func test_he_waits_outside_by_his_car_in_every_robbery() -> void:
	for want in ["base", "party", "manager"]:
		var bank := _bank(want)
		await wait_physics_frames(2)
		assert_not_null(bank.manager, want)
		assert_not_null(bank.manager_car, want)
		assert_false(bank.inside(bank.manager.global_position), "he's out of the bank")
		assert_lt(bank.manager.global_position.distance_to(bank.manager_car.global_position), 6.0, "by his car")
		assert_eq(bank.manager.boss, want == "manager", want)


func test_he_paces_back_and_forth() -> void:
	var bank := _bank("base")
	await wait_physics_frames(2)
	var from := bank.manager.global_position
	await wait_seconds(BankManager.PAUSE + 1.5)
	assert_gt(bank.manager.global_position.distance_to(from), 0.4, "he walked")
	assert_lt(absf(bank.manager.global_position.z - from.z), 0.2, "along the sidewalk")


func test_he_complains_out_loud() -> void:
	var bank := _bank("base")
	await wait_seconds(2.5)
	assert_string_starts_with(bank.manager.said(), "MANAGER_")


func test_he_gives_the_key_once_and_it_opens_the_back_door() -> void:
	var bank := _bank("base")
	await wait_physics_frames(2)
	assert_eq(bank.back_door.prompt_key(cop), "PROMPT_DOOR_LOCKED")
	assert_eq(bank.manager.prompt_key(cop), "PROMPT_TALK_MANAGER")
	watch_signals(bank.manager)
	bank.manager.use(cop)
	assert_true(cop.has_key)
	assert_signal_emitted(bank.manager, "key_given")
	assert_eq(bank.manager.said(), "MANAGER_KEY")
	bank.manager.use(cop)
	assert_string_starts_with(bank.manager.said(), "MANAGER_AGAIN_")
	assert_signal_emit_count(bank.manager, "key_given", 1)
	bank.back_door.use(cop)
	assert_false(bank.back_door.locked)
	assert_true(bank.back_door.is_open)


func test_his_walkie_is_hidden() -> void:
	var bank := _bank("base")
	await wait_physics_frames(2)
	var walkie := bank.manager.find_child("walkie", true, false) as Node3D
	assert_not_null(walkie)
	assert_false(walkie.visible)
