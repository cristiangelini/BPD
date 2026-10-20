extends GutTest

## The owner brought in from the last raid, interrogated the next shift (interrogatorio.md, "El dueño del
## allanamiento", decision 93).

const LEVEL_SCENE := preload("res://scenes/levels/interrogation.tscn")
const CUSTODY := {"owner": "baker", "story": "wedding", "slips": ["«¡Yo no guardé nada en el horno!»"], "missed": 300}

var level: InterrogationLevel
var case: InterrogationCase


func before_each() -> void:
	Campaign.current = null
	PlaceDraw.custody = CUSTODY.duplicate(true)
	level = LEVEL_SCENE.instantiate()
	level.case_seed = 7
	(level.get_node("Cop") as Cop).input_enabled = false
	add_child_autofree(level)
	await wait_physics_frames(2)
	case = level.case


func after_each() -> void:
	Campaign.current = null
	PlaceDraw.custody = {}


func _act(id: String) -> void:
	case._gap_left = 0.0
	case.act(id)


func test_an_owner_in_custody_is_interrogated_next_whatever_the_shift() -> void:
	assert_eq(PlaceDraw.pick(1, [], 1), "interrogation")
	assert_eq(PlaceDraw.pick(1, ["--place=bakery"], 1), "bakery", "--place still wins")
	PlaceDraw.custody = {}
	var campaign := Campaign.new()
	campaign.custody = CUSTODY.duplicate(true)
	Campaign.current = campaign
	assert_eq(PlaceDraw.custody_now().owner, "baker", "a campaign keeps its own")


func test_marta_takes_the_chair_and_lets_slip_what_she_said_in_the_raid() -> void:
	assert_eq(level.suspect.kind, "owner_baker")
	assert_eq(case.suspect_id, "owner")
	assert_eq(case.crime, "owner_baker")
	case.give_tip()
	case.nerves = 25.0
	_act("slam_table")
	assert_eq(case.suspect.saying(), CUSTODY.slips[0], "her own slip from the raid")
	case.nerves = 55.0
	_act("aim_lamp")
	assert_eq(case.suspect.saying(), tr("OWNER_SLIP_2"), "past what she said, a line of her own")


func test_her_confession_pays_the_salary_and_half_the_evidence_left_behind() -> void:
	var campaign := Campaign.start_new()
	campaign.custody = CUSTODY.duplicate(true)
	Campaign.save_path = "user://test_owner_interrogation/partida.json"
	case.give_tip()
	case.nerves = 99.0
	_act("slam_table")
	assert_true(case.confessed)
	case.finish_shift()
	assert_eq(campaign.money, ShiftReport.SALARY + 150)
	assert_eq(campaign.custody, {}, "interrogated, she goes home")
	assert_eq(PlaceDraw.custody, {})
	Campaign.save_path = Campaign.SAVE_PATH
