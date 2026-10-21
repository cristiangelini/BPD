extends GutTest

## The golf thieves (persecucion-lugares.md, "Ladrones en carrito de golf"): a cart at 25 km/h that goes hole to hole
## at the golf club, a clock that starts at the gate, and when they're stopped one gives up and the other runs off.

const LEVEL_SCENE := preload("res://scenes/levels/chase.tscn")


func _level() -> ChaseLevel:
	var level: ChaseLevel = LEVEL_SCENE.instantiate()
	level.case_seed = 7
	level.suspect_id = "golf_cart"
	level.get_node("Cop").input_enabled = false
	level.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(level)
	return level


func _golf(level: ChaseLevel) -> GolfClub:
	return level.get_node("City/Built/Golf")


## Into the club through the gate, in the patrol car.
func _drive_in(level: ChaseLevel, cop: Cop) -> void:
	var golf := _golf(level)
	var car := level.case.car
	car.global_transform = golf.global_transform * Transform3D(Basis(Vector3.UP, PI / 2), GolfLayout.GATE + Vector3(6, 0.6, 0))
	if not car.passengers().has(cop):
		car.enter(cop, 0)


func test_the_cart_route_goes_hole_to_hole_and_keeps_off_the_lakes() -> void:
	var route := GolfLayout.cart_route(7)
	assert_eq(route.size(), GolfLayout.CART_STOPS + 1)
	for k in route.size() - 1:
		var from := GolfLayout.to_club(route[k])
		var to := GolfLayout.to_club(route[k + 1])
		assert_true(GolfLayout.HOLES.has(from), "%s is a hole" % from)
		assert_ne(from, to)
		for t in 21:
			assert_false(GolfLayout.in_lake(from.lerp(to, t / 20.0)), "no lake from %s to %s" % [from, to])
	assert_ne(GolfLayout.cart_route(8), route, "another seed, another route")


func test_the_clock_waits_until_a_cop_goes_through_the_gate() -> void:
	var level := _level()
	await wait_physics_frames(5)
	var case := level.case
	var cop: Cop = level.get_node("Cop")
	case.give_tip()
	var golf := _golf(level)
	assert_true(golf.inside(level.truck.global_position), "they wait in the club")
	case.car.enter(cop, 0)
	await wait_physics_frames(30)
	assert_false(case.chasing, "taking the wheel at the station doesn't start it")
	assert_eq(case.time_left, ChaseCase.TIME_LIMIT)
	_drive_in(level, cop)
	await wait_physics_frames(3)
	assert_true(case.chasing, "through the gate, it starts")
	var from := level.truck.global_position
	await wait_physics_frames(Engine.physics_ticks_per_second * 3)
	assert_lt(case.time_left, ChaseCase.TIME_LIMIT - 2.5, "and the clock runs")
	var speed := Vector2(level.truck.global_position.x - from.x, level.truck.global_position.z - from.z).length() / 3.0
	assert_lt(speed, SuspectCar.SPEEDS["golf_cart"] + 0.3, "25 km/h at most")
	assert_gt(speed, 3.0)
	assert_true(golf.inside(level.truck.global_position), "on the lawn still")
	assert_false(golf.in_lake(level.truck.global_position))
	assert_false(case.tasks.wrong_turn(), "no streets to send him down")


func test_stopped_one_gives_up_and_the_other_runs_off() -> void:
	var level := _level()
	await wait_physics_frames(5)
	var case := level.case
	var cop: Cop = level.get_node("Cop")
	case.give_tip()
	_drive_in(level, cop)
	await wait_physics_frames(3)
	case.pull_over()
	assert_not_null(case.suspect)
	assert_not_null(case.runner, "two of them")
	assert_true(level.truck.get_node("Rider").visible == false and level.truck.get_node("Rider2").visible == false,
		"both got off the cart")
	case.car.exit(cop)
	var runner := case.runner
	runner.global_position = _golf(level).to_global(Vector3(-25, 0.1, 0))
	cop.global_position = runner.global_position + Vector3(4, 0.1, 0)
	await wait_physics_frames(5)
	var from := runner.global_position
	var still := case.suspect.global_position
	await wait_physics_frames(Engine.physics_ticks_per_second)
	var ran := Vector2(runner.global_position.x - from.x, runner.global_position.z - from.z)
	assert_almost_eq(ran.length(), ChaseSuspect.RUN_SPEED, 1.0, "he runs at 5 m/s")
	assert_lt(ran.x, 0.0, "away from the cop")
	assert_lt(case.suspect.global_position.distance_to(still), 0.3, "the other one stays")
	case.suspect.cuffed(Handcuffs.SECONDS)
	await wait_physics_frames(2)
	assert_false(case.caught, "one cuffed isn't enough")
	runner.cuffed(Handcuffs.SECONDS)
	var cuffed_at := runner.global_position
	await wait_physics_frames(10)
	assert_true(case.caught)
	assert_lt(runner.global_position.distance_to(cuffed_at), 0.3, "cuffed, he stops")


func test_the_runner_stays_in_the_club() -> void:
	var level := _level()
	await wait_physics_frames(5)
	var case := level.case
	var cop: Cop = level.get_node("Cop")
	case.give_tip()
	_drive_in(level, cop)
	await wait_physics_frames(3)
	case.pull_over()
	var golf := _golf(level)
	case.car.exit(cop)
	case.runner.global_position = golf.to_global(Vector3(GolfLayout.HALF.x - 8.0, 0.1, 0))
	for i in Engine.physics_ticks_per_second * 4:
		cop.global_position = case.runner.global_position + golf.global_basis * Vector3(-4, 0.1, 0)
		await wait_physics_frames(1)
	assert_true(golf.inside(case.runner.global_position), "the fence keeps him in")
	assert_false(golf.in_lake(case.runner.global_position))


func test_both_go_back_in_the_patrol_car_one_in_the_trunk() -> void:
	var level := _level()
	await wait_physics_frames(5)
	var case := level.case
	var cop: Cop = level.get_node("Cop")
	case.give_tip()
	_drive_in(level, cop)
	await wait_physics_frames(3)
	case.pull_over()
	case.suspect.cuffed(Handcuffs.SECONDS)
	case.runner.cuffed(Handcuffs.SECONDS)
	await wait_physics_frames(2)
	var car := case.car
	car.global_transform = case.station_parking
	await wait_physics_frames(2)
	case.escort.board()
	await wait_physics_frames(5)
	assert_false(case.case_solved, "the runner is still out")
	case.runner_escort.board()
	await wait_physics_frames(2)
	var trunk := car.prisoner_seat().translated_local(ChaseCase.TRUNK_SEAT).origin
	assert_lt(case.runner.global_position.distance_to(trunk), 0.05, "in the trunk")
	assert_gt(case.runner.global_position.distance_to(case.suspect.global_position), 1.0, "not on top of the other one")
	car.enter(cop, 0)
	await wait_physics_frames(5)
	assert_true(case.case_solved)
	TranslationServer.set_locale("es")
	for key in ["BRIEF_CHASE_golf_cart", "HINT_GOLF_CLOCK", "HINT_GOLF_RUNNER", "CHASE_GOLF_RUNNER_LINE_1"]:
		assert_ne(tr(key), key, "%s needs a text" % key)
