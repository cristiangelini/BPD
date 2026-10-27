extends GutTest

## The city's airport (politico-aeropuerto.md, step 1, decision 231): its block, the terminal and what's in it, the
## glass wall and the doors, and the X-ray screen.

const LEVEL := preload("res://scenes/levels/airport.tscn")

var airport: Airport


func before_each() -> void:
	airport = LEVEL.instantiate()
	airport.case_seed = 7
	(airport.get_node("Cop") as Cop).input_enabled = false
	add_child_autofree(airport)
	await wait_physics_frames(3)


func _ray(from: Vector3, to: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(airport.to_global(from), airport.to_global(to))
	query.collision_mask = 1
	return airport.get_world_3d().direct_space_state.intersect_ray(query)


func test_it_fills_block_6_4_and_play_opens_it() -> void:
	var lot := CityLayout.place("airport")
	assert_eq(lot.block, Vector2i(6, 4))
	assert_true(lot.get("park", false), "the whole block")
	assert_eq(PlaceDraw.PLACES.get("airport"), "res://scenes/levels/airport.tscn")


func test_the_terminal_has_its_counter_belt_xray_shop_gate_and_plane() -> void:
	var built := airport.get_node("Built")
	for name: String in ["Counter", "Xray", "Plane", "Screen"]:
		assert_not_null(built.get_node_or_null(name), name)
	assert_eq(built.find_children("Shelf*", "", false, false).size(), Airport.SHELVES.size())
	assert_eq(built.find_children("Seats*", "", false, false).size(), Airport.SEATS.size())
	assert_eq(airport.press.size(), 3, "the press in front of the screen")


func test_where_is_what() -> void:
	assert_true(airport.in_terminal(airport.to_global(Vector3(0, 1, 10))))
	assert_false(airport.in_terminal(airport.to_global(Vector3(0, 1, -10))), "the apron is outside")
	assert_true(airport.in_shop(airport.to_global(Vector3(-15, 1, 2))))
	assert_true(airport.at_gate(airport.to_global(Vector3(15, 1, 2))))
	assert_false(airport.at_gate(airport.to_global(Vector3(-15, 1, 2))))


func test_the_doors_are_open_and_the_glass_is_not() -> void:
	assert_true(_ray(Vector3(0, 1.5, Airport.FRONT_Z + 3), Vector3(0, 1.5, Airport.FRONT_Z - 3)).is_empty(),
		"in through the front doors")
	assert_false(_ray(Vector3(-10, 1.5, Airport.FRONT_Z + 3), Vector3(-10, 1.5, Airport.FRONT_Z - 3)).is_empty(),
		"a wall beside them")
	assert_false(_ray(Vector3(0, 2, Airport.BACK_Z + 2), Vector3(0, 2, Airport.BACK_Z - 2)).is_empty(),
		"the glass wall stops you")
	assert_true(_ray(Vector3(Airport.GATE_DOOR_X, 1.5, Airport.BACK_Z + 2), Vector3(Airport.GATE_DOOR_X, 1.5,
		Airport.BACK_Z - 2)).is_empty(), "out to the apron through the gate's door")


func test_the_screen_shows_the_inside_of_the_xray_machine() -> void:
	await wait_process_frames(2)
	var down := -airport.feed_camera.global_basis.z
	assert_almost_eq(down.y, -1.0, 0.01, "looking down onto the belt")
	var at := airport.to_local(airport.feed_camera.global_position)
	assert_almost_eq(Vector2(at.x, at.z), Vector2(Airport.XRAY_AT.x, Airport.XRAY_AT.z), Vector2(0.01, 0.01))
	assert_eq((airport.screen.material_override as StandardMaterial3D).albedo_texture, airport.feed.get_texture())


func test_the_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	for key: String in ["PLACE_AIRPORT", "AIRPORT_CHECKIN", "AIRPORT_XRAY", "AIRPORT_DUTY_FREE", "AIRPORT_GATE"]:
		assert_ne(tr(key), key, key)
