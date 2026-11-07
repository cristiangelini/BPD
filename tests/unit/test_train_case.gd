extends GutTest

## The train's case (escena-tren.md, step 4a): the level with its case, board and stamp, what was stolen and where,
## the search, nobody going home and the last station that loses the case.

const LEVEL := preload("res://scenes/levels/train.tscn")
const COP_SCENE := preload("res://scenes/player/cop.tscn")


func test_the_level_starts_the_case_with_the_board_in_the_dining_car() -> void:
	var level: TrainLevel = LEVEL.instantiate()
	level.case_seed = 11
	add_child_autofree(level)
	await wait_physics_frames(2)
	assert_eq(level.case.place, level.train)
	assert_true(level.case.tip_given, "by radio, right away")
	assert_eq(level.train.car_of(level.board.global_position + Vector3.UP), Train.CAR_NAMES.find("dining"))
	assert_eq(level.train.car_of(level.stamp.global_position + Vector3.UP), Train.CAR_NAMES.find("dining"))
	var lines := level.case.briefing_lines()
	assert_eq(lines[0], "BRIEF_TRAIN_A_" + level.train.loot, "the comisario says what was stolen")


func test_the_loot_and_its_spot_come_from_the_seed_and_the_right_spot_has_it() -> void:
	var looted := {}
	var spots := {}
	for seed_value in range(1, 40):
		var train := Train.new()
		train.case_seed = seed_value
		add_child_autofree(train)
		var case := CrimeSceneCase.new()
		case.case_seed = seed_value
		case.place = train
		add_child_autofree(case)
		case.start()
		looted[train.loot] = true
		spots[train.loot_spot] = true
		if seed_value < 4:
			var cop: Cop = COP_SCENE.instantiate()
			add_child_autofree(cop)
			for spot: String in Train.LOOT_SPOTS:
				if spot != train.loot_spot:
					train.search(spot, cop)
			assert_false(train.loot_found, "nothing in the others")
			train.search(train.loot_spot, cop)
			assert_true(train.loot_found)
			assert_true(case.loot_found)
			assert_not_null(train.find_child("Loot", true, false))
	assert_eq(looted.size(), Train.LOOTS.size(), "all three get stolen")
	assert_eq(spots.size(), Train.LOOT_SPOTS.size(), "in all three spots")


func test_nobody_gets_off_but_the_last_station_loses_the_case() -> void:
	var level: TrainLevel = LEVEL.instantiate()
	level.case_seed = 11
	add_child_autofree(level)
	await wait_physics_frames(2)
	var case := level.case
	case.elapsed = CrimeSceneCase.LEAVE_FROM + 5 * CrimeSceneCase.LEAVE_EVERY
	await wait_physics_frames(2)
	assert_eq(case.gone.size(), 0, "nobody goes home on a train")
	assert_false(case.lost)
	level.train.ride.time = TrainRide.end_time()
	await wait_physics_frames(2)
	assert_true(case.lost, "the culprit got off at the last station")
	assert_false(case.solved())


func test_accused_in_time_the_last_station_changes_nothing() -> void:
	var level: TrainLevel = LEVEL.instantiate()
	level.case_seed = 11
	add_child_autofree(level)
	await wait_physics_frames(2)
	var case := level.case
	var culprit := case.plan.culprit
	level.train.stick_sticker(2, level.train.magicians[culprit])
	case.accuse(2)
	assert_true(case.accused)
	level.train.ride.time = TrainRide.end_time()
	await wait_physics_frames(2)
	assert_false(case.lost)
