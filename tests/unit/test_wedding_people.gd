extends GutTest

## The wedding's people (escena-boda.md, step 2): Tito and his five groomsmen alike but for what WeddingTraits draws
## with the seed (Tito always first, with the white carnation; one stubborn), Rosa, the DJ, grandma Chola with her ear
## trumpet and the guests, all standing clear of the tables and of each other, each with a line on E.


func _hall(seed_value := 3) -> WeddingHall:
	var hall := WeddingHall.new()
	hall.case_seed = seed_value
	add_child_autofree(hall)
	return hall


func test_the_traits_come_from_the_seed() -> void:
	assert_eq(WeddingTraits.draw(7), WeddingTraits.draw(7), "same seed, same suspects")
	var differs := false
	for seed_value in range(1, 6):
		if WeddingTraits.draw(seed_value) != WeddingTraits.draw(seed_value + 100):
			differs = true
	assert_true(differs, "other seeds, other suspects")
	for seed_value in range(1, 30):
		var suspects := WeddingTraits.draw(seed_value)
		assert_eq(suspects.size(), WeddingTraits.COUNT)
		assert_eq(suspects[0].name, "Tito")
		assert_eq(suspects.filter(func(s: Dictionary) -> bool: return s.groom).size(), 1, "one groom")
		assert_true(suspects[0].groom)
		assert_eq(suspects.filter(func(s: Dictionary) -> bool: return s.stubborn).size(), 1, "one stubborn")
		var signatures := {}
		for suspect in suspects:
			assert_true(WeddingTraits.COLOGNES.has(suspect.cologne))
			signatures[WeddingTraits.signature(suspect)] = true
		assert_eq(signatures.size(), WeddingTraits.COUNT, "no two the same")


func test_the_tuxedos_wear_their_traits() -> void:
	var hall := _hall()
	var traits := WeddingTraits.draw(3)
	assert_eq(hall.tuxedos.size(), 6)
	for tuxedo in hall.tuxedos:
		assert_eq(tuxedo.traits, traits[tuxedo.index])
		assert_eq(tuxedo.part("glasses").visible, bool(tuxedo.traits.glasses))
		assert_false(tuxedo.part("teeth").visible, "teeth hidden until he bites")
		assert_true(tuxedo.part("hat").visible)
		var carnation: MeshInstance3D = tuxedo.part("carnation").find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D
		assert_eq(carnation.material_override == null, tuxedo.index == 0, "white carnation only for Tito")
	var small: TuxedoGuest = hall.tuxedos.reduce(func(a: TuxedoGuest, b: TuxedoGuest) -> TuxedoGuest:
		return a if a.traits.shoe <= b.traits.shoe else b)
	var big: TuxedoGuest = hall.tuxedos.reduce(func(a: TuxedoGuest, b: TuxedoGuest) -> TuxedoGuest:
		return a if a.traits.shoe >= b.traits.shoe else b)
	if small.traits.shoe < big.traits.shoe:
		assert_lt(small.part("legs").scale.z, big.part("legs").scale.z, "bigger shoes for bigger feet")


func test_everyone_stands_clear_and_talks() -> void:
	var hall := _hall()
	var people: Array = []
	people.append_array(hall.tuxedos)
	people.append_array([hall.bride, hall.dj, hall.grandma])
	people.append_array(hall.guests)
	assert_eq(people.size(), 13)
	assert_not_null(hall.ear_trumpet, "grandma's ear trumpet")
	var cop: Cop = null
	for i in people.size():
		var person: WeddingPerson = people[i]
		var spot := Vector2(person.position.x, person.position.z)
		assert_lt(absf(spot.x) + 0.45, WeddingHall.HALF_X, "%s inside" % person.name)
		assert_lt(absf(spot.y) + 0.45, WeddingHall.HALF_Z, "%s inside" % person.name)
		for top in hall.table_tops:
			assert_gt(spot.distance_to(Vector2(top.x, top.z)), WeddingHall.TABLE_RADIUS + 0.45, "%s off the tables" % person.name)
		for j in range(i + 1, people.size()):
			var other: WeddingPerson = people[j]
			assert_gt(spot.distance_to(Vector2(other.position.x, other.position.z)), 0.95, "%s and %s apart" % [person.name, other.name])
		assert_ne(person.prompt_key(cop), "")
		person.use(cop)
		assert_ne(person.said(), "", "%s says something" % person.name)
		if not person is TuxedoGuest:
			assert_ne(tr(person.said()), person.said(), "%s's line is translated" % person.name)
	hall.tuxedos[0].talk()
	assert_eq(hall.tuxedos[0].said(), "WEDDING_GROOM_LINE_0", "Tito's first line")
	hall.tuxedos[1].talk()
	assert_eq(hall.tuxedos[1].said(), "WEDDING_GROOMSMAN_LINE_1", "the groomsmen start on their own line")
