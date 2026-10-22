extends GutTest

## The club case's evidence (infiltracion.md, step 6b): 3 of 6 kinds by the seed, each found its own way.

const LEVEL := preload("res://scenes/levels/grandpa_club.tscn")

var club: GrandpaClub
var cop: Cop


## A club whose seed draws `kind`.
func _club_with(kind: String) -> void:
	var case_seed := 1
	while true:
		var drawn := ClubEvidence.draw(case_seed, ClubEvidence.KINDS)
		if drawn.has(kind):
			break
		case_seed += 1
	club = LEVEL.instantiate()
	club.case_seed = case_seed
	cop = club.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(club)
	await wait_physics_frames(2)
	club.bingo.set_physics_process(false)
	club.dance.set_process(false)
	club.case.give_tip()


func test_three_of_six_by_the_seed() -> void:
	var drawn := ClubEvidence.draw(77, ClubEvidence.KINDS)
	assert_eq(drawn.size(), ClubEvidence.COUNT)
	assert_eq(ClubEvidence.draw(77, ClubEvidence.KINDS), drawn, "same seed, same evidence")
	for kind in drawn:
		assert_has(ClubEvidence.KINDS, kind)


func test_only_the_drawn_ones_are_in_the_club() -> void:
	await _club_with("bag")
	assert_not_null(club.get_node_or_null("Evidence_bag"))
	for kind: String in ["press", "bag"]:
		assert_eq(club.get_node_or_null("Evidence_" + kind) != null, club.evidence.kinds.has(kind))


func test_searching_the_bag() -> void:
	await _club_with("bag")
	(club.get_node("Evidence_bag") as ClubEvidenceSpot).use(cop)
	assert_has(club.case.evidence_found, "bag")


func test_the_press_counts_only_photographed() -> void:
	await _club_with("press")
	var press: ClubEvidenceSpot = club.get_node("Evidence_press")
	press.use(cop)
	assert_does_not_have(club.case.evidence_found, "press")
	press.photographed(cop)
	assert_has(club.case.evidence_found, "press")


func test_grabbing_the_notebook() -> void:
	await _club_with("notebook")
	var notebook: Grabbable = club.evidence.items["notebook"]
	cop.get_node("Grabber").grab(notebook)
	await wait_physics_frames(2)
	assert_has(club.case.evidence_found, "notebook")


func test_the_office_key_is_in_a_kitchen_pot() -> void:
	await _club_with("notebook")
	var pot: KeyPot = club.get_node("KeyPot")
	pot.use(cop)
	assert_true(cop.has_key)


func test_recording_the_talkers() -> void:
	await _club_with("recording")
	var talkers := club.evidence.talkers
	assert_eq(talkers.size(), 2)
	assert_true(talkers[0].distracted, "busy talking")
	cop.global_position = (talkers[0].global_position + talkers[1].global_position) / 2 + Vector3(0, 0.1, 0)
	cop.belt_select(2)
	for i in int(ClubEvidence.RECORD_TIME / 0.5) + 1:
		club.evidence._physics_process(0.5)
	assert_has(club.case.evidence_found, "recording")


func test_without_the_camera_nothing_is_recorded() -> void:
	await _club_with("recording")
	var talkers := club.evidence.talkers
	cop.global_position = (talkers[0].global_position + talkers[1].global_position) / 2 + Vector3(0, 0.1, 0)
	for i in 20:
		club.evidence._physics_process(0.5)
	assert_does_not_have(club.case.evidence_found, "recording")
