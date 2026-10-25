extends GutTest

## Crowded car step 2 (control-auto-lleno.md, "Cómo es", steps 3 and 5): every city car has a door on the driver's side;
## opening it pops its riders out one after the other, the driver first, while one or two stay in a packed car. The car
## won't go until they're all back in, and the faces on its windows come and go with them.

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
	queue.variant = "crowded_car"
	add_child_autofree(queue)
	queue.set_physics_process(false)


func _tick(seconds: float) -> void:
	for i in roundi(seconds / 0.1):
		queue._physics_process(0.1)
		for car: QueueCar in queue.get_children().filter(func(n: Node) -> bool: return n is QueueCar):
			car.set_physics_process(false)
			car._physics_process(0.1)


## A car with `riders`, stopped at the barrier as the queue's front.
func _car(riders: int, plate := "QRS 482") -> QueueCar:
	var car := QueueCar.new()
	car.name = "Packed"
	car.checkpoint = checkpoint
	car.plate = plate
	car.crowd = riders
	car.at = Vector3(0, 0, 3)
	queue.cars.append(car)
	queue.add_child(car)
	_tick(3)
	assert_true(car.waiting())
	return car


## Its door open and every rider popped out.
func _spilled(riders: int) -> QueueCar:
	var car := _car(riders)
	car.door.set_angle(TrunkLid.MAX_ANGLE)
	_tick(QueueCar.POP_EVERY * (riders + 1) + 0.2)
	return car


func test_every_city_car_has_a_door() -> void:
	var car := _car(2)
	assert_not_null(car.door)
	assert_true(car.door.side)
	assert_eq(car.door.prompt_key(null), "PROMPT_CAR_DOOR")


func test_riders_pop_out_one_after_the_other() -> void:
	var car := _car(12)
	car.door.set_angle(TrunkLid.MAX_ANGLE)
	assert_eq(car.clowns_out.size(), 0, "not all at once")
	_tick(0.1)
	assert_eq(car.clowns_out.size(), 1)
	assert_true(car.clowns_out[0] is CrowdRider)
	assert_true(car.clowns_out[0].is_driver, "the driver first")
	assert_false(car.can_go(), "more to come out")
	# 0.35 s in 0.1 s ticks is one every 4 ticks.
	_tick(1.2)
	assert_eq(car.clowns_out.size(), 4)


func test_in_a_packed_car_someone_stays_in() -> void:
	var car := _spilled(15)
	var stay := CrowdedCar.stay_in(car.plate, 15)
	assert_between(stay, 1, 2)
	assert_eq(car.clowns_out.size(), 15 - stay)
	assert_eq(car.clowns_out.filter(func(c: ConvoyClown) -> bool: return c.is_driver).size(), 1)
	var shown := car.get_node("Faces").get_children().filter(func(f: Node3D) -> bool: return f.visible).size()
	assert_eq(shown, stay, "only who's still inside shows on the windows")


func test_a_few_all_get_out() -> void:
	var car := _spilled(3)
	assert_eq(car.clowns_out.size(), 3)


func test_riders_look_the_same_on_every_pc() -> void:
	assert_eq(CrowdRider.look_of("ABC 111", 4), CrowdRider.look_of("ABC 111", 4))
	assert_false(CrowdRider.look_of("ABC 111", 0).kid, "the driver is never a kid")
	var kids := 0
	for i in range(1, 200):
		if CrowdRider.look_of("ABC 111", i).kid:
			kids += 1
	assert_between(kids, 20, 90)


func test_the_car_won_t_go_until_they_re_all_back() -> void:
	var car := _spilled(10)
	barrier.use(null)
	assert_eq(car.state, "waiting")
	for out in car.clowns_out.duplicate():
		out.out_for = ConvoyClown.OUT_AT_LEAST
		out.global_position = car.door_point()
		out._physics_process(0.1)
	await wait_physics_frames(2)
	assert_true(car.can_go())
	assert_false(car.door.is_open, "the door shuts behind them")
	var shown := car.get_node("Faces").get_children().filter(func(f: Node3D) -> bool: return f.visible).size()
	assert_eq(shown, 10, "everyone squashed on the windows again")
	barrier.use(null)
	assert_eq(car.state, "going")


func test_popped_riders_fly_before_they_walk() -> void:
	var car := _spilled(4)
	var out := car.clowns_out[3] as CrowdRider
	out.out_for = 0.0
	out.linear_velocity = Vector3(5, 0, 0)
	out._physics_process(0.1)
	assert_almost_eq(out.linear_velocity.x, 5.0, 0.01, "still flying")
	out.out_for = CrowdRider.FLY
	out._physics_process(0.1)
	assert_lt(Vector2(out.linear_velocity.x, out.linear_velocity.z).length(), ConvoyClown.SPEED + 0.01)


func test_the_driver_hands_the_license_and_the_others_dont() -> void:
	var car := _spilled(5)
	var driver := car.clowns_out[0]
	assert_eq(driver.prompt_key(null), "PROMPT_PAPERS")
	var rider := car.clowns_out[2]
	assert_eq(rider.prompt_key(null), "PROMPT_CROWD_RIDER")
	rider.use(null)
	assert_eq(rider.saying(), tr("CROWD_NOT_DRIVER"))
	rider.cuffed(1.0)
	assert_eq(rider.saying(), tr("CROWD_NOT_DRIVER"), "cuffing a passenger detains nobody")


func test_a_grabbed_rider_complains() -> void:
	var car := _spilled(4)
	var out := car.clowns_out[1]
	out.hold(1, out.global_position + Vector3.UP)
	assert_eq(out.saying(), tr("CROWD_RIDER_LINE_0"))


func test_letting_it_through_with_people_out_keeps_it() -> void:
	var car := _spilled(4)
	queue.release_front()
	assert_eq(car.state, "waiting")


func test_texts_are_translated() -> void:
	for key in ["PROMPT_CAR_DOOR", "PROMPT_CROWD_RIDER", "HINT_RIDERS_OUT", "CROWD_NOT_DRIVER"]:
		assert_ne(tr(key), key)
	for i in CrowdRider.RIDER_LINES:
		assert_ne(tr("CROWD_RIDER_LINE_%d" % i), "CROWD_RIDER_LINE_%d" % i)
