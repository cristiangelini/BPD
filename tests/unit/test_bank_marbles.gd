extends GutTest

## The duck grandma's marbles (robo-banco-abuelos.md, step 3, decision 122): when the grandpa gang gets nervous she
## throws them in front of the entrance, once; a cop running over them slips and stays down a while, walking or
## crouched nothing happens.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
var cop: Cop


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


func _robber(animal: String) -> BankRobber:
	for robber in bank.robbers:
		if robber.animal == animal:
			return robber
	return null


## The cop on the marbles going `speed` m/s toward the street.
func _over_marbles(speed: float) -> void:
	cop.global_position = bank.marbles.global_position + Vector3.UP * 0.1
	cop.velocity = bank.global_basis.z * speed


func test_no_marbles_until_the_gang_gets_nervous() -> void:
	await _start("grandpas")
	assert_null(bank.marbles)
	assert_eq(get_tree().get_nodes_in_group("bank_marbles").size(), 0)


func test_the_duck_throws_them_when_a_robber_sees_a_cop() -> void:
	await _start("grandpas")
	var rabbit := _robber("conejo")
	rabbit.spotted.emit(rabbit, cop)
	assert_not_null(bank.marbles)
	assert_eq(bank.marbles.global_position.distance_to(bank.global_transform * (BankLevel.MARBLES_AT
		+ Vector3.UP * BankLevel.FLOOR_TOP)), 0.0)
	assert_true(bank.inside(bank.marbles.global_position))
	assert_eq(_robber("pato").said(), "ROBBER_GRANDPA_MARBLES")
	assert_false(_robber("pato").find_child("props", true, false).visible, "her bag is empty")
	var first := bank.marbles
	rabbit.spotted.emit(rabbit, cop)
	assert_eq(bank.marbles, first, "only one handful")


func test_a_cuffed_duck_throws_nothing() -> void:
	await _start("grandpas")
	var duck := _robber("pato")
	cop.global_position = bank.global_transform * Vector3(0, 0.1, 9.0)
	duck.cuffed(Handcuffs.SECONDS)
	var rabbit := _robber("conejo")
	rabbit.spotted.emit(rabbit, cop)
	assert_null(bank.marbles)


func test_no_marbles_in_the_young_gangs_robbery() -> void:
	await _start("base")
	var rabbit := _robber("conejo")
	rabbit.spotted.emit(rabbit, cop)
	assert_null(bank.marbles)


func test_running_over_them_you_slip() -> void:
	await _start("grandpas")
	bank.spill_marbles()
	watch_signals(bank.marbles)
	_over_marbles(GameScale.RUN_SPEED)
	bank.marbles._physics_process(1.0 / 60.0)
	assert_true(cop.is_staggered())
	assert_signal_emitted(bank.marbles, "slipped")


func test_walking_over_them_nothing_happens() -> void:
	await _start("grandpas")
	bank.spill_marbles()
	_over_marbles(GameScale.WALK_SPEED)
	bank.marbles._physics_process(1.0 / 60.0)
	assert_false(cop.is_staggered())


func test_crouched_nothing_happens() -> void:
	await _start("grandpas")
	bank.spill_marbles()
	cop.set_crouching(true)
	_over_marbles(GameScale.RUN_SPEED)
	bank.marbles._physics_process(1.0 / 60.0)
	assert_false(cop.is_staggered())


func test_running_beside_them_nothing_happens() -> void:
	await _start("grandpas")
	bank.spill_marbles()
	_over_marbles(GameScale.RUN_SPEED)
	cop.global_position += Vector3(BankMarbles.RADIUS + 0.5, 0, 0)
	bank.marbles._physics_process(1.0 / 60.0)
	assert_false(cop.is_staggered())


func test_down_for_a_while_then_up() -> void:
	await _start("grandpas")
	bank.spill_marbles()
	_over_marbles(GameScale.RUN_SPEED)
	bank.marbles._physics_process(1.0 / 60.0)
	for i in int((BankMarbles.SLIP_TIME + 0.2) * 60):
		cop.step(1.0 / 60.0, Vector2.ZERO, false, false, false)
	assert_false(cop.is_staggered())
