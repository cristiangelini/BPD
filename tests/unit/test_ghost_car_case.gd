extends GutTest

## Ghost car step 4 (control-auto-fantasma.md, "Cómo es", steps 6 and 7): the cuffs on the ghost car find nobody; the
## pilot is the wanted driver, cuffed and walked to the patrol car like any other, and his remote falls by his feet;
## in the patrol car's trunk it adds 100 to a solved case's 500. Once he's out of the queue the ghost car stops its
## pranks. An innocent driver is a complaint as always.

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
	queue.variant = "ghost_car"
	queue.case_seed = 12
	queue.plan = WantedPlan.draw(12, false, false, false, true)
	level.add_child(queue)
	queue.set_physics_process(false)
	case = TrafficCase.new()
	case.case_seed = 12
	case.plan = queue.plan
	case.queue = queue
	case.clues = TrafficClues.new()
	case.clues.plan = case.plan
	case.patrol_car = (load("res://scenes/vehicles/patrol_car.tscn") as PackedScene).instantiate()
	level.add_child(case.patrol_car)
	case.patrol_car.global_transform = CityLayout.parking("station")
	level.add_child(case)
	case.start()


## Every car of the plan up to the pilot's, all stopped in the queue.
func _fill() -> void:
	for i in queue.plan.wanted_index + 1:
		queue.spawn().set_physics_process(false)
	for t in 600:
		for car in queue.cars:
			car._physics_process(0.1)
		if queue.cars.all(func(car: QueueCar) -> bool: return car.waiting()):
			return


func _car(ghost: bool, pilot: bool) -> QueueCar:
	for car in queue.cars:
		if car.ghost == ghost and car.puppeteer == pilot:
			return car
	return null


func test_the_cuffs_on_the_ghost_car_find_nobody() -> void:
	_fill()
	var ghost := _car(true, false)
	ghost.cuffed(Handcuffs.SECONDS)
	assert_eq(case.innocents, 0, "no complaint")
	assert_null(case.suspect)
	assert_eq(ghost.state, "waiting")
	assert_eq(ghost.saying(), tr("GHOST_NO_ONE_TO_CUFF"))


func test_the_pilot_is_taken_out_and_drops_his_remote() -> void:
	_fill()
	var pilot := _car(false, true)
	assert_true(pilot.wanted)
	pilot.cuffed(Handcuffs.SECONDS)
	assert_not_null(case.suspect)
	assert_eq(pilot.state, "pulled_over")
	await wait_physics_frames(1)
	assert_null(pilot.get_node_or_null("WindowDriver"), "he got out of his window")
	var remotes := get_tree().get_nodes_in_group("rc_remotes")
	assert_eq(remotes.size(), 1)
	var remote := remotes[0] as RcRemote
	assert_lt(remote.global_position.distance_to(case.suspect.global_position), 1.5, "by his feet")


func test_the_ghost_car_stops_its_pranks_once_he_is_out() -> void:
	_fill()
	var ghost := _car(true, false)
	var rig := ghost.get_node("Pilot") as GhostPilot
	assert_true(rig.live())
	_car(false, true).cuffed(Handcuffs.SECONDS)
	assert_false(rig.live())
	rig.set_physics_process(false)
	var before := rig.pranks
	for i in 400:
		rig._physics_process(0.1)
	assert_eq(rig.pranks, before)


func test_his_remote_in_the_trunk_adds_100_to_the_pay() -> void:
	assert_eq(case.remote_bonus(), [])
	var remote := RcRemote.new()
	level.add_child(remote)
	case.patrol_car._on_trunk_entered(remote)
	assert_eq(case.remote_bonus(), [RcRemote.VALUE])
	assert_eq(case.extras(), [RcRemote.VALUE])
	var report := ShiftReport.pay(true, case.extras(), case.fines())
	assert_eq(report.total, ShiftReport.SALARY + 100)
	assert_eq(ShiftReport.pay(false, case.extras(), case.fines()).total, 0, "only with the case solved")


func test_his_remote_never_loses_value() -> void:
	var remote := RcRemote.new()
	level.add_child(remote)
	assert_eq(remote.hit(30.0), 0.0)


func test_an_innocent_driver_is_a_complaint() -> void:
	_fill()
	var innocent: QueueCar = null
	for car in queue.cars:
		if not car.ghost and not car.puppeteer:
			innocent = car
			break
	innocent.cuffed(Handcuffs.SECONDS)
	assert_eq(case.innocents, 1)
	assert_eq(get_tree().get_nodes_in_group("rc_remotes").size(), 0)


func test_it_counts_as_its_own_case_in_the_campaign() -> void:
	assert_eq(case.campaign_key(), "traffic_ghost_car")


func test_the_texts_are_translated() -> void:
	for key in ["GHOST_NO_ONE_TO_CUFF", "HINT_GHOST_REMOTE", "PROMPT_RC_REMOTE"]:
		assert_ne(tr(key), key)
