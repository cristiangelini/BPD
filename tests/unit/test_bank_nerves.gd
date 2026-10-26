extends GutTest

## El Conejo's nerves (robo-banco-pueblo.md, step 3, decision 127): noise, don Plácido's shouts and seeing a cop raise
## them, silence and kept promises calm him; from half way he leaves the drill to peek and it stands still; full, he
## bolts for the van; and seeing a cop when already very nervous he bolts instead of giving up.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
var cop: Cop
var nerves: BankNerves


func before_each() -> void:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != "town":
		seed_ += 1
	bank = LEVEL.instantiate()
	bank.case_seed = seed_
	cop = bank.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)
	nerves = bank.nerves
	watch_signals(nerves)


func test_the_town_drill_is_shorter_and_only_he_has_nerves() -> void:
	assert_eq(bank.drill.drill_time, BankDrill.TOWN_TIME)
	assert_lt(BankDrill.TOWN_TIME, BankDrill.DRILL_TIME)
	assert_not_null(nerves)
	assert_eq(nerves.robber, bank.boss)
	assert_eq(nerves.nerves, 0.0)


func test_a_cop_running_near_him_raises_them() -> void:
	cop.global_position = bank.boss.global_position + Vector3(-2.5, 0, -1.5)
	cop.is_running = true
	nerves._listen_left = 0.0
	await wait_physics_frames(3)
	assert_almost_eq(nerves.nerves, BankNerves.NOISE, 1.0)
	assert_true(bank.clerk.asleep, "don Plácido is too far to hear it")


func test_don_placido_shouting_raises_them_and_silence_calms_him() -> void:
	bank.clerk.wake("talk")
	assert_almost_eq(nerves.nerves, BankNerves.SHOUT, 0.1)
	await wait_seconds(1.0)
	assert_lt(nerves.nerves, BankNerves.SHOUT - 1.0)


func test_a_kept_promise_calms_him_and_a_lie_doesnt() -> void:
	nerves.add(40.0)
	bank.phone.kept.emit("donuts")
	assert_almost_eq(nerves.nerves, 40.0 - BankNerves.KEPT, 0.5)
	bank.phone.lied.emit("donuts")
	assert_almost_eq(nerves.nerves, 40.0 - BankNerves.KEPT + BankNerves.LIED, 0.5)


func test_half_way_he_leaves_the_drill_to_peek() -> void:
	var yaw := bank.boss.rotation.y
	nerves.add(BankNerves.PEEK + 10.0)
	await wait_physics_frames(2)
	assert_true(nerves.peeking())
	assert_almost_eq(absf(angle_difference(bank.boss.rotation.y, yaw)), PI, 0.01, "turned to the corridor's door")
	assert_eq(bank.boss.said(), "ROBBER_CONEJO_PEEK")
	var drilled := bank.drill.drilled
	await wait_seconds(0.5)
	assert_eq(bank.drill.drilled, drilled, "the drill stands still")
	nerves.peek_left = 0.05
	await wait_physics_frames(5)
	assert_false(nerves.peeking())
	assert_almost_eq(bank.boss.rotation.y, yaw, 0.01, "back to the drill")
	await wait_physics_frames(5)
	assert_gt(bank.drill.drilled, drilled, "and it runs again")


func test_full_he_bolts_for_the_van() -> void:
	nerves.add(BankNerves.MAX)
	assert_true(nerves.bolting)
	assert_signal_emitted_with_parameters(nerves, "bolted", [bank.boss])
	assert_true(bank.boss.running)
	assert_eq(bank.boss.said(), "ROBBER_CONEJO_BOLT")
	await wait_until(func() -> bool: return bank.boss.in_van, 30.0)
	assert_true(bank.boss.in_van, "he made it out to the van")


func test_seeing_a_cop_he_gives_up_but_very_nervous_he_bolts() -> void:
	bank.boss._saw_cop(cop)
	assert_true(bank.boss.surrendered)
	assert_almost_eq(nerves.nerves, BankNerves.SCARE, 0.1)
	assert_false(nerves.bolting)
	nerves.nerves = BankNerves.BOLT_SCARED
	bank.boss._saw_cop(cop)
	assert_true(nerves.bolting)
	assert_false(bank.boss.surrendered, "too scared to stand still")
