extends GutTest

## The rink's ice (allanamiento-pista.md, step 2): without skates a cop slides and falls if turning hard while fast;
## the rental's skates make the ice easy and fast and the floor slow; the resurfacer's button sets it going round the
## ice for 30 s, pushing props and shoving cops.

const SCENE := preload("res://scenes/levels/rink.tscn")
const STEP := 1.0 / 60.0


func _rink() -> Rink:
	var rink: Rink = SCENE.instantiate()
	rink.case_seed = 5
	rink.get_node("Cop").input_enabled = false
	rink.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(rink)
	return rink


## The cop at `at` (rink space), facing +x.
func _place(rink: Rink, at: Vector3) -> Cop:
	var cop: Cop = rink.get_node("Cop")
	cop.global_position = rink.to_global(at)
	cop.rotation.y = -PI / 2
	cop.slide = Vector3.ZERO
	return cop


func _walk(cop: Cop, wish: Vector2, frames: int) -> void:
	for i in frames:
		cop.step(STEP, wish, false, false, false)
		await wait_physics_frames(1)


func _flat_speed(cop: Cop) -> float:
	return Vector2(cop.velocity.x, cop.velocity.z).length()


func test_without_skates_the_ice_slides_and_the_floor_doesnt() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	var cop := _place(rink, Vector3(-6.0, Rink.ICE_TOP + 0.05, 0.0))
	await _walk(cop, Vector2.ZERO, 5)
	assert_true(rink.ice.is_on_ice(cop))
	await _walk(cop, Vector2(0, -1), 15)
	assert_lt(_flat_speed(cop), GameScale.WALK_SPEED * 0.6, "it gets going slowly on the ice")
	await _walk(cop, Vector2(0, -1), 90)
	await _walk(cop, Vector2.ZERO, 20)
	assert_gt(_flat_speed(cop), 0.5, "and it doesn't stop when it lets go")
	cop = _place(rink, Vector3(-6.0, Rink.FLOOR_TOP + 0.05, -9.0))
	await _walk(cop, Vector2.ZERO, 5)
	assert_false(rink.ice.is_on_ice(cop))
	await _walk(cop, Vector2(0, -1), 3)
	assert_almost_eq(_flat_speed(cop), GameScale.WALK_SPEED, 0.1, "on the floor it walks at once")


func test_turning_hard_while_fast_on_the_ice_is_a_fall() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	var cop := _place(rink, Vector3(-6.0, Rink.ICE_TOP + 0.05, 0.0))
	await _walk(cop, Vector2.ZERO, 3)
	watch_signals(rink.ice)
	cop.slide = Vector3(1.5, 0, 0)
	await _walk(cop, Vector2(0, 1), 3)
	assert_eq(rink.ice.falls, 0, "slow, turning around is fine")
	cop.slide = Vector3(4.0, 0, 0)
	await _walk(cop, Vector2(1, 0), 3)
	assert_eq(rink.ice.falls, 0, "turning 90 degrees is fine too")
	cop.slide = Vector3(4.0, 0, 0)
	await _walk(cop, Vector2(0, 1), 3)
	assert_eq(rink.ice.falls, 1, "but turning around fast is a fall")
	assert_signal_emitted_with_parameters(rink.ice, "fell", [cop])
	assert_true(cop.is_staggered())
	for key: String in ["HINT_RINK_FELL", "PROMPT_RINK_SKATES_ON", "PROMPT_RINK_SKATES_OFF", "HINT_RINK_SKATES_ON",
			"HINT_RINK_SKATES_OFF", "PROMPT_RINK_RESURFACER", "HINT_RINK_RESURFACER_HIT"]:
		assert_ne(tr(key), key, "%s is translated" % key)


func test_the_skates_make_the_ice_easy_and_fast_and_the_floor_slow() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	var cop := _place(rink, Vector3(-6.0, Rink.ICE_TOP + 0.05, 0.0))
	assert_eq(rink.skate_rental.prompt_key(cop), "PROMPT_RINK_SKATES_ON")
	rink.skate_rental.use(cop)
	assert_true(rink.ice.has_skates(cop))
	assert_eq(rink.skate_rental.prompt_key(cop), "PROMPT_RINK_SKATES_OFF")
	await _walk(cop, Vector2(0, -1), 30)
	assert_almost_eq(_flat_speed(cop), GameScale.WALK_SPEED * RinkIce.SKATE_FAST, 0.1, "fast on the ice")
	cop.slide = Vector3(4.0, 0, 0)
	await _walk(cop, Vector2(0, 1), 3)
	assert_eq(rink.ice.falls, 0, "with skates it doesn't fall")
	cop = _place(rink, Vector3(-6.0, Rink.FLOOR_TOP + 0.05, -9.0))
	await _walk(cop, Vector2(0, -1), 3)
	assert_almost_eq(_flat_speed(cop), GameScale.WALK_SPEED * RinkIce.SKATE_DUCK, 0.1, "a duck off it")
	rink.skate_rental.use(cop)
	assert_false(rink.ice.has_skates(cop))
	await _walk(cop, Vector2(0, -1), 3)
	assert_almost_eq(_flat_speed(cop), GameScale.WALK_SPEED, 0.1, "skates back on the counter")


func test_the_resurfacer_goes_round_the_ice_for_30_seconds() -> void:
	assert_eq(IceResurfacer.loop_at(0.0)[0], IceResurfacer.LOOP[0])
	assert_eq(IceResurfacer.loop_at(24.0)[0], IceResurfacer.LOOP[1])
	assert_eq(IceResurfacer.loop_at(IceResurfacer.loop_length())[0], IceResurfacer.LOOP[0], "round and round")
	var rink := _rink()
	await wait_physics_frames(2)
	watch_signals(rink.resurfacer)
	var start := rink.resurfacer.position
	rink.resurfacer_button.use(rink.get_node("Cop"))
	assert_true(rink.resurfacer.is_running())
	assert_signal_emitted(rink.resurfacer, "started")
	await wait_seconds(1.0)
	assert_almost_eq(rink.resurfacer.position.distance_to(start), IceResurfacer.SPEED, 0.3, "it drives")
	rink.resurfacer.run_left = 0.05
	await wait_physics_frames(5)
	assert_false(rink.resurfacer.is_running())
	var stopped := rink.resurfacer.position
	await wait_physics_frames(10)
	assert_eq(rink.resurfacer.position, stopped, "it stays where it got to")


func test_the_resurfacer_pushes_props_and_shoves_cops() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	var prop := ClubEvidence.make_item("Box", Rink.COCOA_MODEL, Vector3(0.4, 0.4, 0.4), 2.0)
	rink.add_child(prop)
	prop.global_position = rink.to_global(Vector3(8.5, Rink.ICE_TOP + 0.25, -5.0))
	var cop := _place(rink, Vector3(-2.0, Rink.ICE_TOP + 0.05, -5.0))
	rink.resurfacer.start()
	await wait_seconds(2.5)
	assert_lt(rink.to_local(prop.global_position).x, 7.5, "the prop is pushed ahead")
	await wait_until(func() -> bool: return cop.is_staggered(), 5.0)
	assert_true(cop.is_staggered(), "the cop in its way is shoved")
