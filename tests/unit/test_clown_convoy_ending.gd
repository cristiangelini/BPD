extends GutTest

## Clown convoy step 5 (control-payasos.md, "Cómo es", steps 6 to 8): the driver can be cuffed out of his car and the
## other clowns hop back in; the wanted clown gets walked to the patrol car, an innocent one is a complaint, and the
## wanted clown car getting past runs off as the circus's, dropping inflatable clowns. Play draws the rush hour and
## the convoy half and half.

var level: Node3D
var checkpoint: TrafficCheckpoint
var queue: TrafficQueue
var case: TrafficCase


func before_each() -> void:
	level = Node3D.new()
	add_child_autofree(level)
	var city := Node3D.new()
	city.name = "City"
	level.add_child(city)
	checkpoint = TrafficCheckpoint.new()
	level.add_child(checkpoint)
	checkpoint.global_transform = TrafficControlLevel.checkpoint_at()
	var barrier := RoadBarrier.new()
	barrier.freeze = true
	level.add_child(barrier)
	barrier.global_transform = checkpoint.global_transform
	checkpoint.ready_now = true
	checkpoint.set_physics_process(false)
	queue = TrafficQueue.new()
	queue.checkpoint = checkpoint
	queue.variant = "clown_convoy"
	level.add_child(queue)
	queue.set_physics_process(false)
	case = TrafficCase.new()
	case.case_seed = 12
	case.plan = WantedPlan.draw(12, true)
	case.queue = queue
	case.clues = TrafficClues.new()
	case.clues.plan = case.plan
	case.patrol_car = (load("res://scenes/vehicles/patrol_car.tscn") as PackedScene).instantiate()
	level.add_child(case.patrol_car)
	case.patrol_car.global_transform = CityLayout.parking("station")
	level.add_child(case)
	case.start()


## A clown car at the barrier, wanted or not, with its clowns out.
func _spilled(wanted: bool) -> QueueCar:
	var car := queue.spawn()
	car.wanted = wanted
	car.set_physics_process(false)
	for i in 200:
		car._physics_process(0.1)
		if car.waiting():
			break
	car.open_door()
	for out in car.clowns_out:
		out.set_physics_process(false)
	return car


func test_cuffing_the_wanted_driver_out_of_the_car_takes_him_out_there() -> void:
	var car := _spilled(true)
	var driver := car.clowns_out[0]
	driver.global_position = car.door_point() + Vector3(2, 0, 0)
	var at := driver.global_position
	driver.cuffed(Handcuffs.SECONDS)
	assert_not_null(case.suspect)
	assert_eq(case.suspect.kind, "clown")
	assert_almost_eq(Vector2(case.suspect.global_position.x, case.suspect.global_position.z).distance_to(
		Vector2(at.x, at.z)), 0.0, 0.1, "where he stood")
	assert_eq(car.clowns_out.size(), 0, "the others hop back in")
	assert_eq(get_tree().get_nodes_in_group("convoy_clowns").filter(
		func(n: Node) -> bool: return not n.is_queued_for_deletion()).size(), 0)
	assert_eq(car.state, "pulled_over")


func test_cuffing_a_rider_does_nothing() -> void:
	var car := _spilled(true)
	var rider := car.clowns_out[1]
	rider.cuffed(Handcuffs.SECONDS)
	assert_null(case.suspect)
	assert_eq(case.innocents, 0)
	assert_eq(rider.saying(), tr("CONVOY_NOT_DRIVER"))


func test_an_innocent_driver_is_a_complaint_and_his_car_goes() -> void:
	var car := _spilled(false)
	car.clowns_out[0].cuffed(Handcuffs.SECONDS)
	assert_eq(case.innocents, 1)
	assert_true(car.can_go())
	assert_eq(car.state, "going")


func test_the_wanted_clown_car_runs_off_dropping_dummies() -> void:
	var car := queue.spawn()
	car.wanted = true
	car.set_physics_process(false)
	for i in 200:
		car._physics_process(0.1)
		if car.waiting():
			break
	queue.release_front()
	assert_not_null(case.chase)
	assert_eq(case.chase.truck.kind, SuspectCar.CLOWN_CAR)
	assert_eq(case.chase.who, "clown")
	assert_eq(case.chase.suspect_id, SuspectCar.CLOWN_CAR, "ChaseDrops drops inflatable clowns from it")


func test_the_wanted_driver_s_seat_is_left_empty() -> void:
	var car := _spilled(true)
	car.clowns_out[0].cuffed(Handcuffs.SECONDS)
	await wait_physics_frames(1)
	assert_null(car.get_node_or_null("Driver"))


func test_play_draws_both_traffic_controls() -> void:
	var seen := {}
	for i in 60:
		seen[TrafficControlLevel.variant_from("", PackedStringArray(), i + 1)] = true
	assert_eq(seen.size(), TrafficControlLevel.VARIANTS.size())
	assert_eq(TrafficControlLevel.variant_from("", PackedStringArray(), 9),
		TrafficControlLevel.variant_from("", PackedStringArray(), 9), "same seed, same variant on every PC")
