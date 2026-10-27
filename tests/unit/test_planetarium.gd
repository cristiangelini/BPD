extends GutTest

## The Municipal Planetarium on its lot (escena-planetario.md, step 1; Planetarium, PlanetariumLevel).

const LEVEL := preload("res://scenes/levels/planetarium.tscn")


func test_the_planetarium_has_its_lot_and_opens_from_play() -> void:
	assert_false(CityLayout.place("planetarium").is_empty())
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["planetarium"]))
	assert_eq(PlaceDraw.pick(5, PackedStringArray(["--place=planetarium"])), "planetarium")
	var lot: Vector3 = CityLayout.place("planetarium").size
	assert_eq(Vector2(lot.x, lot.z), Planetarium.SIZE, "the lot is the planetarium's size")


func test_the_planetarium_is_a_crime_scene_place_with_its_rooms() -> void:
	var planetarium := Planetarium.new()
	add_child_autofree(planetarium)
	assert_true(planetarium is CrimeScenePlace)
	assert_eq(planetarium.variant, "planetarium")
	var at := func(local: Vector3) -> Vector3: return planetarium.to_global(local)
	assert_true(planetarium.at_scene(at.call(Planetarium.SQUARE_AT)), "the square is at the scene")
	assert_false(planetarium.inside(at.call(Planetarium.SQUARE_AT)), "but out of the building")
	assert_eq(planetarium.room(at.call(Planetarium.CASE_AT)), "hall")
	assert_eq(planetarium.room(at.call(Planetarium.SATURN_AT)), "hall")
	assert_eq(planetarium.room(at.call(Planetarium.BASKET_AT)), "shop")
	assert_eq(planetarium.room(at.call(Planetarium.BOOTH_AT)), "shop")
	assert_eq(planetarium.room(at.call(Planetarium.ROCKET_AT)), "kids")
	assert_eq(planetarium.room(at.call(Planetarium.PROJECTOR_AT)), "dome")
	assert_eq(planetarium.room(at.call(Planetarium.CONSOLE_AT)), "control")
	assert_false(planetarium.at_scene(at.call(Vector3(0, 0, Planetarium.SIZE.y))), "the street is out")


func test_the_ring_of_seats_faces_the_projector_and_six_have_a_planet() -> void:
	var planetarium := Planetarium.new()
	add_child_autofree(planetarium)
	assert_eq(Planetarium.PLANET_SEATS.size(), 6)
	for i in Planetarium.SEATS:
		var seat := planetarium.get_node("Seat%d" % i) as Node3D
		assert_eq(planetarium.room(seat.global_position), "dome", "seat %d is in the dome room" % i)
		var ahead := seat.basis.z
		var to_projector := (Planetarium.PROJECTOR_AT - seat.position).normalized()
		assert_gt(ahead.dot(to_projector), 0.9, "seat %d faces the projector" % i)
		var has_planet := Planetarium.PLANET_SEATS.values().has(i)
		assert_eq(seat.get_node_or_null("Planet") != null, has_planet, "seat %d's planet" % i)
	assert_not_null(planetarium.get_node_or_null("Saturn"), "the giant Saturn hangs in the hall")
	assert_not_null(planetarium.get_node_or_null("Projector"))
	assert_not_null(planetarium.get_node_or_null("Dome"), "and the dome is on the roof")


## Walks a ray at knee height from one point to another of the planetarium and says whether nothing is in the way.
func _open(planetarium: Planetarium, from: Vector3, to: Vector3) -> bool:
	var space := planetarium.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(planetarium.to_global(from), planetarium.to_global(to))
	return space.intersect_ray(query).is_empty()


func test_the_doors_lead_from_the_street_to_every_room() -> void:
	var planetarium := Planetarium.new()
	add_child_autofree(planetarium)
	await wait_physics_frames(1)
	var knee := Vector3(0, 0.6, 0)
	assert_true(_open(planetarium, Vector3(0, 0, 13.5) + knee, Vector3(0, 0, 5.0) + knee), "through the front door")
	assert_true(_open(planetarium, Vector3(-4, 0, Planetarium.DOOR_ROOMS_Z) + knee,
		Vector3(-9, 0, Planetarium.DOOR_ROOMS_Z) + knee), "into the shop")
	assert_true(_open(planetarium, Vector3(4, 0, Planetarium.DOOR_ROOMS_Z) + knee,
		Vector3(9, 0, Planetarium.DOOR_ROOMS_Z) + knee), "into the kids' corner")
	assert_true(_open(planetarium, Vector3(0, 0, 1.5) + knee, Vector3(0, 0, -1.0) + knee), "into the dome room")
	assert_true(_open(planetarium, Vector3(7, 0, Planetarium.DOOR_CONTROL_Z) + knee,
		Vector3(11, 0, Planetarium.DOOR_CONTROL_Z) + knee), "into the control room")
	assert_false(_open(planetarium, Vector3(-10, 0, 1.5) + knee, Vector3(-10, 0, -2.0) + knee),
		"the shop has a back wall")


func test_the_level_puts_the_planetarium_on_its_lot() -> void:
	var level: PlanetariumLevel = LEVEL.instantiate()
	level.case_seed = 4
	add_child_autofree(level)
	var lot := (level.get_node("City") as Node3D).transform * CityLayout.lot("planetarium")
	assert_almost_eq(level.planetarium.global_position, lot.origin, Vector3.ONE * 0.01)
	assert_eq(level.planetarium.case_seed, 4)
	TranslationServer.set_locale("es")
	assert_eq(tr("PLACE_PLANETARIUM"), "Planetario Municipal")
