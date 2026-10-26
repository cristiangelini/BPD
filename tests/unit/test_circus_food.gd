extends GutTest

## Circus move step 2 (control-circo.md, "Cómo es" 2): the patrol car's four food buckets. E with one by a cage and
## the animal in it eats its own food, or gets angry at any other (it roars, its cage shakes, the queue's patience
## goes up); El Peludo, in his costume, eats nothing and says something only a person would.

const LEVEL_SCENE := preload("res://scenes/levels/traffic_control.tscn")

var checkpoint: TrafficCheckpoint
var queue: TrafficQueue


func before_each() -> void:
	checkpoint = TrafficCheckpoint.new()
	add_child_autofree(checkpoint)
	checkpoint.ready_now = true
	checkpoint.set_physics_process(false)
	queue = TrafficQueue.new()
	queue.checkpoint = checkpoint
	queue.variant = "circus_move"
	add_child_autofree(queue)
	queue.set_physics_process(false)


func _truck(animal: String, costume := false) -> QueueCar:
	var car := QueueCar.new()
	car.name = "Truck"
	car.checkpoint = checkpoint
	car.plate = "CI 138"
	car.driver = {"name": "Ana", "surname": "Paz", "year": 1980, "line": "DRIVER_LINE_0", "trunk": "bags"}
	car.circus_mode = true
	car.circus = {"animal": animal, "stripes": 0, "cage": 3, "costume": costume}
	car.at = Vector3(0, 0, 10)
	queue.add_child(car)
	car.set_physics_process(false)
	return car


## A bucket of `food` right behind `car`'s cage door.
func _bucket(food: String, car: QueueCar) -> FoodBucket:
	var bucket := FoodBucket.new()
	bucket.food = food
	add_child_autofree(bucket)
	bucket.freeze = true
	bucket.global_position = car.global_transform * (CircusTruck.CAGE_AT + Vector3(0, 0.8, -2.0))
	return bucket


func test_every_animal_eats_one_of_the_four_foods() -> void:
	for animal in CircusTruck.ANIMALS:
		assert_has(CircusTruck.FOODS, CircusTruck.food_of(animal), animal)


func test_its_own_food_it_eats() -> void:
	var car := _truck("lion")
	var bucket := _bucket("meat", car)
	assert_eq(bucket.cage_near(), car)
	var before := queue.patience
	assert_eq(bucket.offer(), "ate")
	assert_eq(car.saying(), tr("CIRCUS_ATE"))
	assert_eq(queue.patience, before)


func test_another_food_makes_it_angry_and_the_queue_impatient() -> void:
	var car := _truck("zebra")
	var bucket := _bucket("fish", car)
	var before := queue.patience
	assert_eq(bucket.offer(), "angry")
	assert_eq(car.saying(), tr("ANIMAL_SOUND_ZEBRA"))
	assert_almost_eq(queue.patience, before + CircusTruck.ANGRY_PATIENCE, 0.01)


func test_el_peludo_eats_nothing_and_talks_like_a_person() -> void:
	var car := _truck("gorilla", true)
	var bucket := _bucket("bananas", car)
	assert_eq(bucket.offer(), "refused")
	assert_eq(car.saying(), tr(CircusTruck.refuse_line(car.plate, 1)))
	assert_string_starts_with(CircusTruck.refuse_line(car.plate, 1), "CIRCUS_REFUSE_")
	bucket.cooldown_left = 0.0
	assert_eq(bucket.offer(), "refused", "nothing, not even the meat")
	assert_ne(car.saying(), tr(CircusTruck.refuse_line(car.plate, 1)), "a new excuse each time")


func test_too_far_from_a_cage_or_too_soon_it_does_nothing() -> void:
	var car := _truck("monkey")
	var bucket := _bucket("bananas", car)
	assert_eq(bucket.offer(), "ate")
	assert_eq(bucket.offer(), "", "not again before its cooldown")
	bucket.cooldown_left = 0.0
	bucket.global_position = car.global_transform * (CircusTruck.CAGE_AT + Vector3(0, 0.8, -5.0))
	assert_null(bucket.cage_near())
	assert_eq(bucket.offer(), "")


func test_the_circus_level_has_the_four_buckets() -> void:
	var level: TrafficControlLevel = LEVEL_SCENE.instantiate()
	level.case_seed = 3
	level.variant = "circus_move"
	add_child_autofree(level)
	var foods := []
	for bucket: FoodBucket in get_tree().get_nodes_in_group("food_buckets"):
		foods.append(bucket.food)
		var model := bucket.get_node("Model")
		assert_true((model.find_child("food_" + bucket.food, true, false) as Node3D).visible)
	foods.sort()
	var all := CircusTruck.FOODS.duplicate()
	all.sort()
	assert_eq(foods, all)


func test_texts_are_translated() -> void:
	var keys := ["CIRCUS_ATE"]
	for food in CircusTruck.FOODS:
		keys.append("PROMPT_FEED_" + food.to_upper())
	for animal in CircusTruck.ANIMALS:
		keys.append(CircusTruck.sound_of(animal))
	for i in CircusTruck.REFUSE_LINES:
		keys.append("CIRCUS_REFUSE_%d" % i)
	for key: String in keys:
		assert_ne(tr(key), key)
