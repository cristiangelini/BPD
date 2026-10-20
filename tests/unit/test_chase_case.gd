extends GutTest

## The chase case (persecucion.md, "Cómo es el caso", decision 94): the clock, the distance meter, stopping and
## cuffing the suspect, driving him back to the station and losing him.

const LEVEL_SCENE := preload("res://scenes/levels/chase.tscn")


func _level() -> ChaseLevel:
	var level: ChaseLevel = LEVEL_SCENE.instantiate()
	level.case_seed = 7
	level.get_node("Cop").input_enabled = false
	level.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(level)
	return level


## Gives the tip and sits the cop at the wheel: the chase is on.
func _chase(level: ChaseLevel) -> Cop:
	var cop: Cop = level.get_node("Cop")
	level.case.give_tip()
	level.case.car.enter(cop, 0)
	return cop


func test_the_suspect_waits_until_a_cop_takes_the_wheel() -> void:
	var level := _level()
	await wait_physics_frames(30)
	var case := level.case
	assert_eq(case.suspect_id, "ice_cream")
	assert_eq(case.car.locked_hint, "HINT_COMISARIO_FIRST", "the comisario first, as always")
	assert_lt(level.truck.global_position.distance_to(case.station_parking.origin), ChaseCase.FAR,
		"he sets off from the corner by the station")
	var waiting_at := level.truck.global_position
	case.give_tip()
	await wait_physics_frames(30)
	assert_false(case.chasing, "nobody at the wheel yet")
	assert_almost_eq(level.truck.global_position.distance_to(waiting_at), 0.0, 0.2)
	assert_eq(case.time_left, ChaseCase.TIME_LIMIT)
	case.car.enter(level.get_node("Cop"), 0)
	await wait_physics_frames(60)
	assert_true(case.chasing)
	assert_gt(level.truck.global_position.distance_to(waiting_at), 3.0, "he drives off")
	assert_lt(case.time_left, ChaseCase.TIME_LIMIT, "and the clock runs")


func test_far_away_the_meter_fills_and_he_gets_away() -> void:
	var level := _level()
	await wait_physics_frames(10)
	_chase(level)
	var case := level.case
	await wait_physics_frames(5)
	# Way behind him, the meter climbs.
	level.truck.global_position = case.car.global_position + Vector3(0, 0, 200)
	case.distance = ChaseCase.ESCAPED - 2.0
	await wait_physics_frames(40)
	assert_true(case.case_failed)
	assert_eq(case.failed_label.text, "CASE_FAILED_ESCAPED")


func test_close_by_the_meter_empties() -> void:
	var level := _level()
	await wait_physics_frames(10)
	_chase(level)
	var case := level.case
	case.distance = 50.0
	await wait_physics_frames(60)
	assert_lt(case.distance, 50.0, "the patrol car right behind him")


func test_after_a_minute_he_got_away() -> void:
	var level := _level()
	await wait_physics_frames(10)
	_chase(level)
	var case := level.case
	await wait_physics_frames(5)
	case.time_left = 0.2
	await wait_physics_frames(30)
	assert_true(case.case_failed)
	assert_eq(case.failed_label.text, "CASE_FAILED_TIME")


func test_stopped_cuffed_and_brought_in_pays_the_salary() -> void:
	var level := _level()
	await wait_physics_frames(10)
	var cop := _chase(level)
	var case := level.case
	var car := case.car
	await wait_physics_frames(5)
	# Cut off by the patrol car across his lane long enough, he gives up and gets out.
	var truck := level.truck
	car.global_transform = Transform3D(truck.global_basis.rotated(Vector3.UP, PI / 2),
		truck.global_position + truck.global_basis.z * 5.0 + Vector3.UP * 0.3)
	await wait_physics_frames(roundi((ChaseCase.STOP_SECONDS + 1.5) * Engine.physics_ticks_per_second))
	assert_true(case.stopped)
	assert_false(level.truck.driving)
	var suspect := case.suspect
	assert_not_null(suspect)
	assert_eq(Handcuffs.cuffable(suspect), suspect, "he can be cuffed")
	assert_eq(suspect.prompt_key(cop), "", "not before he's cuffed")
	suspect.cuffed(Handcuffs.SECONDS)
	await wait_physics_frames(2)
	assert_true(case.caught)
	var frozen := case.time_left
	await wait_physics_frames(30)
	assert_eq(case.time_left, frozen, "caught, the clock stops")
	# Walked to the car, he gets in; with the cop in and the car at the station, it's solved.
	car.exit(cop)
	suspect.global_position = car.to_global(Vector3(1.5, 0.1, 0.0))
	suspect.use(cop)
	await wait_physics_frames(10)
	assert_true(case.escort.in_car)
	car.global_transform = case.station_parking
	car.enter(cop, 0)
	await wait_physics_frames(5)
	assert_true(case.case_solved)
	case.finish_shift()
	assert_true(case.shift_over)
	assert_eq(int(case._result.report.salary), ShiftReport.SALARY, "a salary of 500 (Cristian, 20/10)")


func test_the_place_draw_opens_it() -> void:
	assert_eq(PlaceDraw.pick(7, PackedStringArray(["--place=chase"])), "chase")
	assert_eq(ChaseCase.pick_suspect(7, PackedStringArray()), "ice_cream")


func test_in_a_campaign_a_chase_is_a_shift_with_its_own_quota() -> void:
	Campaign.save_path = "user://test_chase_case/partida.json"
	Campaign.current = Campaign.start_new()
	var level := _level()
	await wait_physics_frames(10)
	var case := level.case
	case.case_solved = true
	case.finish_shift()
	var campaign := Campaign.current
	assert_eq(campaign.shift, 2, "on to the next shift")
	assert_eq(campaign.history[0].story, "chase_ice_cream")
	assert_true(campaign.history[0].approved, "the 500 salary meets the chase's quota of 500")
	Campaign.current = null
	Campaign.save_path = Campaign.SAVE_PATH
	DirAccess.remove_absolute(ProjectSettings.globalize_path("user://test_chase_case/partida.json"))
