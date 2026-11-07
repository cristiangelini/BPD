extends GutTest

## The pawn shop's stories (allanamiento-empenos.md, "Las historias", step 6): each one hides its main evidence where it
## fits with its extras, has its texts and its own clue: the fake trophy that falls with a breath, the armor that walks
## and the parrot's gold tooth, and the customers who know something.

const SCENE := preload("res://scenes/levels/pawn_shop.tscn")


func _shop(story: String, seed_value := 5) -> PawnShop:
	var place: PawnShop = SCENE.instantiate()
	place.case_seed = seed_value
	place.story_id = story
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	place._turn_left = 1000.0
	return place


func test_every_story_has_its_texts_and_hides_its_main_evidence_where_it_fits() -> void:
	TranslationServer.set_locale("es")
	for story: String in PawnShop.STORIES:
		var data: Dictionary = PawnShop.STORIES[story]
		assert_has(PawnShop.SUSPICION_POOL, story)
		for key: String in data.briefing + [data.find] + data.extra_keys:
			assert_ne(tr(key), key, "%s: %s is written" % [story, key])
		assert_ne(tr("CHICHARRA_CLUE_" + story), "CHICHARRA_CLUE_" + story)
		var place := _shop(story)
		assert_not_null(place.main, story)
		assert_eq(place.raid.main_evidence, place.main)
		assert_eq(place.extras.size(), data.extra_keys.size(), "%s: one checklist row per extra" % story)
		if data.get("main_hidden", false):
			assert_true(PawnShop.SPOTS[place.hidden_spots[0]].heavy, "%s: the main evidence needs room" % story)
		place.free()


func test_the_fake_trophy_falls_when_a_cop_walks_by() -> void:
	TranslationServer.set_locale("es")
	var place := _shop("fake_trophy")
	await wait_physics_frames(2)
	var rig := place.rig as FakeTrophyRig
	assert_has(place.extras, rig.copy, "the copy is an extra")
	assert_false(rig.fell)
	var cop: Cop = place.get_node("Cop")
	cop.global_position = rig.copy.global_position - Vector3.UP * 2.0 + place.global_basis.z * 1.0
	await wait_physics_frames(3)
	assert_true(rig.fell)
	assert_has(place.raid.clues_found, tr("CLUE_FAKE_TROPHY"))
	await wait_seconds(1.5)
	assert_lt(rig.copy.global_position.y, place.to_global(FakeTrophyRig.COPY_ON).y - 1.0, "off the shelf")


func test_a_customer_tells_what_they_know_every_other_time() -> void:
	TranslationServer.set_locale("es")
	var place := _shop("fake_trophy")
	await wait_physics_frames(1)
	var customer := place.customers[0]
	var cop: Cop = place.get_node("Cop")
	customer.use(cop)
	assert_eq(customer.said(), "PAWN_RUMOR_FAKE_TROPHY")
	assert_has(place.raid.clues_found, tr("PAWN_RUMOR_FAKE_TROPHY"))
	customer.use(cop)
	assert_ne(customer.said(), "PAWN_RUMOR_FAKE_TROPHY", "and something else in between")
	assert_eq(place.customers[2].rumor, "", "the others know nothing")


func test_the_armor_walks_until_it_falls_apart() -> void:
	TranslationServer.set_locale("es")
	var place := _shop("walking_armor")
	await wait_physics_frames(1)
	var rig := place.rig as WalkingArmorRig
	var body := place.armor_parts[0]
	var start := body.position
	rig.step()
	assert_almost_eq(body.position.z, start.z + WalkingArmorRig.STEPS[0] * WalkingArmorRig.STEP, 0.01)
	assert_almost_eq(place.armor_at, PawnShop.ARMOR_AT + body.position - start, Vector3.ONE * 0.01,
		"the shop knows where it stands")
	assert_almost_eq(rig.look.global_position.z, place.to_global(place.armor_at).z, 0.01, "its clue goes with it")
	rig.look.use(place.get_node("Cop"))
	assert_has(place.raid.clues_found, tr("CLUE_WALKING_ARMOR"))
	rig._step_left = 0.01
	await wait_physics_frames(2)
	assert_eq(rig.steps, 2, "every STEP_EVERY seconds")
	place.knock_armor()
	var fallen := body.position
	rig.step()
	assert_eq(body.position, fallen, "not once it fell apart")


func test_chicharra_has_a_gold_tooth_and_feeding_him_is_the_clue() -> void:
	TranslationServer.set_locale("es")
	var place := _shop("gold_dentures")
	await wait_physics_frames(1)
	assert_not_null(place.parrot.get_node_or_null("GoldTooth"))
	var cop: Cop = place.get_node("Cop")
	place.cookie_jar.use(cop)
	place.parrot.use(cop)
	assert_has(place.raid.clues_found, tr("CLUE_GOLD_DENTURES"))
	assert_string_contains(place.parrot.said(), "Abra la boca")
	assert_eq(place.customers[1].rumor, "PAWN_RUMOR_GOLD_DENTURES")
