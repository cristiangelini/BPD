extends GutTest

## The hostages' party (robo-banco-rehenes.md, step 1, decision 121): half the seeds turn the bank robbery into the
## party, with its garlands, the boombox and the croissants' tray, and the hostages swaying while they sit.

const LEVEL := preload("res://scenes/levels/bank.tscn")


func _bank(party: bool) -> BankLevel:
	var bank: BankLevel = LEVEL.instantiate()
	bank.case_seed = _seed(party)
	bank.get_node("Cop").input_enabled = false
	add_child_autofree(bank)
	return bank


## The first seed from 1 that draws (or doesn't draw) the party.
func _seed(party: bool) -> int:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != ("party" if party else "base"):
		seed_ += 1
	return seed_


func test_about_a_fifth_of_the_seeds_are_the_party() -> void:
	var parties := 0
	for seed_ in range(1, 201):
		if BankLevel.is_party(seed_, PackedStringArray()):
			parties += 1
	assert_between(parties, 30, 70)


func test_the_args_force_one_or_the_other() -> void:
	for seed_ in range(1, 20):
		assert_true(BankLevel.is_party(seed_, PackedStringArray(["--bank=party"])))
		assert_false(BankLevel.is_party(seed_, PackedStringArray(["--bank=base"])))


func test_the_party_decorates_the_hall() -> void:
	var bank := _bank(true)
	await wait_physics_frames(2)
	assert_true(bank.party)
	assert_not_null(bank.get_node_or_null("Party/Boombox"))
	assert_not_null(bank.croissant_tray)
	assert_true(bank.inside(bank.croissant_tray.global_position), "the tray is in the bank")
	for hostage in bank.hostages:
		assert_true(hostage.partying)


func test_the_base_robbery_has_no_party() -> void:
	var bank := _bank(false)
	await wait_physics_frames(2)
	assert_false(bank.party)
	assert_null(bank.get_node_or_null("Party"))
	assert_null(bank.croissant_tray)
	for hostage in bank.hostages:
		assert_false(hostage.partying)


func test_the_hostages_sway_while_they_sit_and_stop_when_led() -> void:
	var bank := _bank(true)
	await wait_physics_frames(2)
	var hostage: BankHostage = bank.hostages[0]
	await wait_process_frames(10)
	var model: Node3D = hostage.get_child(1)
	assert_ne(model.rotation.z, 0.0, "swaying")
	hostage.use(bank.get_node("Cop"))
	await wait_process_frames(2)
	assert_eq(model.rotation.z, 0.0, "standing up to walk")
