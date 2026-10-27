extends GutTest

## The five cats of the Monedero mansion, the transport crate, the music box and the tuna (escena-gato.md, step 3;
## MansionCat, TransportCrate, MusicBox, TunaCan).


func _mansion(seed_value := 5) -> CatMansion:
	var mansion := CatMansion.new()
	mansion.case_seed = seed_value
	add_child_autofree(mansion)
	return mansion


func test_five_cats_one_of_them_duchess() -> void:
	var mansion := _mansion()
	assert_eq(mansion.cats.size(), CatMansion.CAT_COUNT)
	var duchesses := mansion.cats.filter(func(cat: MansionCat) -> bool: return cat.duchess)
	assert_eq(duchesses.size(), 1, "only one is Duquesa")
	assert_eq(mansion.cats[mansion.duchess], duchesses[0])
	for cat in mansion.cats:
		assert_ne(mansion.room(cat.global_position), "", "every cat starts inside the house")
	for spot in CatMansion.HIDE_AT:
		assert_ne(mansion.room(mansion.to_global(spot)), "", "%s is a hiding spot in the house" % spot)
	var picked := {}
	for seed_value in 12:
		picked[absi(hash("mansion duchess %d" % seed_value)) % CatMansion.CAT_COUNT] = true
	assert_gt(picked.size(), 2, "the seed moves Duquesa around")


func test_a_held_cat_jumps_out_and_hides() -> void:
	var mansion := _mansion()
	var cat := mansion.cats[0]
	cat.hold(get_instance_id(), cat.global_position + Vector3.UP * 0.5)
	await wait_physics_frames(2)
	assert_true(cat.is_held(), "she can be held a while")
	cat._held_for = MansionCat.ESCAPE_SECONDS - 0.01
	await wait_physics_frames(3)
	assert_false(cat.is_held(), "after 5 s she jumps out")
	assert_true(cat.is_hiding())
	assert_eq(cat.said(), "CAT_HISS")
	assert_true(cat.hide_spots.has(cat._target), "she runs to a hiding spot")


func test_the_crate_keeps_her_until_opened() -> void:
	var mansion := _mansion()
	var cat := mansion.cats[0]
	cat.hold(get_instance_id(), mansion.crate.door())
	cat.global_position = mansion.crate.door()
	await wait_physics_frames(2)
	assert_eq(mansion.crate.cat, cat, "held to the door, she goes in")
	assert_eq(cat.crate, mansion.crate)
	assert_false(cat.is_held())
	assert_eq(mansion.crate.prompt_key(null), "PROMPT_CAT_CRATE_OPEN")
	cat._held_for = MansionCat.ESCAPE_SECONDS + 1.0
	mansion.crate.global_position += Vector3(1.0, 0, 0)
	await wait_physics_frames(2)
	assert_eq(mansion.crate.cat, cat, "she can't jump out of the crate")
	assert_almost_eq(cat.global_position.x, mansion.crate.global_position.x, 0.2, "she goes where the crate goes")
	mansion.crate.use(null)
	assert_null(mansion.crate.cat)
	assert_null(cat.crate)
	assert_false(cat.freeze, "out again")


func test_only_duchess_purrs_at_the_music_box() -> void:
	var mansion := _mansion()
	var box := mansion.music_box
	var duchess := mansion.cats[mansion.duchess]
	var other := mansion.cats[(mansion.duchess + 1) % CatMansion.CAT_COUNT]
	for cat in [duchess, other]:
		cat.freeze = true
		cat.global_position = box.global_position + Vector3(-1.0, -1.0, 0)
	await wait_physics_frames(2)
	assert_false(duchess.purring, "no music, no purring")
	assert_eq(box.prompt_key(null), "PROMPT_MUSIC_BOX")
	box.use(null)
	await wait_physics_frames(2)
	assert_true(box.playing())
	assert_true(duchess.purring, "Duquesa purrs with her music")
	assert_eq(duchess.said(), "CAT_PURR")
	assert_false(other.purring, "the others don't")
	duchess.global_position = box.global_position + Vector3(-MansionCat.PURR_RANGE - 2.0, -1.0, 0)
	await wait_physics_frames(2)
	assert_false(duchess.purring, "too far to hear it")


func test_the_tuna_calls_the_cats_but_not_one_locked_away() -> void:
	var mansion := _mansion()
	var can := mansion.tuna_cans[0]
	var near := mansion.cats[1]
	var shut := mansion.cats[4]
	shut.shut_in = true
	var far := mansion.cats[2]
	assert_gt(far.global_position.distance_to(can.feed_at), MansionCat.LURE_RANGE, "the drawing room is too far")
	can.use(null)
	assert_true(can.open)
	assert_eq(near._target, can.feed_at, "the kitchen cat runs to eat")
	assert_eq(far._target, Vector3.INF, "the far one doesn't smell it")
	assert_eq(shut._target, Vector3.INF, "a locked cat can't come")
	assert_eq(shut.said(), "CAT_MEOW", "she meows instead")
	assert_eq(can.prompt_key(null), "PROMPT_TUNA_CAN_OPEN")
	TranslationServer.set_locale("es")
	for key in ["PROMPT_MANSION_CAT", "CAT_PURR", "PROMPT_CAT_CRATE", "PROMPT_TUNA_CAN", "PROMPT_MUSIC_BOX"]:
		assert_ne(tr(key), key, "%s is translated" % key)
