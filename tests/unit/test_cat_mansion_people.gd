extends GutTest

## The people of the Monedero mansion (escena-gato.md, step 2; NephewTraits, MansionNephew, MansionLady, MansionParrot).


func test_six_nephews_alike_but_each_their_own() -> void:
	for seed_value in [1, 2, 3, 77, 1234]:
		var nephews := NephewTraits.draw(seed_value)
		assert_eq(nephews.size(), NephewTraits.COUNT)
		var signatures := {}
		var tics := {}
		var scratched := 0
		for nephew in nephews:
			signatures[NephewTraits.signature(nephew)] = true
			tics[nephew.tic] = true
			if nephew.scratch != "":
				scratched += 1
				assert_has(NephewTraits.HANDS, nephew.scratch)
			assert_between(nephew.shoe, NephewTraits.SHOE_MIN, NephewTraits.SHOE_MAX)
		assert_eq(signatures.size(), NephewTraits.COUNT, "no two look the same (seed %d)" % seed_value)
		assert_eq(tics.size(), NephewTraits.COUNT, "one catchphrase each (seed %d)" % seed_value)
		assert_between(scratched, NephewTraits.SCRATCHED.x, NephewTraits.SCRATCHED.y)
	assert_eq(NephewTraits.draw(5), NephewTraits.draw(5), "same seed, same nephews")


func test_the_mansion_puts_the_people_in_their_rooms() -> void:
	var mansion := CatMansion.new()
	mansion.case_seed = 9
	add_child_autofree(mansion)
	assert_eq(mansion.nephews.size(), NephewTraits.COUNT)
	for i in mansion.nephews.size():
		var nephew := mansion.nephews[i]
		assert_eq(mansion.suspect(i), nephew)
		assert_eq(mansion.room(nephew.global_position), "drawing", "the nephews wait in the drawing room")
		assert_eq(nephew.traits, NephewTraits.draw(9)[i])
	assert_null(mansion.suspect(NephewTraits.COUNT))
	assert_eq(mansion.room(mansion.lady.global_position), "hall", "Ofelia is in the hall")
	assert_eq(mansion.room(mansion.parrot.global_position), "drawing", "the parrot is by the nephews")


func test_a_nephew_hides_his_scratch_and_wears_his_own_things() -> void:
	var mansion := CatMansion.new()
	mansion.case_seed = 3
	add_child_autofree(mansion)
	for nephew in mansion.nephews:
		assert_eq(nephew.part("glasses").visible, nephew.traits.glasses)
		assert_false(nephew.part("teeth").visible, "the teeth show only when he bites")
		for hand in NephewTraits.HANDS:
			assert_false(nephew.part("scratch_%s" % hand).visible, "the sleeves hide the scratch")
			assert_true(nephew.part("cuff_%s" % hand).visible)
	var small: MansionNephew = mansion.nephews.reduce(func(a, b): return a if a.traits.shoe < b.traits.shoe else b)
	var big: MansionNephew = mansion.nephews.reduce(func(a, b): return a if a.traits.shoe > b.traits.shoe else b)
	if small.traits.shoe < big.traits.shoe:
		assert_lt(small.part("legs").scale.z, big.part("legs").scale.z, "bigger feet, longer shoes")


func test_the_nephews_ofelia_and_the_parrot_talk() -> void:
	TranslationServer.set_locale("es")
	var mansion := CatMansion.new()
	mansion.case_seed = 11
	add_child_autofree(mansion)
	var nephew := mansion.nephews[0]
	assert_eq(nephew.prompt_key(null), "PROMPT_NEPHEW_TALK")
	nephew.use(null)
	var first := nephew.said()
	assert_string_contains(first, nephew.catchphrase(), "every line ends with the catchphrase")
	nephew.use(null)
	assert_ne(nephew.said(), first, "a different line the second time")
	var phrases := {}
	for other in mansion.nephews:
		phrases[other.catchphrase()] = true
	assert_eq(phrases.size(), NephewTraits.COUNT)
	mansion.lady.use(null)
	assert_ne(mansion.lady.said(), "", "Ofelia talks")
	mansion.parrot.use(null)
	assert_eq(tr(mansion.parrot.said()), tr("PARROT_PRETTY"))
	for key in ["NEPHEW_LINE_0", "NEPHEW_TIC_5", "MANSION_LADY_LINE_4", "PARROT_PRETTY", "PROMPT_PARROT"]:
		assert_ne(tr(key), key, "%s is translated" % key)
