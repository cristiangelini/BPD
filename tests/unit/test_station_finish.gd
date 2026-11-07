extends GutTest

## The station crime scene's end (escena-comisaria.md, step 5): internal affairs comes and takes the case, and half
## the culprits run off in the old patrol car, which loses pieces in the curves.

const LEVEL := preload("res://scenes/levels/station_scene.tscn")


func _level(seed_value: int) -> StationSceneLevel:
	var level: StationSceneLevel = LEVEL.instantiate()
	level.case_seed = seed_value
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	return level


func after_each() -> void:
	Campaign.current = null


func test_internal_affairs_warns_and_then_takes_the_case() -> void:
	var level := _level(21)
	var case := level.case
	case.give_tip()
	assert_eq(case.ia_arrival(), CrimeSceneCase.IA_AT)
	case.elapsed = CrimeSceneCase.IA_AT - CrimeSceneCase.IA_WARN - 0.05
	await wait_physics_frames(6)
	assert_true(case.ia_warned, "the comisario warns on the radio")
	assert_false(case.lost)
	var texts := case.rows().map(func(row: Dictionary) -> String: return row.text)
	assert_true(texts.any(func(text: String) -> bool: return text.begins_with(tr("OBJ_IA_CLOCK").left(10))), "the clock on the planilla")
	case.elapsed = CrimeSceneCase.IA_AT - 0.05
	await wait_physics_frames(6)
	assert_true(case.ia_arrived)
	assert_true(case.lost, "the case is lost")
	assert_false(case.solved())
	assert_not_null(level.get_node_or_null("InternalAffairsAgent"), "the agent comes in")


func test_under_investigation_it_comes_sooner_and_never_after_the_accusation() -> void:
	Campaign.current = Campaign.start_new()
	Campaign.current.investigation = true
	assert_eq(_level(22).case.ia_arrival(), CrimeSceneCase.IA_INVESTIGATING)
	Campaign.current = null
	var level := _level(23)
	var case := level.case
	case.give_tip()
	case.accuse(case.plan.culprit)
	case.elapsed = CrimeSceneCase.IA_AT + 1.0
	await wait_physics_frames(4)
	assert_false(case.ia_arrived, "accused in time, the case is theirs")


func test_half_run_off_in_the_old_patrol_car_and_it_loses_pieces() -> void:
	var seed_value := 13
	while hash(["crime runs", seed_value]) % CrimeSceneCase.RUNS_EVERY != 0:
		seed_value += 1
	var level := _level(seed_value)
	var case := level.case
	case.give_tip()
	assert_true(case.runs_off())
	case.accuse(case.plan.culprit)
	assert_not_null(case.chase, "the chase is on")
	assert_eq(case.chase.suspect_id, SuspectCar.OLD_PATROL)
	assert_eq(case.chase.who, "staff")
	assert_false(level.scene.suspect(case.plan.culprit).visible, "he left the station")
	var drops: ChaseDrops = case.chase.drops
	case.chase.chasing = true
	drops._on_corner(true)
	var pieces := get_tree().get_nodes_in_group("chase_furniture")
	assert_eq(pieces.size(), 1, "a piece in the curve")
	assert_true((pieces[0] as ChaseFurniture).car_part, "off the old patrol car")
