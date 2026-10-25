extends GutTest

## The grandpa robbers passing for hostages (robo-banco-abuelos.md, step 2, decision 122): one who sees a cop takes
## the mask off (a bit of it sticks out of his pocket), walks to a free spot on the hostages' floor and sits there;
## a cop can cuff him like any robber, but one who leads him out by the hand as a hostage lets him get away, and he
## counts as a sack taken. El Oso doesn't hide.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
var cop: Cop


func before_each() -> void:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != "grandpas":
		seed_ += 1
	bank = LEVEL.instantiate()
	bank.case_seed = seed_
	cop = bank.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)


func _robber(animal: String) -> BankRobber:
	for robber in bank.robbers:
		if robber.animal == animal:
			return robber
	return null


func _mask(robber: BankRobber) -> Node3D:
	return robber.find_child("mask", true, false) as Node3D


func _pocket(robber: BankRobber) -> Node3D:
	return robber.find_child("pocket", true, false) as Node3D


## Unmasks `robber` and puts him straight on his spot.
func _seated(robber: BankRobber) -> void:
	robber.unmask()
	robber.global_position = robber.hide_at
	await wait_physics_frames(2)


func test_masks_on_at_the_start() -> void:
	for robber in bank.robbers:
		assert_true(_mask(robber).visible, robber.name)
		assert_false(_pocket(robber).visible, robber.name)


func test_seeing_a_cop_he_takes_the_mask_off_and_goes_to_sit() -> void:
	var rabbit := _robber("conejo")
	watch_signals(rabbit)
	rabbit.look = 0.0
	cop.global_position = rabbit.global_position + rabbit.facing() * 1.2 + Vector3.UP * 0.1
	await wait_physics_frames(2)
	assert_signal_emitted(rabbit, "spotted", "the gang still gets nervous")
	assert_true(rabbit.unmasked)
	assert_false(rabbit.surrendered, "a grandpa doesn't give up, he hides")
	assert_false(_mask(rabbit).visible)
	assert_true(_pocket(rabbit).visible, "the mask sticks out of his pocket")
	assert_eq(rabbit.said(), "ROBBER_GRANDPA_UNMASK")
	assert_true(bank.in_hostage_area(rabbit.hide_at), "his spot is on the hostages' floor")
	var before := rabbit.global_position.distance_to(rabbit.hide_at)
	await wait_seconds(1.0)
	assert_lt(rabbit.global_position.distance_to(rabbit.hide_at), before, "he walks there")


func test_on_his_spot_he_sits_and_passes_for_a_hostage() -> void:
	var rabbit := _robber("conejo")
	await _seated(rabbit)
	assert_true(rabbit.posing)
	assert_eq(rabbit.prompt_key(cop), "PROMPT_LEAD_HOSTAGE")
	assert_false(rabbit.sees_cop(cop), "he doesn't look out for cops any more")


func test_each_one_gets_his_own_spot() -> void:
	var spots := {}
	for animal: String in ["conejo", "chancho", "pato"]:
		var robber := _robber(animal)
		robber.unmask()
		spots[robber.hide_at] = true
	assert_eq(spots.size(), 3)


func test_el_oso_doesnt_hide() -> void:
	var bear := _robber("oso")
	bear.look = 0.0
	cop.global_position = bear.global_position + bear.facing() * 3.0 + Vector3.UP * 0.1
	await wait_physics_frames(2)
	assert_false(bear.unmasked)
	assert_true(_mask(bear).visible)


func test_he_can_be_cuffed_on_his_spot() -> void:
	var duck := _robber("pato")
	await _seated(duck)
	cop.global_position = duck.global_position + Vector3(0, 0.1, -1.0)
	duck.cuffed(Handcuffs.SECONDS)
	assert_true(duck.is_cuffed(), "pretending, he doesn't dodge")
	assert_false(duck.posing)
	assert_eq(duck.prompt_key(cop), "PROMPT_ESCORT_OWNER")


func test_led_out_as_a_hostage_he_gets_away_with_a_sack() -> void:
	var pig := _robber("chancho")
	await _seated(pig)
	watch_signals(pig)
	pig.use(cop)
	assert_eq(pig.led_by, cop)
	assert_string_starts_with(pig.said(), "ROBBER_GRANDPA_KNEE_")
	assert_eq(pig.prompt_key(cop), "PROMPT_LET_GO_HOSTAGE")
	pig.global_position = bank.global_transform * Vector3(0, 0.1, BankLevel.HALF_Z + 2.0)
	await wait_physics_frames(2)
	assert_true(pig.slipped)
	assert_signal_emitted(pig, "slipped_out")
	assert_false(pig.visible)
	assert_eq(bank.bags_taken, 1)
	assert_eq(bank.hostages_freed, 0, "he wasn't a hostage")
	assert_false(BankLevel.is_loose(pig), "his sack is already counted")


func test_let_go_he_walks_back_to_his_spot() -> void:
	var pig := _robber("chancho")
	await _seated(pig)
	pig.use(cop)
	pig.global_position += Vector3(1.5, 0, 1.5)
	pig.use(cop)
	assert_null(pig.led_by)
	await wait_seconds(0.5)
	assert_false(pig.posing, "not yet there")
	pig.global_position = pig.hide_at
	await wait_physics_frames(2)
	assert_true(pig.posing)


func test_a_guest_sees_him_unmasked_and_sitting() -> void:
	var rabbit := _robber("conejo")
	await _seated(rabbit)
	var state := rabbit.net_state()
	var other := _robber("pato")
	other.apply_net_state(state)
	assert_true(other.unmasked)
	assert_true(other.posing)
	assert_false(_mask(other).visible)
