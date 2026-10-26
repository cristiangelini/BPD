extends GutTest

## Circus move step 3 (control-circo.md, "Cómo es" 3 and 4): El Peludo, unwatched for a while, does something only a
## person would. A cage door swings open like the trunk lid: El Peludo sits tight, a real animal hops out and wanders
## until it's lured back with its food; not back in time, it runs off and the circus complains.

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


func test_unwatched_el_peludo_does_something_only_a_person_would() -> void:
	var car := _truck("bear", true)
	for i in int(CircusTruck.UNWATCHED / 0.1) + 1:
		car._act_human(0.1)
	assert_eq(car.acts, 1)
	assert_eq(car.saying(), tr(CircusTruck.human_act(car.plate, 1)))
	assert_string_starts_with(CircusTruck.human_act(car.plate, 1), "CIRCUS_HUMAN_")
	assert_ne(CircusTruck.human_act(car.plate, 2), CircusTruck.human_act(car.plate, 1), "something else next time")


func test_watched_he_behaves() -> void:
	var car := _truck("lion", true)
	var cop: Cop = (load("res://scenes/player/cop.tscn") as PackedScene).instantiate()
	cop.input_enabled = false
	add_child_autofree(cop)
	cop.set_physics_process(false)
	var cage := car.global_transform * CircusTruck.CAGE_AT
	cop.global_position = cage + car.global_basis.z * -6.0
	cop.look_at(Vector3(cage.x, cop.global_position.y, cage.z), Vector3.UP)
	assert_true(CircusTruck.watched(car))
	for i in int(CircusTruck.UNWATCHED / 0.1) + 5:
		car._act_human(0.1)
	assert_eq(car.acts, 0, "not while a cop watches")
	cop.rotate_y(PI)
	assert_false(CircusTruck.watched(car), "his back to him")
	for i in int(CircusTruck.UNWATCHED / 0.1) + 1:
		car._act_human(0.1)
	assert_eq(car.acts, 1)


func test_a_real_animal_never_acts_like_a_person() -> void:
	var car := _truck("bear")
	car.set_physics_process(true)
	await wait_seconds(0.2)
	car.unwatched = CircusTruck.UNWATCHED
	await wait_physics_frames(3)
	assert_eq(car.acts, 0)


func test_the_cage_door_swings_open_after_the_hand() -> void:
	var car := _truck("lion")
	var door := car.get_node("Cage/Door") as CageDoor
	assert_false(door.is_open)
	var cage := car.get_node("Cage") as Node3D
	# A hand behind the cage, pulled out back: the door swings out toward -Z.
	door.holders[1] = cage.global_transform * (door.position + Vector3(-1.0, 1.0, -1.0))
	door._physics_process(0.016)
	door.holders.clear()
	assert_almost_eq(door.angle, PI / 4, 0.01)
	assert_true(door.is_open)


func test_el_peludo_sits_tight_with_his_door_open() -> void:
	var car := _truck("gorilla", true)
	car.open_cage()
	assert_true((car.get_node("Cage/Door") as CageDoor).is_open)
	assert_null(car.loose)
	assert_true(CircusTruck.animal_of(car).visible)


func test_a_real_animal_hops_out_and_the_truck_waits_for_it() -> void:
	var car := _truck("zebra")
	car.open_cage()
	assert_not_null(car.loose)
	assert_false(CircusTruck.animal_of(car).visible, "out of its cage")
	assert_false(car.can_go(), "its truck waits for it")
	assert_eq(car.saying(), tr("ANIMAL_SOUND_ZEBRA"))
	car.open_cage()
	assert_eq(get_tree().get_nodes_in_group("loose_animals").size(), 1, "only one")


func test_its_food_lures_it_back_in() -> void:
	var car := _truck("monkey")
	car.open_cage()
	var animal := car.loose
	var bucket := FoodBucket.new()
	bucket.food = "fish"
	add_child_autofree(bucket)
	bucket.freeze = true
	bucket.holders[1] = Vector3.ZERO
	bucket.global_position = animal.global_position + Vector3(2, 0, 0)
	assert_null(animal.lure(), "not its food")
	bucket.food = "bananas"
	assert_eq(animal.lure(), bucket)
	# The cop walks the bucket to the cage's door: the monkey follows and hops in.
	bucket.global_position = CircusTruck.cage_mouth(car) + Vector3(0, 0.5, -0.5)
	for i in 120:
		animal._process(0.1)
		if not is_instance_valid(car.loose) or animal.state == "home":
			break
	assert_eq(animal.state, "home")
	assert_true(CircusTruck.animal_of(car).visible, "back in")
	assert_false((car.get_node("Cage/Door") as CageDoor).is_open, "the door shut")
	await wait_process_frames(1)
	assert_true(car.can_go())


func test_not_back_in_time_it_runs_off_and_the_circus_complains() -> void:
	var car := _truck("kangaroo")
	watch_signals(queue)
	car.open_cage()
	var animal := car.loose
	animal._process(CircusTruck.LOOSE_SECONDS + 0.1)
	assert_eq(animal.state, "gone")
	assert_true(car.animal_lost)
	assert_signal_emitted_with_parameters(queue, "animal_lost", [car])
	car.open_cage()
	assert_eq(get_tree().get_nodes_in_group("loose_animals").size(), 1, "gone is gone")


func test_texts_are_translated() -> void:
	var keys := ["PROMPT_CAGE_DOOR", "CIRCUS_BACK_IN", "HINT_CIRCUS_ANIMAL_LOST"]
	for i in CircusTruck.HUMAN_ACTS:
		keys.append("CIRCUS_HUMAN_%d" % i)
	for key: String in keys:
		assert_ne(tr(key), key)
