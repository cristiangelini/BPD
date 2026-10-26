extends GutTest

## Parade step 2 (control-desfile.md): every float plays its song, the notes over it. Held at the checkpoint for
## MUSIC_HOLD seconds, its music stops and the crowd boos, and the queue's patience runs out BOO_FACTOR times as fast,
## until the float moves on. Time is stepped by hand, 0.1 s at a time.

const FLOAT := {"theme": "rocket", "skirt": 0, "number": 9, "dancers": [{"mask": 0, "held": 0}]}

var checkpoint: TrafficCheckpoint
var queue: TrafficQueue


func before_each() -> void:
	checkpoint = TrafficCheckpoint.new()
	add_child_autofree(checkpoint)
	checkpoint.global_transform = Transform3D(Basis(Vector3.UP, PI / 2), Vector3(10, 0, -4))
	var barrier := RoadBarrier.new()
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
	queue.variant = "parade"
	add_child_autofree(queue)
	queue.set_physics_process(false)
	queue._until_spawn = 9999.0


func _float() -> QueueCar:
	var car := QueueCar.new()
	car.checkpoint = checkpoint
	car.plate = "DE 200"
	car.driver = {"name": "Ana", "surname": "Paz", "year": 1980, "line": "DRIVER_LINE_0", "trunk": "bags"}
	car.parade_mode = true
	car.parade = FLOAT.duplicate(true)
	car.at = Vector3(0, 0, 12)
	car.speed = QueueCar.SPEED
	car.ahead = queue.cars.back() if not queue.cars.is_empty() else null
	queue.cars.append(car)
	queue.add_child(car)
	car.set_physics_process(false)
	return car


func _tick(seconds: float) -> void:
	for i in roundi(seconds / 0.1):
		queue._physics_process(0.1)
		for car: QueueCar in queue.get_children().filter(func(n: Node) -> bool: return n is QueueCar):
			car._physics_process(0.1)


func _notes(car: QueueCar) -> Label3D:
	return car.get_node("Notes") as Label3D


func test_a_float_plays_its_music_while_it_goes() -> void:
	var car := _float()
	_tick(1.0)
	assert_true(_notes(car).visible)
	assert_eq(_notes(car).text, "♪ ♫ ♪")
	assert_false(car.music_cut)


func test_held_at_the_checkpoint_the_music_stops_and_the_crowd_boos() -> void:
	var car := _float()
	_tick(6.0)
	assert_true(car.waiting(), "stopped at the barrier")
	assert_false(car.music_cut)
	_tick(ParadeFloat.MUSIC_HOLD)
	assert_true(car.music_cut)
	assert_eq(_notes(car).text, tr("PARADE_BOO"))
	assert_eq(queue.booing(), ParadeFloat.BOO_FACTOR)


func test_while_it_boos_the_patience_runs_out_twice_as_fast() -> void:
	_float()
	_tick(6.0)
	queue._set_patience(0.0)
	_tick(1.0)
	var calm := queue.patience
	_tick(ParadeFloat.MUSIC_HOLD)
	queue._set_patience(0.0)
	_tick(1.0)
	assert_almost_eq(queue.patience, calm * ParadeFloat.BOO_FACTOR, 0.01)


func test_only_the_float_at_the_checkpoint_counts() -> void:
	var first := _float()
	var second := _float()
	second.at = Vector3(0, 0, 20)
	_tick(6.0 + ParadeFloat.MUSIC_HOLD)
	assert_true(first.music_cut)
	assert_true(second.waiting(), "waiting behind")
	assert_false(second.music_cut, "not at the checkpoint")


func test_let_through_the_music_plays_again() -> void:
	var car := _float()
	_tick(6.0 + ParadeFloat.MUSIC_HOLD)
	assert_true(car.music_cut)
	queue.release_front()
	_tick(0.5)
	assert_false(car.music_cut)
	assert_eq(_notes(car).text, "♪ ♫ ♪")
	assert_eq(queue.booing(), 1.0)


func test_texts_are_translated() -> void:
	for key in ["PARADE_BOO", "HINT_PARADE_MUSIC_CUT"]:
		assert_ne(tr(key), key)
