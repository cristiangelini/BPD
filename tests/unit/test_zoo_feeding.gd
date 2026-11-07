extends GutTest

## Feeding time at the zoo (escena-zoo.md, step 5): Zoo.start_feeding and end_feeding, ZooAnimal out and lured back
## with its FoodBucket, ZooGate shut on it, the keepers' gloves and Doña Jaula's patience.

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func _zoo_case(seed_value: int) -> Zoo:
	var zoo := Zoo.new()
	zoo.case_seed = seed_value
	add_child_autofree(zoo)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = zoo
	add_child_autofree(case)
	case.start()
	return zoo


func test_the_animals_wait_in_their_enclosures_with_their_buckets() -> void:
	var zoo := Zoo.new()
	add_child_autofree(zoo)
	for kind: String in Zoo.ANIMALS:
		var animal := zoo.animals[kind] as ZooAnimal
		assert_eq(animal.state, "in")
		assert_eq(zoo.room(animal.global_position), kind, "the %s is in its enclosure" % kind)
		var bucket := zoo.buckets[kind] as FoodBucket
		assert_eq(bucket.food, ZooAnimal.FOODS[kind])
		assert_true(bucket.lure_only)
		assert_eq(zoo.room(bucket.global_position), "grounds", "its bucket is on the path")
		assert_eq(zoo.room(zoo.to_global(Zoo.gate_mouth(kind))), "grounds", "out of its gate, the path")


func test_the_order_is_drawn_and_every_animal_comes_out() -> void:
	var orders := {}
	for seed_value in range(1, 25):
		var zoo := _zoo_case(seed_value)
		var order := zoo.order.duplicate()
		order.sort()
		assert_eq(str(order), str(["elephant", "monkey", "ostrich"]), "each once")
		orders[str(zoo.order)] = true
		zoo.free()
	assert_gt(orders.size(), 1, "not always the same order")


func test_feeding_time_lets_one_out_and_the_keepers_put_gloves_on() -> void:
	var zoo := _zoo_case(3)
	var first := zoo.order[0]
	zoo.start_feeding()
	assert_true(zoo.feeding)
	assert_true((zoo.gates[first] as ZooGate).open, "its gate opens")
	assert_eq((zoo.animals[first] as ZooAnimal).state, "loose")
	assert_eq(zoo.director.said(), "ZOO_DIRECTOR_FEEDING")
	for keeper in zoo.keepers:
		assert_true(keeper.gloves_on, "%s has the gloves on" % keeper.traits.name)
	for kind: String in Zoo.ANIMALS:
		if kind != first:
			assert_false((zoo.gates[kind] as ZooGate).open, "only one gate")
	zoo.end_feeding()
	assert_false(zoo.feeding)
	assert_false(zoo.keepers[0].gloves_on, "gloves off")
	assert_eq((zoo.animals[first] as ZooAnimal).state, "loose", "it stays out until it's put back")


func test_lured_back_and_shut_in_she_is_pleased() -> void:
	var zoo := _zoo_case(5)
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	var kind := zoo.order[0]
	zoo.start_feeding()
	var animal := zoo.animals[kind] as ZooAnimal
	var gate := zoo.gates[kind] as ZooGate
	assert_eq(gate.prompt_key(cop), "PROMPT_ZOO_GATE_WAIT")
	var bucket := zoo.buckets[kind] as FoodBucket
	bucket.hold(1, bucket.global_position)
	assert_eq(animal.lure(), bucket, "its food, held close by")
	bucket.global_position = zoo.to_global(Zoo.gate_mouth(kind) + Vector3(0.5, 1.0, 0))
	await wait_seconds(1.0)
	assert_eq(animal.state, "in", "led back to its gate, it goes in")
	assert_eq(gate.prompt_key(cop), "PROMPT_ZOO_GATE_SHUT")
	zoo.patience = 50
	gate.use(cop)
	assert_false(gate.open)
	assert_eq(zoo.patience, 50 + Zoo.PATIENCE_UP)
	assert_eq(zoo.director.said(), "ZOO_DIRECTOR_PLEASED")
	bucket.let_go(1)


func test_a_wrong_bucket_doesnt_lure_it() -> void:
	var zoo := _zoo_case(5)
	var kind := zoo.order[0]
	zoo.start_feeding()
	var other: String = Zoo.ANIMALS[(Zoo.ANIMALS.find(kind) + 1) % 3]
	var bucket := zoo.buckets[other] as FoodBucket
	bucket.hold(1, bucket.global_position)
	bucket.global_position = (zoo.animals[kind] as ZooAnimal).global_position + Vector3(1, 0.5, 0)
	assert_null((zoo.animals[kind] as ZooAnimal).lure())
	bucket.let_go(1)


func test_left_out_it_goes_back_alone_and_she_gets_angry() -> void:
	var zoo := _zoo_case(7)
	zoo.start_feeding()
	var first := zoo.order[0]
	zoo.end_feeding()
	zoo.start_feeding()
	assert_eq((zoo.animals[first] as ZooAnimal).state, "in", "back by itself")
	assert_false((zoo.gates[first] as ZooGate).open)
	assert_eq(zoo.patience, Zoo.PATIENCE - Zoo.PATIENCE_DOWN)
	assert_eq(zoo.director.said(), "ZOO_DIRECTOR_ANGRY", "and she says so")
	assert_eq((zoo.animals[zoo.order[1]] as ZooAnimal).state, "loose", "and the next one comes out")


func test_the_clock_calls_feeding_time() -> void:
	var zoo := _zoo_case(2)
	zoo.feed_clock = Zoo.FEEDING_EVERY - 0.05
	await wait_frames(10)
	assert_true(zoo.feeding)
	zoo.feed_clock = Zoo.FEEDING_EVERY + Zoo.FEEDING_SECONDS - 0.05
	await wait_frames(10)
	assert_false(zoo.feeding)
	assert_lt(zoo.feed_clock, 1.0, "and the clock starts again")
