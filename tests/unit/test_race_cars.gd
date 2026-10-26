extends GutTest

## Street race check step 1 (control-carrera.md): in the "race" variant the queue brings city cars and, among them,
## the racers: a spoiler (big, small or none), a number on both front doors, a neon light under the body and pipes
## that throw sparks while rolling. Time is stepped by hand, 0.1 s at a time, like test_wedding_cars.gd.

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
	queue.variant = "race"
	queue.case_seed = 5
	add_child_autofree(queue)
	queue.set_physics_process(false)


func _tick(seconds: float) -> void:
	for i in roundi(seconds / 0.1):
		queue._physics_process(0.1)
		for car: QueueCar in queue.get_children().filter(func(n: Node) -> bool: return n is QueueCar):
			car.set_physics_process(false)
			car._physics_process(0.1)


func test_the_queue_brings_city_cars_and_racers_from_the_seed() -> void:
	_tick(60)
	assert_gt(queue.spawned, 6)
	for i in queue.get_child_count():
		var car := queue.get_child(i) as QueueCar
		assert_true(car.race_mode)
		var index := String(car.name).trim_prefix("QueueCar").to_int()
		assert_eq(car.racer, RaceCar.racer_at(5, index))
		assert_eq(car.get_node_or_null("Exhaust") != null, car.racer, "only racers wear the race kit")


func test_about_one_in_a_few_is_a_racer() -> void:
	var racers := 0
	for case_seed in 50:
		for i in 12:
			if RaceCar.racer_at(case_seed, i):
				racers += 1
	assert_between(racers, 50 * 12 / 6, 50 * 12 / 2)


func test_a_racer_has_its_number_on_both_doors_and_a_neon() -> void:
	var car := _car({"number": 27, "neon": 2, "spoiler": 2})
	for roundel in ["Roundel", "RoundelLeft"]:
		assert_eq((car.get_node(roundel + "/Number") as Label3D).text, "27")
	assert_eq((car.get_node("NeonLight") as OmniLight3D).light_color, RaceCar.NEONS[2])
	assert_eq((car.get_node("Spoiler") as Node3D).scale, Vector3.ONE)


func test_spoilers_come_big_small_or_none() -> void:
	assert_eq((_car({"number": 1, "neon": 0, "spoiler": 1}).get_node("Spoiler") as Node3D).scale,
		Vector3.ONE * RaceCar.SMALL_SPOILER)
	assert_null(_car({"number": 1, "neon": 0, "spoiler": 0}).get_node_or_null("Spoiler"))
	var kinds := {}
	for i in 40:
		var traits := RaceCar.traits_of("AB %03d" % i)
		kinds[traits.spoiler] = true
		assert_between(int(traits.number), RaceCar.NUMBERS.x, RaceCar.NUMBERS.y)
		assert_lt(int(traits.neon), RaceCar.NEONS.size())
	assert_eq(kinds.size(), RaceCar.SPOILERS.size())
	assert_eq(RaceCar.traits_of("AB 001"), RaceCar.traits_of("AB 001"), "every PC agrees")


func test_the_pipes_throw_sparks_only_while_it_rolls() -> void:
	var car := _car({"number": 8, "neon": 1, "spoiler": 0})
	car.set_physics_process(false)
	car._physics_process(0.1)
	var sparks := car.get_node("Exhaust/Sparks") as CPUParticles3D
	assert_true(sparks.emitting)
	RaceCar.spark(car, 0.0)
	assert_false(sparks.emitting)


func test_online_copies_know_the_racers() -> void:
	var car := _car({"number": 64, "neon": 3, "spoiler": 1})
	var setup := car.net_setup()
	assert_true(setup.race_mode)
	assert_true(setup.racer)
	assert_eq(setup.race.number, 64)


func _car(traits: Dictionary) -> QueueCar:
	var car := QueueCar.new()
	car.checkpoint = checkpoint
	car.plate = "TB 707"
	car.driver = {"name": "Ana", "surname": "Paz", "year": 1980, "line": "DRIVER_LINE_0", "trunk": "bags"}
	car.race_mode = true
	car.racer = true
	car.race = traits
	car.at = Vector3(0, 0, 40)
	car.speed = QueueCar.SPEED
	add_child_autofree(car)
	return car
