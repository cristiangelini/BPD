extends GutTest

## The "Las Palomas" apartment building (docs/diseno/edificio.md, step 1): a 30-floor tower with the lobby and floor 30
## played, on its lot in the city.

const TOWER_SCENE := preload("res://scenes/levels/apartment_tower.tscn")

var tower: ApartmentTower


func before_each() -> void:
	tower = TOWER_SCENE.instantiate()
	tower.get_node("Cop").input_enabled = false
	add_child_autofree(tower)
	await wait_physics_frames(2)


func _ray(from: Vector3, to: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(tower.to_global(from), tower.to_global(to), 1)
	return tower.get_world_3d().direct_space_state.intersect_ray(query)


func test_thirty_floors_tall_on_its_lot() -> void:
	var lot: Dictionary = CityLayout.place("apartments")
	assert_almost_eq((lot.size as Vector3).y, ApartmentTower.ROOF_Y, 0.01, "the city draws it as tall as it is")
	assert_eq(ApartmentTower.TOP_Y, 96.0, "floor 30 at 30 storeys of 3.2 m")
	for place: Dictionary in CityLayout.PLACES:
		if place.id != "apartments":
			assert_lt((place.size as Vector3).y, ApartmentTower.ROOF_Y, "%s is lower" % place.id)
	var roof := _ray(Vector3(0, ApartmentTower.ROOF_Y + 5, 0), Vector3(0, ApartmentTower.ROOF_Y - 1, 0))
	assert_false(roof.is_empty())
	assert_almost_eq(tower.to_local(roof.position).y, ApartmentTower.ROOF_Y, 0.01, "the roof is on top")


func test_twelve_spots_each_on_a_surface() -> void:
	assert_eq(ApartmentTower.SPOTS.size(), 12)
	var heavy := ApartmentTower.SPOTS.filter(func(s: Dictionary) -> bool: return s.heavy).size()
	assert_between(heavy, 4, 8, "some spots take the heavy evidence, some don't")
	var on_top := 0
	for spot: Dictionary in ApartmentTower.SPOTS:
		var at: Vector3 = spot.at
		if ApartmentTower.on_top_floor(at):
			on_top += 1
		var hit := _ray(at + Vector3.UP * 0.25, at + Vector3.DOWN * 0.2)
		assert_false(hit.is_empty(), "%s has something under it" % spot.id)
		if not hit.is_empty():
			assert_almost_eq(tower.to_local(hit.position).y, at.y, 0.03, "%s sits on its surface" % spot.id)
	assert_eq(on_top, 10, "two in the lobby, the rest in 30B")


func test_the_doors_that_are_locked() -> void:
	assert_true(tower.front_door.locked, "the glass door: the intercom or the ram")
	assert_true(tower.flat_door.locked, "30B")
	assert_true(tower.study_door.locked, "30B's study")
	assert_true(tower.rental_door.locked, "30C, for rent")


func test_the_rooms_connect() -> void:
	var y := 1.0
	var top := ApartmentTower.TOP_Y + 1.0
	# The living room to the kitchen, to the bedroom, the bedroom to the bathroom, the living room to the balcony.
	var ways := [
		[Vector3(-2.0, top, 0.8), Vector3(-4.0, top, 0.8)],
		[Vector3(-2.0, top, 5.6), Vector3(-4.0, top, 5.6)],
		[Vector3(-9.0, top, 4.0), Vector3(-9.0, top, 2.4)],
		[Vector3(ApartmentTower.BALCONY_DOOR_X, top, 7.0), Vector3(ApartmentTower.BALCONY_DOOR_X, top, 9.0)],
	]
	for way: Array in ways:
		assert_true(_ray(way[0], way[1]).is_empty(), "open from %s to %s" % [way[0], way[1]])
	# The 29 floors in between are closed: no way in from the street above the lobby.
	assert_false(_ray(Vector3(0, 40, ApartmentTower.HALF_Z + 2), Vector3(0, 40, 0)).is_empty())
	# The fire stairs are shut on both floors: the elevator is the way up.
	assert_false(_ray(Vector3(ApartmentTower.STAIRS_DOOR_X, y, -3.0), Vector3(ApartmentTower.STAIRS_DOOR_X, y, -5.0)).is_empty())
	assert_false(_ray(Vector3(ApartmentTower.STAIRS_DOOR_X, top, -3.0), Vector3(ApartmentTower.STAIRS_DOOR_X, top, -5.0)).is_empty())


func test_ornaments_break_into_fines() -> void:
	assert_eq(tower.ornaments.size(), 30)
	for ornament in tower.ornaments:
		assert_true(ApartmentTower.on_top_floor(ornament.position), "in 30B")
	tower.ornaments[0].broken.emit(tower.ornaments[0].global_position)
	assert_eq(tower.broken_goods, 1)
	assert_eq(tower.fines, Ornament.FINE)


func test_the_ornaments_stay_on_their_shelves() -> void:
	await wait_seconds(1.0)
	for ornament in tower.ornaments:
		assert_true(is_instance_valid(ornament) and ornament.position.y > ApartmentTower.TOP_Y, "nothing fell")
