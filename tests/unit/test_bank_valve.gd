extends GutTest

## The flooding bank's valve and front door (robo-banco-inundado.md, step 2, decision 125): holding E on the valve out
## back turns it (8 s alone, 4 s between two) and stops the water; the front door holds the water in, drains it once the
## pipe is shut and lets out a wave when it opens on deep water.

const LEVEL := preload("res://scenes/levels/bank.tscn")
const COP := preload("res://scenes/player/cop.tscn")

var bank: BankLevel
var cop: Cop


func _bank(want := "flood") -> void:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != want:
		seed_ += 1
	bank = LEVEL.instantiate()
	bank.case_seed = seed_
	cop = bank.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)


func _at_valve(who: Cop, side := 0.0) -> void:
	who.global_position = bank.valve.to_global(Vector3(side, 0.1, 1.0))


func test_only_the_flood_has_a_valve_and_a_front_door() -> void:
	await _bank("base")
	assert_null(bank.valve)
	assert_null(bank.front_door)


func test_the_front_door_is_shut_but_not_locked() -> void:
	await _bank()
	assert_not_null(bank.front_door)
	assert_false(bank.front_door.is_open)
	assert_false(bank.front_door.locked)
	assert_eq(bank.valve.prompt_key(cop), "PROMPT_TURN_VALVE")


func test_one_cop_turns_it_in_eight_seconds() -> void:
	await _bank()
	_at_valve(cop)
	bank.valve.use(cop)
	assert_eq(cop.turning, bank.valve)
	await wait_seconds(2.0)
	assert_almost_eq(bank.valve.turned, 2.0 / BankValve.TURN_TIME, 0.05)
	bank.valve.end_turn(cop)
	var kept := bank.valve.turned
	await wait_seconds(0.5)
	assert_eq(bank.valve.turned, kept, "letting go keeps how far it went")
	assert_null(cop.turning)


func test_two_cops_turn_it_twice_as_fast() -> void:
	await _bank()
	var partner: Cop = COP.instantiate()
	partner.input_enabled = false
	bank.add_child(partner)
	_at_valve(cop, -0.4)
	_at_valve(partner, 0.4)
	await wait_physics_frames(1)
	bank.valve.use(cop)
	bank.valve.use(partner)
	await wait_seconds(1.0)
	assert_almost_eq(bank.valve.turned, 2.0 / BankValve.TURN_TIME, 0.06)


func test_walking_off_lets_go() -> void:
	await _bank()
	_at_valve(cop)
	bank.valve.use(cop)
	cop.global_position = bank.valve.to_global(Vector3(0, 0.1, BankValve.REACH + 2.0))
	await wait_physics_frames(2)
	assert_null(cop.turning)
	assert_true(bank.valve.turners.is_empty())


func test_turned_all_the_way_the_water_stops() -> void:
	await _bank()
	bank.water.level = 0.4
	_at_valve(cop)
	bank.valve.turned = 0.99
	bank.valve.use(cop)
	await wait_seconds(0.3)
	assert_true(bank.valve.is_shut)
	assert_false(bank.water.running)
	assert_null(cop.turning)
	assert_true(bank.water.shut_early(), "shut before it got to a meter")
	var level := bank.water.level
	await wait_physics_frames(10)
	assert_eq(bank.water.level, level, "with the door shut it stays")
	assert_eq(bank.valve.prompt_key(cop), "")


func test_the_open_door_holds_it_while_it_pours_and_drains_it_once_shut() -> void:
	await _bank()
	bank.water.level = 0.15
	bank.front_door.open_from_inside()
	await wait_physics_frames(10)
	assert_almost_eq(bank.water.level, 0.15, 0.0001, "pouring in and out alike")
	bank.water.shut_off()
	await wait_seconds(1.0)
	assert_almost_eq(bank.water.level, 0.15 - BankWater.DRAIN, 0.004)


func test_opening_on_deep_water_lets_a_wave_out() -> void:
	await _bank()
	bank.water.level = 0.5
	cop.global_position = bank.to_global(Vector3(BankLevel.ENTRANCE_X, 0.1, BankLevel.HALF_Z - 1.0))
	var box := RigidBody3D.new()
	var shape := CollisionShape3D.new()
	shape.shape = BoxShape3D.new()
	box.add_child(shape)
	bank.add_child(box)
	box.global_position = bank.to_global(Vector3(BankLevel.ENTRANCE_X + 1.0, 0.6, BankLevel.HALF_Z - 1.5))
	await wait_physics_frames(1)
	bank.front_door.use(cop)
	assert_almost_eq(bank.water.level, 0.5 - BankWater.WAVE_DROP, 0.001)
	assert_true(cop.is_staggered(), "the wave knocks the cop by the door")
	await wait_physics_frames(1)
	assert_gt(box.linear_velocity.dot(bank.global_basis.z), 1.0, "and shoves loose things out")


func test_no_wave_on_shallow_water() -> void:
	await _bank()
	bank.water.level = BankWater.WAVE_MIN - 0.05
	bank.front_door.open_from_inside()
	assert_almost_eq(bank.water.level, BankWater.WAVE_MIN - 0.05, 0.001)


func test_the_pig_running_for_the_van_opens_it() -> void:
	await _bank()
	var pig: BankRobber
	for robber in bank.robbers:
		if robber.animal == "chancho":
			pig = robber
	pig.spotted.emit(pig, cop)
	assert_true(bank.front_door.is_open)


func test_the_texts_are_translated() -> void:
	for key: String in ["PROMPT_TURN_VALVE", "HINT_VALVE_TURN", "HINT_VALVE_FULL", "HINT_VALVE_SHUT"]:
		assert_ne(tr(key), key, key)
