extends GutTest

## The sorry robber (robo-banco-arrepentido.md, step 1, decision 123): a quarter of the seeds, one of the three under
## El Oso cries under his mask with a white hanky and keeps quiet about the cops.

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


func test_the_seeds_draw_all_four_in_quarters() -> void:
	var drawn := {"party": 0, "grandpas": 0, "sorry": 0, "base": 0}
	for seed_ in range(1, 401):
		drawn[BankLevel.variant(seed_, PackedStringArray())] += 1
	for want: String in drawn:
		assert_between(drawn[want], 60, 140, want)


func test_the_arg_forces_it() -> void:
	for seed_ in range(1, 20):
		assert_eq(BankLevel.variant(seed_, PackedStringArray(["--bank=sorry"])), "sorry")


func test_the_sorry_one_is_never_el_oso_and_the_seed_picks_him() -> void:
	var picked := {}
	for seed_ in range(1, 100):
		var animal := BankLevel.sorry_animal(seed_)
		assert_ne(animal, "oso")
		assert_eq(BankLevel.sorry_animal(seed_), animal, "the same seed picks the same one")
		picked[animal] = true
	assert_eq(picked.size(), 3, "any of the three can be")


func test_only_the_sorry_one_has_a_hanky() -> void:
	var bank := _bank("sorry")
	await wait_physics_frames(1)
	assert_not_null(bank.sorry)
	assert_eq(bank.sorry.animal, BankLevel.sorry_animal(bank.case_seed))
	for robber in bank.robbers:
		assert_eq(robber.sorry, robber == bank.sorry, robber.name)
		assert_eq(robber.find_child("Hanky", false, false) != null, robber == bank.sorry, robber.name)
	assert_false(bank.grandpas)
	assert_false(bank.party)


func test_the_other_variants_have_no_sorry_robber() -> void:
	for want: String in ["base", "party", "grandpas"]:
		var bank := _bank(want)
		await wait_physics_frames(1)
		assert_null(bank.sorry, want)
		for robber in bank.robbers:
			assert_false(robber.sorry, "%s %s" % [want, robber.name])


func test_he_sobs_every_few_seconds_with_the_hanky_up() -> void:
	var robber := BankRobber.new()
	robber.animal = "pato"
	robber.sorry = true
	add_child_autofree(robber)
	var hanky := robber.find_child("Hanky", false, false) as Node3D
	assert_eq(hanky.position, BankRobber.HANKY_DOWN)
	robber._sob(BankRobber.SOB_EVERY + 0.01)
	assert_true(robber.is_sobbing())
	assert_eq(robber.said(), "ROBBER_SORRY_SOB_1")
	assert_eq(hanky.position, BankRobber.HANKY_UP)
	robber._sob(BankRobber.SOB_TIME + 0.01)
	robber._sob(0.01)
	assert_false(robber.is_sobbing())
	assert_eq(hanky.position, BankRobber.HANKY_DOWN)
	robber._sob(BankRobber.SOB_EVERY)
	assert_eq(robber.said(), "ROBBER_SORRY_SOB_2", "a different line each time")


func test_he_doesnt_shout_about_a_cop_in_front_of_him() -> void:
	var bank := _bank("sorry")
	await wait_physics_frames(1)
	await wait_physics_frames(1)
	var robber := bank.sorry
	var cop: Cop = bank.get_node("Cop")
	var shouted := []
	robber.spotted.connect(func(_r: BankRobber, _c: Node3D) -> void: shouted.append(true))
	var saw := false
	for i in 10:
		robber.look = 0.0
		cop.global_position = robber.global_position + robber.facing() * 1.2 + Vector3.UP * 0.1
		await wait_physics_frames(1)
		saw = saw or robber.sees_cop(cop)
	assert_true(saw, "he sees the cop")
	assert_eq(shouted.size(), 0, "but keeps quiet")
	assert_false(robber.surrendered)
	assert_false(robber.running)


func test_a_guest_sees_the_hanky_up() -> void:
	var host := BankRobber.new()
	host.animal = "conejo"
	host.sorry = true
	add_child_autofree(host)
	var guest := BankRobber.new()
	guest.animal = "conejo"
	guest.sorry = true
	guest.follower = true
	add_child_autofree(guest)
	host._sob(BankRobber.SOB_EVERY + 0.01)
	guest.apply_net_state(host.net_state())
	assert_true(guest.is_sobbing())
	assert_eq((guest.find_child("Hanky", false, false) as Node3D).position, BankRobber.HANKY_UP)
