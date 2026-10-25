extends GutTest

## The guard dog's jailbreak, step 1 (fuga-perro.md): the third way out, the guard asleep at his desk and Mordisco
## walking his round with the key on his collar.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const TEST_PATH := "user://test_partidas/fuga_perro.json"

var level: JailbreakLevel
var cop: Cop
var guard: SleepyGuard
var dog: GuardDog


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	Campaign.current = null
	level = LEVEL.instantiate()
	level.variant = "dog"
	level.case_seed = 1717
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	cop = level.get_node("Cop")
	guard = level.guard as SleepyGuard
	dog = level.dog


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func test_the_dog_is_one_of_the_ways_out() -> void:
	assert_true(JailbreakLevel.VARIANTS.has("dog"))
	assert_eq(JailbreakLevel.pick_variant(7, PackedStringArray(["--jailbreak=dog"])), "dog")
	assert_true(level.is_dog())
	assert_false(level.is_cleaning())


func test_the_guard_sleeps_at_his_desk_with_no_donuts() -> void:
	assert_not_null(guard)
	assert_true(guard.is_asleep())
	assert_null(level.box, "no donut box tonight")
	assert_true(level.sticks.is_empty(), "nothing to fish with")
	assert_false(guard.key_on_belt)
	assert_true(dog.key_on_collar, "the key is on Mordisco's collar")
	await wait_seconds(0.5)
	assert_true(guard.is_asleep(), "and he keeps sleeping")


func test_a_cop_out_doesnt_bother_him_while_he_sleeps() -> void:
	var lot := level.city.transform * CityLayout.lot("station")
	cop.global_position = lot * Vector3(10.5, 0.1, 5.5)
	await wait_seconds(0.5)
	assert_eq(guard.suspicion, 0.0)


func test_barking_wakes_him_up() -> void:
	guard.heard_bark(SleepyGuard.WAKE_BARK / 2)
	assert_true(guard.is_asleep(), "not yet")
	guard.heard_bark(SleepyGuard.WAKE_BARK / 2 + 0.1)
	assert_false(guard.is_asleep())
	assert_true(guard.said().begins_with("SLEEPY_GUARD_WOKEN"))


func test_a_bit_of_barking_wears_off() -> void:
	guard.heard_bark(SleepyGuard.WAKE_BARK - 0.5)
	await wait_seconds(1.5)
	guard.heard_bark(0.6)
	assert_true(guard.is_asleep())


func test_with_nothing_odd_he_nods_off_again() -> void:
	guard.wake_up()
	guard.calm = SleepyGuard.DOZE_AFTER - 0.2
	await wait_seconds(0.5)
	assert_true(guard.is_asleep())


func test_a_cop_he_sees_keeps_him_awake() -> void:
	guard.wake_up()
	guard.look = 0.0
	var lot := level.city.transform * CityLayout.lot("station")
	cop.global_position = lot * Vector3(10.5, 0.1, 5.5)
	guard.calm = SleepyGuard.DOZE_AFTER - 0.2
	await wait_seconds(0.5)
	assert_false(guard.is_asleep())
	assert_gt(guard.suspicion, 0.0)


func test_mordisco_walks_his_round() -> void:
	var lot := level.city.transform * CityLayout.lot("station")
	var start := dog.target
	dog.wait_left = 0.01
	await wait_physics_frames(3)
	assert_true(dog.is_walking())
	assert_ne(dog.target, start, "on to the next stop")
	var before := dog.global_position
	await wait_seconds(0.3)
	assert_gt(dog.global_position.distance_to(before), 0.1, "moving")
	for i in 600:
		dog._walk(0.1)
	for stop: Array in GuardDog.ROUND:
		var local: Vector3 = stop[0]
		assert_true(level.outside_cells(lot * local), "his round is out of the cells")


func test_the_same_seed_gives_the_same_round() -> void:
	var other := GuardDog.new()
	add_child_autofree(other)
	other.setup_round(1717, level.city.transform * CityLayout.lot("station"))
	assert_eq(other.target, dog.target)
	assert_almost_eq(other.wait_left, dog.wait_left, 0.3)


func test_the_key_on_his_collar_shows() -> void:
	var key := dog.find_child("key", true, false) as Node3D
	assert_not_null(key)
	assert_true(key.visible)
	dog.key_on_collar = false
	assert_false(key.visible)
	assert_eq(dog.net_state()[3], false)
