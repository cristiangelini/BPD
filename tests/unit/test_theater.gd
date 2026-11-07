extends GutTest

## The Teatro Municipal on its lot (escena-teatro.md, step 1; Theater, TheaterLevel).

const LEVEL := preload("res://scenes/levels/theater.tscn")


func test_the_theater_has_its_lot_and_opens_from_play() -> void:
	assert_false(CityLayout.place("theater").is_empty())
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["theater"]))
	assert_eq(PlaceDraw.pick(5, PackedStringArray(["--place=theater"])), "theater")
	var lot: Vector3 = CityLayout.place("theater").size
	assert_eq(Vector2(lot.x, lot.z), Theater.SIZE, "the lot is the theater's size")


func test_the_theater_is_a_crime_scene_place_with_its_rooms() -> void:
	var theater := Theater.new()
	add_child_autofree(theater)
	assert_true(theater is CrimeScenePlace)
	assert_eq(theater.variant, "theater")
	var at := func(local: Vector3) -> Vector3: return theater.to_global(local)
	assert_true(theater.at_scene(at.call(Theater.SIDEWALK_AT)), "the sidewalk is at the scene")
	assert_false(theater.inside(at.call(Theater.SIDEWALK_AT)), "but out of the building")
	assert_eq(theater.room(at.call(Theater.MASK_CASE_AT)), "foyer")
	assert_eq(theater.room(at.call(Theater.BOOTH_AT)), "foyer")
	assert_eq(theater.room(at.call(Theater.FRONT_ROW_AT)), "hall")
	assert_eq(theater.room(at.call(Theater.TUBA_AT)), "hall", "the pit is in the hall")
	assert_eq(theater.room(at.call(Theater.BOX_SEAT_AT)), "hall", "and so are the boxes")
	assert_eq(theater.room(at.call(Theater.TURNTABLE_AT)), "stage")
	assert_eq(theater.room(at.call(Theater.PROMPTER_AT + Vector3(0, 0, -0.2))), "stage")
	for trap: Vector3 in Theater.TRAPDOORS:
		assert_eq(theater.room(at.call(trap)), "stage")
		assert_eq(theater.room(at.call(Vector3(trap.x, Theater.BASEMENT_TOP, trap.z))), "basement")
	for i in Theater.EMBROIDERIES.size():
		assert_eq(theater.room(at.call(Theater.dressing_at(i))), "dressing", "dressing room %d" % i)
	assert_eq(theater.room(at.call(Theater.PROPS_DESK_AT)), "workshop")
	assert_eq(theater.room(at.call(Vector3(-15.5, Theater.STAGE_TOP, -12.0))), "backstage")
	assert_false(theater.at_scene(at.call(Vector3(0, 0, Theater.SIZE.y))), "the street is out")


func test_the_stage_has_its_trapdoors_turntable_and_dressing_rooms() -> void:
	var theater := Theater.new()
	add_child_autofree(theater)
	assert_eq(theater.trapdoors.size(), 4)
	for i in theater.trapdoors.size():
		assert_almost_eq(theater.trapdoors[i].position.x, Theater.TRAPDOORS[i].x, 0.01, "trapdoor %d" % i)
		assert_lt(theater.trapdoors[i].position.y, Theater.STAGE_TOP, "trapdoor %d is flush with the stage" % i)
	assert_not_null(theater.get_node_or_null("Turntable"))
	assert_not_null(theater.get_node_or_null("MaskCase"), "the empty case is in the foyer")
	for i in Theater.EMBROIDERIES.size():
		var sign := theater.get_node("Dressing%d" % i) as Label3D
		assert_eq(sign.text, "SIGN_DRESSING_%s" % Theater.EMBROIDERIES[i].to_upper())
		TranslationServer.set_locale("es")
		assert_ne(tr(sign.text), sign.text, "dressing room %d has its text" % i)


## Walks a ray from one point to another of the theater and says whether nothing is in the way.
func _open(theater: Theater, from: Vector3, to: Vector3) -> bool:
	var space := theater.get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(theater.to_global(from), theater.to_global(to))
	return space.intersect_ray(query).is_empty()


func test_the_doors_lead_from_the_street_to_the_stage_and_down() -> void:
	var theater := Theater.new()
	add_child_autofree(theater)
	await wait_physics_frames(1)
	var knee := Vector3(0, 0.6, 0)
	var above_stage := Vector3(0, Theater.STAGE_TOP + 0.6, 0)
	assert_true(_open(theater, Theater.SIDEWALK_AT + knee, Vector3(0, 0, 6.8) + knee), "through the front door")
	for x: float in Theater.DOORS_HALL_X:
		assert_true(_open(theater, Vector3(x, 0, 5.0) + knee, Vector3(x, 0, 3.0) + knee), "into the hall at %s" % x)
	assert_false(_open(theater, Vector3(0, 0, 5.0) + knee, Vector3(0, 0, 3.0) + knee), "a wall between the doors")
	assert_true(_open(theater, Vector3(-3, 0, Theater.PIT_RAIL_Z - 0.3) + knee,
		Vector3(-3, 0, Theater.STAGE_Z + 0.3) + knee), "the pit is open below the stage's edge")
	for i in Theater.EMBROIDERIES.size():
		var door := Theater.dressing_at(i)
		assert_true(_open(theater, Vector3(door.x, 0, -12.0) + above_stage,
			Vector3(door.x, 0, -13.5) + above_stage), "into dressing room %d" % i)
	assert_true(_open(theater, Vector3(4.0, 0, Theater.DOOR_WORKSHOP_Z) + above_stage,
		Vector3(6.5, 0, Theater.DOOR_WORKSHOP_Z) + above_stage), "into the workshop")
	var hole := Theater.TRAPDOORS[0]
	assert_false(_open(theater, hole + Vector3(0, 1.0, 0), hole + Vector3(0, -1.0, 0)), "the trapdoor is closed")
	theater.trapdoors[0].queue_free()
	await wait_physics_frames(2)
	assert_true(_open(theater, hole + Vector3(0, 1.0, 0), hole + Vector3(0, -1.0, 0)),
		"and without it there is a hole down to the basement")


func test_the_level_puts_the_theater_on_its_lot() -> void:
	var level: TheaterLevel = LEVEL.instantiate()
	level.case_seed = 4
	add_child_autofree(level)
	var lot := (level.get_node("City") as Node3D).transform * CityLayout.lot("theater")
	assert_almost_eq(level.theater.global_position, lot.origin, Vector3.ONE * 0.01)
	assert_eq(level.theater.case_seed, 4)
	await wait_physics_frames(1)
	var space := level.get_world_3d().direct_space_state
	var trap := level.theater.to_global(Theater.TRAPDOORS[0])
	var down := level.theater.to_global(Vector3(Theater.TRAPDOORS[0].x, Theater.BASEMENT_TOP + 0.3, Theater.TRAPDOORS[0].z))
	level.theater.trapdoors[0].queue_free()
	await wait_physics_frames(2)
	assert_true(space.intersect_ray(PhysicsRayQueryParameters3D.create(trap + Vector3.UP, down)).is_empty(),
		"no city ground under the stage: the trapdoor drops all the way to the basement")
	var floor := space.intersect_ray(PhysicsRayQueryParameters3D.create(down, down + Vector3.DOWN))
	assert_false(floor.is_empty(), "and the basement has its floor")
	var street := level.theater.to_global(Theater.SIDEWALK_AT)
	assert_false(space.intersect_ray(PhysicsRayQueryParameters3D.create(street + Vector3.UP, street + Vector3.DOWN))
		.is_empty(), "the sidewalk still has its ground")
	TranslationServer.set_locale("es")
	assert_eq(tr("PLACE_THEATER"), "Teatro Municipal")
