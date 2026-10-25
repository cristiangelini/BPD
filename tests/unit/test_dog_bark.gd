extends GutTest

## The guard dog's jailbreak, step 3 (fuga-perro.md): Mordisco barks at strangers and wakes the guard, begs from a cop
## with food, follows a friend who whistles and lets a friend take the key off his collar.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const TEST_PATH := "user://test_partidas/fuga_perro_ladrido.json"

var level: JailbreakLevel
var cop: Cop
var dog: GuardDog
var guard: SleepyGuard
var lot: Transform3D


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	level = LEVEL.instantiate()
	level.variant = "dog"
	level.case_seed = 3131
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	cop = level.get_node("Cop")
	dog = level.dog
	guard = level.guard as SleepyGuard
	lot = level.city.transform * CityLayout.lot("station")
	for food in level.dog_food:
		food.queue_free()
	# Mordisco in the corridor, facing the cop's spot by the desk.
	dog.set_physics_process(false)
	dog.global_transform = Transform3D(lot.basis * Basis(Vector3.UP, 0.0), lot * Vector3(9.0, 0, 5.2))
	await wait_physics_frames(2)


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func _cop_out() -> void:
	cop.global_position = lot * Vector3(9.0, 0.1, 8.2)
	await wait_physics_frames(3)


func test_he_barks_at_a_stranger_and_wakes_the_guard() -> void:
	await _cop_out()
	dog._watch(0.1)
	assert_eq(dog.barking_at, cop)
	assert_true(dog.said().begins_with("DOG_BARK"))
	for i in int(SleepyGuard.WAKE_BARK / 0.1) + 1:
		dog._watch(0.1)
	assert_false(guard.is_asleep(), "the barking woke him up")


func test_not_at_a_cop_in_the_cells() -> void:
	dog._watch(0.1)
	assert_null(dog.barking_at)


func test_not_at_a_friend() -> void:
	await _cop_out()
	dog.befriend(cop, GuardDog.FRIEND)
	dog._watch(0.1)
	assert_null(dog.barking_at)


func test_not_behind_his_back() -> void:
	await _cop_out()
	dog.global_rotation.y += PI
	dog._watch(0.1)
	assert_null(dog.barking_at)


func test_food_in_hand_and_he_begs_instead() -> void:
	cop.global_position = lot * Vector3(9.0, 0.1, 7.2)
	await wait_physics_frames(2)
	var sausage := DogFood.new()
	level.add_child(sausage)
	sausage.global_position = cop.global_position + Vector3.UP
	cop.handed(sausage)
	await wait_physics_frames(2)
	dog._watch(0.1)
	assert_null(dog.barking_at)
	assert_eq(dog.begging, cop)
	assert_eq(dog.said(), "DOG_BEG")


func test_a_friend_who_whistles_gets_followed() -> void:
	guard.heard_singing(cop)
	assert_null(dog.following, "not a stranger's whistle")
	dog.befriend(cop, GuardDog.FRIEND)
	guard.heard_singing(cop)
	assert_eq(dog.following, cop)
	await _cop_out()
	var before := dog.global_position.distance_to(cop.global_position)
	for i in 10:
		dog._follow(0.1)
	assert_lt(dog.global_position.distance_to(cop.global_position), before, "coming")
	dog.follow_left = 0.05
	dog._follow(0.1)
	assert_null(dog.following, "until he's had enough")


func test_a_friend_takes_the_key_off_his_collar() -> void:
	assert_eq(dog.prompt_key(cop), "", "a stranger can't pet him")
	dog.befriend(cop, GuardDog.FRIEND)
	assert_eq(dog.prompt_key(cop), "PROMPT_PET_DOG_KEY")
	dog.use(cop)
	await wait_physics_frames(2)
	assert_false(dog.key_on_collar)
	assert_true(cop.get_node("Grabber").held is CellKey, "the key in hand")
	cop.get_node("Grabber").release()
	assert_eq(dog.prompt_key(cop), "PROMPT_PET_DOG")


func test_caught_the_key_goes_back_on_his_collar_and_he_remembers_his_friends() -> void:
	dog.befriend(cop, GuardDog.FRIEND)
	dog.use(cop)
	await wait_physics_frames(2)
	await _cop_out()
	guard.wake_up()
	guard.catch()
	await wait_physics_frames(2)
	assert_true(dog.key_on_collar)
	assert_true(dog.is_friend(cop))
	assert_true(get_tree().get_nodes_in_group("guard_clues").all(
			func(clue: Node) -> bool: return not clue is CellKey or clue.is_queued_for_deletion()))
