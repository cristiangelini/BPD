extends GutTest

## The party guests' costumes (infiltracion-fiesta.md, step 2b, decision 171): whichever three of the four bits the
## clues tell, only the Sargento Trucho wears them all.


func test_any_three_bits_point_to_the_boss_alone() -> void:
	for case_seed in range(1, 201):
		var costumes := PartyTraits.draw(case_seed, 12)
		var traits: Array[Dictionary] = []
		traits.assign(costumes.traits)
		for left_out: String in PartyTraits.KINDS:
			var known: Dictionary = traits[costumes.boss].duplicate()
			known.erase(left_out)
			assert_eq(PartyTraits.matching(traits, known), [costumes.boss], "seed %d without %s" % [case_seed, left_out])


func test_two_bits_are_not_always_enough() -> void:
	var ambiguous := 0
	for case_seed in range(1, 101):
		var costumes := PartyTraits.draw(case_seed, 12)
		var traits: Array[Dictionary] = []
		traits.assign(costumes.traits)
		var known := {"cap": traits[costumes.boss].cap, "badge": traits[costumes.boss].badge}
		ambiguous += int(PartyTraits.matching(traits, known).size() > 1)
	assert_gt(ambiguous, 10, "the third clue matters")


func test_the_same_seed_dresses_everyone_the_same() -> void:
	assert_eq(PartyTraits.draw(77, 12), PartyTraits.draw(77, 12))
	assert_ne(PartyTraits.draw(77, 12), PartyTraits.draw(78, 12))


func test_every_bit_has_its_model() -> void:
	for kind: String in PartyTraits.KINDS:
		for value: String in PartyTraits.VALUES[kind]:
			if value != "none":
				assert_true(ResourceLoader.exists(PartyTraits.MODEL % [kind, value]), "%s %s" % [kind, value])
