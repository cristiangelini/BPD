extends GutTest

## The pizzeria as a place to raid (docs/diseno/allanamiento-pizzeria.md, step 2): its lot in the city, the locked
## cold room, the 12 hiding spots, the plates that count when they break and the flour sacks that leave a white patch.

const RAID_SCENE := preload("res://scenes/levels/pizza_raid.tscn")


func _pizzeria() -> PizzaRaid:
	var pizzeria: PizzaRaid = RAID_SCENE.instantiate()
	pizzeria.get_node("Cop").input_enabled = false
	pizzeria.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(pizzeria)
	return pizzeria


func test_the_pizzeria_has_its_lot_menu_and_scene() -> void:
	assert_false(CityLayout.place("pizzeria").is_empty())
	assert_eq(PlaceDraw.PLACES["pizza_raid"], "res://scenes/levels/pizza_raid.tscn")
	assert_eq(MainMenu.PIZZA_RAID_SCENE, PlaceDraw.PLACES["pizza_raid"])
	var size: Vector3 = CityLayout.place("pizzeria").size
	assert_almost_eq(size.x, PizzaRaid.HALF_X * 2, 0.01, "the pizzeria fills its lot")
	assert_almost_eq(size.z, PizzaRaid.HALF_Z * 2, 0.01)
	for key in ["PLACE_PIZZERIA", "MENU_PIZZA_RAID", "CASE_FAILED_LAWYER_PIZZA"]:
		assert_ne(tr(key), key, "%s has its words" % key)


func test_the_car_waits_at_the_station_and_the_cold_room_is_locked() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	assert_almost_eq(pizzeria.car.global_position.distance_to(pizzeria.station_parking.origin), 0.05, 0.1)
	assert_true(pizzeria.cold_door.locked)
	assert_eq(pizzeria.plates.size(), PizzaRaid.PLATE_STACKS.size() * PizzaRaid.PLATES_PER_STACK)
	assert_eq(pizzeria.sacks.size(), PizzaRaid.SACKS_ALONG.size())


func test_twelve_spots_six_for_heavy_things_all_inside() -> void:
	assert_eq(PizzaRaid.SPOTS.size(), 12)
	assert_eq(PizzaRaid.SPOTS.filter(func(spot: Dictionary) -> bool: return spot.heavy).size(), 6)
	var ids := {}
	for spot: Dictionary in PizzaRaid.SPOTS:
		var at: Vector3 = spot.at
		assert_lt(absf(at.x), PizzaRaid.HALF_X, spot.id)
		assert_lt(absf(at.z), PizzaRaid.HALF_Z, spot.id)
		assert_ne(tr("LOC_" + spot.id), "LOC_" + spot.id, "%s has its words" % spot.id)
		ids[spot.id] = true
	assert_eq(ids.size(), 12, "no two spots share an id")


func test_the_stacks_of_plates_stay_whole_when_nobody_touches_them() -> void:
	var pizzeria := _pizzeria()
	await wait_seconds(4.0)
	assert_eq(pizzeria.broken_plates, 0)
	assert_eq(pizzeria.plates.size(), PizzaRaid.PLATE_STACKS.size() * PizzaRaid.PLATES_PER_STACK)


func test_a_plate_that_breaks_counts() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	var plate: Ornament = pizzeria.plates[0]
	plate.hit(5.0)
	await wait_physics_frames(1)
	assert_eq(pizzeria.broken_plates, 1)
	assert_eq(pizzeria.plates.size(), PizzaRaid.PLATE_STACKS.size() * PizzaRaid.PLATES_PER_STACK - 1)


func test_a_burst_sack_leaves_a_patch_of_flour() -> void:
	var pizzeria := _pizzeria()
	await wait_physics_frames(2)
	var sack: FlourSack = pizzeria.sacks[0]
	assert_true(sack.hit(6.0))
	await wait_physics_frames(1)
	assert_eq(pizzeria.burst_sacks, 1)
	assert_eq(pizzeria.sacks.size(), PizzaRaid.SACKS_ALONG.size() - 1)
	assert_eq(pizzeria.flour.patches.size(), 1)
