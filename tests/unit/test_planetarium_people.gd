extends GutTest

## The planetarium's people (escena-planetario.md, step 2): the six guides alike, Doctor Órbita and Doña Nebulosa
## (GuideTraits, PlanetariumGuide, PlanetariumDirector, PlanetariumSleeper).


func test_the_six_guides_are_drawn_with_the_seed() -> void:
	var guides := GuideTraits.draw(11)
	assert_eq(guides.size(), GuideTraits.COUNT)
	assert_eq(GuideTraits.draw(11), guides, "same seed, same guides")
	var looks := {}
	var planets := {}
	var glowing := 0
	for guide in guides:
		looks[GuideTraits.signature(guide)] = true
		planets[guide.planet] = true
		glowing += 1 if guide.glow else 0
	assert_eq(looks.size(), GuideTraits.COUNT, "no two look the same")
	assert_eq(planets.size(), GuideTraits.PLANETS.size(), "each presents another planet")
	assert_eq(GuideTraits.PLANETS, Planetarium.PLANET_SEATS.keys(), "the planets of the seats")
	assert_between(glowing, GuideTraits.GLOWING.x, GuideTraits.GLOWING.y, "two or three have glow paint")


func test_the_people_are_in_their_places() -> void:
	var planetarium := Planetarium.new()
	planetarium.case_seed = 4
	add_child_autofree(planetarium)
	assert_eq(planetarium.guides.size(), GuideTraits.COUNT)
	for guide in planetarium.guides:
		var room := planetarium.room(guide.global_position)
		assert_true(room in ["hall", "dome"], "%s is in the hall or the dome room" % guide.traits.name)
		var target := Planetarium.CASE_AT if room == "hall" else Planetarium.PROJECTOR_AT
		var to := planetarium.to_global(target) - guide.global_position
		to.y = 0
		assert_gt(guide.global_basis.z.dot(to.normalized()), 0.9, "facing what they look after (the model faces +Z)")
	assert_eq(planetarium.suspect(2), planetarium.guides[2])
	assert_null(planetarium.suspect(GuideTraits.COUNT))
	assert_eq(planetarium.room(planetarium.director.global_position), "hall", "Doctor Órbita by the dome's door")
	assert_eq(planetarium.room(planetarium.sleeper.global_position), "dome", "Doña Nebulosa in her seat")
	assert_true(planetarium.sleeper.is_asleep())


func test_a_guide_shows_their_own_traits() -> void:
	var planetarium := Planetarium.new()
	planetarium.case_seed = 9
	add_child_autofree(planetarium)
	for guide in planetarium.guides:
		assert_false(guide.part("teeth").visible, "teeth only when they bite")
		assert_false(guide.part("glow_left").visible, "the glow only in the dark")
		assert_false(guide.part("glow_right").visible)
		assert_true(guide.part("helmet").visible)
		var pin := guide.part("pin").find_children("*", "MeshInstance3D", true, false)[0] as MeshInstance3D
		assert_eq((pin.material_override as StandardMaterial3D).albedo_color,
			Planetarium.PLANET_COLORS[guide.traits.planet], "the pin of their planet")


func test_a_guide_tells_their_planet() -> void:
	var planetarium := Planetarium.new()
	planetarium.case_seed = 2
	add_child_autofree(planetarium)
	TranslationServer.set_locale("es")
	var guide: PlanetariumGuide = planetarium.guides[0]
	guide.use(null)
	assert_string_contains(guide.said(), guide.planet_name())
	guide.use(null)
	assert_string_contains(guide.said(), guide.planet_name(), "every line says the planet")
	planetarium.director.use(null)
	assert_eq(planetarium.director.said(), "DIRECTOR_LINE_0")
	planetarium.sleeper.use(null)
	assert_eq(planetarium.sleeper.said(), "SLEEPER_LINE_0")
