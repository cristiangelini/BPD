extends GutTest

## The Municipal Library on its lot (escena-biblioteca.md, step 1; Library, LibraryLevel).

const LEVEL := preload("res://scenes/levels/library.tscn")


func test_the_library_has_its_lot_and_opens_from_play() -> void:
	assert_false(CityLayout.place("library").is_empty())
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["library"]))
	assert_eq(PlaceDraw.pick(5, PackedStringArray(["--place=library"])), "library")
	var lot: Vector3 = CityLayout.place("library").size
	assert_eq(Vector2(lot.x, lot.z), Library.SIZE, "the lot is the library's size")


func test_the_library_is_a_crime_scene_place_with_its_rooms() -> void:
	var library := Library.new()
	add_child_autofree(library)
	assert_true(library is CrimeScenePlace)
	assert_eq(library.variant, "library")
	var at := func(local: Vector3) -> Vector3: return library.to_global(local)
	assert_true(library.at_scene(at.call(Library.STEPS_AT)), "the steps are at the scene")
	assert_false(library.inside(at.call(Library.STEPS_AT)), "but out of the building")
	for spot: Vector3 in [Library.CASE_AT, Library.ARMCHAIR_AT, Library.DESK_AT, Library.CATALOG_AT]:
		assert_eq(library.room(at.call(spot)), "reading", "%s is in the reading room" % spot)
	assert_eq(library.room(at.call(Library.LADDER_AT)), "stacks")
	assert_eq(library.room(at.call(Library.CUSHION_AT)), "children")
	assert_eq(library.room(at.call(Library.KID_AT)), "children")
	assert_eq(library.room(at.call(Library.CART_AT)), "storage")
	assert_false(library.at_scene(at.call(Vector3(0, 0, Library.SIZE.y))), "the street is out")


func test_eight_sections_with_their_letters() -> void:
	var library := Library.new()
	add_child_autofree(library)
	assert_eq(Library.SECTIONS.keys(), ["A", "B", "C", "D", "E", "F", "G", "H"])
	for letter: String in Library.SECTIONS:
		var shelf: Vector3 = Library.SECTIONS[letter]
		assert_eq(library.room(library.to_global(shelf)), "stacks", "%s is in the stacks" % letter)
		assert_eq(library.section(library.to_global(shelf + Vector3(-0.8, 0, 0))), letter, "in front of %s" % letter)
		assert_not_null(library.get_node_or_null("Section" + letter), "its letter over it")
	assert_eq(library.section(library.to_global(Library.CASE_AT)), "", "the display case is no section")


## Walks a ray at knee height from one point to another of the library and says whether nothing is in the way.
func _open(library: Library, from: Vector3, to: Vector3) -> bool:
	var space := library.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(library.to_global(from), library.to_global(to))
	return space.intersect_ray(query).is_empty()


func test_the_doors_lead_from_the_street_to_every_room() -> void:
	var library := Library.new()
	add_child_autofree(library)
	await wait_physics_frames(1)
	var knee := Vector3(0, 0.6, 0)
	assert_true(_open(library, Vector3(0, 0, 12.9) + knee, Vector3(0, 0, 0.5) + knee), "up the steps and in")
	assert_true(_open(library, Vector3(-3, 0, Library.DOOR_CHILDREN_Z) + knee,
		Vector3(-9, 0, Library.DOOR_CHILDREN_Z) + knee), "into the children's corner")
	assert_true(_open(library, Vector3(-3, 0, Library.DOOR_STORE_Z) + knee,
		Vector3(-11, 0, Library.DOOR_STORE_Z) + knee), "into the storeroom")
	assert_true(_open(library, Vector3(3, 0, 4.0) + knee, Vector3(14, 0, 4.0) + knee), "into the stacks")
	assert_false(_open(library, Vector3(-10, 0, 0) + knee, Vector3(-10, 0, -6) + knee), "the storeroom has a wall")


func test_the_level_puts_the_library_on_its_lot() -> void:
	var level: LibraryLevel = LEVEL.instantiate()
	level.case_seed = 4
	add_child_autofree(level)
	var lot := (level.get_node("City") as Node3D).transform * CityLayout.lot("library")
	assert_almost_eq(level.library.global_position, lot.origin, Vector3.ONE * 0.01)
	assert_eq(level.library.case_seed, 4)
	TranslationServer.set_locale("es")
	assert_eq(tr("PLACE_LIBRARY"), "Biblioteca Municipal")
