extends GutTest

## The hostages who don't want to leave (robo-banco-rehenes.md, step 2, decision 121): at the party, led by the hand
## they walk at half speed and protest, and let go before the door they walk back to their spot and sit down again.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
var cop: Cop


func _open(party: bool) -> void:
	bank = LEVEL.instantiate()
	var seed_ := 1
	while BankLevel.is_party(seed_, PackedStringArray()) != party:
		seed_ += 1
	bank.case_seed = seed_
	cop = bank.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)


func test_at_the_party_they_follow_at_half_speed_and_protest() -> void:
	await _open(true)
	var hostage: BankHostage = bank.hostages[0]
	assert_almost_eq(hostage.speed(), BankHostage.SPEED * BankHostage.RELUCTANT, 0.001)
	hostage.use(cop)
	assert_string_starts_with(hostage.said(), "HOSTAGE_PARTY_")
	var first := hostage.said()
	hostage._protest_left = 0.0
	await wait_physics_frames(2)
	assert_string_starts_with(hostage.said(), "HOSTAGE_PARTY_")
	assert_ne(hostage.said(), first, "a new protest")


func test_let_go_inside_they_walk_back_and_sit_down() -> void:
	await _open(true)
	var hostage: BankHostage = bank.hostages[0]
	var home := hostage.home
	hostage.use(cop)
	hostage.global_position = home + Vector3(2.0, 0, 0)
	hostage.use(cop)
	assert_true(hostage.returning)
	assert_null(hostage.led_by)
	assert_string_starts_with(hostage.said(), "HOSTAGE_BACK_")
	await wait_physics_frames(150)
	assert_false(hostage.returning, "back in their spot")
	assert_almost_eq(Vector2(hostage.global_position.x, hostage.global_position.z), Vector2(home.x, home.z),
		Vector2(0.3, 0.3))
	assert_false(hostage.net_state()[1], "sitting again")


func test_taken_again_on_the_way_back_they_follow() -> void:
	await _open(true)
	var hostage: BankHostage = bank.hostages[1]
	hostage.use(cop)
	hostage.use(cop)
	assert_true(hostage.returning)
	hostage.use(cop)
	assert_false(hostage.returning)
	assert_eq(hostage.led_by, cop)


func test_out_of_the_bank_they_are_still_free() -> void:
	await _open(true)
	var hostage: BankHostage = bank.hostages[2]
	hostage.use(cop)
	hostage.global_position = bank.global_transform * Vector3(0, 0.1, BankLevel.HALF_Z + 2.0)
	await wait_physics_frames(2)
	assert_true(hostage.freed)
	assert_false(hostage.returning)


func test_in_the_base_robbery_they_sit_where_they_are_let_go() -> void:
	await _open(false)
	var hostage: BankHostage = bank.hostages[0]
	assert_almost_eq(hostage.speed(), BankHostage.SPEED, 0.001)
	hostage.use(cop)
	assert_string_starts_with(hostage.said(), "HOSTAGE_")
	hostage.global_position = hostage.home + Vector3(2.0, 0, 0)
	hostage.use(cop)
	assert_false(hostage.returning)
	await wait_physics_frames(20)
	assert_almost_eq(hostage.global_position.x, hostage.home.x + 2.0, 0.1)
