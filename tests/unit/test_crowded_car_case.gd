extends GutTest

## Crowded car step 5 (control-auto-lleno.md, "Cómo es", steps 6 and 7, answer 2): once a packed car is all counted,
## out and in, E on it fines it for too many riders, +20 on a solved case's pay; the gang's driver is cuffed in the car
## or out on the street and walked to the patrol car like any driver; cuffing a passenger detains nobody.

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
	queue.variant = "crowded_car"
	level.add_child(queue)
	queue.set_physics_process(false)
	case = TrafficCase.new()
	case.case_seed = 12
	case.plan = WantedPlan.draw(12, false, false, true)
	case.queue = queue
	case.clues = TrafficClues.new()
	case.clues.plan = case.plan
	case.patrol_car = (load("res://scenes/vehicles/patrol_car.tscn") as PackedScene).instantiate()
	level.add_child(case.patrol_car)
	case.patrol_car.global_transform = CityLayout.parking("station")
	level.add_child(case)
	case.start()


## A car with `riders` at the barrier, wanted or not.
func _car(riders: int, wanted: bool) -> QueueCar:
	queue.plan = null
	var car := queue.spawn()
	car.set_physics_process(false)
	car.crowd = riders
	car.wanted = wanted
	for i in 200:
		car._physics_process(0.1)
		if car.waiting():
			break
	return car


## Its door open, its riders out and every one counted, the ones inside too.
func _counted(car: QueueCar) -> void:
	car.door.set_angle(TrunkLid.MAX_ANGLE)
	for i in roundi(QueueCar.POP_EVERY * (car.crowd + 1) / 0.1) + 2:
		car._physics_process(0.1)
	for out in car.clowns_out:
		out.use(null)
	car.door.use(null)


func test_a_packed_car_all_counted_can_be_fined_once() -> void:
	var car := _car(12, false)
	assert_false(car.can_fine(), "not counted yet")
	assert_eq(car.prompt_key(null), "PROMPT_PAPERS")
	_counted(car)
	assert_eq(car.count_so_far(), 12)
	assert_eq(car.prompt_key(null), "PROMPT_CROWD_FINE")
	car.use(null)
	assert_true(car.fined)
	assert_eq(car.saying(), tr("CROWD_FINED") % 12)
	assert_eq(case.crowd_fines, 1)
	car.use(null)
	assert_eq(case.crowd_fines, 1, "once per car")
	assert_eq(car.prompt_key(null), "PROMPT_PAPERS")


func test_no_fine_without_looking_inside() -> void:
	var car := _car(12, false)
	_counted(car)
	car.looked_inside = false
	assert_false(car.can_fine())


func test_a_car_with_a_few_gets_no_fine() -> void:
	var car := _car(4, false)
	_counted(car)
	assert_false(car.can_fine())


func test_fines_add_20_each_to_a_solved_case() -> void:
	case.crowd_fines = 2
	assert_eq(case.extras(), [TrafficCase.CROWD_FINE_BONUS, TrafficCase.CROWD_FINE_BONUS])
	var report := ShiftReport.pay(true, case.extras(), case.fines())
	assert_eq(report.total, ShiftReport.SALARY + 40)
	assert_eq(ShiftReport.pay(false, case.extras(), case.fines()).total, 0, "only with the case solved")


func test_the_gang_s_driver_cuffed_on_the_street_is_taken_out_there() -> void:
	var car := _car(15, true)
	_counted(car)
	var driver := car.clowns_out[0]
	assert_true(driver.is_driver)
	var at := driver.global_position
	driver.cuffed(1.0)
	assert_not_null(case.suspect)
	assert_eq(case.suspect.kind, "driver")
	assert_almost_eq(case.suspect.global_position.x, at.x, 0.01)
	assert_eq(car.clowns_out.size(), 0, "the rest hop back in")
	assert_eq(car.state, "pulled_over")


func test_cuffing_a_passenger_detains_nobody() -> void:
	var car := _car(15, true)
	_counted(car)
	car.clowns_out[3].cuffed(1.0)
	assert_null(case.suspect)
	assert_eq(case.innocents, 0)


func test_an_innocent_driver_still_counts_against_the_case() -> void:
	var car := _car(13, false)
	case.detain(car)
	assert_eq(case.innocents, 1)


func test_its_own_campaign_key() -> void:
	assert_eq(case.campaign_key(), "traffic_crowded_car")


func test_guests_get_the_fines() -> void:
	case.crowd_fines = 3
	var state := case.snapshot()
	case.crowd_fines = 0
	case.follower = true
	case.apply_snapshot(state)
	assert_eq(case.crowd_fines, 3)


func test_texts_are_translated() -> void:
	for key in ["PROMPT_CROWD_FINE", "CROWD_FINED", "HINT_CROWD_FINED"]:
		assert_ne(tr(key), key)
