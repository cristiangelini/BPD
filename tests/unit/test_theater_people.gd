extends GutTest

## The theater's people (escena-teatro.md, step 2): the six ghosts alike, Maestro Bambalina and Don Susurro
## (GhostTraits, TheaterGhost, TheaterDirector, TheaterPrompter).


func test_the_six_ghosts_are_drawn_with_the_seed() -> void:
	var ghosts := GhostTraits.draw(11)
	assert_eq(ghosts.size(), GhostTraits.COUNT)
	assert_eq(GhostTraits.draw(11), ghosts, "same seed, same ghosts")
	var looks := {}
	var embroideries := {}
	var deep := 0
	for ghost in ghosts:
		looks[GhostTraits.signature(ghost)] = true
		embroideries[ghost.embroidery] = true
		deep += 1 if ghost.deep else 0
	assert_eq(looks.size(), GhostTraits.COUNT, "no two look the same")
	assert_eq(embroideries.size(), Theater.EMBROIDERIES.size(), "each has another embroidery")
	assert_eq(GhostTraits.EMBROIDERY_COLORS.keys(), Theater.EMBROIDERIES, "a color for each dressing room's embroidery")
	assert_between(deep, GhostTraits.DEEP.x, GhostTraits.DEEP.y, "two or three sing deep")


func test_the_people_are_in_their_places() -> void:
	var theater := Theater.new()
	theater.case_seed = 4
	add_child_autofree(theater)
	assert_eq(theater.ghosts.size(), GhostTraits.COUNT)
	var rooms := {}
	for ghost in theater.ghosts:
		var room := theater.room(ghost.global_position + Vector3.UP * 0.1)
		rooms[room] = rooms.get(room, 0) + 1
		var looks := theater.to_global(ghost.position + ghost.basis.z) - ghost.global_position
		if room == "stage":
			assert_gt(looks.z, 0.9, "%s faces the hall" % ghost.traits.name)
		else:
			assert_lt(looks.z, -0.9, "%s faces the stage or their dressing room" % ghost.traits.name)
	assert_eq(rooms, {"stage": 2, "hall": 2, "backstage": 2})
	assert_eq(theater.suspect(2), theater.ghosts[2])
	assert_null(theater.suspect(GhostTraits.COUNT))
	assert_eq(theater.room(theater.director.global_position + Vector3.UP * 0.1), "hall", "the director in the aisle")
	assert_eq(theater.room(theater.prompter.global_position + Vector3.UP * 0.1), "hall", "the prompter in the pit")
	assert_lt(theater.prompter.position.z, Theater.PIT_RAIL_Z, "past the pit's rail")
	assert_almost_eq(theater.prompter.position.x, Theater.PROMPTER_AT.x, 0.01, "right under his shell")


func test_a_ghost_shows_their_own_traits() -> void:
	var theater := Theater.new()
	theater.case_seed = 9
	add_child_autofree(theater)
	for ghost in theater.ghosts:
		assert_true(ghost.part("sheet").visible, "the sheet on")
		assert_false(ghost.part("teeth").visible, "teeth only when they bite")
		var patch := ghost.part("embroidery").find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D
		assert_eq((patch.material_override as StandardMaterial3D).albedo_color,
			GhostTraits.EMBROIDERY_COLORS[ghost.traits.embroidery], "the patch of their embroidery")


func test_they_talk() -> void:
	var theater := Theater.new()
	theater.case_seed = 2
	add_child_autofree(theater)
	TranslationServer.set_locale("es")
	for ghost in theater.ghosts:
		ghost.use(null)
		assert_eq(ghost.said(), tr("GHOST_EMBROIDERY_%s" % ghost.traits.embroidery))
		assert_ne(ghost.said(), "GHOST_EMBROIDERY_%s" % ghost.traits.embroidery, "a line for every embroidery")
	theater.director.use(null)
	assert_eq(theater.director.said(), "THEATER_DIRECTOR_LINE_0")
	theater.director.use(null)
	assert_eq(theater.director.said(), "THEATER_DIRECTOR_LINE_1", "another line each time")
	theater.prompter.use(null)
	assert_eq(theater.prompter.said(), "PROMPTER_LINE_0")
