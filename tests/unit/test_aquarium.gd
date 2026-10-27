extends GutTest

## The Municipal Aquarium on its lot (escena-acuario.md, step 1; Aquarium, AquariumLevel).

const LEVEL := preload("res://scenes/levels/aquarium.tscn")


func test_the_aquarium_has_its_lot_and_opens_from_play() -> void:
	assert_false(CityLayout.place("aquarium").is_empty())
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["aquarium"]))
	assert_eq(PlaceDraw.pick(5, PackedStringArray(["--place=aquarium"])), "aquarium")
	var lot: Vector3 = CityLayout.place("aquarium").size
	assert_eq(Vector2(lot.x, lot.z), Aquarium.SIZE, "the lot is the aquarium's size")


func test_the_aquarium_is_a_crime_scene_place_with_its_rooms() -> void:
	var aquarium := Aquarium.new()
	add_child_autofree(aquarium)
	assert_true(aquarium is CrimeScenePlace)
	assert_eq(aquarium.variant, "aquarium")
	var at := func(local: Vector3) -> Vector3: return aquarium.to_global(local)
	assert_true(aquarium.at_scene(at.call(Aquarium.SQUARE_AT)), "the square is at the scene")
	assert_false(aquarium.inside(at.call(Aquarium.SQUARE_AT)), "but out of the building")
	for spot: Vector3 in [Aquarium.BIG_TANK_AT, Aquarium.BENCH_AT, Aquarium.INK_TANK_AT, Aquarium.IGLOO_AT]:
		assert_eq(aquarium.room(at.call(spot)), "hall", "%s is in the hall" % spot)
	assert_eq(aquarium.room(at.call(Aquarium.BASKET_AT)), "shop")
	assert_eq(aquarium.room(at.call(Aquarium.TILL_AT)), "shop")
	assert_eq(aquarium.room(at.call(Aquarium.BUCKET_AT)), "kitchen")
	assert_eq(aquarium.room(at.call(Aquarium.BOARD_AT)), "kitchen")
	assert_false(aquarium.at_scene(at.call(Vector3(0, 0, Aquarium.SIZE.y))), "the street is out")


func test_six_small_tanks_with_their_animals() -> void:
	var aquarium := Aquarium.new()
	add_child_autofree(aquarium)
	assert_eq(Aquarium.TANKS.keys(), ["sharks", "jellyfish", "seahorses", "turtles", "rays", "penguins"])
	for animal: String in Aquarium.TANKS:
		var spot: Vector3 = Aquarium.TANKS[animal]
		assert_eq(aquarium.room(aquarium.to_global(spot)), "hall", "%s is in the hall" % animal)
		var front := spot + Vector3(-signf(spot.x) * 1.8, 0, 0) if spot.x != 0 else spot + Vector3(0, 0, 2.2)
		assert_eq(aquarium.tank(aquarium.to_global(front)), animal, "in front of the %s" % animal)
		assert_not_null(aquarium.get_node_or_null("Tank" + animal.capitalize()), "its sign over it")
	assert_eq(aquarium.tank(aquarium.to_global(Aquarium.BIG_TANK_AT)), "", "the big tank is no small tank")
	assert_eq(aquarium.tank(aquarium.to_global(Aquarium.INK_TANK_AT)), "", "nor is Doña Tinta's")
	assert_not_null(aquarium.get_node_or_null("Clam"), "Doña Almeja is in the big tank")
	assert_not_null(aquarium.get_node_or_null("Igloo"), "and the igloo in the penguins' pool")


## Walks a ray at knee height from one point to another of the aquarium and says whether nothing is in the way.
func _open(aquarium: Aquarium, from: Vector3, to: Vector3) -> bool:
	var space := aquarium.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(aquarium.to_global(from), aquarium.to_global(to))
	return space.intersect_ray(query).is_empty()


func test_the_doors_lead_from_the_street_to_every_room() -> void:
	var aquarium := Aquarium.new()
	add_child_autofree(aquarium)
	await wait_physics_frames(1)
	var knee := Vector3(0, 0.6, 0)
	assert_true(_open(aquarium, Vector3(0, 0, 13.5) + knee, Vector3(0, 0, 2.5) + knee), "through the shark's mouth")
	assert_true(_open(aquarium, Vector3(-4, 0, Aquarium.DOOR_ROOMS_Z) + knee,
		Vector3(-9, 0, Aquarium.DOOR_ROOMS_Z) + knee), "into the gift shop")
	assert_true(_open(aquarium, Vector3(4, 0, Aquarium.DOOR_ROOMS_Z) + knee,
		Vector3(9, 0, Aquarium.DOOR_ROOMS_Z) + knee), "into the kitchen")
	assert_true(_open(aquarium, Vector3(-5, 0, 1) + knee, Vector3(-11, 0, -5.5) + knee), "to the jellyfish")
	assert_false(_open(aquarium, Vector3(-10, 0, 5) + knee, Vector3(-10, 0, 0) + knee), "the shop has a back wall")
	assert_false(_open(aquarium, Vector3(0, 0, 1) + knee, Vector3(0, 0, -7) + knee), "the big tank is solid glass")


func test_the_level_puts_the_aquarium_on_its_lot() -> void:
	var level: AquariumLevel = LEVEL.instantiate()
	level.case_seed = 4
	add_child_autofree(level)
	var lot := (level.get_node("City") as Node3D).transform * CityLayout.lot("aquarium")
	assert_almost_eq(level.aquarium.global_position, lot.origin, Vector3.ONE * 0.01)
	assert_eq(level.aquarium.case_seed, 4)
	TranslationServer.set_locale("es")
	assert_eq(tr("PLACE_AQUARIUM"), "Acuario Municipal")
