extends GutTest

## The party's fans of the gang (robo-banco-rehenes.md, step 3, decision 121): two hostages by the seed wear a
## cardboard mask of the gang, look around while they sit, and shout when they see a cop, which makes the drill nervous.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
var cop: Cop


func _open(party: bool, seed_from := 1) -> void:
	bank = LEVEL.instantiate()
	var seed_ := seed_from
	while BankLevel.is_party(seed_, PackedStringArray()) != party:
		seed_ += 1
	bank.case_seed = seed_
	cop = bank.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)


func _fans() -> Array[BankHostage]:
	var fans: Array[BankHostage] = []
	for hostage in bank.hostages:
		if hostage.snitch != "":
			fans.append(hostage)
	return fans


func test_two_hostages_are_fans_with_a_mask_at_the_party() -> void:
	await _open(true)
	var fans := _fans()
	assert_eq(fans.size(), BankLevel.SNITCHES)
	for fan in fans:
		assert_has(BankRobber.ANIMALS, fan.snitch)
		assert_not_null(fan.find_child("Mask", true, false), "wears the cardboard mask")


func test_the_fans_change_with_the_seed() -> void:
	var picks := {}
	for from in [1, 50, 100, 150, 200]:
		await _open(true, from)
		var names := []
		for fan in _fans():
			names.append(fan.name)
		picks[str(names)] = true
		bank.free()
	assert_gt(picks.size(), 1)


func test_the_base_robbery_has_no_fans() -> void:
	await _open(false)
	assert_eq(_fans().size(), 0)


func test_a_fan_who_sees_a_cop_shouts_and_the_drill_hurries() -> void:
	await _open(true)
	var fan := _fans()[0]
	fan._turn(0.0)
	fan._look_left = 100.0
	cop.global_position = fan.global_position + (-fan.global_basis.z) * 3.0
	assert_true(fan.sees_cop(cop))
	watch_signals(fan)
	await wait_physics_frames(2)
	assert_signal_emitted(fan, "snitched")
	assert_eq(fan.said(), "HOSTAGE_SNITCH")
	assert_gt(bank.drill.nervous_left, 0.0)
	assert_almost_eq(bank.drill.rate(), BankDrill.NERVOUS_RATE, 0.001)


func test_a_fan_doesnt_see_behind_their_look_and_stops_watching_when_led() -> void:
	await _open(true)
	var fan := _fans()[0]
	fan._turn(0.0)
	cop.global_position = fan.global_position + fan.global_basis.z * 3.0
	assert_false(fan.sees_cop(cop), "behind them")
	fan._turn(PI)
	assert_true(fan.sees_cop(cop), "turned around")
	fan.use(cop)
	assert_eq(fan.head_look, 0.0, "looking ahead while led")
	watch_signals(fan)
	await wait_physics_frames(5)
	assert_signal_not_emitted(fan, "snitched")
