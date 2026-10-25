extends GutTest

## Ghost car step 2 (control-auto-fantasma.md, "Cómo es", steps 3 to 5): while the ghost car and its pilot's car wait
## in the queue, the ghost car pulls a prank every 15 to 25 s, and every prank shows the pilot's remote at his window
## for 2 s (the tic). E at its window scares a prank out of it; opening its trunk makes it bolt. Time is stepped by
## hand, 0.1 s at a time, like test_ghost_car_cars.gd.

var checkpoint: TrafficCheckpoint
var barrier: RoadBarrier
var queue: TrafficQueue


func before_each() -> void:
	checkpoint = TrafficCheckpoint.new()
	add_child_autofree(checkpoint)
	checkpoint.global_transform = Transform3D(Basis(Vector3.UP, PI / 2), Vector3(10, 0, -4))
	barrier = RoadBarrier.new()
	barrier.freeze = true
	add_child_autofree(barrier)
	barrier.global_transform = checkpoint.global_transform
	for z in [4.0, 7.0]:
		var cone := TrafficCone.new()
		cone.freeze = true
		add_child_autofree(cone)
		cone.global_position = checkpoint.global_transform * Vector3(-1, 0, z)
	checkpoint.ready_now = checkpoint.is_set_up()
	checkpoint.set_physics_process(false)
	queue = TrafficQueue.new()
	queue.checkpoint = checkpoint
	queue.variant = "ghost_car"
	queue.case_seed = 5
	add_child_autofree(queue)
	queue.set_physics_process(false)


func _tick(seconds: float) -> void:
	for i in roundi(seconds / 0.1):
		queue.patience = 0.0
		queue._physics_process(0.1)
		for car: QueueCar in queue.get_children().filter(func(n: Node) -> bool: return n is QueueCar):
			car.set_physics_process(false)
			car._physics_process(0.1)
			var pilot := car.get_node_or_null("Pilot") as GhostPilot
			if pilot:
				pilot.set_physics_process(false)
				pilot._physics_process(0.1)


func _ghost() -> QueueCar:
	for car in queue.cars:
		if car.ghost:
			return car
	return null


func _pilot_car() -> QueueCar:
	for car in queue.cars:
		if car.puppeteer:
			return car
	return null


## Until both are stopped in the queue.
func _wait_for_both() -> void:
	for i in 1200:
		_tick(0.1)
		var ghost := _ghost()
		var pilot := _pilot_car()
		if ghost and pilot and ghost.waiting() and pilot.waiting():
			return
	fail_test("the ghost car and its pilot never waited together")


func test_its_pilot_comes_a_few_cars_behind() -> void:
	for case_seed in 30:
		var behind := GhostCar.pilot_at(case_seed) - GhostCar.ghost_at(case_seed)
		assert_between(behind, GhostCar.PILOT_BEHIND.x, GhostCar.PILOT_BEHIND.y)
	_wait_for_both()
	assert_eq(String(_pilot_car().name), "QueueCar%d" % GhostCar.pilot_at(5))
	assert_false(_pilot_car().ghost)
	assert_not_null(_pilot_car().get_node_or_null("WindowDriver"), "he leans on his window like everyone")


func test_no_prank_until_its_pilot_waits_behind_it() -> void:
	var pranks := 0
	for i in 600:
		_tick(0.1)
		var ghost := _ghost()
		var pilot := _pilot_car()
		if ghost and not (pilot and pilot.waiting()):
			pranks = (ghost.get_node("Pilot") as GhostPilot).pranks
		if pilot and pilot.waiting():
			break
	assert_eq(pranks, 0)


func test_it_pranks_every_15_to_25_seconds_and_the_pilot_shows_his_remote() -> void:
	_wait_for_both()
	var ghost := _ghost()
	var rig := ghost.get_node("Pilot") as GhostPilot
	var kinds := {}
	var since := 0.0
	var gaps: Array[float] = []
	var before := rig.pranks
	for i in 1500:
		_tick(0.1)
		since += 0.1
		if rig.pranks > before:
			before = rig.pranks
			gaps.append(since)
			since = 0.0
			kinds[rig.last_prank] = true
			assert_true(rig.ticking())
			assert_true(GhostCar.remote_showing(_pilot_car()), "the tic")
	assert_gt(gaps.size(), 4)
	for gap in gaps.slice(1):
		assert_between(gap, GhostPilot.PRANK_EVERY.x - 0.2, GhostPilot.PRANK_EVERY.y + 0.2)
	assert_gt(kinds.size(), 2, str(kinds))


func test_the_remote_hides_again_after_the_tic() -> void:
	_wait_for_both()
	var rig := _ghost().get_node("Pilot") as GhostPilot
	rig.prank("honk")
	_tick(0.1)
	assert_true(GhostCar.remote_showing(_pilot_car()))
	_tick(GhostPilot.TIC_SECONDS + 0.2)
	assert_false(GhostCar.remote_showing(_pilot_car()))
	for car in queue.cars:
		if not car.puppeteer:
			assert_false(GhostCar.remote_showing(car), "only the pilot has one")


func test_each_prank_does_its_thing() -> void:
	_wait_for_both()
	var ghost := _ghost()
	var rig := ghost.get_node("Pilot") as GhostPilot
	rig.prank("honk")
	assert_true(ghost.saying().length() > 0)
	rig.prank("lights")
	var lit := false
	for i in 10:
		_tick(0.1)
		lit = lit or rig.flashing()
	assert_true(lit)
	_tick(2.0)
	assert_false(rig.flashing())
	var at := ghost.global_position
	rig.prank("creep")
	assert_almost_eq(_farthest(0.3), GhostPilot.CREEP, 0.01)
	assert_lt((ghost.global_position - checkpoint.global_position).length(), (at - checkpoint.global_position).length(),
		"toward the barrier")
	_tick(2.0)
	assert_almost_eq(ghost.lurch, 0.0, 0.01, "back to its place")
	rig.prank("reverse")
	assert_almost_eq(_farthest(0.5), GhostPilot.REVERSE, 0.01)


## The farthest the ghost car lurched over the next `seconds`.
func _farthest(seconds: float) -> float:
	var most := 0.0
	for i in roundi(seconds / 0.1):
		_tick(0.1)
		if absf(_ghost().lurch) > absf(most):
			most = _ghost().lurch
	return most


func test_backing_up_shoves_the_cop_behind() -> void:
	_wait_for_both()
	var ghost := _ghost()
	var cop: Cop = load("res://scenes/player/cop.tscn").instantiate()
	add_child_autofree(cop)
	cop.global_position = ghost.global_position - ghost.global_basis.z * (ghost.length() / 2 + 0.6)
	(ghost.get_node("Pilot") as GhostPilot).prank("reverse")
	assert_true(cop.is_staggered())


func test_e_at_its_window_scares_a_prank_out_of_it() -> void:
	_wait_for_both()
	var ghost := _ghost()
	var rig := ghost.get_node("Pilot") as GhostPilot
	_tick(GhostPilot.SCARE_GAP + 0.5)
	var before := rig.pranks
	ghost.use(null)
	_tick(GhostPilot.SCARED_AFTER + 0.2)
	assert_eq(rig.pranks, before + 1)
	ghost.use(null)
	_tick(GhostPilot.SCARED_AFTER + 0.2)
	assert_eq(rig.pranks, before + 1, "not again so soon")


func test_opening_its_trunk_makes_it_bolt() -> void:
	_wait_for_both()
	var ghost := _ghost()
	var rig := ghost.get_node("Pilot") as GhostPilot
	ghost.lid.set_angle(TrunkLid.MAX_ANGLE)
	assert_eq(rig.last_prank, "bolt")
	assert_almost_eq(_farthest(0.6), GhostPilot.BOLT, 0.01)
	assert_true(rig.ticking())
