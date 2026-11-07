extends GutTest

## The evidence room behind the station's break room (escena-comisaria.md, step 1; EvidenceRoom).

const CITY_SCENE := preload("res://scenes/levels/city.tscn")


func _blocks(at: Vector3, piece: Array) -> bool:
	var center: Vector3 = piece[0]
	var half: Vector3 = piece[1] / 2
	return absf(at.x - center.x) < half.x and absf(at.z - center.z) < half.z and center.y - half.y < 1.5


func _station() -> Transform3D:
	var p := CityLayout.place("station")
	return Transform3D(Basis(Vector3.UP, CityLayout.side_turn(p.side)), CityLayout.lot_center(p.block, p.side, p.along, p.size.z))


func _rect(from: Vector3, to: Vector3) -> Rect2:
	return Rect2(Vector2(minf(from.x, to.x), minf(from.z, to.z)), Vector2(absf(from.x - to.x), absf(from.z - to.z)))


func test_the_door_from_the_break_room_and_the_gate_are_open() -> void:
	var walls := StationRooms.back_wall(9.0) + EvidenceRoom.shell() + EvidenceRoom.bars()
	var door := Vector3((EvidenceRoom.DOOR.x + EvidenceRoom.DOOR.y) / 2, 0, EvidenceRoom.FROM_Z)
	var gate := Vector3((EvidenceRoom.GATE.x + EvidenceRoom.GATE.y) / 2, 0, EvidenceRoom.CAGE_Z)
	for at: Vector3 in [door, gate]:
		for piece: Array in walls:
			assert_false(_blocks(at, piece), "nothing low stands in the doorway at %s" % at)
	assert_between(door.x, StationRooms.BACK_X, StationRooms.HALF_X, "the door is in the break room")
	var bars_between := EvidenceRoom.bars().filter(func(post: Array) -> bool:
		return (post[0] as Vector3).x > EvidenceRoom.GATE.y + 0.1 and (post[1] as Vector3).y > 2.0)
	assert_gt(bars_between.size(), 10, "the rest of the cage's front is bars")


func test_the_room_fits_on_the_free_ground_of_the_block_clear_of_the_interrogation_wing() -> void:
	var station := _station()
	var room := _rect(station * Vector3(EvidenceRoom.FROM_X, 0, EvidenceRoom.FROM_Z),
		station * Vector3(EvidenceRoom.TO_X, 0, EvidenceRoom.TO_Z))
	var block := CityLayout.block_center(CityLayout.place("station").block)
	var inner := CityLayout.BLOCK / 2 - CityLayout.SIDEWALK
	assert_true(Rect2(Vector2(block.x, block.z) - Vector2.ONE * inner, Vector2.ONE * inner * 2).encloses(room), "inside the block")
	for lot: Dictionary in CityLayout.fillers():
		assert_false(CityLayout.footprint(lot.block, lot.side, lot.along, lot.size).intersects(room), "clear of the filler lots")
	var wing := _rect(station * Vector3(-InterrogationWing.HALF_X, 0, InterrogationWing.FROM_Z),
		station * Vector3(InterrogationWing.HALF_X, 0, InterrogationWing.TO_Z))
	assert_false(wing.intersects(room), "clear of the interrogation wing")


func test_the_shelves_are_in_the_cage_and_the_book_and_the_vcr_in_the_front_room() -> void:
	for item: Array in EvidenceRoom.FURNITURE:
		var at: Vector3 = item[1]
		assert_between(at.x, EvidenceRoom.FROM_X, EvidenceRoom.TO_X, "%s inside the room" % item[0])
		if (item[0] as String).begins_with("evidence_shelf"):
			assert_between(at.z, EvidenceRoom.TO_Z, EvidenceRoom.CAGE_Z, "%s in the cage" % item[0])
		elif item[0] != "security_camera":
			assert_between(at.z, EvidenceRoom.CAGE_Z, EvidenceRoom.FROM_Z, "%s in the front room" % item[0])
		if not EvidenceRoom.SOLID.has(item[0]):
			continue
		var footprint: Vector3 = (EvidenceRoom.SOLID[item[0]] as Vector3).rotated(Vector3.UP, item[2]).abs()
		for piece: Array in EvidenceRoom.shell() + EvidenceRoom.bars():
			if (piece[0] as Vector3).y - (piece[1] as Vector3).y / 2 > 2.0:
				continue
			var gap: Vector3 = (at - piece[0]).abs() - (footprint + piece[1]) / 2
			assert_true(gap.x > 0 or gap.z > 0, "%s clear of the walls and bars" % item[0])
	var gaps := EvidenceRoom.FURNITURE.filter(func(f: Array) -> bool: return f[0] == "evidence_shelf_gap")
	assert_eq(gaps.size(), 1, "one shelf with the empty spot")


func test_the_city_builds_the_room_with_its_gate_and_sign() -> void:
	var city: City = CITY_SCENE.instantiate()
	add_child_autofree(city)
	await wait_physics_frames(2)
	assert_not_null(city.evidence_gate, "the cage's gate")
	assert_false(city.cell_doors.has(city.evidence_gate), "not one of the cells' doors")
	var sign: Label3D = city.find_child("EvidenceSign", true, false)
	assert_not_null(sign)
	assert_eq(sign.text, "SIGN_EVIDENCE_ROOM")
	# Walking from the break room into the front room: a ray through the door hits nothing until the bars' gate.
	var station := city.global_transform * _station()
	var space := city.get_world_3d().direct_space_state
	var door_x := (EvidenceRoom.DOOR.x + EvidenceRoom.DOOR.y) / 2
	var hit := space.intersect_ray(PhysicsRayQueryParameters3D.create(station * Vector3(door_x, 1.0, -7.0),
		station * Vector3(door_x, 1.0, EvidenceRoom.CAGE_Z + 0.3)))
	assert_true(hit.is_empty(), "the door is open")
	# The gate closes the cage until it is opened.
	var gate_x := (EvidenceRoom.GATE.x + EvidenceRoom.GATE.y) / 2
	hit = space.intersect_ray(PhysicsRayQueryParameters3D.create(station * Vector3(gate_x, 1.0, EvidenceRoom.CAGE_Z + 1.0),
		station * Vector3(gate_x, 1.0, EvidenceRoom.CAGE_Z - 1.0)))
	assert_false(hit.is_empty(), "the gate is shut")
