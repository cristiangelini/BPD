extends GutTest

## Don Plácido and the noise (robo-banco-pueblo.md, step 2, decision 127): a cop running near him, the siren near the
## bank, something falling hard near him or talking to him wakes him and he shouts; a crouching cop takes his key
## without waking him; waking up in a cop's arms he slips out of them, and carried out of the bank he goes home.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
var cop: Cop
var clerk: BankClerk


func before_each() -> void:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != "town":
		seed_ += 1
	bank = LEVEL.instantiate()
	bank.case_seed = seed_
	cop = bank.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)
	clerk = bank.clerk
	watch_signals(clerk)


func _put_cop(local: Vector3) -> void:
	cop.global_position = bank.to_global(local + Vector3.UP * BankLevel.FLOOR_TOP)


func test_a_cop_running_near_him_wakes_him_and_he_shouts() -> void:
	_put_cop(BankLevel.CLERK_AT + Vector3(2.0, 0, 3.0))
	cop.is_running = true
	await wait_physics_frames(3)
	assert_false(clerk.asleep)
	assert_true(clerk.woke_ever)
	assert_signal_emitted_with_parameters(clerk, "shouted", [clerk, "run"])
	assert_string_starts_with(clerk.get_node("Bubble").text, "CLERK_THIEVES_")


func test_walking_near_him_doesnt() -> void:
	_put_cop(BankLevel.CLERK_AT + Vector3(1.0, 0, 2.0))
	cop.is_running = false
	await wait_physics_frames(10)
	assert_true(clerk.asleep)
	assert_false(clerk.woke_ever)


func test_he_falls_asleep_again_after_shouting() -> void:
	clerk.wake("talk")
	clerk.shout_left = 0.05
	await wait_physics_frames(10)
	assert_true(clerk.asleep)
	assert_eq(clerk.get_node("Bubble").text, "CLERK_SNORE")
	assert_true(clerk.woke_ever, "it still counts")


func test_the_siren_near_the_bank_wakes_him_far_away_it_doesnt() -> void:
	bank.car.siren_on = true
	await wait_physics_frames(5)
	assert_true(clerk.asleep, "at the station it's far")
	bank.car.global_position = clerk.global_position + Vector3(0, 0, BankClerk.WAKE_SIREN - 5.0)
	await wait_physics_frames(3)
	assert_signal_emitted_with_parameters(clerk, "shouted", [clerk, "siren"])


func test_something_falling_hard_near_him_wakes_him() -> void:
	var thing := RigidBody3D.new()
	thing.collision_layer = 4
	thing.gravity_scale = 0.0
	var shape := CollisionShape3D.new()
	shape.shape = SphereShape3D.new()
	thing.add_child(shape)
	bank.add_child(thing)
	thing.global_position = clerk.global_position + Vector3(0, 2.0, 2.5)
	thing.linear_velocity = Vector3(0, -6.0, 0)
	await wait_physics_frames(int(BankClerk.LISTEN_EVERY * 60) + 4)
	assert_signal_emitted_with_parameters(clerk, "shouted", [clerk, "fall"])


func test_crouching_the_key_comes_out_without_waking_him() -> void:
	cop.has_key = false
	cop.set_crouching(true)
	assert_eq(clerk.prompt_key(cop), "PROMPT_TAKE_CLERK_KEY")
	clerk.use(cop)
	assert_true(cop.has_key)
	assert_false(clerk.has_key())
	assert_true(clerk.asleep)
	assert_signal_emitted(clerk, "key_taken")


func test_standing_talking_wakes_him() -> void:
	cop.set_crouching(false)
	assert_eq(clerk.prompt_key(cop), "PROMPT_WAKE_CLERK")
	clerk.use(cop)
	assert_false(clerk.asleep)
	assert_true(clerk.has_key(), "and the key stays in his pocket")
	assert_signal_emitted_with_parameters(clerk, "shouted", [clerk, "talk"])


func test_waking_up_carried_he_slips_out_of_the_cops_hands() -> void:
	var grabber := cop.get_node("Grabber") as Grabber
	grabber.grab(clerk)
	assert_false(clerk.freeze, "off his stool")
	clerk.wake("run")
	assert_null(grabber.held)
	assert_true(clerk.holders.is_empty())


func test_carried_out_of_the_bank_he_goes_home() -> void:
	clerk.freeze = false
	clerk.global_position = bank.to_global(Vector3(0, 0.2, BankLevel.HALF_Z + 3.0))
	await wait_physics_frames(3)
	assert_true(clerk.out)
	assert_signal_emitted(clerk, "freed_now")
	assert_eq(clerk.get_node("Bubble").text, "CLERK_YAWN")
	clerk._home_left = 0.05
	await wait_physics_frames(10)
	assert_true(clerk.gone)
	assert_false(clerk.visible)
