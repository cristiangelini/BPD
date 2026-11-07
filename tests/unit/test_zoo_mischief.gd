extends GutTest

## What the animals get up to while loose and the little train (escena-zoo.md, step 5b): ZooAnimal's mischief,
## Zoo.spray and its washed signal, Doña Jaula out of patience, and ZooTrain.

const COP_SCENE := preload("res://scenes/player/cop.tscn")


## A zoo with its case set up, `first` the first animal out at feeding time.
func _zoo_case(first: String) -> Zoo:
	var zoo := Zoo.new()
	zoo.case_seed = 4
	add_child_autofree(zoo)
	var case := CrimeSceneCase.new()
	case.case_seed = 4
	case.place = zoo
	add_child_autofree(case)
	case.start()
	var rest: Array[String] = []
	for kind: String in Zoo.ANIMALS:
		if kind != first:
			rest.append(kind)
	zoo.order = [first, rest[0], rest[1]] as Array[String]
	return zoo


func _cop_at(zoo: Zoo, local: Vector3) -> Cop:
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	cop.global_position = zoo.to_global(local + Vector3.UP * 0.1)
	return cop


func test_things_that_can_be_grabbed_are_in_their_group() -> void:
	var bread := Bread.new()
	add_child_autofree(bread)
	assert_true(bread.is_in_group("grabbables"), "even with its own _ready")


func test_the_monkey_takes_something_and_lets_go_for_bananas() -> void:
	var zoo := _zoo_case("monkey")
	zoo.start_feeding()
	var monkey := zoo.animals.monkey as ZooAnimal
	var bread := Bread.new()
	zoo.add_child(bread)
	bread.position = Zoo.gate_mouth("monkey") + Vector3(2.0, 0.2, 0)
	await wait_seconds(2.0)
	assert_eq(monkey.carried, bread, "it took the loaf")
	assert_true(bread.freeze)
	var bananas := zoo.buckets.monkey as FoodBucket
	bananas.hold(1, bananas.global_position)
	bananas.global_position = monkey.global_position + Vector3(2.0, 0.5, 0)
	await wait_frames(3)
	assert_null(monkey.carried, "bananas: it lets go")
	assert_false(bread.freeze)
	bananas.let_go(1)


func test_the_ostrich_knocks_a_cop_down() -> void:
	var zoo := _zoo_case("ostrich")
	zoo.start_feeding()
	var cop := _cop_at(zoo, Zoo.gate_mouth("ostrich") + Vector3(3.0, 0, 0))
	await wait_seconds(2.0)
	assert_true(cop.is_staggered(), "down")
	assert_eq(cop.get_node("Hud/Hint").text, "HINT_ZOO_OSTRICH")


func test_the_elephant_sprays_and_washes() -> void:
	var zoo := _zoo_case("elephant")
	watch_signals(zoo)
	zoo.start_feeding()
	var elephant := zoo.animals.elephant as ZooAnimal
	elephant._spray_clock = ZooAnimal.SPRAY_EVERY - 0.05
	await wait_frames(10)
	assert_signal_emitted(zoo, "washed", "it sprayed")
	var cop := _cop_at(zoo, Vector3(-8, 0, 10))
	zoo.spray(cop.global_position + Vector3(1, 0, 0), 3.0)
	assert_true(cop.is_staggered(), "soaked, it slips")
	assert_eq(cop.get_node("Hud/Hint").text, "HINT_ZOO_SOAKED")


func test_out_of_patience_a_cop_feeds_the_penguins() -> void:
	var zoo := _zoo_case("monkey")
	var cop := _cop_at(zoo, Zoo.DIRECTOR_AT + Vector3(1, 0, 1))
	zoo.start_feeding()
	zoo.patience = Zoo.PATIENCE_DOWN - 5
	zoo.start_feeding()
	assert_eq(zoo.patience, Zoo.PATIENCE / 2, "she's got half her patience back")
	assert_true(cop.is_staggered(), "and the nearest cop is busy")
	assert_eq(cop.get_node("Hud/Hint").text, "HINT_ZOO_PUNISHED")


func test_the_train_goes_round_and_shoves_cops_aside() -> void:
	var zoo := Zoo.new()
	add_child_autofree(zoo)
	var train := zoo.train
	assert_eq(train.perimeter(), 2.0 * (Zoo.TRACK.size.x + Zoo.TRACK.size.y))
	assert_eq(train.point_on(0.0)[0], Vector3(Zoo.TRACK.position.x, 0, Zoo.TRACK.position.y))
	assert_eq(train.point_on(Zoo.TRACK.size.x)[0], Vector3(Zoo.TRACK.end.x, 0, Zoo.TRACK.position.y))
	assert_eq(train.point_on(train.perimeter() + 1.0)[0], train.point_on(1.0)[0], "round and round")
	var start := train.along
	await wait_seconds(0.5)
	assert_gt(train.along, start, "it never stops")
	var ahead: Vector3 = train.point_on(train.along + 2.0)[0]
	var cop := _cop_at(zoo, ahead)
	await wait_seconds(1.0)
	assert_true(cop.is_staggered(), "shoved aside")
	assert_eq(cop.get_node("Hud/Hint").text, "HINT_ZOO_TRAIN")
