extends GutTest

## Don Tómbola at the fun fair (allanamiento-parque.md, step 3): his round with the megaphone, the strength tester's
## bell that takes him to hand over the prize (once every 45 s, and the third time he catches on), the weak swing, the
## heavy thing thrown on the pad, and the rides he can't stand to see switched on.

const SCENE := preload("res://scenes/levels/fair.tscn")


func _fair() -> Fair:
	var fair: Fair = SCENE.instantiate()
	fair.case_seed = 5
	fair.get_node("Cop").input_enabled = false
	fair.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(fair)
	return fair


func test_he_walks_his_round_and_speaks_as_don_tombola() -> void:
	var fair := _fair()
	await wait_physics_frames(2)
	var start := fair.owner_npc.global_position
	await wait_seconds(3.0)
	assert_gt(fair.owner_npc.global_position.distance_to(start), 2.0, "he walks")
	assert_eq(fair.owner_npc.voice, "TOMBOLA")
	for key: String in ["TOMBOLA_LINE_1", "TOMBOLA_PRINTER", "TOMBOLA_FIX_1", "TOMBOLA_FIX_DONE", "TOMBOLA_HURT",
			"TOMBOLA_DOOR", "TOMBOLA_SAW", "TOMBOLA_NOTHING", "TOMBOLA_OFFENDED", "TOMBOLA_LAWYER", "TOMBOLA_RIDE",
			"TOMBOLA_FLUNG", "TOMBOLA_CAUGHT_ON", "PROMPT_FAIR_HIT", "HINT_FAIR_NEED_MALLET", "HINT_FAIR_WEAK_HIT",
			"FAIR_DING"]:
		assert_ne(tr(key), key, "%s is translated" % key)


func test_the_bell_takes_him_to_the_prize_twice_and_the_third_time_he_catches_on() -> void:
	var fair := _fair()
	await wait_physics_frames(2)
	fair.owner_npc.fix_time = 1.5
	fair.owner_npc.start_at(2)
	fair.tester.ring()
	assert_true(fair.tester.is_giving_prize())
	assert_eq(fair.owner_npc.errand(), "printer", "he runs to the prize")
	await wait_until(func() -> bool: return fair.owner_npc.is_fixing(), 10.0)
	assert_lt(fair.owner_npc.global_position.distance_to(fair.to_global(Fair.PRIZE_SPOT)), 0.5, "at the tester")
	assert_false(fair.owner_npc.can_see(fair.to_global(Fair.CAROUSEL_AT + Vector3.UP)), "his back to the fair")
	await wait_seconds(1.8)
	assert_false(fair.tester.is_giving_prize(), "prize handed over")
	assert_gt(fair.tester.rest_left, 0.0)
	fair.tester.ring()
	assert_false(fair.tester.is_giving_prize(), "not again before 45 s")
	fair.tester.rest_left = 0.0
	fair.tester.ring()
	assert_true(fair.tester.is_giving_prize(), "the second time he comes")
	fair.tester.fix()
	fair.tester.rest_left = 0.0
	var before := fair.owner_npc.complaint
	fair.tester.ring()
	assert_false(fair.tester.is_giving_prize(), "the third time he doesn't come")
	assert_almost_eq(fair.owner_npc.complaint, before + Fair.CAUGHT_ON, 0.01, "and it adds to the complaint")


func test_a_swing_needs_the_mallet_and_a_weak_one_leaves_the_cop_staring() -> void:
	var fair := _fair()
	await wait_physics_frames(2)
	var cop: Cop = fair.get_node("Cop")
	fair.tester.button.use(cop)
	assert_eq(fair.tester.rings, 0, "no mallet, no swing")
	cop.global_position = fair.to_global(Fair.TESTER_AT + Vector3(0, 0.1, 1.4))
	await wait_physics_frames(2)
	(cop.get_node("Grabber") as Node).grab(fair.tester.mallet)
	var weak := false
	for i in 20:
		var rings := fair.tester.rings
		fair.tester.button.use(cop)
		if fair.tester.rings == rings:
			weak = true
			assert_true(cop.is_staggered(), "staring at the mallet")
		fair.tester.fix()
		fair.tester.rest_left = 0.0
	assert_gt(fair.tester.rings, 0, "some swings ring the bell")
	assert_true(weak, "some swings are weak")


func test_something_heavy_thrown_hard_on_the_pad_rings_it() -> void:
	var fair := _fair()
	await wait_physics_frames(2)
	var mallet := fair.tester.mallet
	mallet.global_position = fair.to_global(Fair.TESTER_AT + StrengthTester.PAD_AT + Vector3(0, 1.2, 0))
	mallet.linear_velocity = Vector3(0, -8.0, 0)
	await wait_physics_frames(20)
	assert_eq(fair.tester.rings, 1, "the bell rang")
	var light := ClubEvidence.make_item("Light", StrengthTester.MALLET_MODEL, Vector3(0.3, 0.2, 0.3), 0.5)
	fair.add_child(light)
	light.global_position = fair.to_global(Fair.TESTER_AT + StrengthTester.PAD_AT + Vector3(0, 1.0, 0))
	await wait_physics_frames(30)
	assert_eq(fair.tester.rings, 1, "something light dropped on it doesn't")


func test_he_complains_about_a_ride_switched_on_once_per_ride() -> void:
	var fair := _fair()
	await wait_physics_frames(2)
	fair.owner_npc.start_at(0)
	await wait_physics_frames(2)
	var before := fair.owner_npc.complaint
	fair.rides.press("carousel")
	assert_almost_eq(fair.owner_npc.complaint, before + Fair.SAW_RIDE, 0.01, "he saw the carousel start")
	fair.rides.press("carousel")
	fair.rides.press("carousel")
	assert_almost_eq(fair.owner_npc.complaint, before + Fair.SAW_RIDE, 0.01, "only once per ride")
