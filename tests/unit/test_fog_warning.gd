extends GutTest

## Fog check step 2 (control-neblina.md, "Cómo es" 2): unwarned, the cars come out of the fog fast and brake late:
## behind a car they bump into it, at the barrier they run the checkpoint, barrier and cones and all, and the queue's
## patience goes up. A lit cone by the lane, or a cop's flashlight on the car, warns it and it brakes in time. Time is
## stepped by hand, 0.1 s at a time.

const COP_SCENE := preload("res://scenes/player/cop.tscn")

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
	checkpoint.ready_now = true
	checkpoint.set_physics_process(false)
	queue = TrafficQueue.new()
	queue.checkpoint = checkpoint
	queue.variant = "fog"
	queue.case_seed = 5
	add_child_autofree(queue)
	queue.set_physics_process(false)


## The next car, driven until it stops, runs the checkpoint or `seconds` go by.
func _drive(car: QueueCar, seconds := 20.0) -> void:
	car.set_physics_process(false)
	for i in roundi(seconds / 0.1):
		car._physics_process(0.1)
		if car.state != "coming":
			return


func test_unwarned_it_runs_the_checkpoint() -> void:
	watch_signals(queue)
	var car := queue.spawn()
	_drive(car)
	assert_eq(car.state, "overrun")
	assert_eq(queue.sneaked, 1)
	assert_false(queue.cars.has(car))
	assert_almost_eq(queue.patience, FogCar.OVERRUN_PATIENCE, 0.01)
	assert_signal_emitted_with_parameters(queue, "passed", [car, true])
	var at := car.at.z
	for i in 10:
		car._physics_process(0.1)
	assert_lt(car.at.z, at - 5.0, "and on it goes")


func test_a_lit_cone_by_the_lane_warns_it() -> void:
	var flare := FogFlare.new()
	flare.freeze = true
	add_child_autofree(flare)
	flare.global_position = checkpoint.global_transform * Vector3(2.0, 0, 30.0)
	var car := queue.spawn()
	_drive(car)
	assert_true(car.warned)
	assert_eq(car.state, "waiting", "stopped at the barrier")
	assert_eq(queue.sneaked, 0)


func test_a_knocked_over_cone_warns_nobody() -> void:
	var flare := FogFlare.new()
	flare.freeze = true
	add_child_autofree(flare)
	flare.global_transform = checkpoint.global_transform * Transform3D(Basis(Vector3.RIGHT, PI / 2),
		Vector3(2.0, 0.2, 30.0))
	assert_false(flare.lit())
	var car := queue.spawn()
	_drive(car)
	assert_eq(car.state, "overrun")


func test_a_cop_s_flashlight_warns_it() -> void:
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	cop.global_position = checkpoint.global_transform * Vector3(-3.0, 0.1, 30.0)
	await wait_physics_frames(2)
	cop.look_at(checkpoint.global_transform * Vector3(0, cop.global_position.y, 45.0), Vector3.UP)
	cop.belt.flashlight.toggle()
	await wait_physics_frames(1)
	var car := queue.spawn()
	_drive(car)
	assert_true(car.warned)
	assert_eq(car.state, "waiting")


func test_behind_a_car_it_bumps_into_it() -> void:
	var flare := FogFlare.new()
	flare.freeze = true
	add_child_autofree(flare)
	flare.global_position = checkpoint.global_transform * Vector3(2.0, 0, 30.0)
	var first := queue.spawn()
	_drive(first)
	flare.free()
	var second := queue.spawn()
	_drive(second)
	assert_eq(second.state, "waiting", "stopped behind it")
	assert_eq(second.saying(), tr(FogCar.bump_line(second.plate)))
	assert_eq(queue.sneaked, 0)


func test_the_fog_level_has_four_lit_cones() -> void:
	var level: TrafficControlLevel = (load("res://scenes/levels/traffic_control.tscn") as PackedScene).instantiate()
	level.case_seed = 3
	level.variant = "fog"
	add_child_autofree(level)
	assert_eq(level.find_children("FogFlare*", "", false, false).size(), TrafficControlLevel.FLARES_FROM_DOOR.size())


func test_texts_are_translated() -> void:
	var keys := ["HINT_FOG_OVERRUN"]
	for i in FogCar.BUMP_LINES:
		keys.append("FOG_BUMP_%d" % i)
	for key: String in keys:
		assert_ne(tr(key), key)
