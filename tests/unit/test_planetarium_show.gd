extends GutTest

## The star show (escena-planetario.md, step 5): every two minutes at the scene the lights go out for a while, the glow
## paint shows and the guides swap places; a flashlight stops it and costs Doctor Órbita's patience, and at 0 he throws
## the cops out of the dome room (StarShow).

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
	cop.global_position = planetarium.to_global(Vector3(0, 0.1, 5.5))
	return [planetarium, case, cop]


func test_the_show_comes_every_two_minutes_at_the_scene() -> void:
	var made := _planetarium_case(3)
	var planetarium: Planetarium = made[0]
	var case: CrimeSceneCase = made[1]
	var show := planetarium.star_show
	show.set_physics_process(false)
	show.tick(StarShow.EVERY + 1.0)
	assert_false(show.is_on(), "not before the cops get there")
	case.at_tent = true
	show.tick(StarShow.EVERY - 1.0)
	assert_false(show.is_on())
	show.tick(1.5)
	assert_true(show.is_on(), "two minutes at the scene: lights out")
	assert_false(planetarium.lamps.any(func(lamp: OmniLight3D) -> bool: return lamp.visible), "every lamp off")
	var culprit := planetarium.guides[case.plan.culprit]
	assert_true(culprit.in_dark and culprit.part("glow_left").visible, "the culprit's gloves glow")
	var before: Array[Vector3] = []
	for guide in planetarium.guides:
		before.append(guide.position)
	show.tick(StarShow.DARK_SECONDS + 0.1)
	assert_false(show.is_on(), "thirty seconds later the lights come back")
	assert_true(planetarium.lamps.all(func(lamp: OmniLight3D) -> bool: return lamp.visible))
	assert_false(culprit.part("glow_left").visible, "and the glow fades")
	for i in planetarium.guides.size():
		assert_ne(planetarium.guides[i].position, before[i], "%s moved in the dark" % planetarium.guides[i].traits.name)
		assert_has(before, planetarium.guides[i].position, "to another guide's spot")
	assert_almost_eq(show.until_show, StarShow.EVERY, 0.01, "the next one in two minutes")


func test_a_flashlight_stops_the_show_and_costs_patience() -> void:
	var made := _planetarium_case(4)
	var planetarium: Planetarium = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var show := planetarium.star_show
	show.set_physics_process(false)
	case.at_tent = true
	cop.belt.flashlight.toggle()
	show.tick(1.0)
	assert_eq(show.patience, StarShow.PATIENCE, "a flashlight with the lights on is fine")
	show.start_show()
	show.tick(0.1)
	assert_false(show.is_on(), "the flashlight stops the show")
	assert_true(planetarium.lamps.all(func(lamp: OmniLight3D) -> bool: return lamp.visible))
	assert_eq(show.patience, StarShow.PATIENCE - StarShow.FLASHLIGHT_PATIENCE)
	assert_almost_eq(show.until_show, StarShow.EVERY, 0.01, "and it starts over")
	assert_eq(cop._hint.text, "HINT_SHOW_STOPPED")
	assert_eq(planetarium.director.said(), "DIRECTOR_FLASHLIGHT")


func test_out_of_patience_he_throws_the_cops_out_of_the_dome() -> void:
	var made := _planetarium_case(5)
	var planetarium: Planetarium = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var show := planetarium.star_show
	show.set_physics_process(false)
	case.at_tent = true
	show.patience = StarShow.FLASHLIGHT_PATIENCE
	cop.belt.flashlight.toggle()
	show.start_show()
	show.tick(0.1)
	assert_true(show.banned, "patience 0: banned")
	assert_eq(planetarium.director.said(), "DIRECTOR_BANNED")
	cop.global_position = planetarium.to_global(Planetarium.PROJECTOR_AT + Vector3(2, 0.1, 0))
	assert_eq(planetarium.room(cop.global_position), "dome")
	show.tick(0.1)
	assert_eq(planetarium.room(cop.global_position), "hall", "thrown out to the hall")
	assert_eq(cop._hint.text, "HINT_DOME_BANNED")
	for key in ["HUD_ORBITA_PATIENCE", "HUD_NEXT_SHOW", "DIRECTOR_SHOW_STARTS", "HINT_SHOW_ENDS", "HINT_DOME_BANNED"]:
		assert_ne(tr(key), key, "%s is translated" % key)
