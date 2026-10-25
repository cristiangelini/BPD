extends GutTest

## Fruit truck step 4 (control-frutas.md, "Cómo es", steps 5 and 6): a watermelon split from an innocent fruit seller's
## pickup is a 20 complaint, the wanted one's isn't; the wanted fruit seller is cuffed and walked to the patrol car like
## any driver; a gold watch in the patrol car's trunk adds 100 to a solved case's 500.

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
	queue.variant = "fruit_truck"
	level.add_child(queue)
	queue.set_physics_process(false)
	case = TrafficCase.new()
	case.case_seed = 12
	case.plan = WantedPlan.draw(12, false, true)
	case.queue = queue
	case.clues = TrafficClues.new()
	case.clues.plan = case.plan
	case.patrol_car = (load("res://scenes/vehicles/patrol_car.tscn") as PackedScene).instantiate()
	level.add_child(case.patrol_car)
	case.patrol_car.global_transform = CityLayout.parking("station")
	level.add_child(case)
	case.start()


## A pickup at the barrier, wanted or not.
func _pickup(wanted: bool) -> QueueCar:
	queue.plan = null
	var car := queue.spawn()
	car.set_physics_process(false)
	for i in 200:
		car._physics_process(0.1)
		if car.waiting():
			break
	for melon in car.bed_melons():
		melon.from_wanted = wanted
	car.wanted = wanted
	return car


## Its first watermelon, taken down and split.
func _split(car: QueueCar, kind := "normal") -> void:
	var melon := car.bed_melons()[0]
	melon.kind = kind
	melon.leave_bed()
	melon.hit(INF)


func test_an_innocent_watermelon_split_is_a_complaint() -> void:
	var car := _pickup(false)
	_split(car)
	assert_eq(case.melon_complaints, 1)
	assert_eq(case.fines(), TrafficCase.MELON_FINE)
	_split(car)
	assert_eq(case.fines(), 2 * TrafficCase.MELON_FINE)


func test_the_wanted_one_s_watermelons_are_no_complaint() -> void:
	var car := _pickup(true)
	_split(car, "hollow")
	_split(car)
	assert_eq(case.melon_complaints, 0)
	await wait_physics_frames(2)
	assert_eq(get_tree().get_nodes_in_group("gold_watches").size(), Watermelon.WATCHES)


func test_complaints_add_up_with_the_innocents_detained() -> void:
	var car := _pickup(false)
	_split(car)
	case.detain(car)
	assert_eq(case.innocents, 1)
	assert_eq(case.fines(), TrafficCase.COMPLAINT_FINE + TrafficCase.MELON_FINE)


func test_the_wanted_fruit_seller_is_taken_out_cuffed() -> void:
	var car := _pickup(true)
	case.detain(car)
	assert_not_null(case.suspect)
	assert_eq(case.suspect.kind, "driver")
	assert_eq(car.state, "pulled_over")


func test_a_gold_watch_in_the_trunk_adds_100_to_the_pay() -> void:
	assert_eq(case.watch_bonus(), [])
	var watch := GoldWatch.new()
	level.add_child(watch)
	case.patrol_car._on_trunk_entered(watch)
	assert_eq(case.watch_bonus(), [GoldWatch.VALUE])
	var second := GoldWatch.new()
	level.add_child(second)
	case.patrol_car._on_trunk_entered(second)
	assert_eq(case.watch_bonus(), [GoldWatch.VALUE], "one watch is enough")
	var report := ShiftReport.pay(true, case.watch_bonus(), case.fines())
	assert_eq(report.total, ShiftReport.SALARY + 100)


func test_a_gold_watch_never_loses_value() -> void:
	var watch := GoldWatch.new()
	level.add_child(watch)
	assert_eq(watch.hit(30.0), 0.0)
	assert_false(watch.is_broken)


func test_it_counts_as_its_own_case_in_the_campaign() -> void:
	assert_eq(case.campaign_key(), "traffic_fruit_truck")


func test_a_guest_sees_the_complaints() -> void:
	var car := _pickup(false)
	_split(car)
	var state := case.snapshot()
	assert_eq(state.melons, 1)


func test_the_texts_are_translated() -> void:
	for key in ["HINT_FRUIT_COMPLAINT", "HINT_FRUIT_WATCHES"]:
		assert_ne(tr(key), key)
