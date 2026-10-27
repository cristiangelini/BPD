extends GutTest

## The street race story (allanamiento-taller.md, step 5): the trophy with the nitro tank and the race map hidden with the
## seed, the circle of rubber marks on the floor that is a clue the first time a cop walks into it, and the trophy in the
## trunk solving the case.

const SCENE := preload("res://scenes/levels/garage.tscn")


func _garage(case_seed := 5) -> Garage:
	var garage: Garage = SCENE.instantiate()
	garage.story_id = "street_race"
	garage.case_seed = case_seed
	garage.get_node("Cop").input_enabled = false
	garage.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(garage)
	return garage


func test_the_trophy_and_its_extras_are_hidden() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	assert_eq(garage.main, garage.hidden[0])
	assert_almost_eq((garage.main as RigidBody3D).mass, 4.0, 0.01)
	assert_eq(garage.extras.size(), 2, "the nitro tank and the race map")
	assert_true(Garage.SPOTS[garage.hidden_spots[1]].heavy, "the nitro tank lies where it fits")


func test_the_marks_lie_on_the_floor_away_from_the_cars() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	var marks: Node3D = garage.get_node("RubberMarks")
	assert_eq(marks.get_child_count(), StreetRaceRig.MARKS * 2 + 1, "two tires' worth of marks and the area")
	var reach := StreetRaceRig.RADIUS + StreetRaceRig.TRACK + StreetRaceRig.MARK_SIZE.z
	for car: Dictionary in Garage.CARS:
		var at: Vector3 = car.at
		assert_gt(absf(at.z - StreetRaceRig.CENTER.z), Garage.CAR_SIZE.z / 2 + reach, "clear of every car")
	assert_lt(StreetRaceRig.CENTER.z + reach, Garage.HALF_Z, "inside the shed")


func test_walking_into_the_circle_is_a_clue_once() -> void:
	var garage := _garage()
	await wait_physics_frames(2)
	var rig := garage.rig as StreetRaceRig
	var cop: Cop = garage.get_node("Cop")
	cop.global_position = garage.to_global(StreetRaceRig.CENTER + Vector3.UP * 0.1)
	await wait_physics_frames(5)
	assert_true(rig.seen)
	assert_has(garage.raid.clues_found, tr("CLUE_RUBBER_MARKS"))
	var clues: int = garage.raid.clues_found.size()
	rig.see(cop)
	assert_eq(garage.raid.clues_found.size(), clues, "the clue only once")


func test_the_trophy_in_the_trunk_solves_the_case() -> void:
	var garage := _garage()
	await wait_physics_frames(10)
	garage.main.global_position = garage.car.to_global(Vector3(0, 0.6, -1.7))
	await wait_physics_frames(10)
	assert_true(garage.car.is_delivered(garage.main))
	assert_true(garage.raid.mark(garage.raid.suspicions.find("street_race")))
	garage.car.enter(garage.get_node("Cop"))
	assert_true(garage.raid.case_solved)


func test_the_story_texts_exist() -> void:
	for key: String in ["BRIEF_STREET_RACE_B", "BRIEF_STREET_RACE_C", "BRIEF_STREET_RACE_D", "OBJ_FIND_RACE_TROPHY",
			"OBJ_EXTRA_NITRO_TANK", "OBJ_EXTRA_RACE_MAP", "GRASITA_CLUE_street_race", "HINT_RUBBER_MARKS",
			"CLUE_RUBBER_MARKS"]:
		assert_ne(tr(key), key)
