extends GutTest

## The station's people in its crime scene (escena-comisaria.md, step 2; StationStaff).


func _clear(at: Vector3, solid: Array, radius := 0.45) -> bool:
	var gap: Vector3 = (at - (solid[0] as Vector3)).abs() - (solid[1] as Vector3) / 2 - Vector3.ONE * radius
	return gap.x > 0 or gap.z > 0


## Everything a person can bump into in the station and the evidence room, as [center, size] footprints.
func _solids() -> Array:
	var solids := StationRooms.walls() + StationRooms.counter() + StationRooms.bars() + EvidenceRoom.shell() + EvidenceRoom.bars()
	for set: Array in [[StationRooms.FURNITURE, StationRooms.SOLID], [EvidenceRoom.FURNITURE, EvidenceRoom.SOLID]]:
		for item: Array in set[0]:
			if (set[1] as Dictionary).has(item[0]):
				solids.append([item[1], ((set[1] as Dictionary)[item[0]] as Vector3).rotated(Vector3.UP, item[2]).abs()])
	return solids.filter(func(piece: Array) -> bool: return (piece[0] as Vector3).y - (piece[1] as Vector3).y / 2 < 1.5)


func test_each_one_stands_clear_in_their_room_and_el_chancho_in_cell_1() -> void:
	var solids := _solids()
	for id: String in StationStaff.WHO:
		var at: Vector3 = StationStaff.WHO[id].at
		for piece: Array in solids:
			assert_true(_clear(at, piece), "%s clear of %s" % [id, piece[0]])
	var chancho: Vector3 = StationStaff.WHO.chancho.at
	assert_between(chancho.x, StationRooms.FRONT_X, StationRooms.CELL_SPLIT_X, "in the west cell")
	assert_between(chancho.z, StationRooms.SPLIT_Z, StationRooms.CELL_FRONT_Z, "behind its bars")
	var polilla: Vector3 = StationStaff.WHO.polilla.at
	assert_between(polilla.z, EvidenceRoom.CAGE_Z, EvidenceRoom.FROM_Z, "the clerk in the evidence room's front room")
	assert_eq(StationStaff.COWORKERS.size() + 1, 6, "with the armero, six coworkers")


func test_they_appear_with_their_plate_and_their_teeth_hidden() -> void:
	var root := Node3D.new()
	add_child_autofree(root)
	var people := StationStaff.spawn_all(root)
	assert_eq(people.size(), StationStaff.WHO.size())
	for person: StationStaff in people:
		assert_almost_eq(person.position.distance_to(StationStaff.WHO[person.who].at), 0.0, 0.001)
		var teeth := person.part("teeth")
		assert_not_null(teeth, "%s has teeth to bite with" % person.who)
		assert_false(teeth.visible, "hidden until they bite")
		var plate: Label3D = person.get_node_or_null("Plate")
		if person.who == "chancho":
			assert_null(plate, "el Chancho has no name plate")
		else:
			assert_eq(plate.text, "STAFF_NAME_" + person.who.to_upper())
			assert_lt(plate.pixel_size, 0.002, "it reads only up close")


func test_e_on_them_gets_a_different_line_each_time_and_every_text_exists() -> void:
	var root := Node3D.new()
	add_child_autofree(root)
	var people := StationStaff.spawn_all(root)
	for person: StationStaff in people:
		var lines := {}
		for i in StationStaff.WHO[person.who].lines:
			person.use(null)
			lines[person.said()] = true
		assert_eq(lines.size(), StationStaff.WHO[person.who].lines, "%s says all their lines" % person.who)
		for key: String in [person.prompt_key(null), person.line_key(0), person.line_key(3)] + ([person.name_key()] if person.who != "chancho" else []):
			assert_ne(tr(key), key, "%s has a text" % key)
	people[0].use(null)
	assert_eq(people[0].said(), people[0].line_key(0), "and they go round")
