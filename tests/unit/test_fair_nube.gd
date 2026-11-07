extends GutTest

## Nube and the cans booth at the fun fair (allanamiento-parque.md, step 4): 3 cans on the shelf, 3 balls on the
## counter, the cans that stand up again after 5 s, and Nube who tells whoever knocks them all down what she saw, once
## per cop.

const SCENE := preload("res://scenes/levels/fair.tscn")


func _fair() -> Fair:
	var fair: Fair = SCENE.instantiate()
	fair.case_seed = 5
	fair.get_node("Cop").input_enabled = false
	fair.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(fair)
	return fair


## `cop` throws ball `index` (it leaves their hands now).
func _throw(fair: Fair, cop: Cop, index: int, from: Vector3, toward: Vector3) -> void:
	var ball := fair.cans_booth.balls[index]
	var grabber := cop.get_node("Grabber")
	ball.global_position = fair.cans_booth.to_global(from)
	ball.hold(grabber.get_instance_id(), ball.global_position)
	ball.throw_toward(grabber.get_instance_id(), fair.cans_booth.global_basis * toward)


func _knock_all(fair: Fair) -> void:
	for can in fair.cans_booth.cans:
		can.global_position += Vector3(0, -0.6, 0.6)


func test_the_booth_has_3_cans_standing_and_3_balls_and_nube_speaks() -> void:
	var fair := _fair()
	await wait_seconds(0.8)
	assert_eq(fair.cans_booth.cans.size(), 3)
	assert_eq(fair.cans_booth.balls.size(), 3)
	assert_eq(fair.cans_booth.down_count(), 0, "the cans stand still on the shelf")
	assert_eq(fair.cans_booth.balls_on_counter(), 3)
	assert_eq(fair.nube.prompt_key(fair.get_node("Cop")), "PROMPT_NUBE")
	for key: String in ["PROMPT_NUBE", "NUBE_RULES", "NUBE_AGAIN", "NUBE_WON", "NUBE_NOTHING", "NUBE_MISSED",
			"NUBE_IDLE_1", "NUBE_IDLE_2", "NUBE_IDLE_3"]:
		assert_ne(tr(key), key, "%s is translated" % key)


func test_a_ball_thrown_at_the_cans_knocks_them() -> void:
	var fair := _fair()
	await wait_seconds(0.8)
	var cop: Cop = fair.get_node("Cop")
	_throw(fair, cop, 0, Vector3(0, CansBooth.SHELF_TOP + 0.1, CansBooth.SHELF_Z + 0.7), Vector3(0, 0, -1))
	await wait_physics_frames(30)
	assert_gt(fair.cans_booth.down_count(), 0, "at least one can fell")
	assert_gt(fair.cans_booth.reset_left, 0.0, "the cans will stand up again")


func test_knocking_all_three_makes_nube_tell_what_she_saw_once_per_cop() -> void:
	var fair := _fair()
	await wait_seconds(0.8)
	var cop: Cop = fair.get_node("Cop")
	fair.nube.clue = "the clue"
	fair.nube.clue_speech = "I saw him hide something in the teddy."
	watch_signals(fair.nube)
	_throw(fair, cop, 1, Vector3(0, 1.6, 2.5), Vector3(0, 0, 1))
	_knock_all(fair)
	await wait_physics_frames(5)
	assert_eq(fair.cans_booth.wins, 1)
	assert_eq(fair.cans_booth.last_thrower(), cop)
	assert_signal_emitted_with_parameters(fair.nube, "told", ["the clue"])
	assert_true(fair.nube.listeners.has(cop))
	await wait_seconds(CansBooth.RESET + 0.3)
	assert_eq(fair.cans_booth.down_count(), 0, "they stood up again")
	assert_eq(fair.cans_booth.balls_on_counter(), 3, "and the balls came back")
	_throw(fair, cop, 2, Vector3(0, 1.6, 2.5), Vector3(0, 0, 1))
	_knock_all(fair)
	await wait_physics_frames(5)
	assert_eq(fair.cans_booth.wins, 2)
	assert_signal_emit_count(fair.nube, "told", 1, "once per cop")


func test_some_cans_left_standing_is_a_miss() -> void:
	var fair := _fair()
	await wait_seconds(0.8)
	watch_signals(fair.cans_booth)
	fair.cans_booth.cans[0].global_position += Vector3(0, -0.6, 0.6)
	await wait_seconds(CansBooth.RESET + 0.3)
	assert_signal_emitted(fair.cans_booth, "missed")
	assert_signal_not_emitted(fair.cans_booth, "won")
	assert_eq((fair.nube.get_node("Bubble") as Label3D).text, "NUBE_MISSED")
	assert_eq(fair.cans_booth.down_count(), 0)
