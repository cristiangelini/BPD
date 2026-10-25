extends GutTest

## Cuffing the bank's manager (robo-banco-gerente.md, step 3, decision 124): the boss gives up, walks to the patrol
## car, the gang gets nervous and El Oso hangs up; the honest one protests, is let go soon and it counts once.

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


func test_the_boss_gives_up_and_el_oso_hangs_up() -> void:
	var bank := _bank("manager")
	await wait_physics_frames(2)
	watch_signals(bank.manager)
	bank.manager.cuffed(Handcuffs.SECONDS)
	assert_true(bank.manager.caught)
	assert_signal_emitted(bank.manager, "caught_now")
	assert_eq(bank.manager.said(), "MANAGER_CAUGHT")
	assert_gt(bank.drill.nervous_left, 0.0, "the gang heard it")
	assert_true(bank.phone.hung_up)
	assert_eq(bank.phone.said(), "BEAR_PHONE_BOSS_GONE")
	bank.phone.use(cop)
	assert_eq(bank.phone.request, "", "no more requests")
	assert_eq(bank.phone.said(), "PHONE_NO_ANSWER")


func test_the_caught_boss_stops_pacing_and_radioing() -> void:
	var bank := _bank("manager")
	await wait_physics_frames(2)
	bank.manager.cuffed(Handcuffs.SECONDS)
	bank.manager._walkie_in = 0.1
	var at := bank.manager.global_position
	watch_signals(bank.manager)
	await wait_seconds(BankManager.PAUSE + 1.0)
	assert_signal_not_emitted(bank.manager, "radioed")
	assert_lt(bank.manager.global_position.distance_to(at), 0.05)


func test_the_caught_boss_is_walked_to_the_patrol_car() -> void:
	var bank := _bank("manager")
	await wait_physics_frames(2)
	bank.manager.cuffed(Handcuffs.SECONDS)
	assert_eq(bank.manager.prompt_key(cop), "PROMPT_ESCORT_OWNER")
	bank.manager.use(cop)
	var escort := OwnerEscort.of(bank.manager)
	assert_eq(escort.escorted_by, cop)
	cop.global_position = bank.car.global_position + Vector3(3, 0.1, 0)
	bank.manager.global_position = bank.car.global_position + Vector3(2, 0.1, 0)
	await wait_physics_frames(3)
	assert_true(escort.in_car)
	assert_eq(bank.manager.prompt_key(cop), "")


func test_the_trunk_stays_shut_once_he_is_caught() -> void:
	var bank := _bank("manager")
	await wait_physics_frames(2)
	bank.manager_trunk.use(cop)
	bank.manager.cuffed(Handcuffs.SECONDS)
	await wait_seconds(ManagerTrunk.REOPEN + 0.5)
	assert_false(bank.manager_trunk.is_open)


func test_the_honest_one_protests_and_is_let_go_soon() -> void:
	var bank := _bank("base")
	await wait_physics_frames(2)
	assert_null(OwnerEscort.of(bank.manager), "no escort for the honest one")
	watch_signals(bank.manager)
	bank.manager.cuffed(Handcuffs.SECONDS)
	assert_false(bank.manager.caught)
	assert_true(bank.manager.is_cuffed())
	assert_eq(bank.manager.said(), "MANAGER_VICTIM")
	assert_false(bank.phone.hung_up)
	bank.manager.cuffed(Handcuffs.SECONDS)
	assert_signal_emit_count(bank.manager, "wrongly_cuffed", 1)
	await wait_seconds(BankManager.HONEST_CUFF + 0.5)
	assert_false(bank.manager.is_cuffed())


func test_the_handcuffs_reach_him() -> void:
	var bank := _bank("base")
	await wait_physics_frames(2)
	var cuffs := Handcuffs.new()
	cuffs.cop = cop
	add_child_autofree(cuffs)
	assert_eq(cuffs.cuffable(bank.manager), bank.manager)
