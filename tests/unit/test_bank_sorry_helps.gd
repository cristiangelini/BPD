extends GutTest

## The sorry robber's other helps (robo-banco-arrepentido.md, step 3, decision 123): after the back door he unplugs the
## drill for a minute and then walks two hostages out of the back door, resting at his spot between helps.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
var cop: Cop


func _bank(animal: String) -> void:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != "sorry" or BankLevel.sorry_animal(seed_) != animal:
		seed_ += 1
	bank = LEVEL.instantiate()
	bank.case_seed = seed_
	cop = bank.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)
	# Out of every robber's sight, by the patrol car.
	cop.global_position = bank.car.global_position + Vector3(3, 0.1, 0)
	await wait_physics_frames(1)


func _until(robber: BankRobber, help: String, seconds: float) -> void:
	var left := seconds
	while help not in robber.helps_done and left > 0.0:
		await wait_physics_frames(10)
		left -= 10.0 / Engine.physics_ticks_per_second


func test_the_helps_come_in_order() -> void:
	assert_eq(BankRobber.HELPS, ["door", "drill", "hostages"] as Array[String])
	var robber := BankRobber.new()
	robber.helps_done = ["door"] as Array[String]
	assert_eq(robber.next_help(), "drill")
	robber.helps_done = ["door", "drill", "hostages"] as Array[String]
	assert_eq(robber.next_help(), "")
	robber.free()


func test_he_unplugs_the_drill_for_a_minute() -> void:
	await _bank("chancho")
	var robber := bank.sorry
	robber.helps_done = ["door"] as Array[String]
	robber.try_turn(cop)
	await wait_physics_frames(2)
	assert_eq(robber.helping, "drill")
	assert_eq(robber.said(), "ROBBER_SORRY_GO_DRILL")
	var drilled := bank.drill.drilled
	await _until(robber, "drill", 40.0)
	assert_has(robber.helps_done, "drill")
	assert_gt(bank.drill.paused_left, BankLevel.UNPLUGGED - 5.0)
	var at := bank.drill.drilled
	await wait_physics_frames(30)
	assert_eq(bank.drill.drilled, at, "the drill stands still")
	assert_gt(at, drilled - 0.01)


func test_he_walks_two_hostages_out_of_the_back_door() -> void:
	await _bank("pato")
	var robber := bank.sorry
	robber.helps_done = ["door", "drill"] as Array[String]
	var picked := bank._sorry_pick()
	assert_eq(picked.size(), BankLevel.SORRY_HOSTAGES)
	robber.try_turn(cop)
	await wait_physics_frames(2)
	assert_eq(robber.helping, "hostages")
	var left := 40.0
	while robber.help_stage == 0 and left > 0.0:
		await wait_physics_frames(10)
		left -= 10.0 / Engine.physics_ticks_per_second
	for hostage in picked:
		assert_eq(hostage.led_by, robber, "he has them by the hand")
	assert_eq(picked[0].said(), "HOSTAGE_SORRY_TAKEN", "the first one says so")
	assert_true(bank.back_door.is_open, "he opens the back door for them")
	await _until(robber, "hostages", 60.0)
	assert_has(robber.helps_done, "hostages")
	for hostage in picked:
		assert_true(hostage.freed, "%s is free" % hostage.name)
	assert_true(robber.going_back or robber.rest_left > 0.0, "and he walks back in")


func test_with_nobody_left_sitting_the_hostages_help_is_skipped() -> void:
	await _bank("conejo")
	for hostage in bank.hostages:
		hostage.free_hostage()
	assert_eq(bank._sorry_way("hostages").size(), 0)
	assert_eq(bank._sorry_help("hostages", 0).size(), 0)


func test_out_of_the_back_door_is_the_corridor_side() -> void:
	assert_true(BankLevel.in_corridor(BankLevel.OUT_BACK))
	assert_true(BankLevel.in_corridor(BankLevel.AT_DRILL))
	assert_false(BankLevel.in_corridor(Vector3(0, 0, 3)))
