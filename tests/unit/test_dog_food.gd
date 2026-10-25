extends GutTest

## The guard dog's jailbreak, step 2 (fuga-perro.md): the food on the trays, in the fridge and on the desk, Mordisco
## smelling it and eating it, and each cop's friendship.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const TEST_PATH := "user://test_partidas/fuga_perro_comida.json"

var level: JailbreakLevel
var cop: Cop
var dog: GuardDog
var lot: Transform3D


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	level = LEVEL.instantiate()
	level.variant = "dog"
	level.case_seed = 2626
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	cop = level.get_node("Cop")
	dog = level.dog
	lot = level.city.transform * CityLayout.lot("station")


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func _food(kind: String, at: Vector3) -> DogFood:
	var food := DogFood.new()
	food.kind = kind
	level.add_child(food)
	food.global_position = at
	return food


func test_there_is_always_enough_food_for_four_friends() -> void:
	for drawn in 50:
		var kinds := JailbreakLevel.dog_food_kinds(drawn + 1)
		var total := 0.0
		for kind in kinds:
			total += DogFood.KINDS[kind][0]
		assert_true(total >= JailbreakLevel.DOG_FOOD_ENOUGH, "seed %d: %d" % [drawn + 1, total])
		assert_eq(kinds, JailbreakLevel.dog_food_kinds(drawn + 1), "same seed, same food")
	assert_eq(level.dog_food.size(), JailbreakLevel.dog_food_kinds(2626).size() + 1, "and the sandwich")
	assert_eq(level.dog_food.back().kind, "sandwich")


func test_the_food_stays_put_on_its_trays_shelves_and_desk() -> void:
	await wait_seconds(1.0)
	for food in level.dog_food:
		assert_true(food.global_position.y > lot.origin.y - 0.05, "%s didn't fall through" % food.name)
	var on_shelf := level.dog_food[JailbreakLevel.TRAYS_AT.size() * JailbreakLevel.ON_TRAY + 4]
	assert_gt(on_shelf.global_position.y, lot.origin.y + 0.6, "the fridge's middle shelf holds")


func test_food_deep_in_a_cell_is_out_of_his_reach() -> void:
	var tray_food := level.dog_food[0]
	assert_false(level.outside_cells(tray_food.global_position))
	assert_null(dog.reach_point(tray_food))
	var near_bars := _food("sausage", lot * Vector3(8.0, 0.05, StationRooms.CELL_FRONT_Z - 0.3))
	assert_not_null(dog.reach_point(near_bars), "just behind the bars, he gets it")


func test_he_smells_food_on_the_floor_and_eats_it() -> void:
	dog.global_position = lot * Vector3(8.0, 0, 6.5)
	cop.global_position = lot * Vector3(9.5, 0.1, 6.0)
	var sausage := _food("sausage", lot * Vector3(9.5, 0.05, 6.0))
	cop.handed(sausage)
	await wait_physics_frames(2)
	cop.get_node("Grabber").release()
	await wait_seconds(0.5)
	assert_eq(dog.smell(), sausage)
	for i in 100:
		dog._physics_process(0.05)
		if not is_instance_valid(sausage) or sausage.is_queued_for_deletion():
			break
	assert_true(not is_instance_valid(sausage) or sausage.is_queued_for_deletion(), "eaten")
	assert_almost_eq(dog.friendship_of(cop), 40.0, 0.5, "the cop who gave it gets the friendship")


func test_food_in_hand_or_too_far_isnt_smelled() -> void:
	dog.global_position = lot * Vector3(2.5, 0, 5.5)
	var far := _food("ham", lot * Vector3(13.0, 0.05, 8.0))
	await wait_seconds(0.5)
	assert_null(dog.smell(), "more than 8 m away")
	far.global_position = dog.global_position + Vector3(1, 0.05, 0)
	cop.handed(far)
	await wait_physics_frames(2)
	assert_null(dog.smell(), "held")


func test_lettuce_and_donuts() -> void:
	dog.befriend(cop, 30.0)
	var lettuce := _food("lettuce", dog.global_position)
	cop.handed(lettuce)
	await wait_physics_frames(2)
	cop.get_node("Grabber").release()
	dog.eat(lettuce)
	assert_almost_eq(dog.friendship_of(cop), 20.0, 0.01)
	assert_eq(dog.said(), "DOG_SPIT")
	for i in GuardDog.STUFFED_AFTER:
		dog.eat(_food("donut", dog.global_position))
	assert_gt(dog.stuffed_left, 0.0, "stuffed")
	var before := dog.global_position
	await wait_seconds(0.3)
	assert_eq(dog.global_position, before, "lying down")


func test_friendship_fades_but_a_friend_stays() -> void:
	dog.befriend(cop, 50.0)
	dog._forget(60.0)
	assert_almost_eq(dog.friendship_of(cop), 48.0, 0.01)
	dog.befriend(cop, 100.0)
	assert_true(dog.is_friend(cop))
	dog._forget(600.0)
	assert_true(dog.is_friend(cop))


func test_guests_get_his_friends() -> void:
	dog.befriend(cop, 70.0)
	var other := GuardDog.new()
	add_child_autofree(other)
	other.apply_net_state(dog.net_state())
	assert_almost_eq(other.friendship_of(cop), 70.0, 0.01)
