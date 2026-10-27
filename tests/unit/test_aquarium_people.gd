extends GutTest

## The aquarium's people (escena-acuario.md, step 2): the six divers alike, Don Anzuelo, Bigotes and Doña Tinta
## (DiverTraits, AquariumDiver, AquariumKeeper, SeaLion, AquariumOctopus).


func test_the_six_divers_are_drawn_with_the_seed() -> void:
	var divers := DiverTraits.draw(11)
	assert_eq(divers.size(), DiverTraits.COUNT)
	assert_eq(DiverTraits.draw(11), divers, "same seed, same divers")
	var looks := {}
	var tanks := {}
	var inked := 0
	for diver in divers:
		looks[DiverTraits.signature(diver)] = true
		tanks[diver.tank] = true
		inked += 1 if diver.ink else 0
	assert_eq(looks.size(), DiverTraits.COUNT, "no two look the same")
	assert_eq(tanks.size(), DiverTraits.TANKS.size(), "each looks after another tank")
	assert_eq(DiverTraits.TANKS, Aquarium.TANKS.keys(), "the tanks of the aquarium")
	assert_between(inked, DiverTraits.INKED.x, DiverTraits.INKED.y, "two or three have ink")


func test_the_people_are_in_the_hall() -> void:
	var aquarium := Aquarium.new()
	aquarium.case_seed = 4
	add_child_autofree(aquarium)
	assert_eq(aquarium.divers.size(), DiverTraits.COUNT)
	for diver in aquarium.divers:
		assert_eq(aquarium.room(diver.global_position), "hall", "%s is in the hall" % diver.traits.name)
		var to_tank := aquarium.to_global(Aquarium.BIG_TANK_AT) - diver.global_position
		assert_gt(diver.global_basis.z.dot(to_tank.normalized()), 0.9, "facing the big tank (the model faces +Z)")
	assert_eq(aquarium.suspect(2), aquarium.divers[2])
	assert_null(aquarium.suspect(DiverTraits.COUNT))
	assert_eq(aquarium.room(aquarium.keeper.global_position), "hall", "Don Anzuelo by the penguins")
	assert_eq(aquarium.room(aquarium.sea_lion.global_position), "hall", "Bigotes loose in the hall")
	assert_almost_eq(aquarium.to_local(aquarium.octopus.global_position), Aquarium.INK_TANK_AT + Vector3(0, 0.4, 0),
		Vector3.ONE * 0.01, "Doña Tinta in her tank")


func test_a_diver_shows_their_own_traits() -> void:
	var aquarium := Aquarium.new()
	aquarium.case_seed = 9
	add_child_autofree(aquarium)
	for diver in aquarium.divers:
		assert_eq(diver.part("glasses").visible, diver.traits.glasses)
		assert_false(diver.part("teeth").visible, "teeth only when they bite")
		assert_false(diver.part("ink_left").visible, "the ink only with the glove off")
		assert_true(diver.part("hood").visible)
		assert_true(diver.part("glove_right").visible)


func test_a_diver_tells_their_tank() -> void:
	var aquarium := Aquarium.new()
	aquarium.case_seed = 2
	add_child_autofree(aquarium)
	TranslationServer.set_locale("es")
	var diver: AquariumDiver = aquarium.divers[0]
	diver.use(null)
	assert_string_contains(diver.said(), diver.tank_name())
	diver.talk()
	assert_string_contains(diver.said(), diver.tank_name(), "every line says the tank")
	aquarium.keeper.use(null)
	assert_eq(aquarium.keeper.said(), "KEEPER_LINE_0")
	aquarium.sea_lion.use(null)
	assert_eq(aquarium.sea_lion.said(), "SEA_LION_LINE_0")
	aquarium.octopus.use(null)
	assert_eq(aquarium.octopus.said(), "OCTOPUS_LINE_0")


func test_bigotes_waddles_round_the_big_tank() -> void:
	var aquarium := Aquarium.new()
	add_child_autofree(aquarium)
	var start := aquarium.sea_lion.position
	await wait_physics_frames(30)
	var moved := aquarium.sea_lion.position - start
	assert_gt(moved.length(), 0.3, "he moves")
	assert_almost_eq(moved.x, 0.0, 0.01, "along his loop, down the west side first")
	assert_lt(moved.z, 0.0)
	assert_not_null(aquarium.sea_lion.nose(), "with a nose to balance things on")
	aquarium.sea_lion.waddling = false
	var stopped := aquarium.sea_lion.position
	await wait_physics_frames(10)
	assert_eq(aquarium.sea_lion.position, stopped, "and stays put when he stops")


func test_the_glass_of_dona_tintas_tank_is_her() -> void:
	var aquarium := Aquarium.new()
	add_child_autofree(aquarium)
	await wait_physics_frames(1)
	var space := aquarium.get_world_3d().direct_space_state
	var from := aquarium.to_global(Aquarium.INK_TANK_AT + Vector3(-3.0, 1.4, 0))
	var to := aquarium.to_global(Aquarium.INK_TANK_AT + Vector3(0, 1.4, 0))
	var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
	assert_eq(hit.get("collider"), aquarium.octopus, "E on the glass is E on her")
