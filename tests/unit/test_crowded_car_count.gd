extends GutTest

## Crowded car step 3 (control-auto-lleno.md, "Cómo es", step 4): E on a rider not counted yet sticks the car's next
## number on them, front and back, so nobody counts them twice; E on the open door counts who stayed in. The car says
## the count so far.

var queue: TrafficQueue
var checkpoint: TrafficCheckpoint


func before_each() -> void:
	checkpoint = TrafficCheckpoint.new()
	add_child_autofree(checkpoint)
	checkpoint.set_physics_process(false)
	queue = TrafficQueue.new()
	queue.checkpoint = checkpoint
	queue.variant = "crowded_car"
	add_child_autofree(queue)
	queue.set_physics_process(false)


## A car with `riders`, its door open and its riders popped out.
func _spilled(riders: int, plate := "QRS 482") -> QueueCar:
	var car := QueueCar.new()
	car.name = "Packed"
	car.checkpoint = checkpoint
	car.plate = plate
	car.crowd = riders
	car.at = Vector3(0, 0, 3)
	car.set_physics_process(false)
	queue.add_child(car)
	car.door.set_angle(TrunkLid.MAX_ANGLE)
	for i in roundi((QueueCar.POP_EVERY * (riders + 1) + 0.2) / 0.1):
		car._physics_process(0.1)
	return car


func test_e_on_a_rider_sticks_the_next_number() -> void:
	var car := _spilled(6)
	var a := car.clowns_out[2] as CrowdRider
	var b := car.clowns_out[4] as CrowdRider
	assert_eq(a.prompt_key(null), "PROMPT_COUNT_RIDER")
	a.use(null)
	b.use(null)
	assert_eq(a.sticker, 1)
	assert_eq(b.sticker, 2)
	assert_eq((a.get_node("Sticker") as Label3D).text, "1")
	assert_eq((a.get_node("StickerBack") as Label3D).text, "1", "on the back too")
	assert_eq(car.counted, 2)
	assert_eq(car.saying(), tr("CROWD_COUNT") % 2)


func test_a_rider_can_t_be_counted_twice() -> void:
	var car := _spilled(4)
	var a := car.clowns_out[1] as CrowdRider
	a.use(null)
	a.use(null)
	car.count_rider(a)
	assert_eq(car.counted, 1)
	assert_eq(a.sticker, 1)
	assert_eq(a.saying(), tr("CROWD_NOT_DRIVER"), "a counted one says they came along")
	assert_eq(a.prompt_key(null), "PROMPT_CROWD_RIDER")


func test_the_driver_counts_first_then_hands_papers() -> void:
	var car := _spilled(3)
	var driver := car.clowns_out[0] as CrowdRider
	assert_eq(driver.prompt_key(null), "PROMPT_COUNT_RIDER")
	driver.use(null)
	assert_eq(driver.prompt_key(null), "PROMPT_PAPERS")


func test_looking_in_the_door_counts_who_stayed() -> void:
	var car := _spilled(14)
	var stay := CrowdedCar.stay_in(car.plate, 14)
	for out in car.clowns_out:
		out.use(null)
	assert_eq(car.count_so_far(), 14 - stay)
	assert_eq(car.door.prompt_key(null), "PROMPT_LOOK_INSIDE")
	car.door.use(null)
	assert_true(car.looked_inside)
	assert_eq(car.count_so_far(), 14, "everyone counted")
	assert_eq(car.saying(), tr("CROWD_INSIDE") % [stay, 14])
	assert_eq(car.door.prompt_key(null), "PROMPT_CAR_DOOR", "once is enough")
	car.door.use(null)
	assert_eq(car.count_so_far(), 14)


func test_nobody_inside_a_car_with_a_few() -> void:
	var car := _spilled(3)
	car.door.use(null)
	assert_eq(car.saying(), tr("CROWD_INSIDE_NONE") % 0)


func test_the_count_stays_after_they_get_back_in() -> void:
	var car := _spilled(5)
	for out in car.clowns_out.duplicate():
		out.use(null)
		out.out_for = ConvoyClown.OUT_AT_LEAST
		out.global_position = car.door_point()
		out._physics_process(0.1)
	await wait_physics_frames(2)
	assert_true(car.can_go())
	assert_eq(car.count_so_far(), 5)


func test_e_on_a_closed_trunk_still_asks_for_papers() -> void:
	var car := _spilled(2)
	car.driver = {"name": "Rita", "surname": "Paz", "year": 1980, "line": "TRAFFIC_LINE_0"}
	car.state = "waiting"
	car.lid.use(null)
	assert_true(car.papers_checked)


func test_texts_are_translated() -> void:
	for key in ["PROMPT_COUNT_RIDER", "PROMPT_LOOK_INSIDE", "CROWD_COUNT", "CROWD_INSIDE", "CROWD_INSIDE_NONE"]:
		assert_ne(tr(key), key)
