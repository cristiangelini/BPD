extends GutTest

## The interrogation wing behind the station (interrogatorio.md, "Dónde pasa"; InterrogationWing).

const CITY_SCENE := preload("res://scenes/levels/city.tscn")


func _blocks(at: Vector3, piece: Array) -> bool:
	var center: Vector3 = piece[0]
	var half: Vector3 = piece[1] / 2
	return absf(at.x - center.x) < half.x and absf(at.z - center.z) < half.z and center.y - half.y < 1.5


func _station() -> Transform3D:
	var p := CityLayout.place("station")
	return Transform3D(Basis(Vector3.UP, CityLayout.side_turn(p.side)), CityLayout.lot_center(p.block, p.side, p.along, p.size.z))


func test_the_doors_from_the_office_to_both_rooms_are_open() -> void:
	var walls := StationRooms.back_wall(9.0) + InterrogationWing.walls() + InterrogationWing.shell()
	var doors := [
		Vector3((InterrogationWing.OFFICE_DOOR.x + InterrogationWing.OFFICE_DOOR.y) / 2, 0, InterrogationWing.FROM_Z),
		Vector3((InterrogationWing.OBSERVATION_DOOR.x + InterrogationWing.OBSERVATION_DOOR.y) / 2, 0, InterrogationWing.HALL_Z),
		Vector3((InterrogationWing.ROOM_DOOR.x + InterrogationWing.ROOM_DOOR.y) / 2, 0, InterrogationWing.HALL_Z),
	]
	for door: Vector3 in doors:
		for piece: Array in walls:
			assert_false(_blocks(door, piece), "nothing low stands in the doorway at %s" % door)
	var office := (InterrogationWing.OFFICE_DOOR.x + InterrogationWing.OFFICE_DOOR.y) / 2
	assert_between(office, -StationRooms.BACK_X, StationRooms.BACK_X, "the door is in the comisario's office")


func test_the_wing_fits_on_the_free_ground_of_the_block() -> void:
	var station := _station()
	var a := station * Vector3(-InterrogationWing.HALF_X, 0, InterrogationWing.FROM_Z)
	var b := station * Vector3(InterrogationWing.HALF_X, 0, InterrogationWing.TO_Z)
	var wing := Rect2(Vector2(minf(a.x, b.x), minf(a.z, b.z)), Vector2(absf(a.x - b.x), absf(a.z - b.z)))
	var block := CityLayout.block_center(CityLayout.place("station").block)
	var inner := CityLayout.BLOCK / 2 - CityLayout.SIDEWALK
	assert_true(Rect2(Vector2(block.x, block.z) - Vector2.ONE * inner, Vector2.ONE * inner * 2).encloses(wing), "inside the block")
	for lot: Dictionary in CityLayout.fillers():
		assert_false(CityLayout.footprint(lot.block, lot.side, lot.along, lot.size).intersects(wing), "clear of the filler lots")


func test_the_suspect_sits_in_the_interrogation_room_and_the_observers_see_through_the_mirror() -> void:
	var at := InterrogationWing.SUSPECT_AT
	assert_between(at.x, InterrogationWing.MIRROR_X, InterrogationWing.HALF_X)
	assert_between(at.z, InterrogationWing.TO_Z, InterrogationWing.HALL_Z)
	var desk: Array = InterrogationWing.FURNITURE.filter(func(f: Array) -> bool: return f[0] == "recording_desk")[0]
	assert_lt(desk[1].x, InterrogationWing.MIRROR_X, "the recording desk is on the observers' side")
	assert_between(desk[1].z, InterrogationWing.MIRROR.x, InterrogationWing.MIRROR.y, "right in front of the mirror")
	for item: Array in InterrogationWing.FURNITURE:
		if not InterrogationWing.SOLID.has(item[0]):
			continue
		var footprint := [item[1], (InterrogationWing.SOLID[item[0]] as Vector3).rotated(Vector3.UP, item[2]).abs()]
		for piece: Array in InterrogationWing.walls():
			var gap: Vector3 = (item[1] - piece[0]).abs() - (footprint[1] + piece[1]) / 2
			assert_true(gap.x > 0 or gap.z > 0, "%s clear of the walls" % item[0])


func test_the_city_builds_the_wing_with_its_mirror_and_lamp() -> void:
	var city: Node3D = CITY_SCENE.instantiate()
	add_child_autofree(city)
	await wait_physics_frames(2)
	var lamp: SpotLight3D = city.find_child("InterrogationLamp", true, false)
	assert_not_null(lamp, "the lamp over the table")
	assert_not_null(city.find_child("Mirror", true, false))
	assert_not_null(city.find_child("ObservationGlass", true, false))
	# The mirror stops you like glass: a ray from the observation room to the suspect hits it.
	var station := _station()
	var space := (city as Node3D).get_world_3d().direct_space_state
	var from := city.global_transform * station * Vector3(InterrogationWing.MIRROR_X - 1.0, 1.5, -14.5)
	var to := city.global_transform * station * Vector3(InterrogationWing.SUSPECT_AT.x, 1.5, -14.5)
	var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(from, to))
	assert_false(hit.is_empty(), "the glass is solid")
	var local: Vector3 = (city.global_transform * station).affine_inverse() * (hit.position as Vector3)
	assert_almost_eq(local.x, InterrogationWing.MIRROR_X - 0.02, 0.05, "it hits the mirror pane")
