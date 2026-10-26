extends GutTest

## Fog check step 3 (control-neblina.md, "Cómo es" 3): the patrol car's foghorn goes "¡BUUUUH!" and every car in the
## fog answers with its own horn, the further the later, its bubble drawn on the screen so the fog doesn't swallow
## it; then it needs 10 s.

var checkpoint: TrafficCheckpoint
var queue: TrafficQueue
var horn: FogHorn


func before_each() -> void:
	checkpoint = TrafficCheckpoint.new()
	add_child_autofree(checkpoint)
	checkpoint.global_transform = Transform3D(Basis(Vector3.UP, PI / 2), Vector3(10, 0, -4))
	checkpoint.ready_now = true
	checkpoint.set_physics_process(false)
	queue = TrafficQueue.new()
	queue.checkpoint = checkpoint
	queue.variant = "fog"
	queue.case_seed = 5
	add_child_autofree(queue)
	queue.set_physics_process(false)
	horn = FogHorn.new()
	horn.freeze = true
	add_child_autofree(horn)
	horn.global_position = checkpoint.global_transform * Vector3(3, 0, 0)


func _cars(count: int) -> Array[QueueCar]:
	var cars: Array[QueueCar] = []
	for i in count:
		var car := queue.spawn()
		car.set_physics_process(false)
		car.at = Vector3(0, 0, 8.0 + 15.0 * i)
		car._place()
		cars.append(car)
	return cars


func test_every_car_in_the_fog_answers_with_its_own_horn() -> void:
	var cars := _cars(3)
	assert_true(horn.blow())
	assert_eq(horn.bubble.text, tr("FOGHORN_SOUND"))
	await wait_seconds(FogHorn.ANSWER_MAX + 0.2)
	for car in cars:
		assert_true(car.horn_bubble.showing(), car.name)
		assert_eq(car.horn_bubble.text, tr(FogCar.horn_text(car.fog.horn)))


func test_the_further_the_later() -> void:
	var cars := _cars(3)
	horn.blow()
	await wait_seconds(0.35)
	assert_true(cars[0].horn_bubble.showing(), "the near one right away")
	assert_false(cars[2].horn_bubble.showing(), "the far one not yet")


func test_then_it_needs_ten_seconds() -> void:
	assert_true(horn.blow())
	assert_false(horn.blow(), "not again so soon")
	assert_eq(horn.held_prompt_key(null), "PROMPT_FOGHORN_WAIT")
	horn._process(FogHorn.COOLDOWN)
	assert_eq(horn.held_prompt_key(null), "PROMPT_FOGHORN")
	assert_true(horn.blow())


func test_a_car_out_of_the_fog_check_doesn_t_answer() -> void:
	queue.variant = "rush_hour"
	var car := queue.spawn()
	car.set_physics_process(false)
	assert_null(car.horn_bubble)
	horn.blow()
	await wait_seconds(0.2)
	assert_null(car.get_node_or_null("HornBubble"))


func test_every_horn_is_used_and_translated() -> void:
	for i in FogCar.HORNS:
		assert_ne(tr(FogCar.horn_text(i)), FogCar.horn_text(i))
	for key in ["PROMPT_FOGHORN", "PROMPT_FOGHORN_WAIT", "FOGHORN_SOUND"]:
		assert_ne(tr(key), key)


func test_the_fog_level_has_a_foghorn() -> void:
	var level: TrafficControlLevel = (load("res://scenes/levels/traffic_control.tscn") as PackedScene).instantiate()
	level.case_seed = 3
	level.variant = "fog"
	add_child_autofree(level)
	assert_not_null(level.get_node_or_null("FogHorn") as FogHorn)
