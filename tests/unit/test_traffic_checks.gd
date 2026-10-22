extends GutTest

## Traffic control step 3 (control-transito.md, "Revisar un auto"): each car has a driver drawn from the seed, says
## its line at the barrier, hands the license with E and has a trunk that opens by lifting its lid.

var checkpoint: TrafficCheckpoint
var queue: TrafficQueue


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
	queue.case_seed = 5
	add_child_autofree(queue)
	queue.set_physics_process(false)


func _drive_to_barrier() -> QueueCar:
	var car := queue.spawn()
	car.set_physics_process(false)
	for i in 200:
		car._physics_process(0.1)
		if car.waiting():
			break
	return car


func test_drivers_come_from_the_seed() -> void:
	var a := RandomNumberGenerator.new()
	a.seed = 9
	var b := RandomNumberGenerator.new()
	b.seed = 9
	assert_eq(DriverTraits.draw(a), DriverTraits.draw(b))
	var kinds := {}
	var lines := {}
	for i in 300:
		var driver := DriverTraits.draw(a)
		kinds[driver.trunk] = true
		lines[driver.line] = true
		assert_true(driver.year >= 1950 and driver.year <= 2004)
	assert_eq(kinds.size(), DriverTraits.TRUNKS.size())
	assert_eq(lines.size(), DriverTraits.LINES)


func test_every_line_is_translated() -> void:
	for i in DriverTraits.LINES:
		var key := "DRIVER_LINE_%d" % i
		assert_ne(tr(key), key)
	for key in ["LICENSE_TEXT", "PROMPT_PAPERS", "PROMPT_TRUNK", "TRUNK_CONTRABAND", "TRUNK_GRANDPA"]:
		assert_ne(tr(key), key)


func test_the_first_car_says_its_line_at_the_barrier() -> void:
	var car := _drive_to_barrier()
	assert_true(car.waiting())
	assert_eq(car.saying(), tr(car.driver.line))


func test_e_on_a_stopped_car_shows_the_license() -> void:
	var car := _drive_to_barrier()
	assert_eq(car.prompt_key(null), "PROMPT_PAPERS")
	car.use(null)
	assert_true(car.papers_checked)
	assert_string_contains(car.saying(), car.driver.surname)
	assert_string_contains(car.saying(), str(car.driver.year))


func test_moving_cars_dont_show_papers() -> void:
	var car := queue.spawn()
	car.set_physics_process(false)
	assert_eq(car.prompt_key(null), "")
	car.use(null)
	assert_false(car.papers_checked)


func test_lifting_the_lid_opens_the_trunk() -> void:
	var car := _drive_to_barrier()
	car.driver.trunk = "grandpa"
	var lid := car.lid
	# A hand at the lid's back edge, a little up: still closed.
	lid.holders[1] = car.global_transform * (QueueCar.TRUNK_HINGE + Vector3(0, 0.2, -0.9))
	lid._physics_process(0.1)
	assert_false(lid.is_open)
	assert_false(car.trunk_checked)
	# Lifted high: open, and the grandpa shows.
	lid.holders[1] = car.global_transform * (QueueCar.TRUNK_HINGE + Vector3(0, 0.9, -0.3))
	lid._physics_process(0.1)
	assert_true(lid.is_open)
	assert_true(car.trunk_checked)
	assert_true(car.get_node("Trunk").visible)
	assert_eq(car.saying(), tr("TRUNK_GRANDPA"))
	# Let go, it stays where it was.
	lid.holders.clear()
	var angle := lid.angle
	lid._physics_process(0.1)
	assert_eq(lid.angle, angle)


func test_the_lid_never_goes_past_its_hinge() -> void:
	var car := _drive_to_barrier()
	car.lid.holders[1] = car.global_transform * (QueueCar.TRUNK_HINGE + Vector3(0, 2, 1))
	car.lid._physics_process(0.1)
	assert_almost_eq(car.lid.angle, TrunkLid.MAX_ANGLE, 0.001)
	car.lid.holders[1] = car.global_transform * (QueueCar.TRUNK_HINGE + Vector3(0, -1, -0.5))
	car.lid._physics_process(0.1)
	assert_almost_eq(car.lid.angle, 0.0, 0.001)
