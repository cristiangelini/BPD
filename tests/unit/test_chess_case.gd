extends GutTest

## The chess club's case (infiltracion-ajedrez.md, step 5, decision 175): the infiltration case with the club's texts,
## 3 of its 6 pieces of evidence by the seed (the hollow black king on the stage, the briefcase under the Gran
## Maestro's chair, the coded score sheet in the cafeteria, the trophy cabinet, the ledger in the locked office, whose
## key is taped under table 8, and two members' gossip to record), the pleased players' tips and Alfil to cuff.

const LEVEL := preload("res://scenes/levels/chess_club.tscn")

var club: ChessClub
var cop: Cop


## A club whose seed has the evidence `kind`.
func _club_with(kind: String) -> void:
	var case_seed := 1
	while true:
		club = LEVEL.instantiate()
		club.case_seed = case_seed
		club.get_node("Cop").input_enabled = false
		add_child_autofree(club)
		if club.evidence.kinds.has(kind):
			break
		club.free()
		case_seed += 1
	cop = club.get_node("Cop")
	await wait_physics_frames(2)
	club.games.set_physics_process(false)
	club.case.give_tip()


## Solving it leaves Alfil in custody for the next shift's draw (RaidCase): not for the next test's.
func after_each() -> void:
	PlaceDraw.custody = {}


func test_the_chess_case_with_its_own_texts() -> void:
	await _club_with("king")
	assert_eq(club.case.place, club)
	assert_eq(club.case.texts(), InfiltrationCase.VARIANTS["chess"])
	assert_eq(club.case.rows()[0].text, "OBJ_CHESS_GET_IN")
	assert_eq(club.evidence.kinds.size(), ClubEvidence.COUNT)
	for kind: String in club.evidence.kinds:
		assert_has(ChessClub.EVIDENCE_KINDS, kind)


func test_grabbing_the_hollow_king_on_the_stage() -> void:
	await _club_with("king")
	var king: Grabbable = club.evidence.items["king"]
	assert_true(club.in_tournament(king.global_position))
	cop.global_position = king.global_position + Vector3(0, -1.0, 1.0)
	cop.get_node("Grabber").grab(king)
	await wait_physics_frames(2)
	assert_has(club.case.evidence_found, "king")


func test_grabbing_the_briefcase_under_the_chair() -> void:
	await _club_with("briefcase")
	var briefcase: Grabbable = club.evidence.items["briefcase"]
	assert_true(club.in_tournament(briefcase.global_position))
	cop.global_position = briefcase.global_position + Vector3(0, -0.1, 1.0)
	cop.get_node("Grabber").grab(briefcase)
	await wait_physics_frames(2)
	assert_has(club.case.evidence_found, "briefcase")


func test_the_office_key_is_taped_under_table_8() -> void:
	await _club_with("king")
	var key: KeyPot = club.get_node("KeyTable")
	assert_true(club.in_hall(key.global_position))
	assert_lt(Vector2(key.position.x - ChessClub.TABLES[ChessClub.KEY_TABLE].x,
		key.position.z - ChessClub.TABLES[ChessClub.KEY_TABLE].z).length(), 1.0, "by table 8")
	assert_eq(key.prompt_key(cop), "PROMPT_CHESS_TABLE_KEY")
	assert_true(club.office_door.locked)
	key.use(cop)
	assert_true(cop.has_key)


func test_photographing_the_score_sheet() -> void:
	await _club_with("sheet")
	var sheet: ClubEvidenceSpot = club.get_node("Evidence_sheet")
	assert_true(club.in_cafe(sheet.global_position))
	sheet.use(cop)
	assert_false(club.case.evidence_found.has("sheet"), "E isn't a photo")
	sheet.photographed(cop)
	assert_has(club.case.evidence_found, "sheet")


func test_searching_the_trophy_cabinet_and_the_office_desk() -> void:
	await _club_with("trophy")
	var cabinet: ClubEvidenceSpot = club.get_node("Evidence_trophy")
	assert_true(club.in_hall(cabinet.global_position))
	cabinet.use(cop)
	assert_has(club.case.evidence_found, "trophy")
	await _club_with("ledger")
	var desk: ClubEvidenceSpot = club.get_node("Evidence_ledger")
	assert_true(club.in_back_room(desk.global_position), "in Alfil's office")
	desk.use(cop)
	assert_has(club.case.evidence_found, "ledger")


func test_the_recording_pair_stands_by_each_other() -> void:
	await _club_with("recording")
	assert_eq(club.evidence.talkers.size(), 2)
	for talker in club.evidence.talkers:
		assert_ne(talker, club.rival, "the rival is busy playing")
		assert_ne(talker, club.alfil)
	var apart := club.evidence.talkers[0].global_position.distance_to(club.evidence.talkers[1].global_position)
	assert_lt(apart, ClubEvidence.RECORD_REACH * 2, "a cop can stand by both")


func test_a_pleased_player_tips_the_evidence_not_found_yet() -> void:
	await _club_with("king")
	var kinds: Array = club.evidence.kinds
	assert_eq(club.games.tip(), "CHESS_TIP_" + kinds[0])
	club.case.found(kinds[0])
	assert_eq(club.games.tip(), "CHESS_TIP_" + kinds[1])
	for kind: String in kinds:
		club.case.found(kind)
	assert_eq(club.games.tip(), "CHESS_GG")


func test_cuffing_alfil_solves_it() -> void:
	await _club_with("king")
	for kind: String in club.evidence.kinds.slice(0, 2):
		club.case.found(kind)
	club.alfil.cuffed(20.0)
	assert_true(club.case.solved())
	assert_eq(club.case.report().salary, InfiltrationCase.SALARY * 2 / 3)
	assert_eq(club.case.custody().owner, "alfil")
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_alfil"))
	assert_true(ChaseSuspect.MODELS.has("alfil"))


func test_cuffing_a_player_gives_them_away() -> void:
	await _club_with("king")
	for member in club.members:
		if member != club.alfil:
			member.cuffed(5.0)
			break
	assert_true(club.suspicion.found_out)


func test_the_case_texts_are_translated() -> void:
	TranslationServer.set_locale("es")
	var keys: Array[String] = ["HINT_GO_CHESS", "HINT_CHESS_IN", "HINT_ALFIL_CUFFED", "HINT_ESCAPE_alfil",
		"OBJ_CHESS_GET_IN", "OBJ_CHESS_EVIDENCE", "OBJ_CHESS_CUFF_ALFIL", "OBJ_CHESS_CATCH_ALFIL", "OBJ_CHESS_CAREFUL",
		"OBJ_CHESS_FOUND_OUT", "PROMPT_CHESS_TABLE_KEY", "PROMPT_CHESS_sheet", "PROMPT_CHESS_trophy",
		"PROMPT_CHESS_ledger", "CRIME_owner_alfil", "CONFESS_owner_alfil", "CHESS_SHEET", "CHESS_GG"]
	keys.append_array(InfiltrationCase.VARIANTS["chess"].brief)
	for kind: String in ChessClub.EVIDENCE_KINDS:
		keys.append("EVIDENCE_CHESS_" + kind)
		keys.append("CHESS_TIP_" + kind)
	for i in 4:
		keys.append("CHESS_TALK_%d" % i)
	for i in 3:
		keys.append("ALFIL_SLIP_%d" % (i + 1))
		keys.append("CHASE_ALFIL_LINE_%d" % (i + 1))
	for key in keys:
		assert_ne(tr(key), key)
