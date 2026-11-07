extends GutTest

## The magic odometer story (allanamiento-taller.md, step 5): the drill with its notebook and sign hidden with the seed,
## the dashboards of the cars on the floor (one says 12 km, the clue the first time it's read) and the drill in the
## trunk solving the case.

const SCENE := preload("res://scenes/levels/garage.tscn")


func _garage(case_seed := 5) -> Garage:
	var garage: Garage = SCENE.instantiate()
	garage.story_id = "magic_odometer"
	garage.case_seed = case_seed
	garage.get_node("Cop").input_enabled = false
	garage.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(garage)
	return garage


func test_the_drill_and_its_extras_are_hidden() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	assert_eq(garage.main, garage.hidden[0])
	assert_almost_eq((garage.main as RigidBody3D).mass, 2.0, 0.01)
	assert_eq(garage.extras.size(), 2, "the notebook and the sign")
	assert_true(Garage.SPOTS[garage.hidden_spots[2]].heavy, "the big sign lies where it fits")


func test_one_dashboard_says_12_km_and_reading_it_is_a_clue_once() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	var rig := garage.rig as MagicOdometerRig
	assert_has([0, 2], rig.wound_back)
	assert_eq(rig.dashboards.size(), 2, "the cars on the floor")
	var cop: Cop = garage.get_node("Cop")
	var other: int = 2 - rig.wound_back
	(rig.dashboards[other] as GarageDashboard).use(cop)
	assert_false(garage.raid.clues_found.has(tr("CLUE_ODOMETER")), "a normal car says nothing")
	var low := rig.dashboards[rig.wound_back] as GarageDashboard
	assert_eq(low.reading, "HINT_ODOMETER_LOW")
	low.use(cop)
	assert_has(garage.raid.clues_found, tr("CLUE_ODOMETER"))
	var clues: int = garage.raid.clues_found.size()
	low.use(cop)
	assert_eq(garage.raid.clues_found.size(), clues, "the clue only once")


func test_the_drill_in_the_trunk_solves_the_case() -> void:
	var garage := _garage()
	await wait_physics_frames(10)
	garage.main.global_position = garage.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(garage.car.is_delivered(garage.main))
	assert_true(garage.raid.mark(garage.raid.suspicions.find("magic_odometer")))
	garage.car.enter(garage.get_node("Cop"))
	assert_true(garage.raid.case_solved)


func test_the_story_texts_exist() -> void:
	for key: String in ["BRIEF_MAGIC_ODOMETER_B", "BRIEF_MAGIC_ODOMETER_C", "BRIEF_MAGIC_ODOMETER_D",
			"OBJ_FIND_ODOMETER_DRILL", "OBJ_EXTRA_KM_NOTEBOOK", "OBJ_EXTRA_ZERO_KM_SIGN", "GRASITA_CLUE_magic_odometer",
			"CLUE_ODOMETER", "HINT_ODOMETER", "HINT_ODOMETER_LOW", "PROMPT_DASHBOARD"]:
		assert_ne(tr(key), key)
