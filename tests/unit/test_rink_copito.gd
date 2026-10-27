extends GutTest

## Copito and the hot chocolate at the rink (allanamiento-pista.md, step 4): the bar's machine pours up to 3 cups, a cup
## tilted or knocked hard spills, and Copito tells whoever brings him a full one what he saw, once per cop.

const SCENE := preload("res://scenes/levels/rink.tscn")


func _rink() -> Rink:
	var rink: Rink = SCENE.instantiate()
	rink.case_seed = 5
	rink.get_node("Cop").input_enabled = false
	rink.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(rink)
	return rink


## The cop beside Copito with a fresh cup in hand.
func _bring_cup(rink: Rink) -> CocoaCup:
	var cop: Cop = rink.get_node("Cop")
	var cup := rink.pour_cocoa()
	cop.global_position = rink.to_global(Rink.COPITO_AT + Vector3(0, 0.1, 1.2))
	await wait_physics_frames(2)
	cup.global_position = (cop.get_node("Grabber") as Node).hold_point()
	(cop.get_node("Grabber") as Node).grab(cup)
	await wait_physics_frames(10)
	return cup


func test_copito_shivers_and_explains_and_his_lines_are_translated() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	var cop: Cop = rink.get_node("Cop")
	assert_eq(rink.copito.prompt_key(cop), "PROMPT_COPITO")
	rink.copito.use(cop)
	assert_eq((rink.copito.get_node("Bubble") as Label3D).text, "COPITO_RULES")
	for key: String in ["PROMPT_RINK_COCOA", "HINT_RINK_COCOA_MAX", "PROMPT_RINK_COCOA_CUP", "RINK_COCOA_SPILLED",
			"PROMPT_COPITO", "PROMPT_COPITO_COCOA", "COPITO_RULES", "COPITO_AGAIN", "COPITO_WON", "COPITO_NOTHING",
			"COPITO_EMPTY", "COPITO_THANKS", "COPITO_IDLE_1", "COPITO_IDLE_2", "COPITO_IDLE_3"]:
		assert_ne(tr(key), key, "%s is translated" % key)


func test_the_machine_pours_up_to_three_cups_that_stand_full() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	var cop: Cop = rink.get_node("Cop")
	for i in 3:
		rink.cocoa_button.use(cop)
	assert_eq(rink.cups.size(), 3)
	rink.cocoa_button.use(cop)
	assert_eq(rink.cups.size(), 3, "no more than three at once")
	await wait_physics_frames(30)
	assert_true(rink.cups[0].full, "it stands on the counter without spilling")
	assert_almost_eq(rink.cups[0].global_position.y, rink.to_global(Rink.CUP_AT).y, 0.1)


func test_a_cup_tilted_or_dropped_spills() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	var tilted := rink.pour_cocoa()
	await wait_physics_frames(2)
	tilted.rotation.x = PI / 2
	await wait_physics_frames(2)
	assert_false(tilted.full, "tilted, it spills")
	var dropped := rink.pour_cocoa()
	dropped.global_position = rink.to_global(Vector3(10.0, Rink.FLOOR_TOP + 2.0, 10.5))
	await wait_physics_frames(60)
	assert_false(dropped.full, "dropped from up high, it spills")


func test_a_full_cup_makes_copito_talk_once_per_cop() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	var cop: Cop = rink.get_node("Cop")
	rink.copito.clue = "the clue"
	rink.copito.clue_speech = "I saw her hide something in the penguin."
	watch_signals(rink.copito)
	var cup := await _bring_cup(rink)
	assert_true(cup.full)
	assert_eq(rink.copito.prompt_key(cop), "PROMPT_COPITO_COCOA")
	rink.copito.use(cop)
	assert_signal_emitted_with_parameters(rink.copito, "told", ["the clue"])
	assert_null((cop.get_node("Grabber") as Node).get("held"), "he took the cup")
	await wait_physics_frames(2)
	assert_false(is_instance_valid(cup))
	await _bring_cup(rink)
	rink.copito.use(cop)
	assert_eq((rink.copito.get_node("Bubble") as Label3D).text, "COPITO_THANKS")
	assert_signal_emit_count(rink.copito, "told", 1, "once per cop")
	assert_eq(rink.copito.cups, 2)


func test_an_empty_cup_gets_nothing() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	var cop: Cop = rink.get_node("Cop")
	rink.copito.clue_speech = "Something."
	watch_signals(rink.copito)
	var cup := await _bring_cup(rink)
	cup.spill()
	rink.copito.use(cop)
	assert_eq((rink.copito.get_node("Bubble") as Label3D).text, "COPITO_EMPTY")
	assert_signal_not_emitted(rink.copito, "told")
