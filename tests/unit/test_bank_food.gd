extends GutTest

## Food wins the party's hostages over (robo-banco-rehenes.md, step 4, decision 121): a croissant from the tray or a
## donut from a box makes them follow at full speed without protesting, and the hostage El Oso lets go for a kept
## promise only gets to the door and walks back in unless a cop takes them by the hand there.

const LEVEL := preload("res://scenes/levels/bank.tscn")
const DONUT_BOX := preload("res://scenes/props/donut_box.tscn")

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


func test_the_tray_hands_out_its_croissants() -> void:
	await _open(true)
	var tray := bank.croissant_tray
	assert_eq(tray.prompt_key(cop), "PROMPT_TAKE_CROISSANT")
	tray.use(cop)
	assert_is(cop.get_node("Grabber").held, BankCroissant)
	assert_eq(tray.left, BankCroissantTray.CROISSANTS - 1)
	tray.use(cop)
	assert_eq(tray.left, BankCroissantTray.CROISSANTS - 1, "hands full: none taken")
	tray.set_left(0)
	assert_eq(tray.prompt_key(cop), "PROMPT_CROISSANTS_GONE")


func test_a_croissant_wins_a_hostage_over() -> void:
	await _open(true)
	bank.croissant_tray.use(cop)
	var croissant: BankCroissant = cop.get_node("Grabber").held
	var hostage: BankHostage = bank.hostages[0]
	assert_eq(hostage.prompt_key(cop), "PROMPT_FEED_HOSTAGE")
	hostage.use(cop)
	assert_true(hostage.fed)
	assert_eq(hostage.led_by, cop)
	assert_string_starts_with(hostage.said(), "HOSTAGE_FED_")
	assert_almost_eq(hostage.speed(), BankHostage.SPEED, 0.001, "full speed")
	assert_null(cop.get_node("Grabber").held, "the croissant is gone")
	await wait_physics_frames(1)
	assert_false(is_instance_valid(croissant))
	hostage._protest_left = 0.0
	await wait_physics_frames(2)
	assert_string_starts_with(hostage.said(), "HOSTAGE_FED_", "no protests")


func test_a_donut_from_the_box_wins_one_over_too() -> void:
	await _open(true)
	var box: DonutBox = DONUT_BOX.instantiate()
	bank.add_child(box)
	cop.handed(box)
	var hostage: BankHostage = bank.hostages[1]
	hostage.use(cop)
	assert_true(hostage.fed)
	assert_eq(box.donuts, DonutBox.DONUTS - 1)
	assert_eq(cop.get_node("Grabber").held, box, "the box stays in hand")
	assert_eq(hostage.prompt_key(cop), "PROMPT_LET_GO_HOSTAGE", "fed once is enough")


func test_in_the_base_robbery_food_does_nothing() -> void:
	await _open(false)
	var box: DonutBox = DONUT_BOX.instantiate()
	bank.add_child(box)
	cop.handed(box)
	var hostage: BankHostage = bank.hostages[0]
	assert_false(hostage.wants_food())
	assert_eq(hostage.prompt_key(cop), "PROMPT_LEAD_HOSTAGE")


func test_the_released_hostage_waits_at_the_door_and_walks_back_in() -> void:
	await _open(true)
	var freed_before := bank.hostages_freed
	bank.release_hostage()
	var hostage: BankHostage = bank.hostages[0]
	assert_false(hostage.sitting())
	assert_eq(hostage.said(), "HOSTAGE_DOOR")
	assert_false(bank.inside(hostage.global_position), "at the door, outside")
	assert_false(hostage.freed)
	hostage._door_left = 0.01
	await wait_physics_frames(2)
	assert_true(hostage.returning)
	await wait_physics_frames(600)
	assert_true(hostage.sitting(), "back in their spot")
	assert_almost_eq(Vector2(hostage.global_position.x, hostage.global_position.z),
		Vector2(hostage.home.x, hostage.home.z), Vector2(0.3, 0.3))
	assert_eq(bank.hostages_freed, freed_before)


func test_taken_by_the_hand_at_the_door_they_are_free() -> void:
	await _open(true)
	bank.release_hostage()
	var hostage: BankHostage = bank.hostages[0]
	hostage.use(cop)
	await wait_physics_frames(2)
	assert_true(hostage.freed)
	assert_eq(bank.hostages_freed, 1)


func test_in_the_base_robbery_the_released_hostage_goes_free() -> void:
	await _open(false)
	bank.release_hostage()
	assert_true(bank.hostages[0].freed)
	assert_eq(bank.hostages_freed, 1)
