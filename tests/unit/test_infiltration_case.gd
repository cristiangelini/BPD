extends GutTest

## The grandparents' club case (infiltracion.md, step 6): the comisario's briefing, the planilla, getting in disguised,
## cuffing Doña Chela and the pay by evidence.

const LEVEL := preload("res://scenes/levels/grandpa_club.tscn")

var club: GrandpaClub
var cop: Cop
var case: InfiltrationCase


func before_each() -> void:
	club = LEVEL.instantiate()
	club.case_seed = 4242
	cop = club.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(club)
	await wait_physics_frames(2)
	club.bingo.set_physics_process(false)
	club.dance.set_process(false)
	case = club.case
	case.give_tip()


func test_the_comisario_gives_the_case() -> void:
	assert_true(case.tip_given)
	var texts := case.rows().map(func(row: Dictionary) -> String: return row.text)
	assert_has(texts, "OBJ_CLUB_GET_IN")
	assert_has(texts, "OBJ_CLUB_CUFF_CHELA")


func test_getting_in_counts_only_in_disguise() -> void:
	cop.global_position = club.global_transform * Vector3(4, 0.1, 9)
	await wait_physics_frames(2)
	assert_false(case.got_in, "no disguise")
	cop.put_on_disguise("wig", 0.0)
	cop.put_on_disguise("glasses", 0.0)
	await wait_physics_frames(2)
	assert_true(case.got_in)


func test_cuffing_chela_solves_it_and_pays_by_evidence() -> void:
	case.found("notebook")
	case.found("envelope")
	club.chela.cuffed(20.0)
	assert_true(case.solved())
	var pay := case.report()
	assert_eq(pay.salary, InfiltrationCase.SALARY * 2 / 3, "one third less for the missing one")
	assert_true(pay.approved)


func test_all_the_evidence_pays_the_whole_salary() -> void:
	for kind: String in ["notebook", "envelope", "cage", "press"]:
		case.found(kind)
	assert_eq(case.evidence_found.size(), InfiltrationCase.EVIDENCE, "no more than 3")
	club.chela.cuffed(20.0)
	assert_eq(case.report().salary, InfiltrationCase.SALARY)


func test_without_evidence_it_doesnt_pass() -> void:
	club.chela.cuffed(20.0)
	assert_false(case.report().approved)


func test_cuffing_a_grandparent_gives_them_away() -> void:
	club.members[3].cuffed(20.0)
	assert_true(club.suspicion.found_out)
	assert_true(case.found_out)
	assert_false(case.solved())


func test_a_guest_follows_the_case() -> void:
	case.found("notebook")
	var state := case.snapshot()
	var other: GrandpaClub = LEVEL.instantiate()
	other.case_seed = 4242
	other.get_node("Cop").input_enabled = false
	add_child_autofree(other)
	await wait_physics_frames(1)
	other.case.follower = true
	other.case.apply_snapshot(state)
	assert_eq(other.case.evidence_found, case.evidence_found)
	assert_true(other.case.tip_given)
