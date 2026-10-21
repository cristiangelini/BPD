extends GutTest

## A chase in the middle of another case (persecucion-final.md, decision 96): it starts at once from where the
## suspect's vehicle is parked, with the clock and the distance meter, and when he's caught or gets away the case it
## interrupted goes on.

const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")


func _house() -> GrandpaHouse:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.story = GrandpaHouse.BINGO
	house.case_seed = 7
	house.start_at_station = false
	house.get_node("Cop").input_enabled = false
	house.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(house)
	return house


## The getaway car parked in front of the patrol car, on the street by the house.
func _chase(house: GrandpaHouse, kind := "night") -> ChaseCase:
	var at := house.car.global_transform.translated_local(Vector3(0, 0, -9))
	return ChaseCase.begin(house, kind, at, house.car, house.get_node("City"), 7, house.city_map)


func _flat(v: Vector3) -> Vector2:
	return Vector2(v.x, v.z)


func test_it_starts_at_once_and_drives_off_from_where_he_parked() -> void:
	var house := _house()
	await wait_physics_frames(10)
	var parked := house.car.global_transform.translated_local(Vector3(0, 0, -9)).origin
	var chase := _chase(house)
	assert_true(chase.embedded)
	assert_true(chase.chasing, "no comisario and no wheel to wait for")
	assert_lt(_flat(chase.truck.global_position).distance_to(_flat(parked)), 0.1, "from where he parked")
	assert_eq(chase.weather.kind, "", "no night in the middle of the raid")
	assert_true(chase.weather.shows_suspect())
	assert_not_null(chase.meters, "the clock and the distance at the top")
	assert_eq(house.city_map.suspect, chase.truck, "the copilot's map can show him")
	await wait_physics_frames(Engine.physics_ticks_per_second * 2)
	assert_gt(_flat(chase.truck.global_position).distance_to(_flat(parked)), 6.0, "he drives off")
	assert_lt(chase.time_left, ChaseCase.TIME_LIMIT - 1.5, "and the clock runs")
	TranslationServer.set_locale("es")
	for key in ["HINT_CHASE_FLEES", "HINT_CHASE_CAUGHT_HERE", "HINT_CHASE_BACK_TO_CASE", "HINT_CHASE_GOT_AWAY"]:
		assert_ne(tr(key), key, "%s needs a text" % key)


func test_caught_and_in_the_patrol_car_the_raid_goes_on() -> void:
	var house := _house()
	await wait_physics_frames(10)
	var chase := _chase(house)
	watch_signals(chase)
	await wait_physics_frames(3)
	chase.pull_over()
	chase.suspect.cuffed(Handcuffs.SECONDS)
	await wait_physics_frames(2)
	assert_true(chase.caught)
	assert_signal_not_emitted(chase, "ended", "not until he's in the car")
	chase.escort.board()
	await wait_physics_frames(2)
	assert_signal_emitted_with_parameters(chase, "ended", [true])
	assert_false(chase.chasing)
	assert_eq(house.car.prisoner, chase.suspect, "he rides in the patrol car")
	await wait_physics_frames(2)
	assert_false(is_instance_valid(chase.meters), "the meters go")
	assert_false(house.raid.case_failed)
	assert_false(house.raid.shift_over, "no shift of its own: the raid goes on")


func test_got_away_his_car_is_gone_and_the_raid_goes_on() -> void:
	var house := _house()
	await wait_physics_frames(10)
	var chase := _chase(house)
	watch_signals(chase)
	var truck := chase.truck
	chase.distance = ChaseCase.ESCAPED - 0.1
	house.car.global_position += Vector3(0, 0, 200)
	await wait_physics_frames(5)
	assert_signal_emitted_with_parameters(chase, "ended", [false])
	assert_false(house.raid.case_failed, "the chase is lost, not the raid")
	await wait_seconds(ChaseCase.GONE_AFTER + 0.5)
	assert_false(is_instance_valid(truck), "his car is gone")
	assert_false(house.raid.shift_over)


func test_on_foot_the_distance_counts_from_the_nearest_cop() -> void:
	var house := _house()
	await wait_physics_frames(10)
	var chase := _chase(house, "wheelchair")
	assert_true(chase.on_foot())
	var cop: Cop = house.get_node("Cop")
	await wait_physics_frames(3)
	cop.global_position = chase.truck.global_position + Vector3(4, 0.1, 0)
	house.car.global_position += Vector3(0, 0, 200)
	chase.distance = 50.0
	await wait_physics_frames(Engine.physics_ticks_per_second / 2)
	assert_lt(chase.distance, 50.0, "a cop on foot right by him keeps him close, the car far away doesn't count")
