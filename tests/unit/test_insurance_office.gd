extends GutTest

## The insurance office "Seguros Todo Tranquilo" (docs/diseno/seguros.md, step 1): the place itself, on its lot in the
## city.

const OFFICE_SCENE := preload("res://scenes/levels/insurance_office.tscn")


func _office() -> InsuranceOffice:
	var office: InsuranceOffice = OFFICE_SCENE.instantiate()
	office.get_node("Cop").input_enabled = false
	add_child_autofree(office)
	return office


func test_twelve_spots_each_on_a_surface() -> void:
	var office := _office()
	await wait_physics_frames(2)
	assert_eq(InsuranceOffice.SPOTS.size(), 12)
	var heavy := InsuranceOffice.SPOTS.filter(func(s: Dictionary) -> bool: return s.heavy).size()
	assert_eq(heavy, 6, "half the spots take the heavy evidence")
	var space := office.get_world_3d().direct_space_state
	for spot: Dictionary in InsuranceOffice.SPOTS:
		var at: Vector3 = spot.at
		assert_true(absf(at.x) < InsuranceOffice.HALF_X and absf(at.z) < InsuranceOffice.HALF_Z, "%s is inside" % spot.id)
		# Only the built office (layer 1), not what lies there.
		var query := PhysicsRayQueryParameters3D.create(at + Vector3.UP * 0.25, at + Vector3.DOWN * 0.2, 1)
		var hit := space.intersect_ray(query)
		assert_false(hit.is_empty(), "%s has something under it" % spot.id)
		if not hit.is_empty():
			assert_almost_eq((hit.position as Vector3).y, at.y, 0.03, "%s sits on its surface" % spot.id)
		assert_eq(tr("LOC_" + spot.id).begins_with("LOC_"), false, "%s has its place name" % spot.id)


func test_the_reception_is_open_and_the_boss_office_and_archive_locked() -> void:
	var office := _office()
	await wait_physics_frames(2)
	assert_true(office.boss_door.locked, "the boss's office")
	assert_true(office.archive_door.locked, "the archive")
	var space := office.get_world_3d().direct_space_state
	var front := InsuranceOffice.HALF_Z
	var reception := InsuranceOffice.RECEPTION_Z
	var opening := InsuranceOffice.RECEPTION_OPENINGS[1]
	# Street to reception, reception to the cubicles, the cubicles to the meeting room and to the kitchen nook.
	var ways := [
		[Vector3(0, 1.0, front + 2), Vector3(0, 1.0, front - 1.5)],
		[Vector3(opening, 1.0, reception + 1), Vector3(opening, 1.0, reception - 1)],
		[Vector3(InsuranceOffice.EAST_X - 1, 1.0, InsuranceOffice.MEETING_DOOR_Z), Vector3(InsuranceOffice.EAST_X + 0.5, 1.0, InsuranceOffice.MEETING_DOOR_Z)],
		[Vector3(InsuranceOffice.EAST_X - 1, 1.0, -1.0), Vector3(InsuranceOffice.EAST_X + 2, 1.0, -1.0)],
	]
	for way: Array in ways:
		var query := PhysicsRayQueryParameters3D.create(way[0], way[1], 1)
		assert_true(space.intersect_ray(query).is_empty(), "open from %s to %s" % [way[0], way[1]])


func test_the_chairs_roll_and_a_running_cop_scatters_the_papers() -> void:
	var office := _office()
	await wait_physics_frames(5)
	assert_eq(office.chairs.size(), 12, "a rolling chair in each cubicle")
	assert_eq(office.piles.size(), 12, "and a pile of papers")
	var chair := office.chairs[0]
	var from := chair.global_position
	chair.apply_central_impulse(Vector3(-1, 0, 0) * chair.mass * 2.0)
	await wait_seconds(0.6)
	assert_gt(chair.global_position.distance_to(from), 0.5, "a push rolls it away")
	var pile := office.piles[5]
	var flew := []
	pile.scattered.connect(func(at: Vector3) -> void: flew.append(at))
	var cop: Cop = office.get_node("Cop")
	cop.global_position = pile.global_position + Vector3(0, -0.5, 0.2)
	cop.velocity = Vector3(0, 0, -3.0)
	await wait_physics_frames(3)
	assert_true(pile.is_scattered, "a running cop sends the papers flying")
	assert_eq(flew.size(), 1)
	assert_false(office.piles[6].is_scattered, "only that one")


func test_a_cop_walking_by_leaves_the_papers_alone() -> void:
	var office := _office()
	await wait_physics_frames(5)
	var pile := office.piles[5]
	var cop: Cop = office.get_node("Cop")
	cop.global_position = pile.global_position + Vector3(0, -0.5, 0.2)
	cop.velocity = Vector3(0, 0, -1.0)
	await wait_physics_frames(3)
	assert_false(pile.is_scattered)


func test_the_fragile_things_are_fines() -> void:
	var office := _office()
	await wait_physics_frames(30)
	assert_eq(office.monitors.size(), InsuranceOffice.CUBICLE_COLUMNS.size(), "the middle row's monitors")
	assert_eq(office.trophies.size(), InsuranceOffice.TROPHIES)
	for item: Ornament in office.monitors + office.trophies:
		assert_false(item.is_broken, "%s survives standing still" % item.name)
	office.monitors[0].hit(Ornament.BREAK_SPEED + 1.0)
	office.trophies[0].hit(Ornament.BREAK_SPEED + 1.0)
	assert_eq(office.fines, Ornament.FINE * 2)
	assert_eq(office.broken_goods, 2)


func test_the_office_sits_on_its_lot_and_the_car_starts_at_the_station() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var city: Node3D = office.get_node("City")
	var lot := CityLayout.place("insurance")
	var center := CityLayout.lot_center(lot.block, lot.side, lot.along, lot.size.z)
	assert_lt((city.transform * center).distance_to(Vector3.ZERO), 0.01, "the office is at the origin of its scene")
	assert_eq(lot.size.x, InsuranceOffice.HALF_X * 2, "as wide as its lot")
	assert_eq(lot.size.z, InsuranceOffice.HALF_Z * 2, "as deep as its lot")
	assert_eq(lot.size.y, InsuranceOffice.BUILDING_TOP, "as tall as its lot")
	assert_lt(office.car.global_position.distance_to(office.station_parking.origin), 0.2)
	assert_lt(office.get_node("Cop").global_position.distance_to(office.car.global_position), 4.0)
	assert_eq(office.city_map.target, "insurance")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["insurance"]))
