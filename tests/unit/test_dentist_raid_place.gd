extends GutTest

## The dental office as a place to raid (docs/diseno/allanamiento-dentista.md, step 2): its lot in the city, the locked
## storeroom, the 12 hiding spots, the fish tank that breaks when hit hard (a fine, and a wet floor that makes a
## running cop slip) and the molds that count when they break.

const RAID_SCENE := preload("res://scenes/levels/dentist_raid.tscn")


func _office() -> DentistRaid:
	var office: DentistRaid = RAID_SCENE.instantiate()
	office.get_node("Cop").input_enabled = false
	office.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(office)
	return office


func _prop(office: DentistRaid, at: Vector3, velocity: Vector3) -> Grabbable:
	var prop := ClubEvidence.make_item("Thrown", DentistRaid.JAR_MODEL, Vector3(0.3, 0.3, 0.3), 2.0)
	office.add_child(prop)
	prop.global_position = office.to_global(at)
	prop.linear_velocity = office.global_transform.basis * velocity
	return prop


func test_the_office_has_its_lot_menu_and_scene() -> void:
	assert_false(CityLayout.place("dentist").is_empty())
	assert_eq(PlaceDraw.PLACES["dentist_raid"], "res://scenes/levels/dentist_raid.tscn")
	assert_eq(MainMenu.DENTIST_RAID_SCENE, PlaceDraw.PLACES["dentist_raid"])
	var size: Vector3 = CityLayout.place("dentist").size
	assert_almost_eq(size.x, DentistRaid.HALF_X * 2, 0.01, "the building fills its lot")
	assert_almost_eq(size.z, DentistRaid.HALF_Z * 2, 0.01)
	for key in ["PLACE_DENTIST", "MENU_DENTIST_RAID", "CASE_FAILED_LAWYER_DENTIST"]:
		assert_ne(tr(key), key, "%s has its words" % key)


func test_the_car_waits_at_the_station_and_the_storeroom_is_locked() -> void:
	var office := _office()
	await wait_physics_frames(2)
	assert_almost_eq(office.car.global_position.distance_to(office.station_parking.origin), 0.05, 0.1)
	assert_true(office.storeroom_door.locked)
	assert_eq(office.molds.size(), DentistRaid.MOLDS)


func test_twelve_spots_six_for_heavy_things_all_inside() -> void:
	assert_eq(DentistRaid.SPOTS.size(), 12)
	assert_eq(DentistRaid.SPOTS.filter(func(spot: Dictionary) -> bool: return spot.heavy).size(), 6)
	var ids := {}
	for spot: Dictionary in DentistRaid.SPOTS:
		var at: Vector3 = spot.at
		assert_lt(absf(at.x), DentistRaid.HALF_X, spot.id)
		assert_lt(absf(at.z), DentistRaid.HALF_Z, spot.id)
		assert_ne(tr("LOC_" + spot.id), "LOC_" + spot.id, "%s has its words" % spot.id)
		ids[spot.id] = true
	assert_eq(ids.size(), 12, "no two spots share an id")


func test_a_hard_hit_breaks_the_fish_tank_once_with_a_fine_and_a_wet_floor() -> void:
	var office := _office()
	await wait_physics_frames(2)
	assert_false(office.on_wet_floor(DentistRaid.TANK_AT + Vector3(-1.5, 0, 0)))
	_prop(office, DentistRaid.TANK_AT + Vector3(-1.5, 0.7, 0), Vector3(8.0, 0, 0))
	await wait_physics_frames(30)
	assert_true(office.tank_broken)
	assert_eq(office.fines, DentistRaid.TANK_FINE)
	assert_eq(office.broken_goods, 1)
	assert_true(office.on_wet_floor(DentistRaid.TANK_AT + Vector3(-1.5, 0, 0)))
	office.break_fish_tank()
	assert_eq(office.fines, DentistRaid.TANK_FINE, "it only breaks once")


func test_a_gentle_touch_leaves_the_fish_tank_alone() -> void:
	var office := _office()
	await wait_physics_frames(2)
	_prop(office, DentistRaid.TANK_AT + Vector3(-1.2, 0.7, 0), Vector3(1.5, 0, 0))
	await wait_physics_frames(30)
	assert_false(office.tank_broken)


func test_a_cop_running_on_the_wet_floor_slips() -> void:
	var office := _office()
	await wait_physics_frames(2)
	office.break_fish_tank()
	var cop: Cop = office.get_node("Cop")
	cop.global_position = office.to_global(DentistRaid.TANK_AT + Vector3(-2.0, 0.1, 0))
	cop.is_running = true
	cop.velocity = office.global_transform.basis * Vector3(GameScale.WALK_SPEED * 1.6, 0, 0)
	await wait_physics_frames(1)
	assert_true(office._slipped.has(cop), "running on the wet floor knocks the cop down")


func test_a_mold_that_breaks_counts() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var mold: Ornament = office.molds[0]
	mold.hit(5.0)
	await wait_physics_frames(1)
	assert_eq(office.broken_goods, 1)
	assert_eq(office.molds.size(), DentistRaid.MOLDS - 1)
