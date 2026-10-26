extends GutTest

## The roof robbery (robo-banco-techo.md, step 3, decision 126): cuffing El Oso's nephew catches him for good and his
## helicopter, without a pilot, falls wherever it is.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
var cop: Cop


func before_each() -> void:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != "roof":
		seed_ += 1
	bank = LEVEL.instantiate()
	bank.case_seed = seed_
	cop = bank.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)


func test_the_cuffs_catch_him_for_good() -> void:
	watch_signals(bank.nephew)
	assert_true(bank.roof_way_out())
	assert_eq(Handcuffs.cuffable(bank.nephew), bank.nephew)
	bank.nephew.cuffed(Handcuffs.SECONDS)
	assert_true(bank.nephew.is_cuffed())
	assert_eq(bank.nephew.said(), "NEPHEW_CAUGHT")
	assert_signal_emit_count(bank.nephew, "caught_now", 1)
	bank.nephew.cuffed(Handcuffs.SECONDS)
	assert_signal_emit_count(bank.nephew, "caught_now", 1, "only the first time")
	bank.nephew.use(cop)
	assert_eq(bank.nephew.said(), "NEPHEW_CAUGHT_AGAIN")
	assert_false(bank.roof_way_out(), "no pilot, no way out by the roof")


func test_the_helicopter_falls_from_the_air() -> void:
	cop.global_position = bank.to_global(BankLevel.HELIPAD_AT + Vector3(-4, BankLevel.ROOF + 0.1, 0))
	await wait_seconds(2.0)
	assert_true(bank.helicopter.flying)
	var high := bank.helicopter.global_position.y
	bank.nephew.cuffed(Handcuffs.SECONDS)
	assert_true(bank.helicopter.crashed)
	assert_false(bank.helicopter.flying)
	assert_eq(bank.helicopter.spin, 0.0, "the rotors stop")
	await wait_seconds(2.0)
	assert_lt(bank.helicopter.global_position.y, high - 2.0, "it fell")


func test_crashed_it_doesnt_fly_again() -> void:
	bank.nephew.cuffed(Handcuffs.SECONDS)
	bank.nephew_rest = 0.0
	cop.global_position = bank.to_global(BankLevel.HELIPAD_AT + Vector3(-4, BankLevel.ROOF + 0.1, 0))
	await wait_physics_frames(5)
	assert_false(bank.helicopter.flying)
	bank.helicopter.take_off()
	assert_false(bank.helicopter.flying)
