extends GutTest

## Wedding breathalyzer check step 1 (control-boda.md): in the "wedding" variant the queue brings the wedding's convoy.
## Every driver leans on their window; the guests' cars wear a bow and cans and their drivers a bow tie, the newlyweds'
## white car comes up front with its board, the bride and the groom, and a few plain city cars come along. Time is
## stepped by hand, 0.1 s at a time, like test_ghost_car_cars.gd.

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
	queue.variant = "wedding"
	queue.case_seed = 5
	add_child_autofree(queue)
	queue.set_physics_process(false)


func _tick(seconds: float) -> void:
	for i in roundi(seconds / 0.1):
		queue._physics_process(0.1)
		for car: QueueCar in queue.get_children().filter(func(n: Node) -> bool: return n is QueueCar):
			car.set_physics_process(false)
			car._physics_process(0.1)


func test_the_convoy_has_the_newlyweds_up_front_and_some_city_cars() -> void:
	_tick(60)
	assert_gt(queue.spawned, 6)
	var newlyweds := 0
	for i in queue.get_child_count():
		var car := queue.get_child(i) as QueueCar
		assert_true(car.wedding_mode)
		assert_not_null(car.get_node_or_null("WindowDriver"), "every driver leans on the window")
		if car.newlyweds:
			newlyweds += 1
			assert_true(car.guest)
			assert_eq(String(car.name), "QueueCar%d" % WeddingCar.newlyweds_at(5))
			assert_eq(car.look, WeddingCar.NEWLYWEDS_LOOK, "white")
	assert_eq(newlyweds, 1)


func test_newlyweds_lead_and_one_in_a_few_is_a_city_car() -> void:
	var city := 0
	for case_seed in 50:
		assert_lt(WeddingCar.newlyweds_at(case_seed), WeddingCar.NEWLYWEDS_AT)
		assert_true(WeddingCar.guest_at(case_seed, WeddingCar.newlyweds_at(case_seed)))
		for i in 12:
			if not WeddingCar.guest_at(case_seed, i):
				city += 1
	assert_between(city, 50 * 12 / 8, 50 * 12 / 2)


func test_a_guest_wears_the_bow_the_cans_and_a_bow_tie() -> void:
	var car := _car(true, false)
	assert_not_null(car.get_node_or_null("Bow"))
	assert_not_null(car.get_node_or_null("Cans"))
	assert_not_null(car.get_node_or_null("WindowDriver/BowTie"))
	assert_null(car.get_node_or_null("JustMarried"))
	var city := _car(false, false)
	assert_null(city.get_node_or_null("Bow"))
	assert_null(city.get_node_or_null("WindowDriver/BowTie"))
	assert_not_null(city.get_node_or_null("WindowDriver"))


func test_the_newlyweds_have_the_board_the_veil_and_the_groom() -> void:
	var car := _car(true, true)
	assert_not_null(car.get_node_or_null("JustMarried"))
	assert_eq((car.get_node("JustMarried/Words") as Label3D).text, tr("WEDDING_JUST_MARRIED"))
	assert_not_null(car.get_node_or_null("WindowDriver/Veil"))
	assert_not_null(car.get_node_or_null("Groom/BowTie"))


func test_the_cans_rattle_while_it_rolls_and_hang_still_when_stopped() -> void:
	var car := _car(true, false)
	car.set_physics_process(false)
	var swings := {}
	for i in 10:
		car._physics_process(0.1)
		swings[snappedf((car.get_node("Cans") as Node3D).rotation.x, 0.01)] = true
	assert_gt(swings.size(), 3)
	car.speed = 0.0
	WeddingCar.rattle(car, 0.0, 3.0)
	assert_eq((car.get_node("Cans") as Node3D).rotation.x, 0.0)


func test_a_guest_honks_to_celebrate_while_it_waits() -> void:
	var car := _car(true, false)
	car.set_physics_process(false)
	car.state = "pulled_over"
	car.state = "waiting"
	var lines := {}
	for i in roundi(WeddingCar.HONK_EVERY + WeddingCar.HONK_SPREAD + WeddingCar.HONK_EVERY + 10) * 10:
		car._physics_process(0.1)
		if car.saying() != "":
			lines[car.saying()] = true
	assert_true(lines.has(tr("WEDDING_HONK_0")))
	assert_gt(car.honks, 0)
	assert_lte(WeddingCar.honk_every("AB 123"), WeddingCar.HONK_EVERY + WeddingCar.HONK_SPREAD)


func test_online_copies_know_the_wedding_cars() -> void:
	var car := _car(true, true)
	var setup := car.net_setup()
	assert_true(setup.wedding_mode)
	assert_true(setup.guest)
	assert_true(setup.newlyweds)


func _car(is_guest: bool, are_newlyweds: bool) -> QueueCar:
	var car := QueueCar.new()
	car.checkpoint = checkpoint
	car.plate = "RT 214"
	car.driver = {"name": "Ana", "surname": "Paz", "year": 1980, "line": "DRIVER_LINE_0", "trunk": "bags"}
	car.wedding_mode = true
	car.guest = is_guest
	car.newlyweds = are_newlyweds
	car.at = Vector3(0, 0, 40)
	car.speed = QueueCar.SPEED
	add_child_autofree(car)
	return car
