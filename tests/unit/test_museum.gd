extends GutTest

## The city's museum on its lot (escena-museo.md, step 1; Museum, MuseumLevel).

const LEVEL := preload("res://scenes/levels/museum.tscn")


func test_the_museum_has_its_lot_and_opens_from_play() -> void:
	assert_false(CityLayout.place("museum").is_empty())
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["museum"]))
	assert_eq(PlaceDraw.pick(5, PackedStringArray(["--place=museum"])), "museum")
	var lot: Vector3 = CityLayout.place("museum").size
	assert_eq(Vector2(lot.x, lot.z), Museum.SIZE, "the lot is the museum's size")


func test_the_museum_is_a_crime_scene_place_with_its_rooms() -> void:
	var museum := Museum.new()
	add_child_autofree(museum)
	assert_true(museum is CrimeScenePlace)
	assert_eq(museum.variant, "museum")
	assert_true(museum.at_scene(museum.to_global(Museum.STATUE_AT)), "the steps are at the scene")
	assert_false(museum.inside(museum.to_global(Museum.STATUE_AT)), "but out of the building")
	assert_true(museum.in_gallery(museum.to_global(Museum.EMPTY_FRAME_AT)), "the empty frame is in the gallery")
	for at in Museum.PEDESTALS:
		assert_true(museum.in_gallery(museum.to_global(at)), "%s in the gallery" % at)
	assert_true(museum.in_bathroom(museum.to_global(Museum.TOILET_AT)), "the toilet is in the bathroom")
	assert_true(museum.in_bathroom(museum.to_global(Museum.SINK_AT)), "and the sink")
	assert_false(museum.in_gallery(museum.to_global(Museum.TOILET_AT)))
	assert_false(museum.at_scene(museum.to_global(Vector3(0, 0, Museum.SIZE.y))), "the street is out")


func test_the_lockers_and_the_desk_are_in_their_rooms() -> void:
	for at in Museum.LOCKERS:
		assert_gt(at.x, Museum.HALL_X, "the lockers are east of the hall")
		assert_between(at.z, Museum.HALL_Z, Museum.FRONT_Z)
	assert_lt(Museum.DESK_AT.x, -Museum.HALL_X, "the desk is west of the hall")
	assert_between(Museum.DESK_AT.z, Museum.HALL_Z, Museum.FRONT_Z)
	for at in Museum.STORED:
		assert_lt(at.x, Museum.GALLERY_X, "the stored paintings are in the storage room")
		assert_lt(at.z, Museum.BATHROOM_Z)


## Walks a ray at knee height from one point to another of the museum and says whether nothing is in the way.
func _open(museum: Museum, from: Vector3, to: Vector3) -> bool:
	var space := museum.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(museum.to_global(from), museum.to_global(to))
	return space.intersect_ray(query).is_empty()


func test_the_doors_lead_from_the_street_to_every_room() -> void:
	var museum := Museum.new()
	add_child_autofree(museum)
	await wait_physics_frames(1)
	var knee := Vector3(0, 0.6, 0)
	var hall := Vector3(0, 0, 7) + knee
	assert_true(_open(museum, Vector3(0, 0, 12.5) + knee, hall), "in by the front door")
	assert_true(_open(museum, hall, Vector3(0, 0, 1) + knee), "into the gallery")
	assert_true(_open(museum, Vector3(-3, 0, Museum.DOOR_SIDE_Z) + knee, Vector3(-9, 0, Museum.DOOR_SIDE_Z) + knee),
		"into the security room")
	assert_true(_open(museum, Vector3(3, 0, Museum.DOOR_SIDE_Z) + knee, Vector3(9, 0, Museum.DOOR_SIDE_Z) + knee),
		"into the lockers")
	assert_true(_open(museum, Vector3(-6, 0, Museum.DOOR_STORAGE_Z) + knee,
		Vector3(-10, 0, Museum.DOOR_STORAGE_Z) + knee), "into the storage room")
	assert_true(_open(museum, Vector3(-6, 0, Museum.DOOR_BATHROOM_Z) + knee,
		Vector3(-9.5, 0, Museum.DOOR_BATHROOM_Z) + knee), "into the bathroom")
	assert_false(_open(museum, Vector3(-6, 0, -10) + knee, Vector3(-10, 0, -10) + knee), "the storage has a wall")
	assert_false(_open(museum, Vector3(-9.5, 0, 0.5) + knee, Vector3(-9.5, 0, 2) + knee),
		"and the bathroom is walled off from it")


func test_the_level_puts_the_museum_on_its_lot() -> void:
	var level: MuseumLevel = LEVEL.instantiate()
	level.case_seed = 4
	add_child_autofree(level)
	var lot := (level.get_node("City") as Node3D).transform * CityLayout.lot("museum")
	assert_almost_eq(level.museum.global_position, lot.origin, Vector3.ONE * 0.01)
	assert_eq(level.museum.case_seed, 4)
	TranslationServer.set_locale("es")
	assert_ne(tr("SIGN_MUSEUM"), "SIGN_MUSEUM")
