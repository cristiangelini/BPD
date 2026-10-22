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


func test_choristers_on_spots_and_ernesto_in_front_of_them() -> void:
	assert_eq(chapel.members.size(), ChurchChoir.MEMBERS)
	for member: ClubMember in chapel.members:
		assert_true(chapel.spots.any(func(at: Vector3) -> bool: return at.distance_to(member.position) < 0.01), "on a spot")
		assert_true(member.look.begins_with("corista"))
	assert_eq(chapel.free_spots.size(), chapel.spots.size() - ChurchChoir.MEMBERS, "spots left for the cops")
	assert_eq(chapel.boss, chapel.ernesto)
	assert_true(chapel.ernesto.is_boss())
	assert_lt(chapel.ernesto.global_basis.z.dot(chapel.members[0].global_basis.z), 0.0, "facing each other")


func test_a_chorister_and_ernesto_have_their_own_lines() -> void:
	var cop: Cop = chapel.get_node("Cop")
	chapel.members[0].use(cop)
	assert_true(chapel.members[0].said().begins_with("CHOIR_GOSSIP_"))
	chapel.ernesto.use(cop)
	assert_true(chapel.ernesto.said().begins_with("ERNESTO_"))
	chapel.ernesto.cuffed(5.0)
	assert_eq(chapel.ernesto.said(), "ERNESTO_CUFFED")


## A cop walking into the doorway from the sidewalk.
func _walk_in(cop: Cop) -> void:
	cop.global_position = chapel.global_transform * Vector3(ChurchChoir.ENTRANCE_X, 0.1, ChurchChoir.HALF_Z + 1.0)
	cop.global_rotation.y = 0.0
	await wait_physics_frames(2)
	for i in 30:
		cop.step(1.0 / 60.0, Vector2(0, -1), false, false, false)
		chapel.door_lady._physics_process(1.0 / 60.0)


func test_the_lady_at_the_door_wants_a_robe() -> void:
	var cop: Cop = chapel.get_node("Cop")
	cop.put_on_disguise("wig", 0.0)
	cop.put_on_disguise("mustache", 0.0)
	await _walk_in(cop)
	assert_eq(chapel.door_lady.said(), "DOORLADY_NO_1", "a grandparent's disguise isn't a robe")
	var inside_z := (chapel.global_transform.affine_inverse() * cop.global_position).z
	assert_gt(inside_z, ChurchChoir.HALF_Z - 0.5, "didn't get in")


func test_the_lady_at_the_door_lets_a_chorister_in() -> void:
	var cop: Cop = chapel.get_node("Cop")
	cop.put_on_disguise("robe", 0.0)
	await _walk_in(cop)
	assert_eq(chapel.door_lady.said(), "DOORLADY_WELCOME")
