extends GutTest

## The grandpa Oso on the phone and the getaway on a motor walker (robo-banco-abuelos.md, step 4, decision 122): he
## asks in his own words and doesn't hear the first "yes" (E twice to promise); when the vault opens he runs along
## the sidewalk on a motor walker at 10 km/h, van or no van.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
var cop: Cop
var phone: BankPhone


func _start(want: String) -> void:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != want:
		seed_ += 1
	bank = LEVEL.instantiate()
	bank.case_seed = seed_
	cop = bank.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)
	phone = bank.phone


func test_the_grandpa_oso_is_deaf_and_the_young_one_isnt() -> void:
	await _start("grandpas")
	assert_true(phone.deaf)
	bank.queue_free()
	await _start("base")
	assert_false(phone.deaf)


func test_he_asks_in_his_own_words() -> void:
	await _start("grandpas")
	phone.use(cop)
	assert_string_starts_with(phone.said(), "BEAR_GRANDPA_ASK_")
	assert_eq(phone.said(), "BEAR_GRANDPA_ASK_" + phone.request.to_upper())


func test_the_first_yes_he_doesnt_hear() -> void:
	await _start("grandpas")
	phone.use(cop)
	phone.use(cop)
	assert_false(phone.promised)
	assert_string_starts_with(phone.said(), "BEAR_GRANDPA_WHAT_")
	assert_eq(phone.prompt_key(cop), "PROMPT_PHONE_LOUDER")
	phone.use(cop)
	assert_true(phone.promised, "the second one, louder, he hears")
	assert_eq(phone.said(), "BEAR_PHONE_DEAL")


func test_saying_it_again_gives_more_time() -> void:
	await _start("grandpas")
	phone.use(cop)
	phone._physics_process(BankPhone.ASK_TIME - 1.0)
	phone.use(cop)
	phone._physics_process(BankPhone.ASK_TIME - 1.0)
	assert_ne(phone.request, "", "still on the line")


func test_each_call_he_has_to_hear_it_twice_again() -> void:
	await _start("grandpas")
	phone.use(cop)
	phone.use(cop)
	phone.use(cop)
	phone._physics_process(BankPhone.PROMISE_TIME + 0.1)
	assert_eq(phone.request, "")
	phone.use(cop)
	assert_eq(phone.prompt_key(cop), "PROMPT_PHONE_PROMISE")


func test_a_guest_sees_he_heard_the_first_yes() -> void:
	await _start("grandpas")
	phone.use(cop)
	phone.use(cop)
	var state := phone.net_state()
	phone.said_once = false
	phone.apply_net_state(state)
	assert_true(phone.said_once)


func test_the_vault_opens_and_he_runs_on_a_motor_walker() -> void:
	await _start("grandpas")
	bank.drill.drilled = BankDrill.SLOW_TIME
	bank.drill._physics_process(0.1)
	assert_not_null(bank.chase)
	assert_eq(bank.chase.suspect_id, SuspectCar.WALKER)
	assert_eq(bank.chase.who, "oso_grandpa")
	assert_almost_eq(SuspectCar.SPEEDS[SuspectCar.WALKER], 10.0 / 3.6, 0.01)
	assert_true(is_instance_valid(bank.van), "the van stays parked")
	assert_eq(bank.bags_taken, 4)


func test_the_grandpa_oso_rides_the_walker() -> void:
	await _start("grandpas")
	bank.start_getaway(SuspectCar.WALKER)
	var rider := bank.chase.truck.get_node("Rider") as Node3D
	assert_not_null(rider)
	assert_not_null(rider.find_child("mask", true, false), "his own model, with the mask")
	assert_eq(ChaseSuspect.model_for("oso_grandpa"), ChaseSuspect.MODELS["oso_grandpa"])
