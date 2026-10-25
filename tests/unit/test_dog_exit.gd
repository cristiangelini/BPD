extends GutTest

## The guard dog's jailbreak, step 4 (fuga-perro.md): out in the patrol car, with Mordisco if he's everyone's friend,
## and the guard's third catch still loses with the comisario in his pajamas.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const TEST_PATH := "user://test_partidas/fuga_perro_salida.json"

var level: JailbreakLevel
var cop: Cop
var car: PatrolCar
var dog: GuardDog


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.current = Campaign.start_new()
	Campaign.current.finish_shift("bingo", false, {"total": 300, "approved": false})
	level = LEVEL.instantiate()
	level.variant = "dog"
	level.case_seed = 4747
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	cop = level.get_node("Cop")
	car = level.get_node("PatrolCar")
	dog = level.dog
	level.guard.set_physics_process(false)


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func _board() -> void:
	car.enter(cop)
	await wait_physics_frames(3)


func _drive_away() -> void:
	car.global_position = level.car_home.origin + level.car_home.basis.x * (JailbreakLevel.ESCAPE_DISTANCE + 5.0)
	await wait_process_frames(3)


func _labels() -> Array:
	return level.end_screen.find_children("*", "Label", true, false).map(func(label: Label) -> String: return label.text)


func test_everyones_friend_he_jumps_in_and_comes_along() -> void:
	dog.befriend(cop, GuardDog.FRIEND)
	dog.global_position = car.global_position + car.global_basis.x * 3.0
	await _board()
	assert_true(dog.riding, "in the car")
	dog._physics_process(0.0)
	assert_lt(dog.global_position.distance_to(car.prisoner_seat().origin), 0.1, "on the back seat")
	await _drive_away()
	dog._physics_process(0.0)
	assert_lt(dog.global_position.distance_to(car.prisoner_seat().origin), 0.1, "riding along")
	assert_eq(level.guard.outcome, "escaped")
	assert_true(_labels().any(func(text: String) -> bool: return text.contains(tr("JAILBREAK_ESCAPED_DOG"))))


func test_not_a_friend_he_stays() -> void:
	dog.global_position = car.global_position + car.global_basis.x * 3.0
	await _board()
	assert_false(dog.riding)
	await _drive_away()
	assert_eq(level.guard.outcome, "escaped", "they get away all the same")
	assert_false(_labels().any(func(text: String) -> bool: return text.contains(tr("JAILBREAK_ESCAPED_DOG"))))


func test_too_far_from_the_car_he_stays() -> void:
	dog.befriend(cop, GuardDog.FRIEND)
	dog.set_physics_process(false)
	dog.global_position = car.global_position + car.global_basis.x * (JailbreakLevel.DOG_RIDE_REACH + 3.0)
	await _board()
	assert_false(dog.riding)


func test_the_third_catch_brings_the_comisario_in_his_pajamas() -> void:
	for i in JailbreakLevel.CATCHES:
		level.guard.catch()
	assert_not_null(level.get_node_or_null("PajamaComisario"))
	await wait_seconds(JailbreakLevel.LOST_DELAY + 0.2)
	assert_eq(level.guard.outcome, "lost")
	assert_true(Campaign.current.is_over())
