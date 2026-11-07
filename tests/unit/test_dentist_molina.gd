extends GutTest

## Dr. Molina at the dental office raid (allanamiento-dentista.md, step 3): his round along the corridor, the
## next-patient bell that sends him to consulting room 1 with his back to the door, the bell's rest after it, and the
## molds, chairs, fish tank and door that go on his complaint.

const RAID_SCENE := preload("res://scenes/levels/dentist_raid.tscn")


func _office() -> DentistRaid:
	var office: DentistRaid = RAID_SCENE.instantiate()
	office.get_node("Cop").input_enabled = false
	office.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(office)
	return office


## Keeps him standing at `at` (his round is just there).
func _stand(office: DentistRaid, at: Vector3) -> void:
	office.molina.global_position = at
	office.molina.route = [at, at + Vector3(0, 0, 0.1)]
	office.molina.start_at(0)


func test_he_walks_his_round_and_speaks_as_the_doctor() -> void:
	var office := _office()
	await wait_physics_frames(2)
	var start := office.molina.global_position
	await wait_seconds(3.0)
	assert_gt(office.molina.global_position.distance_to(start), 2.0, "he walks")
	assert_eq(office.molina.voice, "MOLINA")
	for key: String in ["MOLINA_LINE_1", "MOLINA_PRINTER", "MOLINA_FIX_1", "MOLINA_FIX_DONE", "MOLINA_HURT",
			"MOLINA_DOOR", "MOLINA_SAW", "MOLINA_NOTHING", "MOLINA_OFFENDED", "MOLINA_LAWYER", "MOLINA_MOLD",
			"MOLINA_CHAIR", "MOLINA_TANK", "PROMPT_NEXT_BELL", "HINT_BELL_BUSY", "HINT_BELL_RESTING", "DING_BELL"]:
		assert_ne(tr(key), key, "%s is translated" % key)


func test_the_bell_sends_him_to_his_patient_with_his_back_to_the_door() -> void:
	var office := _office()
	await wait_physics_frames(2)
	office.molina.fix_time = 1.5
	var cop: Cop = office.get_node("Cop")
	office.bell.button.use(cop)
	assert_true(office.bell.is_ringing())
	assert_eq(office.molina.errand(), "printer", "he goes to see the next patient")
	await wait_until(func() -> bool: return office.molina.is_fixing(), 15.0)
	assert_lt(office.molina.global_position.distance_to(DentistRaid.PATIENT_SPOT), 0.5, "beside chair 1")
	var door := Vector3(DentistRaid.ROOM_DOORS[0], 1.0, DentistRaid.ROOMS_Z)
	assert_false(office.molina.can_see(door), "his back to the door")
	await wait_seconds(1.8)
	assert_false(office.molina.is_fixing())
	assert_false(office.bell.is_ringing())
	assert_gt(office.bell.rest_left, 0.0, "the bell rests")
	office.bell.button.use(cop)
	assert_false(office.bell.is_ringing(), "not again until it rested")


func test_a_mold_he_sees_break_goes_on_the_complaint() -> void:
	var office := _office()
	await wait_physics_frames(2)
	_stand(office, Vector3(2.75, DentistRaid.FLOOR_TOP, -1.0))
	await wait_physics_frames(2)
	office.molds[0].hit(5.0)
	assert_eq(office.molina.complaint, DentistRaid.SAW_MOLD)
	assert_eq(office.molina.get_node("Bubble").text, "MOLINA_MOLD")


func test_a_cop_up_on_his_chair_goes_on_the_complaint_once() -> void:
	var office := _office()
	await wait_physics_frames(2)
	_stand(office, Vector3(-8.25, DentistRaid.FLOOR_TOP, 0.0))
	var cop: Cop = office.get_node("Cop")
	assert_eq(office.chair_under(DentistRaid.CHAIRS[0] + Vector3(0, 1.0, -0.3)), 0)
	assert_eq(office.chair_under(DentistRaid.CHAIRS[0] + Vector3(0, 0.1, 1.5)), -1, "beside it, on the floor")
	cop.global_position = DentistRaid.CHAIRS[0] + Vector3(0, 1.2, -0.3)
	await wait_physics_frames(3)
	assert_eq(office.molina.complaint, DentistRaid.SAW_IN_CHAIR)
	assert_eq(office.molina.get_node("Bubble").text, "MOLINA_CHAIR")
	await wait_physics_frames(10)
	assert_eq(office.molina.complaint, DentistRaid.SAW_IN_CHAIR, "once while the cop stays up there")


func test_the_fish_tank_and_the_storeroom_door_go_on_the_complaint() -> void:
	var office := _office()
	await wait_physics_frames(2)
	_stand(office, Vector3(6.0, DentistRaid.FLOOR_TOP, 5.5))
	await wait_physics_frames(2)
	office.break_fish_tank()
	assert_eq(office.molina.complaint, FloorBoss.SAW_BREAK)
	assert_eq(office.molina.get_node("Bubble").text, "MOLINA_TANK")
	office.storeroom_door.broken.emit()
	assert_eq(office.molina.complaint, FloorBoss.SAW_BREAK + FloorBoss.DOOR_BROKEN)


func test_at_100_he_calls_his_lawyer_and_the_case_fails() -> void:
	var office := _office()
	await wait_physics_frames(2)
	office.molina.praise(-FloorBoss.MAX_COMPLAINT, "MOLINA_SAW")
	assert_true(office.molina.has_called_lawyer)
	assert_true(office.get_node("%CaseFailed").visible)
	assert_eq(office.complaint_bar.value, FloorBoss.MAX_COMPLAINT)
