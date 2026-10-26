extends GutTest

## The grandpa robbers (robo-banco-abuelos.md, step 1, decision 122): a fifth of the seeds turn the gang into
## retirees with cane and cardigan, who walk at half pace and whose old drill takes longer.

const LEVEL := preload("res://scenes/levels/bank.tscn")


func _bank(want: String) -> BankLevel:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != want:
		seed_ += 1
	var bank: BankLevel = LEVEL.instantiate()
	bank.case_seed = seed_
	bank.get_node("Cop").input_enabled = false
	add_child_autofree(bank)
	return bank


func test_the_seeds_draw_grandpas_a_sixth_of_the_time() -> void:
	var grandpas := 0
	for seed_ in range(1, 401):
		if BankLevel.variant(seed_, PackedStringArray()) == "grandpas":
			grandpas += 1
	assert_between(grandpas, 25, 100)


func test_the_args_force_one() -> void:
	for seed_ in range(1, 20):
		for want: String in ["party", "grandpas", "base"]:
			assert_eq(BankLevel.variant(seed_, PackedStringArray(["--bank=" + want])), want)


func test_the_base_seeds_the_other_tests_use_stay_base() -> void:
	assert_eq(BankLevel.variant(4, PackedStringArray()), "base")
	assert_eq(BankLevel.variant(3, PackedStringArray()), "party")


func test_the_gang_is_four_grandpas_with_their_masks_on() -> void:
	var bank := _bank("grandpas")
	await wait_physics_frames(1)
	assert_true(bank.grandpas)
	assert_false(bank.party)
	assert_eq(bank.robbers.size(), BankRobber.ANIMALS.size())
	for robber in bank.robbers:
		assert_true(robber.grandpa, robber.name)
		assert_not_null(robber.find_child("mask", true, false), "%s wears the mask" % robber.name)
		assert_not_null(robber.find_child("cane", true, false), "%s has a cane" % robber.name)
	assert_null(bank.find_child("Party", false, false), "no party with the grandpas")


func test_the_base_gang_is_young() -> void:
	var bank := _bank("base")
	await wait_physics_frames(1)
	assert_false(bank.grandpas)
	for robber in bank.robbers:
		assert_false(robber.grandpa)
		assert_null(robber.find_child("cane", true, false))
	assert_eq(bank.drill.drill_time, BankDrill.DRILL_TIME)


func test_their_old_drill_takes_longer() -> void:
	var bank := _bank("grandpas")
	await wait_physics_frames(1)
	assert_eq(bank.drill.drill_time, BankDrill.SLOW_TIME)
	assert_gt(BankDrill.SLOW_TIME, BankDrill.DRILL_TIME)
	assert_almost_eq(bank.drill.bar.max_value, BankDrill.SLOW_TIME, 0.01)
	assert_almost_eq(bank.drill.time_left(), BankDrill.SLOW_TIME, 1.0)
	bank.drill.drilled = BankDrill.DRILL_TIME
	await wait_physics_frames(2)
	assert_false(bank.drill.is_open, "the young gang's time isn't enough")


func test_they_walk_at_half_pace() -> void:
	var bank := _bank("grandpas")
	await wait_physics_frames(1)
	for robber in bank.robbers:
		assert_almost_eq(OwnerEscort.of(robber).speed, OwnerEscort.SPEED * BankRobber.GRANDPA_PACE, 0.001)
		assert_almost_eq(robber.run_speed(), BankRobber.RUN_SPEED * BankRobber.GRANDPA_PACE, 0.001)


func test_the_pig_grandpa_runs_slower_to_the_van() -> void:
	var bank := _bank("grandpas")
	await wait_physics_frames(1)
	var pig: BankRobber = bank.robbers[BankRobber.ANIMALS.find("chancho")]
	var from := pig.global_position
	pig.running = true
	await wait_seconds(1.0)
	var went := Vector2(pig.global_position.x - from.x, pig.global_position.z - from.z).length()
	assert_between(went, 0.5, BankRobber.RUN_SPEED * BankRobber.GRANDPA_PACE * 1.2)
