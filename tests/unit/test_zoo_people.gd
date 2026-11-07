extends GutTest

## The zoo's people (escena-zoo.md, step 2): the six keepers alike, Doña Jaula and Don Pico (KeeperTraits, ZooKeeper,
## ZooDirector, ZooParrot).


func test_the_six_keepers_are_drawn_with_the_seed() -> void:
	var keepers := KeeperTraits.draw(11)
	assert_eq(keepers.size(), KeeperTraits.COUNT)
	assert_eq(KeeperTraits.draw(11), keepers, "same seed, same keepers")
	var looks := {}
	var smells := {}
	var pecked := 0
	for keeper in keepers:
		looks[KeeperTraits.signature(keeper)] = true
		smells[keeper.smell] = true
		pecked += 1 if keeper.pecked else 0
	assert_eq(looks.size(), KeeperTraits.COUNT, "no two look the same")
	assert_eq(smells.size(), KeeperTraits.SMELLS.size(), "each smells of another food")
	assert_between(pecked, KeeperTraits.PECKED.x, KeeperTraits.PECKED.y, "two or three have a band-aid")


func test_the_people_are_in_their_places() -> void:
	var zoo := Zoo.new()
	zoo.case_seed = 4
	add_child_autofree(zoo)
	assert_eq(zoo.keepers.size(), KeeperTraits.COUNT)
	var rooms := {}
	for keeper in zoo.keepers:
		var room := zoo.room(keeper.global_position)
		rooms[room] = rooms.get(room, 0) + 1
	assert_eq(rooms, {"entrance": 2, "grounds": 3, "hut": 1})
	assert_eq(zoo.suspect(2), zoo.keepers[2])
	assert_null(zoo.suspect(KeeperTraits.COUNT))
	assert_eq(zoo.room(zoo.director.global_position), "grounds", "Doña Jaula by the penguins' glass")
	assert_gt(zoo.director.position.z, Zoo.GLASS_Z, "on the visitors' side")
	assert_almost_eq(zoo.parrot.position.y, Zoo.PARROT_AT.y, 0.01, "Don Pico up on his perch")


func test_a_keeper_shows_their_own_traits() -> void:
	var zoo := Zoo.new()
	zoo.case_seed = 9
	add_child_autofree(zoo)
	for keeper in zoo.keepers:
		assert_true(keeper.part("cap").visible, "the cap on")
		assert_false(keeper.part("teeth").visible, "teeth only when they bite")
		assert_false(keeper.part("glove_right").visible, "gloves off until feeding time")
		assert_eq(keeper.part("bandage").visible, keeper.traits.pecked, "the band-aid only if pecked")
		keeper.wear_gloves(true)
		assert_true(keeper.part("glove_right").visible)
		assert_false(keeper.part("bandage").visible, "the gloves hide it")


func test_they_talk() -> void:
	var zoo := Zoo.new()
	zoo.case_seed = 2
	add_child_autofree(zoo)
	TranslationServer.set_locale("es")
	for keeper in zoo.keepers:
		keeper.use(null)
		assert_eq(keeper.said(), tr("KEEPER_SMELL_%s" % keeper.traits.smell))
		assert_ne(keeper.said(), "KEEPER_SMELL_%s" % keeper.traits.smell, "a line for every smell")
	zoo.director.use(null)
	assert_eq(zoo.director.said(), "ZOO_DIRECTOR_LINE_0")
	zoo.director.use(null)
	assert_eq(zoo.director.said(), "ZOO_DIRECTOR_LINE_1", "another line each time")
	zoo.parrot.use(null)
	assert_eq(zoo.parrot.said(), "PARROT_LINE_0")
	for key in ["PROMPT_KEEPER_TALK", "PROMPT_ZOO_DIRECTOR", "PROMPT_ZOO_PARROT", "ZOO_DIRECTOR_LINE_4", "PARROT_LINE_3"]:
		assert_ne(tr(key), key, "%s is translated" % key)
