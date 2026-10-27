extends GutTest

## The living scarecrow story (docs/diseno/allanamiento-granja.md, step 6): the costume stuffed with banknotes, the
## cousin's hat and the clipping, the scarecrow that moves while nobody looks and sneezes when stared at up close.

const RAID_SCENE := preload("res://scenes/levels/farm_raid.tscn")


func _farm(case_seed := 5) -> FarmRaid:
	var farm: FarmRaid = RAID_SCENE.instantiate()
	farm.case_seed = case_seed
	farm.story_id = "living_scarecrow"
	farm.get_node("Cop").input_enabled = false
	farm.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(farm)
	return farm


## Puts the cop `distance` m in front of the scarecrow, looking at its head (or away from it).
func _face(farm: FarmRaid, cop: Cop, distance: float, toward := true) -> void:
	var head := farm.scarecrow.global_position + Vector3.UP * LivingScarecrowRig.HEAD
	cop.global_position = farm.scarecrow.global_position + farm.global_basis.z * distance
	var eye := cop.camera.global_position
	var target := head if toward else eye + (eye - head)
	cop.camera.look_at(target)


func test_the_story_hides_the_costume_the_hat_and_the_clipping() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	assert_true(farm.rig is LivingScarecrowRig)
	assert_eq(farm.main.mass, 4.0)
	assert_eq(farm.main.full_value, 1000.0)
	assert_eq(farm.extras.map(func(e: Evidence) -> float: return e.full_value), [300.0, 200.0])
	assert_true(FarmGoat.is_paper(farm.extras[1]), "Tota eats the clipping if she finds it")
	assert_has(farm.raid.suspicions, "living_scarecrow")


func test_it_moves_only_while_nobody_looks() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	var rig := farm.rig as LivingScarecrowRig
	var cop: Cop = farm.get_node("Cop")
	_face(farm, cop, 8.0)
	assert_true(rig.seen())
	rig._move_left = 0.02
	await wait_physics_frames(3)
	assert_eq(rig.place, 0, "it stays put while a cop watches")
	_face(farm, cop, 8.0, false)
	assert_false(rig.seen())
	rig._move_left = 0.02
	await wait_physics_frames(3)
	assert_eq(rig.place, 1)
	assert_almost_eq(farm.scarecrow.position.x, LivingScarecrowRig.PLACES[1].x, 0.01)


func test_staring_up_close_makes_it_sneeze() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	var rig := farm.rig as LivingScarecrowRig
	var cop: Cop = farm.get_node("Cop")
	watch_signals(rig)
	_face(farm, cop, 2.5)
	rig._physics_process(LivingScarecrowRig.STARE - 0.5)
	assert_signal_not_emitted(rig, "sneezed", "not yet")
	rig._physics_process(0.6)
	assert_signal_emitted(rig, "sneezed")
	assert_true(farm.raid.clues_found.has(tr("CLUE_SCARECROW_SNEEZE")))
	_face(farm, cop, 12.0)
	rig._physics_process(LivingScarecrowRig.STARE + 1.0)
	assert_signal_emit_count(rig, "sneezed", 1, "from afar it holds it in")


func test_a_guest_sees_it_where_the_host_has_it() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	var rig := farm.rig as LivingScarecrowRig
	rig.apply_net_state(2)
	assert_eq(rig.place, 2)
	assert_almost_eq(farm.scarecrow.position.z, LivingScarecrowRig.PLACES[2].z, 0.01)
