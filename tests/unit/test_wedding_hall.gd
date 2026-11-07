extends GutTest

## The wedding crime scene's hall (escena-boda.md, step 1): the Salón Gala dressed for Rosa and Tito's wedding on the
## party hall's lot, with its head table, eight numbered round tables, the cake, the DJ and the rice by the entrance,
## clear of the dance floor and the rooms; and --place=wedding opens it.

const LEVEL := preload("res://scenes/levels/wedding.tscn")


func _hall() -> WeddingHall:
	var hall := WeddingHall.new()
	hall.case_seed = 3
	add_child_autofree(hall)
	return hall


func _clear_of_rooms(at: Vector3, radius: float) -> bool:
	var spot := Vector2(at.x, at.z)
	var rooms: Array[Rect2] = [PartyHall.DANCE, PartyHall.COAT_CHECK,
		Rect2(PartyHall.RESTROOM_X, PartyHall.RESTROOM_Z, PartyHall.HALF_X - PartyHall.RESTROOM_X,
			PartyHall.HALF_Z - PartyHall.RESTROOM_Z),
		Rect2(PartyHall.OFFICE_X, -PartyHall.HALF_Z, PartyHall.HALF_X - PartyHall.OFFICE_X,
			PartyHall.OFFICE_Z + PartyHall.HALF_Z)]
	for room: Rect2 in rooms:
		if room.grow(radius).has_point(spot):
			return false
	return absf(at.x) + radius < WeddingHall.HALF_X and absf(at.z) + radius < WeddingHall.HALF_Z


func test_the_hall_has_its_wedding_furniture() -> void:
	var hall := _hall()
	assert_eq(hall.variant, "wedding")
	assert_not_null(hall.cake, "the cake")
	assert_not_null(hall.dj_booth, "the DJ")
	assert_not_null(hall.office_door, "the office stays locked")
	assert_true(hall.office_door.locked)
	assert_eq(hall.table_tops.size(), 8)
	for i in 8:
		assert_not_null(hall.get_node_or_null("Centerpiece%d" % (i + 1)), "table %d has flowers" % (i + 1))
		assert_eq((hall.get_node("TableNumber%d" % (i + 1)) as Label3D).text, str(i + 1))
	assert_eq((hall.get_node("Rice") as MultiMeshInstance3D).multimesh.instance_count, WeddingHall.RICE)
	assert_ne(tr("WEDDING_BANNER"), "WEDDING_BANNER", "the banner is translated")


func test_the_tables_cake_and_dj_are_clear_of_the_rooms_and_each_other() -> void:
	var spots: Array[Vector3] = WeddingHall.TABLES.duplicate()
	for at: Vector3 in WeddingHall.TABLES:
		assert_true(_clear_of_rooms(at, WeddingHall.TABLE_RADIUS), "table at %s" % at)
	assert_true(_clear_of_rooms(WeddingHall.CAKE_TABLE_AT, WeddingHall.CAKE_TABLE_RADIUS), "the cake")
	assert_true(_clear_of_rooms(WeddingHall.DJ_AT, 1.3), "the DJ")
	assert_true(_clear_of_rooms(WeddingHall.HEAD_TABLE_AT, 0.45), "the head table")
	spots.append(WeddingHall.CAKE_TABLE_AT)
	for i in spots.size():
		for j in range(i + 1, spots.size()):
			assert_gt(spots[i].distance_to(spots[j]), WeddingHall.TABLE_RADIUS * 2 + 0.8, "room to walk between")
	assert_true(WeddingHall.RICE_AREA.has_point(Vector2(PartyHall.ENTRANCE_X, 8.0)), "the rice is at the door")


func test_the_level_puts_the_wedding_on_the_party_hall_lot() -> void:
	assert_eq(PlaceDraw.PLACES.get("wedding"), "res://scenes/levels/wedding.tscn")
	var level: WeddingLevel = LEVEL.instantiate()
	level.case_seed = 7
	add_child_autofree(level)
	await wait_physics_frames(2)
	var lot := (level.get_node("City") as Node3D).transform * CityLayout.lot("party_hall")
	assert_almost_eq(level.hall.global_position.distance_to(lot.origin), 0.0, 0.01)
	assert_eq(level.hall.case_seed, 7)
	assert_true(level.hall.at_scene(lot * Vector3(0, 1, 0)), "the middle of the hall is the scene")
	assert_false(level.hall.at_scene(lot * Vector3(0, 1, 15)), "the street is not")
