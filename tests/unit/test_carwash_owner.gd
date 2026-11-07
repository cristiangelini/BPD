extends GutTest

## Don Chorro at the car wash (allanamiento-lavadero.md, step 3): his round by the tunnel, the premium wash at the token
## machine that sends the first car through the tunnel and him to dry it with his back to everything (once every 45 s,
## and the third time he catches on), the cop he sees in the tunnel (once per cop) and something falling on the drying
## area's wet floor.

const SCENE := preload("res://scenes/levels/car_wash.tscn")


func _car_wash() -> CarWash:
	var car_wash: CarWash = SCENE.instantiate()
	car_wash.case_seed = 5
	car_wash.get_node("Cop").input_enabled = false
	car_wash.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(car_wash)
	return car_wash


func test_he_walks_his_round_and_speaks_as_don_chorro() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	var start := car_wash.owner_npc.global_position
	await wait_seconds(3.0)
	assert_gt(car_wash.owner_npc.global_position.distance_to(start), 2.0, "he walks")
	assert_eq(car_wash.owner_npc.voice, "CHORRO")
	for key: String in ["CHORRO_LINE_1", "CHORRO_LINE_4", "CHORRO_PRINTER", "CHORRO_FIX_1", "CHORRO_FIX_3",
			"CHORRO_FIX_DONE", "CHORRO_HURT", "CHORRO_DOOR", "CHORRO_SAW", "CHORRO_NOTHING", "CHORRO_OFFENDED",
			"CHORRO_LAWYER", "CHORRO_CAUGHT_ON", "CHORRO_TUNNEL", "CHORRO_WET_FLOOR", "PROMPT_CARWASH_PREMIUM"]:
		assert_ne(tr(key), key, "%s is translated" % key)


func test_the_premium_sends_the_car_through_and_him_to_dry_it_twice_and_the_third_time_he_catches_on() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	var premium := car_wash.premium
	car_wash.owner_npc.fix_time = 1.5
	premium.button.use(car_wash.get_node("Cop"))
	assert_true(premium.is_drying())
	assert_true(car_wash.tunnel.is_running(), "the premium starts the tunnel")
	assert_eq(car_wash.owner_npc.errand(), "printer", "he goes to dry it")
	await wait_until(func() -> bool: return car_wash.owner_npc.is_fixing(), 20.0)
	assert_lt(car_wash.owner_npc.global_position.distance_to(car_wash.to_global(CarWash.DRY_SPOT)), 0.5, "by the exit")
	assert_false(car_wash.owner_npc.can_see(car_wash.to_global(CarWash.DRY_SPOT + Vector3(-2, 1, 2))), "back to it")
	await wait_until(func() -> bool: return car_wash.cars[0].position.distance_to(CarWash.DRY_CAR_AT) < 0.05, 15.0)
	assert_true(CarWash.DRY_CAR_AT.x > CarWash.TUNNEL_X1, "the car came out the other side")
	await wait_until(func() -> bool: return not premium.is_drying(), 5.0)
	await wait_until(func() -> bool: return premium.is_home(), 15.0)
	assert_lt(car_wash.cars[0].position.distance_to(CarWash.CARS[0]), 0.05, "and backs up to its place in line")
	assert_gt(premium.rest_left, 0.0)
	premium.press()
	assert_false(premium.is_drying(), "not again before 45 s")
	premium.rest_left = 0.0
	premium.press()
	assert_true(premium.is_drying(), "the second time he goes")
	premium.fix()
	premium.rest_left = 0.0
	var before := car_wash.owner_npc.complaint
	premium.press()
	assert_false(premium.is_drying(), "the third time he doesn't")
	assert_almost_eq(car_wash.owner_npc.complaint, before + CarWash.CAUGHT_ON, 0.01, "and it adds to the complaint")


func test_he_scolds_a_cop_he_sees_in_the_tunnel_once() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	car_wash.owner_npc.route = [Vector3(9.0, CarWash.FLOOR_TOP, 0.0), Vector3(9.5, CarWash.FLOOR_TOP, 0.0)]
	car_wash.owner_npc.start_at(0)
	var cop: Cop = car_wash.get_node("Cop")
	cop.global_position = car_wash.to_global(Vector3(4.5, CarWash.CONVEYOR_TOP + 0.05, 0.0))
	var before := car_wash.owner_npc.complaint
	await wait_seconds(CarWash.TUNNEL_CHECK_EVERY * 2.5)
	assert_almost_eq(car_wash.owner_npc.complaint, before + CarWash.SAW_TUNNEL, 0.5, "a cop in his tunnel")
	await wait_seconds(CarWash.TUNNEL_CHECK_EVERY * 2.5)
	assert_almost_eq(car_wash.owner_npc.complaint, before + CarWash.SAW_TUNNEL, 0.5, "once per cop")


func test_something_falling_on_the_wet_floor() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	car_wash.owner_npc.route = [Vector3(9.0, CarWash.FLOOR_TOP, 0.0), Vector3(9.5, CarWash.FLOOR_TOP, 0.0)]
	car_wash.owner_npc.start_at(0)
	var before := car_wash.owner_npc.complaint
	var item := ClubEvidence.make_item("Dropped", CarWash.TOKEN_MODEL, Vector3(0.3, 0.3, 0.3), 1.0)
	car_wash.add_child(item)
	item.global_position = car_wash.to_global(Vector3(14.0, 2.5, -2.0))
	await wait_physics_frames(40)
	assert_almost_eq(car_wash.owner_npc.complaint, before + CarWash.SAW_WET_FLOOR, 0.5, "¡eso no se lava así!")
