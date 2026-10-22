extends GutTest

## The neighborhood chapel (infiltracion-coro.md, step 3a, decision 101): its lot in the city, the pews with the
## aisle, the choir's platform with a stand for each spot, the organ, the locked sacristy and the cops starting at the
## station by the robes.

const LEVEL := preload("res://scenes/levels/church_choir.tscn")

var chapel: ChurchChoir


func before_each() -> void:
	chapel = LEVEL.instantiate()
	chapel.get_node("Cop").input_enabled = false
	add_child_autofree(chapel)
	await wait_physics_frames(2)


func test_it_has_its_lot_and_play_can_open_it() -> void:
	assert_false(CityLayout.place("chapel").is_empty())
	assert_eq(PlaceDraw.pick(1234, PackedStringArray(["--place=choir"])), "choir")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["choir"]))


func test_it_is_the_choir_infiltration_place() -> void:
	assert_true(chapel is InfiltrationPlace)
	assert_eq(chapel.variant, "choir")


func test_the_platform_has_a_spot_for_each_chorister_and_cop() -> void:
	assert_eq(chapel.spots.size(), ChurchChoir.ROW_ZS.size() * ChurchChoir.SPOTS_PER_ROW)
	for spot: Vector3 in chapel.spots:
		assert_true(ChurchChoir.PLATFORM.has_point(Vector2(spot.x, spot.z)), "on the platform")
		assert_almost_eq(spot.y, ChurchChoir.FLOOR_TOP + ChurchChoir.PLATFORM_HEIGHT, 0.01)


func test_the_aisle_and_the_entrance_are_clear() -> void:
	for x: float in ChurchChoir.PEW_XS:
		assert_gt(absf(x - ChurchChoir.ENTRANCE_X) - ChurchChoir.PEW_SIZE.x / 2, GameScale.DOOR_WIDTH / 2,
			"the pews leave the aisle as wide as the door")


func test_the_sacristy_is_locked() -> void:
	assert_true(chapel.sacristy_door.locked)


func test_the_cops_start_at_the_station() -> void:
	var cop: Cop = chapel.get_node("Cop")
	var station := chapel.city.global_transform * CityLayout.lot("station")
	assert_lt(cop.global_position.distance_to(station * StationRooms.SPAWNS[0]), 0.5)


func test_the_getaway_waits_on_the_street_out_of_the_entrance() -> void:
	var local := chapel.global_transform.affine_inverse() * chapel.getaway_at().origin
	assert_almost_eq(local.x, ChurchChoir.ENTRANCE_X, 0.01)
	assert_gt(local.z, ChurchChoir.HALF_Z + CityLayout.SIDEWALK, "past the sidewalk")
