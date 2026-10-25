extends GutTest

## The flooding bank's wet drill, hostages up on the counter and duck floats (robo-banco-inundado.md, step 3, decision
## 125): from 0.5 m the drill goes at half pace; from 0.6 m the hostages get up on the counter and won't come down
## without a float from the patrol car's trunk, or until the water is low again.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
var cop: Cop


func _bank() -> void:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != "flood":
		seed_ += 1
	bank = LEVEL.instantiate()
	bank.case_seed = seed_
	cop = bank.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)
	# The door open with the pipe pouring: the level stays where the test puts it.
	bank.front_door.open_from_inside()


func _flood(level: float) -> void:
	bank.water.level = level
	await wait_physics_frames(2)


func test_the_wet_drill_goes_at_half_pace() -> void:
	await _bank()
	var dry := bank.drill.rate()
	await _flood(0.55)
	assert_true(bank.drill.wet)
	assert_almost_eq(bank.drill.rate(), dry * BankDrill.WET_RATE, 0.001)
	assert_eq(bank.water.duck.said(), "DUCK_DRILL_WET")
	await _flood(0.3)
	assert_false(bank.drill.wet, "dry again under 0.5 m")


func test_waist_deep_they_get_up_on_the_counter() -> void:
	await _bank()
	var led := bank.hostages[0]
	led.use(cop)
	assert_eq(led.led_by, cop)
	await _flood(0.65)
	for hostage in bank.hostages:
		assert_true(hostage.perched)
		assert_almost_eq(hostage.global_position.y, bank.to_global(Vector3(0, BankLevel.FLOOR_TOP
			+ BankLevel.COUNTER_SIZE.y, 0)).y, 0.05)
		assert_false(hostage.sitting(), "El Oso can't let one go from up there")
	assert_null(led.led_by, "the water made them let go of the hand")


func test_without_a_float_they_wont_come_down() -> void:
	await _bank()
	await _flood(0.65)
	var hostage := bank.hostages[2]
	assert_eq(hostage.prompt_key(cop), "PROMPT_LEAD_HOSTAGE")
	hostage.use(cop)
	assert_true(hostage.perched)
	assert_null(hostage.led_by)
	assert_string_starts_with(hostage.said(), "HOSTAGE_SWIM_")


func test_a_float_from_the_trunk_brings_one_down() -> void:
	await _bank()
	await _flood(0.65)
	assert_eq(bank.floats.left, BankFloats.FLOATS)
	assert_eq(bank.floats.prompt_key(cop), "PROMPT_TAKE_FLOAT")
	bank.floats.use(cop)
	assert_true(cop.duck_float)
	assert_eq(bank.floats.left, BankFloats.FLOATS - 1)
	bank.floats.use(cop)
	assert_eq(bank.floats.left, BankFloats.FLOATS - 1, "one each")
	var hostage := bank.hostages[1]
	assert_eq(hostage.prompt_key(cop), "PROMPT_GIVE_FLOAT")
	hostage.use(cop)
	assert_false(hostage.perched)
	assert_true(hostage.duck_float)
	assert_false(cop.duck_float)
	assert_eq(hostage.led_by, cop)
	assert_not_null(hostage.get_node_or_null("DuckFloat"))
	assert_null(cop.get_node_or_null("DuckFloat"))


func test_floating_they_follow_at_full_pace() -> void:
	await _bank()
	await _flood(1.0)
	bank.floats.use(cop)
	var hostage := bank.hostages[1]
	hostage.use(cop)
	cop.global_position = hostage.global_position + Vector3(4, 0, 0)
	await wait_physics_frames(2)
	assert_false(hostage.perched, "with the float on they stay in the water")
	var horizontal := Vector2(hostage.velocity.x, hostage.velocity.z).length()
	assert_almost_eq(horizontal, hostage.speed(), 0.1)


func test_only_four_floats() -> void:
	await _bank()
	for i in BankFloats.FLOATS:
		cop.duck_float = false
		bank.floats.use(cop)
	assert_eq(bank.floats.left, 0)
	cop.duck_float = false
	bank.floats.use(cop)
	assert_false(cop.duck_float)
	assert_eq(bank.floats.prompt_key(cop), "")


func test_low_water_brings_them_down_to_their_spot() -> void:
	await _bank()
	var hostage := bank.hostages[3]
	var home := hostage.home
	await _flood(0.65)
	assert_true(hostage.perched)
	await _flood(0.4)
	assert_false(hostage.perched)
	assert_almost_eq(hostage.global_position.distance_to(home), 0.0, 0.1)
	assert_true(hostage.sitting())


func test_the_texts_are_translated() -> void:
	for key: String in ["HUD_DRILL_WET", "DUCK_DRILL_WET", "PROMPT_TAKE_FLOAT", "HINT_FLOAT_TAKEN", "HINT_FLOATS_GONE",
			"PROMPT_GIVE_FLOAT", "HINT_HOSTAGE_FLOAT", "HOSTAGE_SWIM_1", "HOSTAGE_SWIM_3", "HOSTAGE_FLOAT_ON"]:
		assert_ne(tr(key), key, key)
