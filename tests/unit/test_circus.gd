extends GutTest

## The Cascabel Brothers' circus on its lot in the city (escena-circo.md, step 2; Circus, CircusLevel).

const LEVEL := preload("res://scenes/levels/circus.tscn")


func test_the_circus_has_its_lot_and_opens_from_play() -> void:
	assert_false(CityLayout.place("circus").is_empty())
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["circus"]))
	assert_eq(PlaceDraw.pick(5, PackedStringArray(["--place=circus"])), "circus")


func test_the_circus_is_a_crime_scene_place() -> void:
	var circus := Circus.new()
	add_child_autofree(circus)
	assert_true(circus is CrimeScenePlace)
	assert_eq(circus.variant, "circus")
	assert_true(circus.at_scene(circus.to_global(Vector3(0, 0, 0))))
	assert_true(circus.in_tent(circus.to_global(Circus.TENT_AT)), "the ring is in the tent")
	assert_false(circus.in_tent(circus.to_global(Circus.CARAVANS[0])), "the caravans are behind it")
	assert_false(circus.in_tent(circus.to_global(Circus.POOL_AT)), "and the pool beside it")
	assert_false(circus.at_scene(circus.to_global(Vector3(0, 0, Circus.SIZE.y))), "the street is out")


func test_the_caravans_the_pool_and_the_trunk_fit_in_the_lot_out_of_the_tent() -> void:
	var half := Circus.SIZE / 2
	var spots: Array[Vector3] = Circus.CARAVANS.duplicate()
	spots.append_array([Circus.POOL_AT, Circus.TRUNK_AT])
	for at in spots:
		assert_lt(absf(at.x), half.x, "%s inside the lot" % at)
		assert_lt(absf(at.z), half.y, "%s inside the lot" % at)
		assert_gt(Vector2(at.x - Circus.TENT_AT.x, at.z - Circus.TENT_AT.z).length(), Circus.TENT_RADIUS,
			"%s out of the tent" % at)
	var lot: Vector3 = CityLayout.place("circus").size
	assert_eq(Vector2(lot.x, lot.z), Circus.SIZE, "the lot is the circus's size")


func test_the_tent_opens_at_the_front_and_the_ring_has_its_gap() -> void:
	var circus := Circus.new()
	add_child_autofree(circus)
	await wait_physics_frames(1)
	var space := circus.get_world_3d().direct_space_state
	# Walking in from the street to the ring's middle, at knee height, nothing is in the way.
	var from := circus.to_global(Circus.TENT_AT + Vector3(0, 0.3, Circus.TENT_RADIUS + 2))
	var to := circus.to_global(Circus.TENT_AT + Vector3(0, 0.3, 0))
	var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
	assert_true(hit.is_empty(), "the way in is open")
	# From the side, the wall stops you.
	from = circus.to_global(Circus.TENT_AT + Vector3(Circus.TENT_RADIUS + 2, 1.0, 0))
	to = circus.to_global(Circus.TENT_AT + Vector3(0, 1.0, 0))
	assert_false(space.intersect_ray(PhysicsRayQueryParameters3D.create(from, to)).is_empty(), "the side is walled")


func test_the_level_puts_the_circus_on_its_lot() -> void:
	var level: CircusLevel = LEVEL.instantiate()
	level.case_seed = 4
	add_child_autofree(level)
	var lot := (level.get_node("City") as Node3D).transform * CityLayout.lot("circus")
	assert_almost_eq(level.circus.global_position, lot.origin, Vector3.ONE * 0.01)
	assert_eq(level.circus.case_seed, 4)
	TranslationServer.set_locale("es")
	assert_ne(tr("SIGN_CIRCUS"), "SIGN_CIRCUS")
