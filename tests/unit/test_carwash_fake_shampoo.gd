extends GutTest

## The car wash raid with the fake shampoo (allanamiento-lavadero.md, step 6): the box of fake shampoo solves the case,
## the green foam smelled near the tank or the running jets is the clue, and giant bubbles float out of the tunnel.

const SCENE := preload("res://scenes/levels/car_wash.tscn")


func _car_wash(case_seed := 5) -> CarWash:
	var car_wash: CarWash = SCENE.instantiate()
	car_wash.story_id = "fake_shampoo"
	car_wash.case_seed = case_seed
	car_wash.get_node("Cop").input_enabled = false
	car_wash.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(car_wash)
	return car_wash


func test_the_box_of_fake_shampoo_solves_the_case() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(10)
	assert_has(car_wash.raid.suspicions, "fake_shampoo")
	assert_eq(car_wash.main.scene_file_path, "res://scenes/props/carwash_shampoo_box.tscn")
	assert_eq(car_wash.extras.size(), 2, "the labels and the funnel")
	car_wash.main.global_position = car_wash.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(car_wash.car.is_delivered(car_wash.main))
	assert_true(car_wash.raid.mark(car_wash.raid.suspicions.find("fake_shampoo")))
	car_wash.car.enter(car_wash.get_node("Cop"))
	assert_true(car_wash.raid.case_solved)


func test_the_green_foam_by_the_tank_is_a_clue() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	var rig := car_wash.rig as FakeShampooRig
	assert_false(rig.smelled, "nobody near the tank")
	car_wash.get_node("Cop").global_position = car_wash.to_global(CarWash.FOAM_TANK_AT + Vector3(0, 0.1, 2.0))
	await wait_seconds(FakeShampooRig.CHECK_EVERY * 2.5)
	assert_true(rig.smelled)
	assert_eq(car_wash.raid.clues_found.count(tr("CLUE_GREEN_FOAM")), 1, "one clue")


func test_bubbles_float_out_while_the_tunnel_runs() -> void:
	var car_wash := _car_wash()
	await wait_physics_frames(2)
	var rig := car_wash.rig as FakeShampooRig
	await wait_seconds(FakeShampooRig.BUBBLE_EVERY + 0.2)
	assert_eq(rig.bubbles, 0, "the tunnel is off")
	car_wash.tunnel.start()
	await wait_seconds(FakeShampooRig.BUBBLE_EVERY * 2 + 0.3)
	assert_eq(rig.bubbles, 2)


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_FAKE_SHAMPOO_B", "BRIEF_FAKE_SHAMPOO_C", "BRIEF_FAKE_SHAMPOO_D", "OBJ_FIND_SHAMPOO_BOX",
			"OBJ_EXTRA_SHAMPOO_LABELS", "OBJ_EXTRA_FUNNEL", "POMPITA_CLUE_fake_shampoo", "CLUE_GREEN_FOAM",
			"CARWASH_SMELL"]:
		assert_ne(tr(key), key, key)
