extends GutTest

## The roof robbery (robo-banco-techo.md, step 4b, decision 126): after the sacks El Oso flies off hanging from the toy
## helicopter, low over the street; the cop riding beside the patrol car's driver grabs the rope from the window with E
## and he drops cuffed into the back seat.

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


func _fly_off() -> void:
	bank.drill.drilled = bank.drill.drill_time
	await wait_physics_frames(3)
	bank.roof_bags = 0
	bank.helicopter.crashed = false
	bank._oso_by_air()
	# As if a cop already took the wheel.
	bank.chase.chasing = true
	await wait_physics_frames(2)


func _rope() -> RopeGrab:
	return bank.chase.truck.get_node("RopeGrab")


## The cop rides beside the driver's seat, with the car right under El Oso.
func _under_him() -> void:
	bank.car.enter(cop, 1)
	var at := bank.chase.truck.global_position
	bank.car.global_position = Vector3(at.x, at.y + 0.3, at.z)
	await wait_physics_frames(1)


func test_after_the_sacks_he_flies_off() -> void:
	await _fly_off()
	assert_not_null(bank.chase)
	assert_eq(bank.chase.suspect_id, SuspectCar.TOY_HELICOPTER)
	assert_false(bank.helicopter.visible, "the roof's helicopter is the one flying him")
	assert_eq(bank.chase.truck.collision_layer, 0, "nothing on the street gets in its way")
	assert_not_null(_rope())


func test_only_the_one_beside_the_driver_reaches() -> void:
	await _fly_off()
	assert_false(_rope().can_reach(cop), "on foot")
	bank.car.enter(cop, 0)
	var at := bank.chase.truck.global_position
	bank.car.global_position = Vector3(at.x, at.y + 0.3, at.z)
	await wait_physics_frames(1)
	assert_false(_rope().can_reach(cop), "the driver is driving")
	bank.car.exit(cop)
	await _under_him()
	assert_true(_rope().can_reach(cop))
	assert_eq(cop.window_target(), _rope())
	assert_eq(cop.current_prompt(), "PROMPT_GRAB_ROPE")
	bank.car.global_position += Vector3(BankLevel.HALF_X, 0, 0)
	await wait_physics_frames(1)
	assert_false(_rope().can_reach(cop), "too far from under him")
	assert_null(cop.window_target())


func test_grabbing_the_rope_catches_him() -> void:
	await _fly_off()
	await _under_him()
	watch_signals(bank.chase)
	_rope().use(cop)
	assert_true(bank.chase.stopped)
	assert_true(bank.chase.suspect.was_cuffed)
	assert_true(bank.chase.escort.in_car, "into the back seat")
	assert_false(_rope().active)
	await wait_physics_frames(3)
	assert_signal_emitted_with_parameters(bank.chase, "ended", [true])
	assert_true(bank.case.boss_jailed)


func test_he_gets_away_if_nobody_grabs_it() -> void:
	await _fly_off()
	bank.chase.distance = ChaseCase.ESCAPED
	await wait_physics_frames(3)
	assert_true(bank.getaway_over)
	assert_false(bank.getaway_caught)
	assert_true(bank.case.escaped)
