extends GutTest

## El Oso's phone (robo-banco.md, step 5, decision 102): a call brings a request, a promise kept stops the drill and
## lets a hostage go, a promise not kept hurries the drill, and nobody promising makes him hang up.

const LEVEL := preload("res://scenes/levels/bank.tscn")
const DONUT_BOX := preload("res://scenes/props/donut_box.tscn")

var bank: BankLevel
var cop: Cop
var phone: BankPhone


func before_each() -> void:
	bank = LEVEL.instantiate()
	cop = bank.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)
	phone = bank.phone


## Calls until El Oso asks for `request`, and promises it.
func _promise(request: String) -> void:
	for i in BankPhone.REQUESTS.size():
		phone.use(cop)
		if phone.request == request:
			break
		phone.request = ""
	phone.use(cop)


func test_the_phone_hangs_on_the_patrol_car() -> void:
	assert_eq(phone.get_parent(), bank.car)
	assert_eq(phone.prompt_key(cop), "PROMPT_PHONE_CALL")


func test_a_call_brings_a_request_and_e_promises_it() -> void:
	phone.use(cop)
	assert_true(BankPhone.REQUESTS.has(phone.request))
	assert_true(phone.said().begins_with("BEAR_PHONE_ASK_"))
	assert_eq(phone.prompt_key(cop), "PROMPT_PHONE_PROMISE")
	phone.use(cop)
	assert_true(phone.promised)
	assert_eq(phone.prompt_key(cop), "", "no other call while it's pending")


func test_nobody_promising_he_hangs_up() -> void:
	phone.use(cop)
	phone._physics_process(BankPhone.ASK_TIME + 0.1)
	assert_eq(phone.request, "")
	assert_eq(phone.said(), "BEAR_PHONE_HANGUP")
	assert_eq(bank.drill.nervous_left, 0.0)


func test_a_lie_hurries_the_drill() -> void:
	_promise("donuts")
	phone._physics_process(BankPhone.PROMISE_TIME + 0.1)
	assert_eq(phone.said(), "BEAR_PHONE_LIED")
	assert_gt(bank.drill.nervous_left, 0.0)


func test_donuts_at_the_door_stop_the_drill_and_free_a_hostage() -> void:
	_promise("donuts")
	var box: Node3D = DONUT_BOX.instantiate()
	add_child_autofree(box)
	box.global_position = bank.global_transform * Vector3(BankLevel.ENTRANCE_X, 0.3, BankLevel.HALF_Z + 1.2)
	phone._physics_process(0.1)
	assert_eq(phone.said(), "BEAR_PHONE_KEPT_DONUTS")
	assert_gt(bank.drill.paused_left, 0.0)
	assert_eq(bank.hostages_freed, 1)


func test_singing_him_happy_birthday() -> void:
	_promise("birthday")
	cop.global_position = phone.global_position + Vector3(1.0, 0, 0)
	for i in int(BankPhone.SING_NEEDED / VoiceChat.SING_EVERY):
		phone.heard_singing(cop)
	phone._physics_process(0.1)
	assert_eq(phone.said(), "BEAR_PHONE_KEPT_BIRTHDAY")
	assert_eq(bank.hostages_freed, 1)


func test_singing_far_from_the_phone_doesnt_count() -> void:
	_promise("birthday")
	cop.global_position = phone.global_position + Vector3(BankPhone.SING_REACH + 2.0, 0, 0)
	phone.heard_singing(cop)
	assert_eq(phone.sung, 0.0)


## The patrol car parked at the bank's curb, west of the van.
func _park_at_the_bank() -> void:
	bank.car.global_position = bank.global_transform * Vector3(-6.0, 0.5, BankLevel.VAN_AT.z)


func test_taking_the_car_away() -> void:
	_park_at_the_bank()
	_promise("car_away")
	assert_eq(phone.request, "car_away")
	phone._physics_process(0.1)
	assert_true(phone.promised, "not yet")
	bank.car.global_position = bank.global_position + Vector3(BankPhone.CAR_AWAY + 20.0, 0.5, 0)
	phone._physics_process(0.1)
	assert_eq(phone.said(), "BEAR_PHONE_KEPT_CAR_AWAY")


func test_called_from_afar_he_doesnt_ask_for_the_car() -> void:
	assert_true(phone.car_away(), "the car starts at the station")
	for i in BankPhone.REQUESTS.size():
		phone.use(cop)
		assert_ne(phone.request, "car_away")
		phone.request = ""
