extends GutTest

## The farm raid's case (docs/diseno/allanamiento-granja.md, step 5): the same RaidCase as the other places, with the
## golden eggs story: its box, paint and leaflet in spots drawn with the seed, Don Florencio's slips, Pancho's clue,
## the suspicion notes on the yard and the lead egg that goes "clonc".

const RAID_SCENE := preload("res://scenes/levels/farm_raid.tscn")


func _farm(case_seed := 5, story := "golden_eggs") -> FarmRaid:
	var farm: FarmRaid = RAID_SCENE.instantiate()
	farm.case_seed = case_seed
	farm.story_id = story
	farm.get_node("Cop").input_enabled = false
	farm.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(farm)
	return farm


func test_the_story_hides_its_box_paint_and_leaflet() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	assert_eq(farm.raid.story_id, "golden_eggs")
	assert_eq(farm.hidden.size(), 3)
	assert_eq(farm.main, farm.hidden[0])
	assert_eq(farm.main.mass, 6.0)
	assert_eq(farm.main.full_value, 1000.0)
	assert_eq(farm.extras.size(), 2)
	assert_true(FarmRaid.SPOTS[farm.hidden_spots[0]].heavy, "the 6 kg box goes where heavy things fit")
	assert_true(FarmGoat.is_paper(farm.extras[1]), "Tota would eat the leaflet")
	assert_eq(farm.raid.suspicions.size(), 3)
	assert_has(farm.raid.suspicions, "golden_eggs")
	assert_eq(farm.raid.owner_npc, farm.owner_npc)


func test_the_seed_draws_where_things_go() -> void:
	var a := _farm(5)
	var spots_a := a.hidden_spots.duplicate()
	a.free()
	var b := _farm(5)
	assert_eq(b.hidden_spots, spots_a, "same seed, same spots")
	assert_eq(FarmRaid.pick_story(3, PackedStringArray(["--story=golden_eggs"])), "golden_eggs")
	await wait_physics_frames(1)


func test_florencio_slips_and_pancho_tells() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	assert_eq(farm.owner_npc.slips.size(), 3, "one slip per hidden thing")
	assert_ne(farm.pancho.clue, "")
	assert_ne(farm.pancho.clue_speech, "")
	var notes := farm.get_children().filter(func(n: Node) -> bool: return n is ClueNote)
	assert_eq(notes.size(), 3, "one note per suspicion on the yard")


func test_the_lead_egg_goes_clonc_once_on_the_checklist() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	var rig := farm.rig as GoldenEggsRig
	assert_not_null(rig.lead_egg)
	rig.lead_egg.global_position += Vector3.UP * 1.5
	rig.lead_egg.linear_velocity = Vector3.ZERO
	watch_signals(rig)
	await wait_physics_frames(90)
	assert_signal_emitted(rig, "clonked")
	assert_true(farm.raid.clues_found.has(tr("CLUE_LEAD_EGG")))
	assert_true(is_instance_valid(rig.lead_egg), "it doesn't break")
