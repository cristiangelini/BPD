extends GutTest

## Don Tuerca, the bell and the lift (docs/diseno/allanamiento-taller.md, step 2): he walks among the cars filling the
## complaint, the bell sends him to the counter with his back to the garage (twice; the third ring he notices), and the
## lift's button brings its car down, softly squashing a cop under it.

const SCENE := preload("res://scenes/levels/garage.tscn")


func _garage() -> Garage:
	var garage: Garage = SCENE.instantiate()
	garage.case_seed = 5
	garage.get_node("Cop").input_enabled = false
	garage.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(garage)
	return garage


func test_he_walks_his_round() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	var start := garage.tuerca.global_position
	await wait_seconds(1.0)
	assert_gt(garage.tuerca.global_position.distance_to(start), 0.5)
	assert_eq(garage.tuerca.voice, "TUERCA")


func test_the_bell_sends_him_to_the_counter_where_he_sees_nothing() -> void:
	var garage := _garage()
	garage.tuerca.fix_time = 1.0
	await wait_physics_frames(2)
	garage.tuerca.global_position = garage.to_global(Garage.COUNTER_SPOT + Vector3(2.0, 0, -1.0))
	garage.bell.print_copies()
	assert_true(garage.bell.is_jammed)
	await wait_until(func() -> bool: return garage.tuerca.is_fixing(), 10.0)
	assert_true(garage.tuerca.is_fixing(), "at the counter with the client who isn't there")
	assert_false(garage.tuerca.can_see(garage.to_global(Vector3(0, 1, 0))), "his back to the garage")
	await wait_until(func() -> bool: return not garage.tuerca.is_fixing(), 5.0)
	assert_false(garage.bell.is_jammed)
	assert_gt(garage.bell.rest_left, 0.0, "the bell rests")


func test_the_third_ring_he_notices() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	for i in GarageBell.TRICKS:
		garage.bell.print_copies()
		garage.bell.fix()
		garage.bell.rest_left = 0.0
	var before := garage.tuerca.complaint
	garage.bell.print_copies()
	assert_false(garage.bell.is_jammed, "he doesn't come")
	assert_almost_eq(garage.tuerca.complaint, before + Garage.NOTICED, 0.01)


func test_he_sees_a_windshield_crack() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	garage.tuerca.global_position = garage.to_global(Vector3(-3.5, Garage.FLOOR_TOP, 4.0))
	garage.break_windshield(0)
	assert_almost_eq(garage.tuerca.complaint, Garage.SAW_WINDSHIELD, 0.01)


func test_the_lift_comes_down_and_goes_back_up() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	garage.lift_button.use(garage.get_node("Cop"))
	assert_eq(garage.lift_target, 0.0)
	await wait_until(func() -> bool: return is_zero_approx(garage.lift_height), 10.0)
	assert_almost_eq(garage.cars[1].position.y, Garage.FLOOR_TOP, 0.01, "down on the floor")
	garage.toggle_lift()
	await wait_until(func() -> bool: return is_equal_approx(garage.lift_height, Garage.LIFT_HEIGHT), 10.0)
	assert_almost_eq(garage.cars[1].position.y, Garage.FLOOR_TOP + Garage.LIFT_HEIGHT, 0.01, "and up again")


func test_a_cop_under_the_lift_gets_squashed_softly() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	var cop: Cop = garage.get_node("Cop")
	cop.global_position = garage.to_global(Garage.CARS[1].at + Vector3(0.3, 0.1, 0.5))
	await wait_physics_frames(4)
	watch_signals(garage)
	garage.toggle_lift()
	await wait_until(func() -> bool: return garage.fines > 0, 8.0)
	assert_signal_emitted(garage, "squashed")
	assert_eq(garage.fines, Garage.SQUASH_FINE)
	assert_true(cop.is_staggered(), "on the floor for a while")
	await wait_seconds(2.0)
	assert_eq(garage.fines, Garage.SQUASH_FINE, "once a trip")
