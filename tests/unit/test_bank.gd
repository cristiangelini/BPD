extends GutTest

## The neighborhood bank (robo-banco.md, step 1, decision 102): its lot in the city, the counter, the vault closed by
## its steel door, the locked back door, the vent high on the west wall and the robbers' van at the curb.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel


func before_each() -> void:
	bank = LEVEL.instantiate()
	# A base robbery's seed: the party (robo-banco-rehenes.md) has its own tests.
	bank.case_seed = 4
	bank.get_node("Cop").input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)


func test_it_has_its_lot_and_play_can_open_it() -> void:
	assert_false(CityLayout.place("bank").is_empty())
	assert_eq(PlaceDraw.pick(1234, PackedStringArray(["--place=bank"])), "bank")
	assert_true(ResourceLoader.exists(PlaceDraw.PLACES["bank"]))


func test_the_vault_door_closes_the_doorway() -> void:
	var local := bank.vault_door.position
	assert_almost_eq(local.x, BankLevel.VAULT_X - 0.15, 0.01)
	assert_almost_eq(local.z, BankLevel.VAULT_DOOR_Z, 0.01)
	assert_gt(BankLevel.VAULT_DOOR_RADIUS * 2, GameScale.COP_HEIGHT, "no cop walks under it")


func test_the_back_door_is_locked() -> void:
	assert_true(bank.back_door.locked)


func test_the_vent_needs_a_partner_to_reach() -> void:
	assert_gt(BankLevel.VENT_BOTTOM, GameScale.JUMP_HEIGHT, "a jump alone doesn't reach")
	assert_lt(BankLevel.VENT_BOTTOM, GameScale.COP_HEIGHT + GameScale.JUMP_HEIGHT, "standing on a partner does")
	assert_gt(BankLevel.VENT_SIZE.y, GameScale.CROUCH_HEIGHT, "a crouching cop fits through")


func test_the_hostages_floor_is_in_the_hall() -> void:
	var center := BankLevel.HOSTAGE_AREA.get_center()
	assert_true(bank.in_hostage_area(bank.global_transform * Vector3(center.x, 0, center.y)))
	assert_gt(BankLevel.HOSTAGE_AREA.position.y, BankLevel.COUNTER_Z, "in front of the counter")


func test_the_van_waits_at_the_curb_outside() -> void:
	assert_not_null(bank.van)
	assert_false(bank.inside(bank.van.global_position))
	assert_gt(bank.van.position.z, BankLevel.HALF_Z + CityLayout.SIDEWALK, "past the sidewalk")


func test_the_cops_start_at_the_station() -> void:
	var cop: Cop = bank.get_node("Cop")
	var station := bank.city.global_transform * CityLayout.lot("station")
	assert_lt(cop.global_position.distance_to(station * StationRooms.SPAWNS[0]), 0.5)
