extends GutTest

## The karaoke's speaker of watches story (allanamiento-karaoke.md, step 6): one stage speaker, drawn with the seed, is
## the main evidence and too heavy for one cop, it ticks for a cop next to it (the clue, once), the customers sing
## turned toward the other one, and the extras are hidden.

const SCENE := preload("res://scenes/levels/karaoke.tscn")


func _karaoke(case_seed := 5) -> Karaoke:
	var place: Karaoke = SCENE.instantiate()
	place.story_id = "karaoke_watches"
	place.case_seed = case_seed
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	place._turn_left = 1000.0
	return place


func test_one_stage_speaker_is_the_evidence() -> void:
	var place := _karaoke()
	await wait_physics_frames(10)
	var rig: WatchesRig = place.rig
	assert_has(place.raid.suspicions, "karaoke_watches")
	assert_eq(place.main, rig.speaker)
	assert_almost_eq(place.main.full_value, 1000.0, 0.01)
	assert_eq(place.extras.size(), 2, "the watch and the invoice")
	assert_eq(place.hidden, place.extras)
	assert_gt(rig.speaker.mass, 15.0, "it takes two")
	var at := place.to_local(rig.speaker.global_position)
	assert_almost_eq(at.x, Karaoke.SPEAKER_X[rig.mute], 0.05, "where the speaker was")
	assert_gt(at.y, Karaoke.FLOOR_TOP + Karaoke.STAGE_SIZE.y, "standing on the stage")
	var other := _karaoke(6)
	await wait_physics_frames(2)
	assert_ne((other.rig as WatchesRig).mute, rig.mute, "another seed, the other speaker")


func test_a_cop_next_to_it_hears_it_tick_once() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	var rig: WatchesRig = place.rig
	var cop: Cop = place.get_node("Cop")
	assert_false(rig.heard)
	cop.global_position = rig.speaker.global_position + Vector3(0, -0.85, 1.2)
	await wait_physics_frames(2)
	assert_true(rig.heard)
	assert_true(rig._tick.visible, "tick-tock")
	assert_has(place.raid.clues_found, tr("KARAOKE_TICK_CLUE"))
	var clues: int = place.raid.clues_found.size()
	cop.global_position = place.to_global(Vector3(3.0, Karaoke.FLOOR_TOP + 0.05, 2.0))
	await wait_physics_frames(2)
	assert_false(rig._tick.visible)
	cop.global_position = rig.speaker.global_position + Vector3(0, -0.85, 1.2)
	await wait_physics_frames(2)
	assert_eq(place.raid.clues_found.size(), clues, "the clue is there once")


func test_the_customers_sing_toward_the_other_speaker() -> void:
	var place := _karaoke()
	await wait_physics_frames(2)
	var rig: WatchesRig = place.rig
	place._turn_left = 0.0
	await wait_until(func() -> bool: return place.on_turn != null and place.on_turn.singing, 8.0)
	await wait_physics_frames(2)
	var singer := place.on_turn
	var live: float = Karaoke.SPEAKER_X[1 - rig.mute]
	assert_eq(signf(singer.rotation.y), signf(live - singer.position.x), "turned toward it")


func test_the_watches_texts_exist() -> void:
	for key: String in ["BRIEF_KARAOKE_WATCHES_B", "BRIEF_KARAOKE_WATCHES_C", "BRIEF_KARAOKE_WATCHES_D",
			"OBJ_FIND_WATCH_SPEAKER", "OBJ_EXTRA_FAKE_WATCH", "OBJ_EXTRA_SHIP_INVOICE", "TOTO_CLUE_karaoke_watches",
			"KARAOKE_TICK", "KARAOKE_TICK_CLUE"]:
		assert_ne(tr(key), key, key)


func test_the_speaker_in_the_trunk_solves_the_case() -> void:
	var place := _karaoke()
	await wait_physics_frames(10)
	var speaker := place.main
	speaker.global_transform = Transform3D(place.car.global_basis * Basis(Vector3.RIGHT, PI / 2),
		place.car.to_global(Vector3(0, 0.9, -1.7)))
	await wait_physics_frames(10)
	assert_true(place.car.is_delivered(speaker))
	assert_true(place.raid.mark(place.raid.suspicions.find("karaoke_watches")))
	place.car.enter(place.get_node("Cop"))
	assert_true(place.raid.case_solved)
