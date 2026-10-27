extends GutTest

## The planetarium's clues (escena-planetario.md, step 6a): PlanetariumClues puts the prints on the display case, the
## glowing moon-boot print in the dome room (GlowPrint), the hair by the helmet in the control room, the ice cream in
## the kids' rocket and the photo booth's last photo (PhotoBooth); the glow paint shows on the guides; the vacuum, the
## polish and the school visit spoil some; and CrimeSceneCase says each one on the planilla.

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func _planetarium_case(seed_value: int) -> Array:
	var planetarium := Planetarium.new()
	planetarium.case_seed = seed_value
	add_child_autofree(planetarium)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = planetarium
	add_child_autofree(case)
	case.start()
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	cop.global_position = Vector3(0, 0, 40)
	return [planetarium, case, cop]


## The first seed whose case has (or hasn't) the clue.
func _seed_with(kind: String, has := true) -> int:
	for seed_value in range(1, 200):
		var guides := GuideTraits.draw(seed_value)
		var plan := CrimePlan.draw(guides, seed_value, CrimeSceneCase.VARIANTS.planetarium.clues)
		if plan.clues.has(kind) == has:
			return seed_value
	return -1


func test_each_clue_is_there_only_when_the_case_has_it() -> void:
	for seed_value in [1, 2, 3, 4, 5]:
		var made := _planetarium_case(seed_value)
		var planetarium: Planetarium = made[0]
		var case: CrimeSceneCase = made[1]
		var clues := case.plan.clues
		assert_eq(planetarium.clues.glass.has_prints, clues.has("prints"), "seed %d prints" % seed_value)
		assert_eq(planetarium.has_node("GlowPrint"), clues.has("footprint"), "seed %d footprint" % seed_value)
		assert_eq(case.items.has("hair"), clues.has("hair"), "seed %d hair" % seed_value)
		assert_eq(planetarium.clues.has_bite, clues.has("bite"), "seed %d bite" % seed_value)
		assert_eq(planetarium.clues.has_photo, clues.has("booth"), "seed %d booth" % seed_value)
		assert_true(planetarium.has_node("ForgottenHelmet"), "the helmet is always in the control room")
		if case.items.has("hair"):
			assert_eq(planetarium.room((case.items.hair as Node3D).global_position), "control")


func test_the_glowing_print_shows_only_in_the_dark() -> void:
	var made := _planetarium_case(_seed_with("footprint"))
	var planetarium: Planetarium = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var footprint := planetarium.clues.footprint
	assert_eq(planetarium.room(footprint.global_position), "dome")
	assert_false(footprint.visible, "with the lights on nobody sees it")
	assert_eq(footprint.photo_clues(), {}, "nor photographs it")
	cop.global_position = footprint.global_position
	footprint._physics_process(0.1)
	assert_false(footprint.wiped, "nor wipes it out")
	cop.global_position = Vector3(0, 0, 40)
	planetarium.set_dark(true)
	assert_true(footprint.visible, "in the dark it glows")
	assert_true(footprint.photo_clues().has(case.clue_line("footprint")))
	assert_string_contains(case.clue_line("footprint"), str(case.culprit().shoe))
	cop.global_position = footprint.global_position
	footprint._physics_process(0.1)
	assert_true(footprint.wiped, "stepped on in the dark, it's gone")
	assert_has(case.ruined, "footprint")


func test_the_ice_cream_turns_up_in_the_rocket_and_a_kid_eats_it_later() -> void:
	var made := _planetarium_case(_seed_with("bite"))
	var planetarium: Planetarium = made[0]
	var case: CrimeSceneCase = made[1]
	assert_null(planetarium.clues.ice_cream, "hidden until someone looks in the rocket")
	planetarium.searched("rocket", null)
	var ice_cream := planetarium.clues.ice_cream
	assert_not_null(ice_cream)
	assert_eq(planetarium.room(ice_cream.global_position), "kids")
	assert_true(ice_cream.is_food())
	case.at_tent = true
	planetarium.clues._physics_process(PlanetariumClues.POLISH_SECONDS + 1.0)
	assert_true(ice_cream.spoiled, "the school visit")
	assert_has(case.ruined, "bite")


func test_the_vacuum_and_the_polish_spoil_what_nobody_got() -> void:
	var seed_value := -1
	for s in range(1, 200):
		var plan := CrimePlan.draw(GuideTraits.draw(s), s, CrimeSceneCase.VARIANTS.planetarium.clues)
		if plan.clues.has("hair") and plan.clues.has("prints"):
			seed_value = s
			break
	var made := _planetarium_case(seed_value)
	var planetarium: Planetarium = made[0]
	var case: CrimeSceneCase = made[1]
	case.at_tent = true
	planetarium.clues._physics_process(PlanetariumClues.VACUUM_SECONDS + 0.1)
	assert_has(case.ruined, "hair", "the robot vacuum")
	assert_does_not_have(case.ruined, "prints")
	planetarium.clues._physics_process(PlanetariumClues.POLISH_SECONDS)
	assert_has(case.ruined, "prints", "Doctor Órbita's cloth")
	assert_eq(planetarium.director.said(), "DIRECTOR_POLISH")


func test_the_booth_photo_tells_the_planet_unless_covered() -> void:
	TranslationServer.set_locale("es")
	var made := _planetarium_case(_seed_with("booth"))
	var planetarium: Planetarium = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	assert_eq(planetarium.room(planetarium.booth_tray.global_position), "shop")
	assert_eq(planetarium.booth_tray.prompt_key(cop), "PROMPT_BOOTH_TRAY")
	planetarium.booth_tray.use(cop)
	assert_has(case.clues_found, "booth")
	var planet := tr("PLANET_" + str(case.culprit().planet))
	assert_string_contains(cop._hint.text, planet)
	assert_string_contains(case.clue_line("booth"), planet)
	var again := _planetarium_case(_seed_with("booth"))
	var other: Planetarium = again[0]
	other.booth.use(again[2])
	assert_eq((again[2] as Cop)._hint.text, "HINT_BOOTH_FLASH")
	assert_has((again[1] as CrimeSceneCase).ruined, "booth", "a new photo covers it")
	other.booth_tray.use(again[2])
	assert_eq((again[2] as Cop)._hint.text, "HINT_BOOTH_YOUR_FACE")


func test_the_glow_on_a_guide_is_a_clue() -> void:
	var made := _planetarium_case(_seed_with("glow"))
	var planetarium: Planetarium = made[0]
	var case: CrimeSceneCase = made[1]
	planetarium.set_dark(true)
	var clean := planetarium.guides.filter(func(g: PlanetariumGuide) -> bool: return not g.traits.glow)
	(clean[0] as PlanetariumGuide).look_at_gloves()
	assert_does_not_have(case.clues_found, "glow", "clean gloves say nothing")
	planetarium.guides[case.plan.culprit].look_at_gloves()
	assert_has(case.clues_found, "glow")
	for kind: String in CrimeSceneCase.VARIANTS.planetarium.clues:
		assert_ne(tr("CLUE_PLANETARIUM_RUINED_" + kind), "CLUE_PLANETARIUM_RUINED_" + kind, kind)
		assert_ne(tr("HINT_PLANETARIUM_RUINED_" + kind), "HINT_PLANETARIUM_RUINED_" + kind, kind)
