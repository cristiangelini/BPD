extends GutTest

## The jailbreak, step 6 (fuga.md): out in the patrol car it's "¡Fugados!" and the next shift; the guard's third catch
## brings the comisario in his pajamas and loses the campaign.

const LEVEL := preload("res://scenes/levels/jailbreak.tscn")
const COP_SCENE := preload("res://scenes/player/cop.tscn")
const TEST_PATH := "user://test_partidas/fuga_salida.json"

var level: Node3D
var cop: Cop
var car: PatrolCar


func before_each() -> void:
	Campaign.save_path = TEST_PATH
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.current = Campaign.start_new()
	Campaign.current.finish_shift("bingo", false, {"total": 300, "approved": false})


func after_each() -> void:
	DirAccess.remove_absolute(TEST_PATH)
	Campaign.save_path = Campaign.SAVE_PATH
	Campaign.current = null


func _open() -> void:
	level = LEVEL.instantiate()
	level.get_node("Cop").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	cop = level.get_node("Cop")
	car = level.get_node("PatrolCar")
	level.guard.set_physics_process(false)


## Every cop aboard and the car driven away from the station.
func _drive_away(distance: float) -> void:
	for each: Cop in get_tree().get_nodes_in_group("cops"):
		car.enter(each)
	car.global_position = level.car_home.origin + level.car_home.basis.x * distance
	await wait_process_frames(3)


func test_everyone_in_the_car_away_from_the_station_escapes() -> void:
	await _open()
	await _drive_away(JailbreakLevel.ESCAPE_DISTANCE + 5.0)
	assert_eq(level.guard.outcome, "escaped")
	assert_false(Campaign.current.jailed, "out of the cells")
	assert_false(Campaign.current.is_over(), "the campaign goes on")
	assert_eq(Campaign.load_saved(TEST_PATH).jailed, false, "and it's saved")
	var end: CanvasLayer = level.end_screen
	assert_not_null(end)
	assert_not_null(end.find_child("NextShift", true, false), "the next shift button")
	var labels: Array = end.find_children("*", "Label", true, false).map(func(label: Label) -> String: return label.text)
	assert_has(labels, "JAILBREAK_ESCAPED")
	assert_false(cop.input_enabled)


func test_not_far_enough_or_someone_left_behind_isnt_escaping() -> void:
	await _open()
	await _drive_away(JailbreakLevel.ESCAPE_DISTANCE - 5.0)
	assert_eq(level.guard.outcome, "", "still by the station")
	car.exit(cop)
	var other: Cop = COP_SCENE.instantiate()
	other.input_enabled = false
	level.add_child(other)
	other.global_transform = level.cop_spawn(1)
	await wait_physics_frames(2)
	car.enter(cop)
	car.global_position = level.car_home.origin + level.car_home.basis.x * (JailbreakLevel.ESCAPE_DISTANCE + 5.0)
	await wait_process_frames(3)
	assert_eq(level.guard.outcome, "", "one cop is still in the cells")


func test_the_third_catch_brings_the_comisario_and_loses_the_campaign() -> void:
	await _open()
	level.guard.catch()
	level.guard.catch()
	assert_eq(Campaign.current.jail_catches, 2, "the catches are saved")
	assert_null(level.get_node_or_null("PajamaComisario"))
	level.guard.catch()
	assert_not_null(level.get_node_or_null("PajamaComisario"), "the comisario comes in his pajamas")
	assert_eq(level.guard.outcome, "", "he shouts for a while first")
	await wait_seconds(JailbreakLevel.LOST_DELAY + 0.2)
	assert_eq(level.guard.outcome, "lost")
	assert_true(Campaign.current.suspended)
	assert_true(Campaign.current.is_over(), "the campaign is lost")
	assert_null(level.end_screen.find_child("NextShift", true, false), "no next shift")


func test_the_catches_carry_over_a_reload() -> void:
	Campaign.current.jail_catches = 2
	await _open()
	assert_eq(level.guard.times_caught, 2)


func test_a_guest_shows_how_it_ended_from_the_guard() -> void:
	await _open()
	level.guard.outcome = "lost"
	await wait_process_frames(3)
	assert_not_null(level.end_screen, "the end screen")
	assert_not_null(level.get_node_or_null("PajamaComisario"), "with the comisario")
	assert_true(Campaign.current.jailed, "only the host closes the campaign")


func test_escaping_after_the_last_shift_is_a_promotion() -> void:
	Campaign.current = Campaign.start_new()
	Campaign.current.shift = Campaign.SHIFTS
	Campaign.current.finish_shift("bingo", false, {"total": 300, "approved": false})
	await _open()
	await _drive_away(JailbreakLevel.ESCAPE_DISTANCE + 5.0)
	assert_true(Campaign.current.is_promoted())
	var labels: Array = level.end_screen.find_children("*", "Label", true, false).map(
		func(label: Label) -> String: return label.text)
	assert_has(labels, "SHIFT_PROMOTED")
	assert_null(level.end_screen.find_child("NextShift", true, false), "the campaign is over")


func test_the_campaign_keeps_the_catches_until_the_jailbreak_ends() -> void:
	var campaign: Campaign = Campaign.current
	campaign.jail_catches = 1
	var back := Campaign.from_dict(JSON.parse_string(JSON.stringify(campaign.to_dict())))
	assert_eq(back.jail_catches, 1)
	campaign.finish_jailbreak(true)
	assert_eq(campaign.jail_catches, 0)
