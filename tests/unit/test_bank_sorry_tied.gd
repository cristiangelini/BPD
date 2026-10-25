extends GutTest

## The gang doesn't let the sorry robber help (robo-banco-arrepentido.md, step 4, decision 123): a robber who sees him
## on a help shouts "¡Traidor!" and he ends up tied to a chair; a cop unties him staying by his side, and tied three
## times he gives up.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
var cop: Cop


func before_each() -> void:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != "sorry" or BankLevel.sorry_animal(seed_) != "chancho":
		seed_ += 1
	bank = LEVEL.instantiate()
	bank.case_seed = seed_
	cop = bank.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)
	cop.global_position = bank.car.global_position + Vector3(3, 0.1, 0)
	await wait_physics_frames(1)


## The sorry pig, turned and on his way to `help`, right in front of El Oso's face.
func _caught_by_el_oso(help := "drill") -> void:
	var pig := bank.sorry
	pig.try_turn(cop)
	pig.rest_left = 0.0
	pig.helps_done = ["door"] as Array[String]
	pig.helping = help
	pig.help_path = [pig.global_position] as Array[Vector3]
	var oso := bank.boss
	oso.look = 0.0
	pig.global_position = oso.global_position + oso.facing() * 2.0 + Vector3.UP * 0.05
	await wait_physics_frames(1)


func test_seen_on_a_help_he_gets_tied_to_the_chair() -> void:
	watch_signals(bank.sorry)
	await _caught_by_el_oso()
	var pig := bank.sorry
	assert_true(pig.tied)
	assert_eq(pig.ties, 1)
	assert_signal_emitted(pig, "tied_up")
	assert_eq(bank.boss.said(), "ROBBER_TRAITOR")
	assert_gt(bank.drill.nervous_left, 0.0, "the gang gets nervous")
	var chair := bank.global_transform * BankLevel.CHAIR_AT
	assert_lt(Vector2(pig.global_position.x - chair.x, pig.global_position.z - chair.z).length(), 0.5)
	assert_not_null(pig.find_child("Rope", false, false))
	assert_eq(pig.helping, "", "the help is dropped")
	assert_eq(pig.prompt_key(cop), "PROMPT_UNTIE_SORRY")


func test_resting_at_his_spot_nobody_minds_him() -> void:
	var pig := bank.sorry
	pig.try_turn(cop)
	pig.helping = ""
	pig.rest_left = 100.0
	var oso := bank.boss
	oso.look = 0.0
	pig.global_position = oso.global_position + oso.facing() * 2.0 + Vector3.UP * 0.05
	await wait_physics_frames(2)
	assert_false(pig.tied)


func test_a_cop_by_his_side_unties_him_and_he_goes_back() -> void:
	await _caught_by_el_oso()
	var pig := bank.sorry
	watch_signals(pig)
	cop.global_position = pig.global_position + Vector3(1.0, 0.05, 0)
	pig.use(cop)
	assert_eq(pig.said(), "ROBBER_SORRY_UNTYING")
	pig._untie(BankRobber.UNTIE_TIME / 2)
	assert_true(pig.tied, "not yet")
	pig._untie(BankRobber.UNTIE_TIME / 2 + 0.01)
	assert_false(pig.tied)
	assert_signal_emitted(pig, "untied")
	assert_eq(pig.said(), "ROBBER_SORRY_FREE")
	assert_true(pig.going_back)
	assert_false(pig.find_child("Rope", false, false).visible)
	assert_eq(pig.next_help(), "drill", "he tries it again")


func test_walking_away_stops_the_untying() -> void:
	await _caught_by_el_oso()
	var pig := bank.sorry
	cop.global_position = pig.global_position + Vector3(1.0, 0.05, 0)
	pig.start_untie(cop)
	cop.global_position = pig.global_position + Vector3(BankRobber.UNTIE_REACH + 2.0, 0.05, 0)
	pig._untie(BankRobber.UNTIE_TIME + 1.0)
	assert_true(pig.tied)
	assert_null(pig.untying_by)


func test_tied_three_times_he_gives_up() -> void:
	var pig := bank.sorry
	for i in BankRobber.TIES_TO_QUIT:
		pig.tie(pig.global_position, 0.0)
		pig.start_untie(cop)
		cop.global_position = pig.global_position
		pig._untie(BankRobber.UNTIE_TIME + 0.1)
	assert_true(pig.gave_up)
	assert_eq(pig.said(), "ROBBER_SORRY_QUIT")
	assert_eq(pig.next_help(), "")


func test_tied_he_lets_go_of_the_hostages() -> void:
	var pig := bank.sorry
	var hostage := bank.hostages[0]
	hostage.take_by(pig)
	assert_eq(hostage.led_by, pig)
	pig.tie(pig.global_position, 0.0)
	assert_null(hostage.led_by)


func test_a_guest_sees_him_tied() -> void:
	var guest := BankRobber.new()
	guest.animal = "chancho"
	guest.sorry = true
	guest.follower = true
	add_child_autofree(guest)
	var state := guest.net_state()
	state[11] = true
	guest.apply_net_state(state)
	assert_true(guest.tied)
	assert_true(guest.find_child("Rope", false, false).visible)
