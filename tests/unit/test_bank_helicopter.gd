extends GutTest

## The roof robbery (robo-banco-techo.md, step 2, decision 126): the nephew flies the toy helicopter away when he sees
## a cop on the roof, out of reach for 20 s, and then it lands; his remote needs a rest before flying again, and the
## cops can take it off the roof.

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


func _up_on_the_roof() -> void:
	cop.global_position = bank.to_global(BankLevel.HELIPAD_AT + Vector3(-4, BankLevel.ROOF + 0.1, 0))
	await wait_physics_frames(3)


func test_a_cop_on_the_roof_makes_it_take_off() -> void:
	assert_false(bank.helicopter.flying)
	await _up_on_the_roof()
	assert_true(bank.helicopter.flying)
	assert_eq(bank.nephew.said(), "NEPHEW_TAKE_OFF")
	await wait_seconds(2.0)
	var up := bank.to_local(bank.helicopter.global_position).y - BankLevel.ROOF
	assert_gt(up, 3.0, "up out of reach")


func test_a_cop_in_the_street_doesnt() -> void:
	cop.global_position = bank.to_global(Vector3(0, 0.1, BankLevel.HALF_Z + 2.0))
	await wait_physics_frames(5)
	assert_false(bank.helicopter.flying)


func test_it_slips_out_of_the_hands() -> void:
	var grabber := cop.get_node("Grabber") as Grabber
	grabber.grab(bank.helicopter)
	assert_true(bank.helicopter.is_held())
	bank.helicopter.take_off()
	assert_null(grabber.held)
	assert_false(bank.helicopter.is_held())


func test_it_lands_back_and_rests() -> void:
	await _up_on_the_roof()
	bank.helicopter.fly_left = 0.1
	await wait_seconds(2.5)
	assert_false(bank.helicopter.flying, "back down")
	assert_almost_eq(bank.helicopter.position, bank.helicopter.pad, Vector3.ONE * 0.1, "on its pad")
	assert_almost_eq(bank.nephew_rest, BankLevel.NEPHEW_REST, 3.0, "the remote rests")
	await wait_physics_frames(5)
	assert_false(bank.helicopter.flying, "the cop is still up there, but the remote rests")
	bank.nephew_rest = 0.0
	await wait_physics_frames(2)
	assert_true(bank.helicopter.flying, "rested, it flies away again")


func test_taken_off_the_roof() -> void:
	bank.nephew_rest = 100.0
	assert_false(bank.helicopter_gone)
	bank.helicopter.global_position = bank.to_global(Vector3(BankLevel.HALF_X + 4.0, 0.1, 0))
	await wait_physics_frames(3)
	assert_true(bank.helicopter_gone)
	bank.nephew_rest = 0.0
	await _up_on_the_roof()
	assert_false(bank.helicopter.flying, "the nephew can't fly what isn't up there")
