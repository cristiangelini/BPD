extends GutTest

## The fun fair raid with the fake tickets (allanamiento-parque.md, step 6): the printing machine in the patrol car's
## trunk, tickets with the same number and the ticket booth that prints by itself.

const SCENE := preload("res://scenes/levels/fair.tscn")


func _fair(case_seed := 5) -> Fair:
	var fair: Fair = SCENE.instantiate()
	fair.story_id = "fake_tickets"
	fair.case_seed = case_seed
	fair.get_node("Cop").input_enabled = false
	fair.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(fair)
	return fair


func test_the_printer_hides_where_it_fits_and_solves_the_case() -> void:
	var fair := _fair()
	await wait_physics_frames(10)
	assert_has(fair.raid.suspicions, "fake_tickets")
	assert_eq(fair.main.scene_file_path, "res://scenes/props/fair_ticket_printer.tscn")
	assert_true(Fair.SPOTS[fair.hidden_spots[0]].heavy, "the machine only goes where it fits")
	assert_eq(fair.extras.size(), 2, "the rolls and the stamp")
	fair.main.global_position = fair.car.to_global(Vector3(0, 0.7, -1.7))
	await wait_physics_frames(10)
	assert_true(fair.car.is_delivered(fair.main))
	assert_true(fair.raid.mark(fair.raid.suspicions.find("fake_tickets")))
	fair.car.enter(fair.get_node("Cop"))
	assert_true(fair.raid.case_solved)


func test_two_tickets_read_with_the_same_number_is_the_clue() -> void:
	var fair := _fair()
	await wait_physics_frames(2)
	var rig := fair.rig as FakeTicketsRig
	var cop: Cop = fair.get_node("Cop")
	assert_eq(rig.tickets.size(), FakeTicketsRig.TICKETS.size())
	rig.tickets[0].use(cop)
	assert_does_not_have(fair.raid.clues_found, tr("CLUE_SAME_TICKETS"), "one ticket says nothing")
	rig.tickets[0].use(cop)
	assert_does_not_have(fair.raid.clues_found, tr("CLUE_SAME_TICKETS"), "the same one twice neither")
	rig.tickets[1].use(cop)
	assert_has(fair.raid.clues_found, tr("CLUE_SAME_TICKETS"))
	assert_does_not_have(fair.raid.clues_found, tr("FAIR_TICKET"), "the ticket itself isn't a clue")


func test_the_ticket_booth_prints_by_itself_up_to_a_few() -> void:
	var fair := _fair()
	await wait_physics_frames(2)
	var rig := fair.rig as FakeTicketsRig
	rig._since_print = FakeTicketsRig.PRINT_EVERY
	await wait_physics_frames(2)
	assert_eq(rig.printed, 1)
	assert_eq(rig.tickets.size(), FakeTicketsRig.TICKETS.size() + 1)
	for i in FakeTicketsRig.PRINTED_MAX + 2:
		rig.print_ticket()
	assert_eq(rig.printed, FakeTicketsRig.PRINTED_MAX, "no more than a few lying around")


func test_the_texts_are_translated() -> void:
	for key: String in ["BRIEF_FAKE_TICKETS_B", "BRIEF_FAKE_TICKETS_C", "BRIEF_FAKE_TICKETS_D",
			"OBJ_FIND_TICKET_PRINTER", "OBJ_EXTRA_TICKET_ROLLS", "OBJ_EXTRA_VALID_STAMP", "NUBE_CLUE_fake_tickets",
			"FAIR_TICKET", "CLUE_SAME_TICKETS", "FAIR_PRINTER_WHIR"]:
		assert_ne(tr(key), key, key)
