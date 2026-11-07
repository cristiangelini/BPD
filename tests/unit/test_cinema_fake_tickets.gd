extends GutTest

## The cinema's fake tickets story (allanamiento-cine.md, step 6): the ticket press hidden with its extras, "AGOTADO"
## over the ticket booth, and two neighbors side by side arguing over the same seat, the clue for a cop who gets close.

const SCENE := preload("res://scenes/levels/cinema.tscn")


func _cinema(case_seed := 5) -> Cinema:
	var cinema: Cinema = SCENE.instantiate()
	cinema.story_id = "fake_tickets"
	cinema.case_seed = case_seed
	cinema.get_node("Cop").input_enabled = false
	cinema.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(cinema)
	return cinema


func test_the_press_is_hidden_with_its_extras() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	assert_has(cinema.raid.suspicions, "fake_tickets")
	assert_eq(cinema.main, cinema.hidden[0])
	assert_almost_eq((cinema.main as RigidBody3D).mass, 10.0, 0.01)
	assert_true(Cinema.SPOTS[cinema.hidden_spots[0]].heavy, "the press in a spot it fits")
	assert_eq(cinema.extras.size(), 2, "the stamp and the ticket book")


func test_two_neighbors_argue_over_the_same_seat() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	var rig := cinema.rig as FakeTicketsRig
	assert_eq(rig.arguers.size(), 2)
	assert_eq(rig.arguers[1].seat, rig.arguers[0].seat + 1, "side by side")
	assert_has(cinema.spectators, rig.arguers[0])
	assert_eq(rig.sold_out.text, "CINEMA_SOLD_OUT")
	await wait_seconds(0.3)
	assert_eq(rig.arguers[0].said(), tr("CINEMA_SAME_SEAT_1"))
	await wait_seconds(FakeTicketsRig.ARGUE_EVERY)
	assert_eq(rig.arguers[1].said(), tr("CINEMA_SAME_SEAT_2"), "and the other answers")
	rig.arguers[0].use(cinema.get_node("Cop"))
	assert_eq(rig.arguers[0].said(), "CINEMA_SAME_SEAT_TICKET")


func test_getting_close_to_them_is_a_clue_once() -> void:
	var cinema := _cinema()
	await wait_physics_frames(2)
	var rig := cinema.rig as FakeTicketsRig
	var cop: Cop = cinema.get_node("Cop")
	cop.global_position = rig.arguers[0].global_position + Vector3(0, 0.2, -1.0)
	await wait_physics_frames(6)
	assert_true(rig.heard_by.has(cop))
	assert_has(cinema.raid.clues_found, tr("CLUE_SAME_SEAT"))
	var clues: int = cinema.raid.clues_found.size()
	rig.overhear(cop)
	assert_eq(cinema.raid.clues_found.size(), clues, "the clue only once")


func test_the_stories_texts_exist() -> void:
	for key: String in ["BRIEF_FAKE_TICKETS_B", "BRIEF_FAKE_TICKETS_C", "BRIEF_FAKE_TICKETS_D", "OBJ_FIND_TICKET_PRESS",
			"OBJ_EXTRA_SOLD_OUT_STAMP", "OBJ_EXTRA_TICKET_BOOK", "CHICHO_CLUE_fake_tickets", "CINEMA_SOLD_OUT",
			"CINEMA_SAME_SEAT_TICKET", "HINT_SAME_SEAT", "CLUE_SAME_SEAT"]:
		assert_ne(tr(key), key)
	for key: String in FakeTicketsRig.ARGUMENT:
		assert_ne(tr(key), key)
