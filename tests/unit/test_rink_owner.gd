extends GutTest

## Doña Pirueta at the rink (allanamiento-pista.md, step 3): her round on the ice, her song at the DJ booth that takes
## her to dance in the middle with her eyes closed (once every 45 s, and the third time she catches on), the cop on the
## ice without skates (once per cop) and something heavy falling on her ice.

const SCENE := preload("res://scenes/levels/rink.tscn")


func _rink() -> Rink:
	var rink: Rink = SCENE.instantiate()
	rink.case_seed = 5
	rink.get_node("Cop").input_enabled = false
	rink.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(rink)
	return rink


func test_she_skates_her_round_and_speaks_as_dona_pirueta() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	var start := rink.owner_npc.global_position
	assert_true(Rink.on_ice(rink.to_local(start)), "her round is on the ice")
	await wait_seconds(3.0)
	assert_gt(rink.owner_npc.global_position.distance_to(start), 2.0, "she skates")
	assert_eq(rink.owner_npc.voice, "PIRUETA")
	for key: String in ["PIRUETA_LINE_1", "PIRUETA_LINE_4", "PIRUETA_PRINTER", "PIRUETA_FIX_1", "PIRUETA_FIX_3",
			"PIRUETA_FIX_DONE", "PIRUETA_HURT", "PIRUETA_DOOR", "PIRUETA_SAW", "PIRUETA_NOTHING", "PIRUETA_OFFENDED",
			"PIRUETA_LAWYER", "PIRUETA_CAUGHT_ON", "PIRUETA_SHOES", "PIRUETA_ICE_HIT", "PROMPT_RINK_SONG",
			"RINK_SONG_PLAYING"]:
		assert_ne(tr(key), key, "%s is translated" % key)


func test_her_song_takes_her_to_dance_twice_and_the_third_time_she_catches_on() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	rink.owner_npc.fix_time = 1.5
	rink.song.button.use(rink.get_node("Cop"))
	assert_true(rink.song.is_dancing())
	assert_eq(rink.owner_npc.errand(), "printer", "she skates off to dance")
	await wait_until(func() -> bool: return rink.owner_npc.is_fixing(), 15.0)
	assert_lt(rink.owner_npc.global_position.distance_to(rink.to_global(Rink.DANCE_SPOT)), 0.5, "in the middle")
	var facing := -rink.owner_npc.global_basis.z
	await wait_physics_frames(10)
	assert_gt(facing.angle_to(-rink.owner_npc.global_basis.z), 0.3, "spinning")
	assert_false(rink.owner_npc.can_see(rink.to_global(Rink.DANCE_SPOT + Vector3(2, 1, 0))), "eyes closed")
	await wait_seconds(1.8)
	assert_false(rink.song.is_dancing(), "routine over")
	assert_gt(rink.song.rest_left, 0.0)
	rink.song.play()
	assert_false(rink.song.is_dancing(), "not again before 45 s")
	rink.song.rest_left = 0.0
	rink.song.play()
	assert_true(rink.song.is_dancing(), "the second time she comes")
	rink.song.fix()
	rink.song.rest_left = 0.0
	var before := rink.owner_npc.complaint
	rink.song.play()
	assert_false(rink.song.is_dancing(), "the third time she doesn't")
	assert_almost_eq(rink.owner_npc.complaint, before + Rink.CAUGHT_ON, 0.01, "and it adds to the complaint")


func test_she_scolds_a_cop_on_the_ice_without_skates_once() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	var cop: Cop = rink.get_node("Cop")
	rink.skate_rental.use(cop)
	cop.global_position = rink.to_global(rink.to_local(rink.owner_npc.global_position) + Vector3(2.0, 0.05, 0.0))
	var before := rink.owner_npc.complaint
	await wait_seconds(Rink.SHOES_CHECK_EVERY * 2.5)
	assert_almost_eq(rink.owner_npc.complaint, before, 0.5, "with skates it's fine")
	rink.skate_rental.use(cop)
	await wait_seconds(Rink.SHOES_CHECK_EVERY * 2.5)
	assert_almost_eq(rink.owner_npc.complaint, before + Rink.SAW_SHOES, 0.5, "shoes on her ice")
	await wait_seconds(Rink.SHOES_CHECK_EVERY * 2.5)
	assert_almost_eq(rink.owner_npc.complaint, before + Rink.SAW_SHOES, 0.5, "once per cop")


func test_something_heavy_falling_on_the_ice_and_not_something_light() -> void:
	var rink := _rink()
	await wait_physics_frames(2)
	var near := rink.to_local(rink.owner_npc.global_position) + Vector3(0, 0, 2.5)
	var light := ClubEvidence.make_item("Light", Rink.COCOA_MODEL, Vector3(0.3, 0.3, 0.3), 1.0)
	rink.add_child(light)
	light.global_position = rink.to_global(near + Vector3(0, 2.0, 0))
	var before := rink.owner_npc.complaint
	await wait_physics_frames(40)
	assert_almost_eq(rink.owner_npc.complaint, before, 0.5, "something light doesn't bother her")
	var heavy := ClubEvidence.make_item("Heavy", Rink.COCOA_MODEL, Vector3(0.4, 0.4, 0.4), 8.0)
	rink.add_child(heavy)
	heavy.global_position = rink.to_global(near + Vector3(1.0, 2.0, 0))
	await wait_physics_frames(40)
	assert_almost_eq(rink.owner_npc.complaint, before + Rink.SAW_HEAVY, 0.5, "something heavy does")
