extends GutTest

## The library's noise (escena-biblioteca.md, step 5c): LibraryNoise goes up with what the cops do and down by itself;
## at 50 Doña Sigilo hushes whoever made the last noise, at 100 the lights go out, the readers swap places and Tomasito
## wakes up scared; and the armchair, where reading calms it down faster but loses the hair.

const COP_SCENE := preload("res://scenes/player/cop.tscn")


func _library_case(seed_value: int) -> Array:
	var library := Library.new()
	library.case_seed = seed_value
	add_child_autofree(library)
	var case := CrimeSceneCase.new()
	case.case_seed = seed_value
	case.place = library
	add_child_autofree(case)
	case.start()
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	cop.global_position = library.to_global(Vector3(0, 0.1, 0.5))
	return [library, case, cop]


func _seed_with(kind: String, has := true) -> int:
	for seed_value in range(1, 300):
		var readers := ReaderTraits.draw(seed_value)
		var plan := CrimePlan.draw(readers, seed_value, CrimeSceneCase.VARIANTS.library.clues)
		if plan.clues.has(kind) == has:
			return seed_value
	return -1


func test_noise_goes_up_with_shouts_and_searches_and_down_by_itself() -> void:
	var made := _library_case(3)
	var library: Library = made[0]
	var cop: Cop = made[2]
	var noise := library.noise
	library.shouted_by(cop)
	assert_eq(noise.level, LibraryNoise.SHOUT)
	library.search("section_B", cop)
	assert_eq(noise.level, LibraryNoise.SHOUT + LibraryNoise.SEARCH)
	library.search("cart", made[2])
	assert_eq(noise.level, LibraryNoise.SHOUT + LibraryNoise.SEARCH, "one search at a time, and the cart is quiet")
	cop.global_position = Vector3(0, 0, 60)
	library.shouted_by(cop)
	assert_eq(noise.level, LibraryNoise.SHOUT + LibraryNoise.SEARCH, "outside nobody minds")
	var before := noise.level
	await wait_seconds(1.0)
	assert_almost_eq(noise.level, before - LibraryNoise.DECAY_PER_SECOND, 0.2)


func test_at_fifty_dona_sigilo_hushes_the_last_one() -> void:
	var made := _library_case(3)
	var library: Library = made[0]
	var cop: Cop = made[2]
	var noise := library.noise
	noise.add(LibraryNoise.HUSH_AT, cop)
	assert_true(noise.is_hushed(cop))
	assert_eq(library.librarian.said(), "LIBRARIAN_SHHH")
	assert_lt(library.librarian.global_position.distance_to(cop.global_position), 1.0, "right in their face")
	assert_eq(cop._hint.text, "HINT_LIBRARY_HUSHED")
	noise.hushed[cop] = 0.01
	await wait_physics_frames(3)
	assert_false(noise.is_hushed(cop))
	assert_lt(library.librarian.position.distance_to(Library.LIBRARIAN_AT), 0.2, "back behind her desk")


func test_at_a_hundred_the_lights_go_out_and_the_readers_swap() -> void:
	var made := _library_case(_seed_with("witness"))
	var library: Library = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var seats := library.readers.map(func(r: LibraryReader) -> Vector3: return r.position)
	library.noise.add(LibraryNoise.BLACKOUT_AT, cop)
	assert_gt(library.noise.blackout_left, 0.0)
	assert_false(library.lamps.any(func(l: OmniLight3D) -> bool: return l.visible), "every light off")
	for i in library.readers.size():
		assert_ne(library.readers[i].position, seats[i], "reader %d moved" % i)
	assert_true(library.kid.scared)
	assert_has(case.ruined, "witness")
	assert_eq(library.kid.prompt_key(cop), "PROMPT_KID")
	library.noise.add(LibraryNoise.SHOUT, cop)
	assert_eq(library.noise.level, LibraryNoise.BLACKOUT_AT, "in the dark nothing counts")
	library.noise.lights_back()
	assert_eq(library.noise.level, 0.0)
	assert_true(library.lamps.all(func(l: OmniLight3D) -> bool: return l.visible))


func test_noise_stops_tomasitos_story() -> void:
	var made := _library_case(_seed_with("witness"))
	var library: Library = made[0]
	var cop: Cop = made[2]
	cop.global_position = library.kid.global_position + Vector3(0.8, 0, 0)
	library.kid.use(cop)
	library.noise.add(LibraryNoise.STORY_STOPS_AT - 5.0, cop)
	assert_true(library.kid.reading)
	library.noise.add(5.0, cop)
	assert_false(library.kid.reading)


func test_reading_in_the_armchair_calms_it_but_loses_the_hair() -> void:
	var made := _library_case(_seed_with("hair"))
	var library: Library = made[0]
	var case: CrimeSceneCase = made[1]
	var cop: Cop = made[2]
	var armchair: ReadingArmchair = library.get_node("Armchair")
	assert_eq(armchair.prompt_key(cop), "PROMPT_ARMCHAIR_READ")
	cop.global_position = library.to_global(Library.ARMCHAIR_AT + Vector3(0.9, 0.1, 0))
	library.noise.add(40.0, cop)
	armchair.use(cop)
	assert_has(case.ruined, "hair")
	await wait_seconds(1.0)
	assert_almost_eq(library.noise.level,
		40.0 - LibraryNoise.DECAY_PER_SECOND - LibraryNoise.READING_PER_SECOND, 0.3, "twice as fast")


func test_dark_inside_by_day_only_while_the_lights_are_out() -> void:
	var world := WorldEnvironment.new()
	world.environment = Environment.new()
	world.environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	world.environment.ambient_light_energy = 0.45
	add_child_autofree(world)
	var made := _library_case(3)
	var library: Library = made[0]
	var camera := Camera3D.new()
	add_child_autofree(camera)
	camera.global_position = library.to_global(Vector3(0, 1.6, 0))
	camera.make_current()
	library.noise.blackout()
	await wait_process_frames(2)
	assert_eq(world.environment.ambient_light_source, Environment.AMBIENT_SOURCE_COLOR, "dark inside")
	library.noise.lights_back()
	await wait_process_frames(2)
	assert_eq(world.environment.ambient_light_source, Environment.AMBIENT_SOURCE_SKY, "the sky's light is back")
	assert_almost_eq(world.environment.ambient_light_energy, 0.45, 0.001)
