extends GutTest

## The costume party's case (infiltracion-fiesta.md, step 4, decision 171): the infiltration case with the hall's
## texts, 3 of its 6 clues by the seed, each telling a different bit of the boss's costume on the planilla, the fourth
## told by seeing him in the office; cuffing the Sargento Trucho solves it, and a wrong guest gets a second chance.

const LEVEL := preload("res://scenes/levels/party_hall.tscn")

var hall: PartyHall
var cop: Cop


## A hall whose seed has the clue `kind`.
func _hall_with(kind: String) -> void:
	var case_seed := 1
	while true:
		hall = LEVEL.instantiate()
		hall.case_seed = case_seed
		hall.get_node("Cop").input_enabled = false
		add_child_autofree(hall)
		if hall.evidence.kinds.has(kind):
			break
		hall.free()
		case_seed += 1
	cop = hall.get_node("Cop")
	await wait_physics_frames(2)
	hall.photo.set_process(false)
	hall.case.give_tip()


func test_the_party_case_with_its_own_texts() -> void:
	await _hall_with("ticket")
	assert_eq(hall.case.place, hall)
	assert_eq(hall.case.texts(), InfiltrationCase.VARIANTS["party"])
	assert_eq(hall.case.rows()[0].text, "OBJ_PARTY_GET_IN")
	assert_eq(hall.evidence.kinds.size(), ClubEvidence.COUNT)


func test_each_clue_tells_a_different_bit_and_the_office_the_last() -> void:
	for case_seed in range(1, 9):
		var other: PartyHall = LEVEL.instantiate()
		other.case_seed = case_seed
		other.get_node("Cop").input_enabled = false
		add_child_autofree(other)
		var told: Array = other.clues.values()
		told.append(other.bonus_kind)
		told.sort()
		var all := PartyTraits.KINDS.duplicate()
		all.sort()
		assert_eq(told, all, "seed %d: the 3 clues and the office tell the 4 bits once each" % case_seed)
		for kind: String in PartyHall.CLUE_OF:
			if other.clues.has(kind):
				assert_eq(other.clues[kind], PartyHall.CLUE_OF[kind])
		other.free()


func test_grabbing_the_coat_check_ticket() -> void:
	await _hall_with("ticket")
	var ticket: Grabbable = hall.evidence.items["ticket"]
	var local := hall.global_transform.affine_inverse() * ticket.global_position
	assert_almost_eq(local.z, PartyHall.COAT_COUNTER_Z, 0.3, "on the coat check's counter")
	assert_gt(local.x, PartyHall.COAT_CHECK.position.x)
	assert_lt(local.x, PartyHall.COAT_CHECK.end.x)
	cop.global_position = ticket.global_position + Vector3(0, -0.8, 1.0)
	cop.get_node("Grabber").grab(ticket)
	await wait_physics_frames(2)
	assert_has(hall.case.evidence_found, "ticket")


func test_photographing_the_jewel_bag_and_the_old_photo() -> void:
	for kind: String in ["hair", "old_photo"]:
		await _hall_with(kind)
		var spot: ClubEvidenceSpot = hall.get_node("Evidence_" + kind)
		spot.use(cop)
		assert_false(hall.case.evidence_found.has(kind), "E isn't a photo")
		spot.photographed(cop)
		assert_has(hall.case.evidence_found, kind)
		hall.queue_free()
		await wait_physics_frames(1)


func test_the_clues_are_in_their_rooms() -> void:
	await _hall_with("hair")
	assert_true(hall.in_restroom(hall.get_node("Evidence_hair").global_position))
	var other: PartyHall = hall
	await _hall_with("old_photo")
	assert_ne(other, hall)
	assert_true(hall.in_back_room(hall.get_node("Evidence_old_photo").global_position))


func test_the_planilla_writes_down_the_boss_s_costume() -> void:
	await _hall_with("ticket")
	TranslationServer.set_locale("es")
	var cap: String = hall.guest_traits[hall.members.find(hall.boss)].cap
	hall.case.found("ticket")
	var row: String = hall.case.rows().filter(func(r: Dictionary) -> bool: return r.has("clue")).back().text
	assert_string_contains(row, tr("TRAIT_CAP_" + cap.to_upper()))
	assert_eq(row.count(tr("PARTY_TRAIT_UNKNOWN")), 3, "the other three still unknown")


func test_seeing_the_boss_in_the_office_tells_the_last_bit() -> void:
	await _hall_with("ticket")
	TranslationServer.set_locale("es")
	hall.photo.boss_seen.emit(cop)
	assert_true(hall.case.bonus_clue)
	var boss_traits: Dictionary = hall.guest_traits[hall.members.find(hall.boss)]
	var bit := "TRAIT_%s_%s" % [hall.bonus_kind, boss_traits[hall.bonus_kind]]
	assert_string_contains(hall.clue_row([], true), tr(bit.to_upper()))
	assert_true(hall.case.snapshot().bonus, "the guests' cases see it too")


func test_the_hostess_tells_only_with_no_guest_near() -> void:
	await _hall_with("hostess")
	var near := hall.members[0]
	near.global_position = hall.serpentina.global_position + Vector3(1.0, 0, 0)
	hall.serpentina.use(cop)
	assert_false(hall.case.evidence_found.has("hostess"), "a guest would hear her")
	for guest: ClubMember in hall.members:
		guest.global_position = hall.global_transform * Vector3(5.0, PartyHall.FLOOR_TOP, 0)
	hall.serpentina.use(cop)
	assert_has(hall.case.evidence_found, "hostess")


func test_the_recording_guests_mingle_by_each_other() -> void:
	await _hall_with("recording")
	assert_eq(hall.evidence.talkers.size(), 2)
	assert_false(hall.evidence.talkers.has(hall.boss))
	var apart := hall.evidence.talkers[0].global_position.distance_to(hall.evidence.talkers[1].global_position)
	assert_lt(apart, ClubEvidence.RECORD_REACH * 2, "a cop can stand by both")


func test_cuffing_the_sargento_trucho_solves_it() -> void:
	await _hall_with("ticket")
	for kind: String in hall.evidence.kinds.slice(0, 2):
		hall.case.found(kind)
	hall.boss.cuffed(20.0)
	assert_true(hall.case.solved())
	assert_false(hall.suspicion.found_out, "he is a guest, but cuffing him isn't a mistake")
	assert_eq(hall.case.report().salary, InfiltrationCase.SALARY * 2 / 3)
	assert_eq(hall.case.custody().owner, "trucho")


func test_a_wrong_guest_gets_a_second_chance() -> void:
	await _hall_with("ticket")
	var wrong := hall.members[0] if hall.members[0] != hall.boss else hall.members[1]
	var other := hall.members.filter(func(g: ClubMember) -> bool: return g != wrong and g != hall.boss)[0] as ClubMember
	wrong.cuffed(5.0)
	assert_false(hall.suspicion.found_out, "the first time only raises them")
	assert_almost_eq(other.suspicion, InfiltrationCase.WRONG_CUFF, 0.01)
	wrong.cuffed(5.0)
	assert_true(hall.suspicion.found_out, "the second time gives them away")


func test_the_case_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	var keys: Array[String] = ["HINT_GO_PARTY", "HINT_PARTY_IN", "HINT_PARTY_CLUE", "HINT_WRONG_GUEST",
		"HINT_TRUCHO_CUFFED", "HINT_ESCAPE_trucho", "OBJ_PARTY_CUFF_TRUCHO", "OBJ_PARTY_CATCH_TRUCHO",
		"OBJ_PARTY_CAREFUL", "OBJ_PARTY_FOUND_OUT", "OBJ_PARTY_EVIDENCE", "PARTY_BOSS_ROW", "PARTY_TRAIT_UNKNOWN",
		"SERPENTINA_TELLS", "CRIME_owner_trucho", "CONFESS_owner_trucho"]
	keys.append_array(InfiltrationCase.VARIANTS["party"].brief)
	for kind: String in PartyHall.EVIDENCE_KINDS:
		keys.append("EVIDENCE_PARTY_" + kind)
	for kind: String in ["hair", "old_photo"]:
		keys.append("PROMPT_PARTY_" + kind)
	for kind: String in PartyTraits.KINDS:
		for value: String in PartyTraits.VALUES[kind]:
			keys.append(("TRAIT_%s_%s" % [kind, value]).to_upper())
	for i in 4:
		keys.append("PARTY_TALK_%d" % i)
	for i in 3:
		keys.append("TRUCHO_SLIP_%d" % (i + 1))
		keys.append("CHASE_TRUCHO_LINE_%d" % (i + 1))
	for key in keys:
		assert_ne(tr(key), key)
