extends GutTest

## Rosaura at the karaoke (allanamiento-karaoke.md, step 3): she walks her round up to the stage, a cop on the stage
## with microphone 2 calls her to a duet facing the lyrics screen with her back to the room, the duets rest and the
## third one gives the cops away, and the customers' complaints reach her complaint.

const SCENE := preload("res://scenes/levels/karaoke.tscn")


func _karaoke() -> Karaoke:
	var place: Karaoke = SCENE.instantiate()
	place.case_seed = 5
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	place._turn_left = 1000.0
	return place


## The cop up on the stage (or by the door) with microphone 2 in hand.
func _mic_2(place: Karaoke, up := true) -> Cop:
	var cop: Cop = place.get_node("Cop")
	var at := Karaoke.MIC_STANDS[1] + Vector3(-0.8, 0.05, 0.2) if up else Vector3(3.0, Karaoke.FLOOR_TOP + 0.05, -3.0)
	cop.global_position = place.to_global(at)
	place.mics[1].hold(cop.get_node("Grabber").get_instance_id(), place.to_global(at + Vector3.UP * 1.0))
	return cop


func test_she_walks_her_round() -> void:
	var place := _karaoke()
	assert_not_null(place.owner_boss)
	assert_eq(place.owner_boss.voice, "DIVA")
	var start := place.owner_boss.global_position
	await wait_seconds(1.5)
	assert_gt(place.owner_boss.global_position.distance_to(start), 0.8, "on her way")
	assert_eq(place.owner_boss.complaint, 0.0)


func test_a_cop_with_microphone_2_on_the_stage_gets_a_duet() -> void:
	var place := _karaoke()
	var boss := place.owner_boss
	boss.start_at(5)
	boss.fix_time = 3.0
	await wait_physics_frames(5)
	_mic_2(place)
	await wait_physics_frames(3)
	assert_true(place.duet_call.is_jammed, "called")
	assert_eq(boss.errand(), "printer")
	await wait_until(func() -> bool: return boss.is_fixing(), 8.0)
	assert_true(boss.is_fixing(), "singing")
	var spot := place.to_global(Karaoke.MIC_STANDS[1] + Karaoke.DUET_BESIDE)
	assert_lt(Vector2(boss.global_position.x - spot.x, boss.global_position.z - spot.z).length(), 0.4, "by the mic")
	assert_true(place.on_stage(boss), "up on the stage")
	assert_false(boss.can_see(place.to_global(Karaoke.TILL_ON)), "her back to the room")
	await wait_seconds(3.5)
	assert_false(boss.is_fixing(), "back to her round")
	assert_false(place.duet_call.is_jammed)


func test_microphone_2_off_the_stage_is_no_duet() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	_mic_2(place, false)
	await wait_physics_frames(5)
	assert_false(place.duet_call.is_jammed)
	assert_eq(place.duet_call.calls, 0)


func test_duets_rest_and_the_third_gives_the_cops_away() -> void:
	var place := _karaoke()
	var call := place.duet_call
	watch_signals(call)
	call.duet()
	assert_signal_emit_count(call, "called", 1)
	call.fix()
	call.duet()
	assert_signal_emit_count(call, "called", 1, "resting")
	call.rest_left = 0.0
	call.duet()
	assert_signal_emit_count(call, "called", 2)
	call.fix()
	call.rest_left = 0.0
	call.duet()
	assert_signal_emitted(call, "caught_on")
	assert_signal_emit_count(call, "called", 2, "no duet")
	assert_eq(place.owner_boss.complaint, Karaoke.CAUGHT_ON)


func test_the_customers_complaints_reach_her() -> void:
	var place := _karaoke()
	place.singers[0].complain("KARAOKE_SINGER_NO_MIC")
	assert_eq(place.owner_boss.complaint, Karaoke.SINGER_COMPLAINT)
	place.singers[0].complain("KARAOKE_SINGER_NO_MIC")
	assert_eq(place.owner_boss.complaint, Karaoke.SINGER_COMPLAINT, "each one's cooldown")
	place.singers[1].complain("KARAOKE_SINGER_NO_MIC")
	assert_eq(place.owner_boss.complaint, Karaoke.SINGER_COMPLAINT * 2)
	for key: String in ["DIVA_LINE_1", "DIVA_PRINTER", "DIVA_FIX_3", "DIVA_FIX_DONE", "DIVA_HURT", "DIVA_DOOR",
			"DIVA_SAW", "DIVA_NOTHING", "DIVA_OFFENDED", "DIVA_LAWYER", "DIVA_CAUGHT_ON", "DIVA_SINGER",
			"DIVA_SCREEN", "DIVA_DISCO", "KARAOKE_DUET_SCREEN"]:
		assert_ne(tr(key), key, key)
