extends GutTest

## Tota the goat and the pigs at the farm raid (docs/diseno/allanamiento-granja.md, step 4): she eats the paper she
## finds on the ground and gives it back chewed in the corral, leaves what's heavy or held alone, and the pigs shove
## whoever comes into the mud.

const RAID_SCENE := preload("res://scenes/levels/farm_raid.tscn")
const NOTE_SCENE := preload("res://scenes/props/clue_note.tscn")


func _farm() -> FarmRaid:
	var farm: FarmRaid = RAID_SCENE.instantiate()
	farm.case_seed = 7
	farm.get_node("Cop").input_enabled = false
	farm.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(farm)
	return farm


func _note(farm: FarmRaid, at: Vector3) -> ClueNote:
	var note: ClueNote = NOTE_SCENE.instantiate()
	note.position = at
	farm.add_child(note)
	return note


func test_only_light_loose_paper_is_food() -> void:
	var farm := _farm()
	await wait_physics_frames(1)
	var note := _note(farm, Vector3(0, 1, 0))
	assert_true(FarmGoat.is_paper(note))
	var brick := Grabbable.new()
	brick.mass = 3.0
	brick.set_meta("paper", true)
	assert_false(FarmGoat.is_paper(brick), "too heavy for a paper")
	brick.free()
	assert_false(FarmGoat.is_paper(farm.hens[0]), "she doesn't eat hens")


func test_tota_eats_a_note_and_gives_it_back_chewed_in_the_corral() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	var goat := farm.goat
	var note := _note(farm, goat.position + Vector3(0.4, 0.05, 0))
	watch_signals(goat)
	await wait_physics_frames(40)
	assert_signal_emitted(goat, "ate")
	assert_false(note.visible, "gone into the goat")
	goat.eaten[note] = 0.01
	await wait_physics_frames(2)
	assert_signal_emitted(goat, "gave_back")
	assert_true(note.visible)
	assert_true(note.get_meta("chewed", false), "a little chewed")
	var back := farm.to_local(note.global_position)
	assert_true(FarmRaid.CORRAL.has_point(Vector2(back.x, back.z)), "she gives it back in the corral")


func test_the_pigs_wallow_in_the_mud_and_shove_who_comes_in() -> void:
	var farm := _farm()
	await wait_physics_frames(2)
	assert_eq(farm.pigs.size(), FarmRaid.PIGS)
	for pig: FarmPig in farm.pigs:
		assert_true(FarmRaid.MUD.has_point(Vector2(pig.position.x, pig.position.z)), "in the mud")
	var pig := farm.pigs[0]
	var cop: Cop = farm.get_node("Cop")
	cop.global_position = pig.global_position + Vector3(0.6, 0.05, 0)
	watch_signals(pig)
	pig._shove()
	assert_signal_emitted(pig, "shoved")
	assert_true(cop.is_staggered())
