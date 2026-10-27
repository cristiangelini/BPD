extends GutTest

## The Candelabro mansion on its own level (escena-mansion.md, step 1; Mansion, MansionLevel, MansionStorm).

const LEVEL := preload("res://scenes/levels/mansion.tscn")


func test_the_mansion_opens_from_play_with_the_cops_at_its_door() -> void:
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["mansion"]))
	assert_eq(PlaceDraw.pick(5, PackedStringArray(["--place=mansion"])), "mansion")
	var level: MansionLevel = LEVEL.instantiate()
	level.case_seed = 3
	level.get_node("Cop").input_enabled = false
	level.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(5)
	var mansion := level.mansion
	assert_true(mansion is CrimeScenePlace)
	assert_eq(mansion.variant, "mansion")
	var cop: Node3D = level.get_node("Cop")
	assert_true(mansion.at_scene(cop.global_position), "the cops start at the scene")
	assert_false(mansion.inside(cop.global_position), "outside, by the front door")
	assert_true(mansion.at_scene(level.get_node("PatrolCar").global_position), "the car is on the drive")
	assert_gt(cop.global_position.y, -0.5, "standing on the ground")


func test_every_room_and_thing_is_where_it_goes() -> void:
	var mansion := Mansion.new()
	add_child_autofree(mansion)
	var expected := {
		"hall": [Mansion.CLOCK_AT, Mansion.ARMOUR_AT, Mansion.COAT_RACK_AT, Mansion.STAIRS_AT],
		"dining": [Mansion.TABLE_AT], "lounge": [Mansion.PIANO_AT, Mansion.FIREPLACE_AT, Mansion.CAGE_AT],
		"library": [Mansion.BOOKCASE_AT, Mansion.ARMCHAIR_AT, Mansion.LIBRARY_FIRE_AT],
		"study": [Mansion.SAFE_AT, Mansion.DESK_AT, Mansion.PORTRAIT_AT], "greenhouse": Mansion.PLANTS,
		"pantry": [Mansion.BELL_BOARD_AT, Mansion.PANTRY_SHELF_AT],
	}
	for room: String in expected:
		for at: Vector3 in expected[room]:
			assert_eq(mansion.room_at(mansion.to_global(at)), room, "%s in the %s" % [at, room])
	assert_eq(Mansion.BELL_ROOMS.size(), 6, "one bell per room where someone can say he was")


func test_the_three_passages_run_inside_double_walls_between_their_rooms() -> void:
	var mansion := Mansion.new()
	add_child_autofree(mansion)
	var ends := {"bookcase": ["library", "study"], "clock": ["hall", "greenhouse"], "fireplace": ["lounge", "pantry"]}
	for id: String in Mansion.PASSAGES:
		var p: Dictionary = Mansion.PASSAGES[id]
		var middle: Vector3 = (p["in"] + p.out) / 2
		assert_eq(mansion.passage_at(mansion.to_global(middle)), id, "%s runs inside its wall" % id)
		assert_eq(mansion.room_at(mansion.to_global(middle)), "", "a passage is no room")
		assert_eq(mansion.room_at(mansion.to_global(_beside(p, p["in"]))), ends[id][0], "%s's way in" % id)
		assert_eq(mansion.room_at(mansion.to_global(_beside(p, p.out))), ends[id][1], "%s's way out" % id)


## A point 0.5 m past a passage's end, out in the room it opens to.
func _beside(p: Dictionary, end: Vector3) -> Vector3:
	if p.axis == "z":
		return end + Vector3(signf(end.x - p.fixed) * 0.5, 0, 0)
	return end + Vector3(0, 0, signf(end.z - p.fixed) * 0.5)


## Says whether nothing is in the way of a ray at knee height between two points of the mansion.
func _open(mansion: Mansion, from: Vector3, to: Vector3) -> bool:
	var knee := Vector3(0, 0.6, 0)
	var query := PhysicsRayQueryParameters3D.create(mansion.to_global(from + knee), mansion.to_global(to + knee))
	return mansion.get_world_3d().direct_space_state.intersect_ray(query).is_empty()


func test_the_doors_lead_from_the_drive_to_every_room_and_the_garden() -> void:
	var mansion := Mansion.new()
	add_child_autofree(mansion)
	await wait_physics_frames(1)
	var hall := Vector3(0, 0, 6)
	assert_true(_open(mansion, Vector3(0, 0, Mansion.FRONT_Z + 3), hall), "in by the front door")
	assert_true(_open(mansion, Vector3(-2, 0, Mansion.DOOR_SIDE_Z), Vector3(-8, 0, Mansion.DOOR_SIDE_Z)), "dining")
	assert_true(_open(mansion, Vector3(2, 0, Mansion.DOOR_SIDE_Z), Vector3(10, 0, Mansion.DOOR_SIDE_Z)), "lounge")
	for x: float in Mansion.DOORS_MIDDLE:
		assert_true(_open(mansion, Vector3(x, 0, Mansion.MIDDLE_Z + 1.5), Vector3(x, 0, Mansion.MIDDLE_Z - 1.5)),
			"through the middle wall at x %s" % x)
	for x: float in [Mansion.STUDY_X, Mansion.PANTRY_X]:
		assert_true(_open(mansion, Vector3(x - 1.5, 0, Mansion.DOOR_BACK_Z), Vector3(x + 1.5, 0, Mansion.DOOR_BACK_Z)),
			"through the back wall at x %s" % x)
	var garden := Vector3(Mansion.DOOR_GARDEN_X, 0, Mansion.BACK_Z - 1.5)
	assert_true(_open(mansion, Vector3(Mansion.DOOR_GARDEN_X, 0, Mansion.BACK_Z + 1.5), garden), "out to the garden")
	assert_false(_open(mansion, Vector3(-9, 0, -4), Vector3(-5, 0, -4)), "the passage's wall is closed for now")


func test_the_maze_is_one_piece_from_its_way_in_to_its_gate() -> void:
	var mansion := Mansion.new()
	add_child_autofree(mansion)
	var seen := {Mansion.maze_entry(): true}
	var todo: Array[Vector2i] = [Mansion.maze_entry()]
	while not todo.is_empty():
		var cell: Vector2i = todo.pop_back()
		for step: Vector2i in [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.DOWN, Vector2i.UP]:
			var other := cell + step
			if not seen.has(other) and mansion.maze_joined(cell, other):
				seen[other] = true
				todo.append(other)
	assert_eq(seen.size(), Mansion.MAZE_CELLS.x * Mansion.MAZE_CELLS.y, "every cell can be reached")
	assert_true(seen.has(Mansion.maze_gate()))
	assert_eq(Mansion.maze_cell(Mansion.maze_center(Vector2i(2, 3))), Vector2i(2, 3))
	assert_true(mansion.at_scene(mansion.to_global(Mansion.maze_center(Mansion.maze_gate()))), "the maze is the scene")


func test_the_storm_flashes_now_and_then_and_the_rain_stops_on_the_roof() -> void:
	var storm := MansionStorm.new()
	storm.storm_seed = 4
	storm.roof_size = Vector3(32, 3, 22)
	add_child_autofree(storm)
	assert_eq(storm.flash.light_energy, 0.0, "night")
	storm.bolt()
	assert_eq(storm.bolts, 1)
	assert_eq(storm.flash.light_energy, MansionStorm.FLASH_ENERGY, "lightning")
	await wait_seconds(MansionStorm.FLASH_SECONDS + 0.1)
	assert_almost_eq(storm.flash.light_energy, 0.0, 0.01, "and night again")
	assert_eq((storm.get_node("Roof") as GPUParticlesCollisionBox3D).size, Vector3(32, 3, 22))
	assert_eq((storm.rain.process_material as ParticleProcessMaterial).collision_mode,
		ParticleProcessMaterial.COLLISION_HIDE_ON_CONTACT)
