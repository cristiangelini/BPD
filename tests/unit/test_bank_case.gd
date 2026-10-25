extends GutTest

## The bank robbery case (robo-banco.md, step 6b, decision 102): El Oso in the patrol car solves it and the shift ends
## back at the station; the pay loses 100 per hostage left inside and 50 per sack taken; El Oso getting away loses
## it; solved, he's in custody for the next shift's interrogation.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
var case: BankCase


func before_each() -> void:
	bank = LEVEL.instantiate()
	# A base robbery's seed: the party (robo-banco-rehenes.md) has its own tests.
	bank.case_seed = 4
	bank.get_node("Cop").input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)
	case = bank.case


func after_each() -> void:
	PlaceDraw.custody = {}


## Frees `count` hostages, as if led out.
func _free(count: int) -> void:
	for i in count:
		bank.hostages[i].free_hostage()


func _jail_el_oso() -> void:
	bank.boss.cuffed(Handcuffs.SECONDS)
	OwnerEscort.of(bank.boss).board()


func test_the_planilla_counts_the_hostages() -> void:
	assert_not_null(case)
	var first: Dictionary = case.rows()[0]
	assert_eq(first.text, tr("OBJ_BANK_HOSTAGES") % [0, BankLevel.HOSTAGES])
	_free(2)
	assert_eq(case.rows()[0].text, tr("OBJ_BANK_HOSTAGES") % [2, BankLevel.HOSTAGES])


func test_el_oso_in_the_car_solves_it_and_the_station_ends_the_shift() -> void:
	_free(6)
	bank.car.global_position = bank.global_transform * Vector3(-6.0, 0.5, BankLevel.VAN_AT.z)
	_jail_el_oso()
	assert_true(case.solved())
	await wait_physics_frames(1)
	assert_false(case.shift_over, "not until they're back")
	bank.car.global_transform = bank.station_parking
	await wait_physics_frames(2)
	assert_true(case.shift_over)
	assert_eq(case.report().total, BankCase.SALARY - 2 * BankCase.PER_HOSTAGE)
	assert_true(case.report().approved)


func test_sacks_and_hostages_left_cut_the_pay() -> void:
	_jail_el_oso()
	bank.bags_taken = 2
	assert_eq(case.missed(), BankLevel.HOSTAGES * BankCase.PER_HOSTAGE + 2 * BankCase.PER_BAG)
	assert_eq(case.report().total, 0, "never below zero")


func test_el_oso_getting_away_loses_it() -> void:
	bank.drill.drilled = BankDrill.DRILL_TIME
	bank.drill._physics_process(0.1)
	assert_not_null(bank.chase)
	bank.chase.ended.emit(false)
	assert_true(case.escaped)
	case.finish_shift()
	assert_false(case.solved())
	assert_eq(case.report().total, 0)
	assert_true(PlaceDraw.custody.is_empty())


func test_caught_in_the_chase_solves_it() -> void:
	bank.drill.drilled = BankDrill.DRILL_TIME
	bank.drill._physics_process(0.1)
	bank.chase.ended.emit(true)
	assert_true(case.solved())


func test_el_oso_goes_to_the_interrogation() -> void:
	_free(BankLevel.HOSTAGES)
	_jail_el_oso()
	case.finish_shift()
	var custody := PlaceDraw.custody
	assert_eq(custody.owner, "oso")
	assert_eq(custody.slips, ["BEAR_SLIP_1", "BEAR_SLIP_2", "BEAR_SLIP_3"])
	assert_eq(custody.missed, 0)
	assert_true(InterrogationCase.SUSPECT_MODELS.has("owner_oso"))
