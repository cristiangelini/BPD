extends GutTest

## Wedding breathalyzer check step 5 (control-boda.md, "Cómo es", steps 6 to 9): El Colado's trunk is full of gift
## envelopes; cuffed, they're on his car's trunk lid, +100 in the patrol car's trunk. If his car goes by, he runs off
## in a guest's car with its bow and cans and cuts the cans loose at every corner he turns. Play draws the six controls
## a sixth each.

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
	queue.variant = "wedding"
	level.add_child(queue)
	queue.set_physics_process(false)
	case = TrafficCase.new()
	case.case_seed = 12
	case.plan = WantedPlan.draw(12, false, false, false, false, true)
	case.queue = queue
	case.clues = TrafficClues.new()
	case.clues.plan = case.plan
	case.patrol_car = (load("res://scenes/vehicles/patrol_car.tscn") as PackedScene).instantiate()
	level.add_child(case.patrol_car)
	case.patrol_car.global_transform = CityLayout.parking("station")
	level.add_child(case)
	case.start()


## El Colado's car at the barrier, as the plan seats him.
func _el_colado() -> QueueCar:
	queue.plan = case.plan
	queue.spawned = case.plan.wanted_index
	var car := queue.spawn()
	car.set_physics_process(false)
	for i in 200:
		car._physics_process(0.1)
		if car.waiting():
			break
	return car


func test_his_trunk_is_full_of_gift_envelopes() -> void:
	var car := _el_colado()
	assert_true(car.wanted)
	assert_eq(car.driver.trunk, "envelopes")
	car.lid.set_angle(TrunkLid.MAX_ANGLE)
	car._on_trunk_opened()
	assert_eq(car.saying(), tr("TRUNK_ENVELOPES"))
	assert_gt(car.get_node("Trunk").get_child_count(), 0)


func test_cuffed_his_envelopes_are_on_the_trunk_and_worth_100_in_the_patrol_car() -> void:
	var car := _el_colado()
	case.detain(car)
	assert_not_null(case.suspect)
	var envelopes := level.get_node_or_null("GiftEnvelopes") as GiftEnvelopes
	assert_not_null(envelopes)
	assert_lt(envelopes.global_position.distance_to(car.global_position), 3.0, "on his car")
	assert_eq(case.envelope_bonus(), [])
	case.patrol_car.delivered.append(envelopes)
	assert_eq(case.envelope_bonus(), [GiftEnvelopes.VALUE])
	assert_has(case.extras(), GiftEnvelopes.VALUE)


func test_he_runs_off_dropping_cans_at_every_corner() -> void:
	_el_colado()
	queue.release_front()
	assert_not_null(case.chase)
	var drops := case.chase.drops
	assert_true(drops.wedding)
	assert_not_null(case.chase.truck.get_node_or_null("Cans"), "the guest's car, cans and all")
	case.chase.chasing = true
	drops._on_corner(false)
	assert_eq(drops.cans.size(), 0, "only where he turns")
	drops._on_corner(true)
	assert_eq(drops.cans.size(), ChaseDrops.CANS_PER_CORNER)
	for can in drops.cans:
		assert_lt(can.global_position.distance_to(case.chase.truck.global_position), 8.0)
	for i in 10:
		drops._on_corner(true)
	assert_lte(drops.cans.filter(func(c: ChaseCan) -> bool: return is_instance_valid(c)).size(), ChaseDrops.MAX_CANS)


func test_play_draws_the_wedding_too() -> void:
	assert_has(TrafficControlLevel.VARIANTS, "wedding")
	assert_eq(TrafficControlLevel.variant_from("", PackedStringArray(["--traffic=wedding"])), "wedding")
	var count := {}
	for i in 600:
		var variant := TrafficControlLevel.variant_from("", PackedStringArray(), i + 1)
		count[variant] = count.get(variant, 0) + 1
	assert_eq(count.size(), 6)
	assert_gt(count.wedding, 50)
