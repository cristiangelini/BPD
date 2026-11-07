extends GutTest

## The farm as a place to raid (docs/diseno/allanamiento-granja.md, step 2): its block in the city, the fence with its
## gate, the open house and the locked shed, the eggs and the greenhouse, the 12 hiding spots and the slippery mud.

const RAID_SCENE := preload("res://scenes/levels/farm_raid.tscn")


func _farm() -> FarmRaid:
	var farm: FarmRaid = RAID_SCENE.instantiate()
	farm.get_node("Cop").input_enabled = false
	farm.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(farm)
	return farm


func test_the_farm_fills_its_own_corner_block() -> void:
	var farm := CityLayout.place("farm")
	assert_eq(farm.block, Vector2i(8, 5))
	assert_true(CityLayout.is_park(farm.block), "the city leaves the block grass for the farm's scene")
	for other: Dictionary in CityLayout.PLACES:
		if other.id != "farm":
			assert_ne(other.block, farm.block, "%s shares the farm's block" % other.id)
	assert_true(CityLayout.blocks().has(farm.block))
	assert_true(PlaceDraw.PLACES.has("farm_raid"), "--place=farm_raid opens it")


func test_the_farm_has_its_doors_eggs_and_glass() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	assert_false(farm.house_door.locked, "the house is open")
	assert_true(farm.shed_door.locked, "the tool shed is locked")
	assert_eq(farm.baskets.size(), FarmRaid.BASKETS.size())
	assert_not_null(farm.greenhouse)
	assert_gt(farm.greenhouse.get_child_count(), 0)


func test_the_spots_are_inside_the_fence_and_half_fit_heavy_things() -> void:
	assert_eq(FarmRaid.SPOTS.size(), 12)
	assert_eq(FarmRaid.SPOTS.filter(func(spot: Dictionary) -> bool: return spot.heavy).size(), 6)
	var inside := Rect2(-FarmRaid.FENCE_HALF.x, FarmRaid.FENCE_Z - FarmRaid.FENCE_HALF.y, FarmRaid.FENCE_HALF.x * 2,
		FarmRaid.FENCE_HALF.y * 2)
	var ids := {}
	for spot: Dictionary in FarmRaid.SPOTS:
		assert_true(inside.has_point(Vector2(spot.at.x, spot.at.z)), "%s is inside the fence" % spot.id)
		ids[spot.id] = true
	assert_eq(ids.size(), FarmRaid.SPOTS.size(), "no two spots share an id")
	assert_true(FarmRaid.in_mud(FarmRaid.SPOTS.filter(func(s: Dictionary) -> bool: return s.id == "in_mud")[0].at))


func test_running_in_the_mud_slips_and_walking_does_not() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	var cop: Cop = farm.get_node("Cop")
	cop.global_position = farm.to_global(Vector3(12.5, FarmRaid.GROUND + 0.05, 6.5))
	cop.is_running = true
	cop.velocity = Vector3(GameScale.WALK_SPEED * 0.8, 0, 0)
	farm._physics_process(0.016)
	assert_false(cop.is_staggered(), "slow is fine")
	cop.velocity = Vector3(GameScale.RUN_SPEED, 0, 0)
	farm._physics_process(0.016)
	assert_true(cop.is_staggered(), "running in the mud slips")
	assert_false(FarmRaid.in_mud(Vector3(0, FarmRaid.GROUND, 3.5)), "the yard isn't mud")
