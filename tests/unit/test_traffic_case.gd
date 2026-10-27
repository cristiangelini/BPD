extends GutTest

## Traffic control step 5 (control-transito.md, decision 98): cuffing a stopped car's driver detains them. The
## wanted one gets out to be walked to the patrol car and solves the case; the second innocent loses it, and so does
## the wanted car getting past the checkpoint.

var checkpoint: TrafficCheckpoint
var queue: TrafficQueue
var case: TrafficCase


func before_each() -> void:
	checkpoint = TrafficCheckpoint.new()
	add_child_autofree(checkpoint)
	var barrier := RoadBarrier.new()
	barrier.freeze = true
	add_child_autofree(barrier)
	checkpoint.ready_now = true
	checkpoint.set_physics_process(false)
	queue = TrafficQueue.new()
	queue.checkpoint = checkpoint
	add_child_autofree(queue)
	queue.set_physics_process(false)
	case = TrafficCase.new()
	case.plan = WantedPlan.draw(4)
	case.queue = queue
	case.clues = TrafficClues.new()
	case.clues.plan = case.plan
	case.patrol_car = (load("res://scenes/vehicles/patrol_car.tscn") as PackedScene).instantiate()
	add_child_autofree(case.patrol_car)
	case.patrol_car.global_position = Vector3(40, 0, 0)
	add_child_autofree(case)
	case.start()


func after_each() -> void:
	for node in get_tree().get_nodes_in_group("chase_suspect"):
		node.queue_free()


func _stopped_car(wanted := false) -> QueueCar:
	var car := queue.spawn()
	car.wanted = wanted
	car.set_physics_process(false)
	for i in 200:
		car._physics_process(0.1)
		if car.waiting():
			break
	return car


func test_the_tip_starts_the_radio() -> void:
	assert_true(case.tip_given)
	assert_eq(case.clues.get_parent(), case)
	assert_eq(case.clues.known, 1)


func test_cuffs_on_a_car_go_to_the_case() -> void:
	var car := _stopped_car()
	assert_eq(Handcuffs.cuffable(car), car)
	car.cuffed(Handcuffs.SECONDS)
	assert_eq(case.innocents, 1)
	assert_false(car.is_cuffed())


func test_an_innocent_drives_off_and_the_second_loses_the_case() -> void:
	var first := _stopped_car()
	case.detain(first)
	assert_eq(first.state, "going")
	assert_false(queue.cars.has(first))
	assert_eq(first.saying(), tr("TRAFFIC_INNOCENT_LINE"))
	assert_false(case.lost)
	var second := _stopped_car()
	case.detain(second)
	assert_true(case.lost)
	assert_false(case.solved())


func test_the_wanted_driver_gets_out_cuffed_and_the_patrol_car_solves_it() -> void:
	var car := _stopped_car(true)
	watch_signals(case)
	case.detain(car)
	assert_signal_emitted_with_parameters(case, "detained", [car, true])
	assert_eq(car.state, "pulled_over")
	assert_not_null(case.suspect)
	assert_true(case.suspect.is_cuffed())
	assert_eq(case.suspect.kind, "driver")
	assert_not_null(case.escort)
	assert_false(case.solved())
	case.escort.boarded.emit()
	assert_true(case.solved())


func test_pulled_over_it_moves_to_the_curb_and_stays() -> void:
	var car := _stopped_car(true)
	case.detain(car)
	var z := car.at.z
	for i in 40:
		car._physics_process(0.1)
	assert_almost_eq(car.at.x, QueueCar.CURB_SIDE, 0.01)
	assert_almost_eq(car.at.z, z, 0.01)


func test_a_moving_car_cant_be_detained() -> void:
	var car := queue.spawn()
	car.set_physics_process(false)
	car.cuffed(Handcuffs.SECONDS)
	assert_eq(case.innocents, 0)
	assert_eq(car.state, "coming")


func test_the_wanted_car_let_through_loses_the_case() -> void:
	var car := _stopped_car(true)
	assert_eq(queue.front(), car)
	queue.release_front()
	assert_true(case.lost)


func test_innocents_come_off_the_pay() -> void:
	case.innocents = 1
	case.solved_now = true
	var report := ShiftReport.pay(case.solved(), [], case.innocents * TrafficCase.COMPLAINT_FINE)
	assert_eq(report.total, ShiftReport.SALARY - TrafficCase.COMPLAINT_FINE)
	case.finish_shift()
	assert_true(case.shift_over)


func test_a_guest_finds_the_driver_whose_copy_comes_in_late() -> void:
	# The last test's driver goes at the end of the frame.
	await wait_physics_frames(1)
	var state := case.snapshot()
	case.follower = true
	state.suspect = true
	# The case's news can beat the driver's copy (NpcSync), and the case doesn't send it again.
	case.apply_snapshot(state)
	assert_null(case.suspect)
	var driver := ChaseSuspect.new()
	driver.name = "Driver"
	add_child_autofree(driver)
	await wait_physics_frames(2)
	assert_eq(case.suspect, driver, "found once he's in")
	assert_not_null(case.escort, "and the escort follows the host's")
