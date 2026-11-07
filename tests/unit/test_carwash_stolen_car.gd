extends GutTest

## The car wash raid with the stolen car (allanamiento-lavadero.md, step 6): the real plates solve the case, the taped
## plate on the first car in line is the clue, and that car rides through the tunnel again and again on its own.

const SCENE := preload("res://scenes/levels/car_wash.tscn")


func _car_wash(case_seed := 5) -> CarWash:
	var car_wash: CarWash = SCENE.instantiate()
	car_wash.story_id = "stolen_car"
	car_wash.case_seed = case_seed
	car_wash.get_node("Cop").input_enabled = false
	car_wash.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(car_wash)
	return car_wash


func test_the_real_plates_solve_the_case() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(10)
	assert_has(car_wash.raid.suspicions, "stolen_car")
	assert_eq(car_wash.main.scene_file_path, "res://scenes/props/carwash_plates.tscn")
	assert_eq(car_wash.extras.size(), 2, "the fake papers and the screwdriver")
	car_wash.main.global_position = car_wash.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(car_wash.car.is_delivered(car_wash.main))
	assert_true(car_wash.raid.mark(car_wash.raid.suspicions.find("stolen_car")))
	car_wash.car.enter(car_wash.get_node("Cop"))
	assert_true(car_wash.raid.case_solved)


func test_the_taped_plate_is_a_clue_near_a_cop() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	var rig := car_wash.rig as StolenCarRig
	assert_false(rig.noticed, "nobody near the car")
	car_wash.get_node("Cop").global_position = rig.plate.global_position + Vector3(-1.5, -0.4, 0.8)
	await wait_seconds(StolenCarRig.CHECK_EVERY * 2.5)
	assert_true(rig.noticed)
	assert_eq(car_wash.raid.clues_found.count(tr("CLUE_TAPED_PLATE")), 1, "one clue")


func test_the_car_rides_through_the_tunnel_on_its_own_and_comes_back() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	var rig := car_wash.rig as StolenCarRig
	rig._home_for = StolenCarRig.RIDE_EVERY
	await wait_physics_frames(2)
	assert_eq(rig.rides, 1)
	assert_true(car_wash.tunnel.is_running(), "it starts the tunnel")
	await wait_until(func() -> bool: return car_wash.premium.is_out(), 15.0)
	assert_false(car_wash.premium.is_drying(), "nobody paid")
	await wait_until(func() -> bool: return car_wash.premium.is_home(), 20.0)
	assert_lt(car_wash.cars[0].position.distance_to(CarWash.CARS[0]), 0.05, "back in line")


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_STOLEN_CAR_B", "BRIEF_STOLEN_CAR_C", "BRIEF_STOLEN_CAR_D", "OBJ_FIND_PLATES",
			"OBJ_EXTRA_CAR_PAPERS", "OBJ_EXTRA_SCREWDRIVER", "POMPITA_CLUE_stolen_car", "CLUE_TAPED_PLATE",
			"CARWASH_TAPED_PLATE"]:
		assert_ne(tr(key), key, key)
