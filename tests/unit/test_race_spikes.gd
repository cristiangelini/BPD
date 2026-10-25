extends GutTest

## Street race check step 3 (control-carrera.md): the patrol car's two spike strips. Rolled up, a cop carries one;
## let go on the street, once it lies still it unrolls across the lane. A car over it gets its tires punctured, once:
## a racer brakes to a stop on its rims and complains, a city car limps on and complains. E on the rope rolls it back
## up in 1 s. Time is stepped by hand, 0.1 s at a time, like test_race_heats.gd.

var checkpoint: TrafficCheckpoint
var queue: TrafficQueue
var strip: SpikeStrip
var punctured: Array[QueueCar] = []


func before_each() -> void:
	punctured.clear()
	checkpoint = TrafficCheckpoint.new()
	add_child_autofree(checkpoint)
	checkpoint.global_transform = Transform3D(Basis(Vector3.UP, PI / 2), Vector3(10, 0, -4))
	checkpoint.set_physics_process(false)
	queue = TrafficQueue.new()
	queue.checkpoint = checkpoint
	queue.variant = "race"
	queue.case_seed = 9
	add_child_autofree(queue)
	queue.set_physics_process(false)
	queue.punctured.connect(func(car: QueueCar) -> void: punctured.append(car))
	strip = SpikeStrip.new()
	strip.checkpoint = checkpoint
	add_child_autofree(strip)
	strip.set_physics_process(false)


## A cop dropped it on the street `at` (the checkpoint's space), and it lay still.
func _drop_at(at: Vector3) -> void:
	strip.global_position = checkpoint.global_transform * at
	strip.rotation = Vector3(0.3, 1.0, 0)
	strip.carried = true
	strip.linear_velocity = Vector3.ZERO
	strip._physics_process(0.1)


func _tick(seconds: float) -> void:
	for i in roundi(seconds / 0.1):
		queue._physics_process(0.1)
		strip._physics_process(0.1)
		for car: QueueCar in queue.get_children().filter(func(n: Node) -> bool: return n is QueueCar):
			car.set_physics_process(false)
			car._physics_process(0.1)


func _racer() -> QueueCar:
	var racer := queue.spawn_heat()[0]
	racer.set_physics_process(false)
	return racer


func test_let_go_on_the_street_it_unrolls_across_the_lane() -> void:
	_drop_at(Vector3(RaceCar.LANE, 0.1, 15))
	assert_true(strip.deployed)
	assert_true(strip.freeze)
	assert_almost_eq(absf(strip.global_basis.x.dot(checkpoint.global_basis.x)), 1.0, 0.001, "across the lane")
	assert_almost_eq(strip.global_basis.y.dot(Vector3.UP), 1.0, 0.001, "flat")
	assert_not_null(strip.find_child("spike_strip*", true, false))


func test_it_doesn_t_unroll_before_anyone_carried_it_or_while_held() -> void:
	strip.global_position = checkpoint.global_transform * Vector3(2, 0.1, 2)
	strip._physics_process(0.1)
	assert_false(strip.deployed, "lying next to the patrol car")
	strip.holders[1] = Vector3.ZERO
	strip._physics_process(0.1)
	assert_false(strip.deployed, "in a cop's hands")
	assert_true(strip.carried)
	assert_eq(strip.held_prompt_key(null), "PROMPT_SPIKES_DROP")


func test_a_racer_over_it_brakes_on_its_rims_and_complains() -> void:
	_drop_at(Vector3(RaceCar.LANE, 0.1, 30))
	var racer := _racer()
	for i in 200:
		_tick(0.1)
		if racer.flat:
			break
	assert_true(racer.flat)
	assert_eq(racer.state, "punctured")
	assert_eq(punctured, [racer] as Array[QueueCar])
	assert_almost_eq((racer.get_node("Wheel0") as Node3D).scale.y, QueueCar.FLAT_SQUASH, 0.001)
	_tick(4.0)
	assert_eq(racer.speed, 0.0, "stopped")
	assert_eq(racer.saying(), tr(racer.flat_line()))
	assert_true(racer.flat_line().begins_with("RACE_FLAT_"))
	assert_true(queue.racers.has(racer), "it didn't get away")


func test_a_punctured_racer_never_counts_as_gone_by() -> void:
	var passed: Array[QueueCar] = []
	queue.passed.connect(func(car: QueueCar, _sneaked: bool) -> void: passed.append(car))
	_drop_at(Vector3(RaceCar.LANE, 0.1, 6))
	var heat := queue.spawn_heat()
	_tick(20)
	for racer in heat:
		assert_true(racer.flat)
	assert_lt(heat[0].at.z, -TrafficCheckpoint.ZONE.y, "the first one stopped past the checkpoint")
	assert_true(passed.is_empty())
	for i in range(1, heat.size()):
		assert_gte(heat[i].at.z - heat[i - 1].at.z, QueueCar.LENGTH, "stopped one behind the other")
	assert_eq(punctured.size(), heat.size(), "each one once")


func test_a_city_car_over_it_limps_on_and_complains() -> void:
	_drop_at(Vector3(0, 0.1, 40))
	var car := queue.spawn()
	car.set_physics_process(false)
	_tick(6.0)
	assert_true(car.flat)
	assert_eq(car.saying(), tr(car.flat_line()))
	assert_true(car.flat_line().begins_with("CITY_FLAT_"))
	assert_lte(car.speed, QueueCar.FLAT_SPEED)
	assert_eq(punctured, [car] as Array[QueueCar])


func test_e_on_the_rope_rolls_it_up_and_cars_go_by_unharmed() -> void:
	_drop_at(Vector3(0, 0.1, 40))
	assert_eq(strip.prompt_key(null), "PROMPT_SPIKES_PULL")
	strip.use(null)
	_tick(0.5)
	assert_true(strip.deployed, "still rolling it up")
	_tick(SpikeStrip.ROLL_SECONDS)
	assert_false(strip.deployed)
	assert_false(strip.freeze)
	assert_eq(strip.prompt_key(null), "PROMPT_GRAB")
	assert_false(strip.carried, "it stays rolled up until a cop carries it again")
	var car := queue.spawn()
	car.set_physics_process(false)
	_tick(6.0)
	assert_false(car.flat)


func test_the_race_level_has_two_strips_by_the_patrol_car() -> void:
	var level: TrafficControlLevel = load("res://scenes/levels/traffic_control.tscn").instantiate()
	level.case_seed = 3
	level.variant = "race"
	add_child_autofree(level)
	assert_eq(level.spike_strips.size(), 2)
	assert_eq(level.spike_strips[0].checkpoint, level.checkpoint)
	assert_false(level.spike_strips[0].deployed)


func test_texts_are_translated() -> void:
	for key in ["PROMPT_SPIKES_PULL", "PROMPT_SPIKES_DROP", "RACE_FLAT_9", "CITY_FLAT_2"]:
		assert_ne(tr(key), key)
