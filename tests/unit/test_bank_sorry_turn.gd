extends GutTest

## Turning the sorry robber (robo-banco-arrepentido.md, step 2, decision 123): a cop who talks to him unseen by the
## rest of the gang turns him, and he walks to the back door and opens it from inside, then goes back to his spot.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
var cop: Cop


func _bank(animal: String) -> void:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != "sorry" or BankLevel.sorry_animal(seed_) != animal:
		seed_ += 1
	bank = LEVEL.instantiate()
	bank.case_seed = seed_
	cop = bank.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)


## Where no robber looks: outside, by the patrol car.
func _out_of_sight() -> void:
	cop.global_position = bank.car.global_position + Vector3(3, 0.1, 0)
	await wait_physics_frames(1)


func _walk_until_helped(robber: BankRobber, help: String, seconds: float) -> void:
	var left := seconds
	while help not in robber.helps_done and left > 0.0:
		await wait_physics_frames(10)
		left -= 10.0 / Engine.physics_ticks_per_second


func test_the_prompt_says_to_talk_to_the_crying_one() -> void:
	await _bank("chancho")
	assert_eq(bank.sorry.prompt_key(cop), "PROMPT_TALK_SORRY")
	for robber in bank.robbers:
		if robber != bank.sorry:
			assert_eq(robber.prompt_key(cop), "PROMPT_TALK_ROBBER")


func test_talking_unseen_turns_him() -> void:
	await _bank("chancho")
	await _out_of_sight()
	watch_signals(bank.sorry)
	bank.sorry.use(cop)
	assert_true(bank.sorry.turned)
	assert_signal_emitted(bank.sorry, "turned_now")
	assert_eq(bank.sorry.said(), "ROBBER_SORRY_TURN")
	assert_eq(bank.sorry.prompt_key(cop), "PROMPT_TALK_ROBBER")


func test_he_doesnt_dare_while_another_robber_sees_the_cop() -> void:
	await _bank("chancho")
	var oso := bank.boss
	oso.look = 0.0
	cop.global_position = oso.global_position + oso.facing() * 2.0 + Vector3.UP * 0.1
	await wait_physics_frames(2)
	oso.look = 0.0
	assert_true(oso.sees_cop(cop), "El Oso sees the cop")
	assert_false(bank.sorry.try_turn(cop))
	assert_false(bank.sorry.turned)
	assert_eq(bank.sorry.said(), "ROBBER_SORRY_NOT_NOW")


func test_turned_he_walks_to_the_back_door_and_opens_it_from_inside() -> void:
	await _bank("chancho")
	await _out_of_sight()
	assert_true(bank.back_door.locked)
	var robber := bank.sorry
	robber.try_turn(cop)
	await wait_physics_frames(2)
	assert_eq(robber.helping, "door")
	assert_eq(robber.said(), "ROBBER_SORRY_GO_DOOR")
	await _walk_until_helped(robber, "door", 40.0)
	assert_has(robber.helps_done, "door")
	assert_false(bank.back_door.locked, "unlocked with no key")
	assert_true(bank.back_door.is_open)
	assert_lt(robber.global_position.distance_to(bank.back_door.global_position), 2.0, "he went there")


func test_then_he_goes_back_to_his_spot_and_rests() -> void:
	await _bank("pato")
	await _out_of_sight()
	var robber := bank.sorry
	var home := robber.global_position
	robber.try_turn(cop)
	await _walk_until_helped(robber, "door", 30.0)
	assert_true(bank.back_door.is_open)
	var left := 30.0
	while robber.rest_left <= 0.0 and left > 0.0:
		await wait_physics_frames(10)
		left -= 10.0 / Engine.physics_ticks_per_second
	assert_gt(robber.rest_left, 0.0, "resting at his spot")
	assert_lt(Vector2(robber.global_position.x - home.x, robber.global_position.z - home.z).length(), 0.6)


func test_the_way_from_the_hall_goes_round_the_counter() -> void:
	await _bank("conejo")
	var way: Array[Vector3] = bank._sorry_way("door")
	assert_eq(way.size(), BankLevel.HALL_TO_CORRIDOR.size() + 1)
	assert_true(BankLevel.in_corridor(bank.global_transform.inverse() * way[-1]))


func test_a_guest_copy_doesnt_walk_on_its_own() -> void:
	var guest := BankRobber.new()
	guest.animal = "pato"
	guest.sorry = true
	guest.follower = true
	add_child_autofree(guest)
	var state := guest.net_state()
	state[10] = true
	guest.apply_net_state(state)
	assert_true(guest.turned)
	guest._physics_process(0.1)
	assert_eq(guest.helping, "", "the host's decides his helps")
