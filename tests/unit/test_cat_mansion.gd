extends GutTest

## The Monedero mansion on its lot (escena-gato.md, step 1; CatMansion, CatMansionLevel).

const LEVEL := preload("res://scenes/levels/cat_mansion.tscn")


func test_the_mansion_has_its_lot_and_opens_from_play() -> void:
	assert_false(CityLayout.place("cat_mansion").is_empty())
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["cat_mansion"]))
	assert_eq(PlaceDraw.pick(5, PackedStringArray(["--place=cat_mansion"])), "cat_mansion")
	var lot: Vector3 = CityLayout.place("cat_mansion").size
	assert_eq(Vector2(lot.x, lot.z), CatMansion.SIZE, "the lot is the mansion's size")


func test_the_mansion_is_a_crime_scene_place_with_its_rooms() -> void:
	var mansion := CatMansion.new()
	add_child_autofree(mansion)
	assert_true(mansion is CrimeScenePlace)
	assert_eq(mansion.variant, "cat")
	var at := func(local: Vector3) -> Vector3: return mansion.to_global(local)
	assert_true(mansion.at_scene(at.call(CatMansion.FOUNTAIN_AT)), "the garden is at the scene")
	assert_false(mansion.inside(at.call(CatMansion.FOUNTAIN_AT)), "but out of the house")
	assert_eq(mansion.room(at.call(CatMansion.CRATE_AT)), "hall")
	assert_eq(mansion.room(at.call(CatMansion.STAIRS_AT)), "hall")
	assert_eq(mansion.room(at.call(CatMansion.FRIDGE_AT)), "kitchen")
	assert_eq(mansion.room(at.call(CatMansion.BISCUITS_AT)), "kitchen")
	assert_eq(mansion.room(at.call(CatMansion.TEAPOT_AT)), "kitchen")
	assert_eq(mansion.room(at.call(CatMansion.LITTER_AT)), "laundry")
	assert_eq(mansion.room(at.call(CatMansion.BASKET_AT)), "laundry")
	assert_eq(mansion.room(at.call(CatMansion.ARMCHAIR_AT)), "drawing")
	assert_eq(mansion.room(at.call(CatMansion.MUSIC_BOX_AT)), "drawing")
	assert_eq(mansion.room(at.call(CatMansion.CAGE_AT)), "drawing")
	for suitcase in CatMansion.SUITCASES:
		assert_eq(mansion.room(at.call(suitcase)), "guest", "the suitcases are in the guest room")
	assert_eq(mansion.room(at.call(CatMansion.FOUNTAIN_AT)), "", "the garden is no room")
	assert_false(mansion.at_scene(at.call(Vector3(0, 0, CatMansion.SIZE.y))), "the street is out")


func test_eight_vases_and_six_suitcases() -> void:
	assert_eq(CatMansion.VASES.size(), 8)
	assert_eq(CatMansion.SUITCASES.size(), 6, "one per nephew")
	for vase in CatMansion.VASES:
		assert_lt(absf(vase.x), CatMansion.HALF_X, "%s is in the house" % vase)
		assert_between(vase.z, CatMansion.BACK_Z, CatMansion.FRONT_Z)


## Walks a ray at knee height from one point to another of the mansion and says whether nothing is in the way.
func _open(mansion: CatMansion, from: Vector3, to: Vector3) -> bool:
	var space := mansion.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(mansion.to_global(from), mansion.to_global(to))
	return space.intersect_ray(query).is_empty()


func test_the_doors_lead_from_the_street_to_every_room() -> void:
	var mansion := CatMansion.new()
	add_child_autofree(mansion)
	await wait_physics_frames(1)
	var knee := Vector3(0, 0.6, 0)
	var side := CatMansion.DOOR_SIDE_Z
	assert_true(_open(mansion, Vector3(0, 0, 12.9) + knee, Vector3(0, 0, 2) + knee), "through the gate and the door")
	assert_true(_open(mansion, Vector3(-2, 0, side) + knee, Vector3(-8, 0, side) + knee), "into the kitchen")
	assert_true(_open(mansion, Vector3(2, 0, side) + knee, Vector3(8, 0, side) + knee), "into the drawing room")
	assert_true(_open(mansion, Vector3(0, 0, 0.5) + knee, Vector3(0, 0, -5) + knee), "into the guest room")
	var laundry := CatMansion.DOOR_LAUNDRY_X
	assert_true(_open(mansion, Vector3(laundry, 0, 0) + knee, Vector3(laundry, 0, -6) + knee), "into the laundry")
	assert_false(_open(mansion, Vector3(-8, 0, 0) + knee, Vector3(-8, 0, -6) + knee), "the laundry has a wall")
	assert_false(_open(mansion, Vector3(8, 0, 12.9) + knee, Vector3(8, 0, 10) + knee), "the railings close the garden")


func test_the_level_puts_the_mansion_on_its_lot() -> void:
	var level: CatMansionLevel = LEVEL.instantiate()
	level.case_seed = 4
	add_child_autofree(level)
	var lot := (level.get_node("City") as Node3D).transform * CityLayout.lot("cat_mansion")
	assert_almost_eq(level.mansion.global_position, lot.origin, Vector3.ONE * 0.01)
	assert_eq(level.mansion.case_seed, 4)
	TranslationServer.set_locale("es")
	assert_eq(tr("SIGN_CAT_MANSION"), "Casona Monedero")
