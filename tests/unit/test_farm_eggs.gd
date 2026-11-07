extends GutTest

## The farm's fragile things (docs/diseno/allanamiento-granja.md, "Lo frágil", step 5): the eggs on the stall break
## when they hit something fast and each one adds 2 to Don Florencio's complaint, the greenhouse's glass breaks when
## something hits it fast (a fine), and in the golden eggs story the hens lay eggs, some of them gold.

const RAID_SCENE := preload("res://scenes/levels/farm_raid.tscn")


func _farm() -> FarmRaid:
	var farm: FarmRaid = RAID_SCENE.instantiate()
	farm.case_seed = 5
	farm.story_id = "golden_eggs"
	farm.get_node("Cop").input_enabled = false
	farm.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(farm)
	return farm


func test_the_stall_eggs_sit_whole_and_a_thrown_one_breaks() -> void:
	var farm := _farm()
	await wait_physics_frames(60)
	assert_eq(farm.eggs.size(), FarmRaid.BASKETS.size() * FarmRaid.EGGS_PER_BASKET, "nothing broke by itself")
	var egg := farm.eggs[0]
	egg.global_position += Vector3.UP * 1.5
	egg.linear_velocity = Vector3.DOWN * 5.0
	await wait_physics_frames(30)
	assert_false(is_instance_valid(egg), "splat")
	assert_eq(farm.eggs.size(), FarmRaid.BASKETS.size() * FarmRaid.EGGS_PER_BASKET - 1)
	assert_eq(farm.broken_goods, 1)
	assert_eq(farm.owner_npc.complaint, FarmOwner.EGG_BROKEN)


func test_the_greenhouse_breaks_once_with_a_fine() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	farm.break_greenhouse()
	farm.break_greenhouse()
	assert_true(farm.greenhouse_broken)
	assert_eq(farm.fines, FarmRaid.GLASS_FINE, "fined once")
	assert_eq(farm.broken_goods, 1)


func test_the_hens_lay_and_every_third_egg_is_gold() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	var rig := farm.rig as GoldenEggsRig
	var before := farm.eggs.size()
	var laid: Array[FarmEgg] = []
	for i in GoldenEggsRig.GOLD_EVERY:
		laid.append(rig.lay())
	assert_eq(farm.eggs.size(), before + GoldenEggsRig.GOLD_EVERY)
	assert_false(laid[0].golden)
	assert_true(laid[GoldenEggsRig.GOLD_EVERY - 1].golden, "a golden one")
	assert_true(laid[GoldenEggsRig.GOLD_EVERY - 1].has_meta("golden"))
