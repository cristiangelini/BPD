extends GutTest

## Cuffing the bank's robbers and leading the hostages out (robo-banco.md, step 4, decision 102): the cuffs close
## from behind, a robber who sees the cop up close dodges, the rabbit gives up, the pig runs to the van, cuffed
## robbers are walked to the patrol car, hostages led out by the hand go free, and a robber who sees one being led
## out makes the drill hurry.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
var cop: Cop


func before_each() -> void:
	bank = LEVEL.instantiate()
	# A base robbery's seed: the party (robo-banco-rehenes.md) has its own tests.
	bank.case_seed = 4
	cop = bank.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)


func _robber(animal: String) -> BankRobber:
	for robber in bank.robbers:
		if robber.animal == animal:
			return robber
	return null


## Puts the cop `meters` in front of `robber`'s face (negative: behind them).
func _cop_at(robber: BankRobber, meters: float) -> void:
	robber.look = 0.0
	cop.global_position = robber.global_position + robber.facing() * meters + Vector3.UP * 0.1
	await wait_physics_frames(1)


func test_cuffed_from_behind() -> void:
	var duck := _robber("pato")
	watch_signals(duck)
	await _cop_at(duck, -1.0)
	duck.cuffed(Handcuffs.SECONDS)
	assert_true(duck.is_cuffed())
	assert_signal_emitted(duck, "cuffed_now")
	assert_eq(duck.said(), "ROBBER_PATO_CUFFED")


func test_seen_up_close_they_dodge() -> void:
	var duck := _robber("pato")
	await _cop_at(duck, 1.0)
	duck.cuffed(Handcuffs.SECONDS)
	assert_false(duck.is_cuffed())
	assert_eq(duck.said(), "ROBBER_DODGE")


func test_the_rabbit_gives_up_and_lets_himself_be_cuffed() -> void:
	var rabbit := _robber("conejo")
	await _cop_at(rabbit, 1.2)
	await wait_physics_frames(1)
	assert_true(rabbit.surrendered)
	rabbit.cuffed(Handcuffs.SECONDS)
	assert_true(rabbit.is_cuffed(), "from the front too")


func test_the_pig_runs_to_the_van_and_hides() -> void:
	var pig := _robber("chancho")
	assert_eq(pig.run_path.size(), BankLevel.PIG_RUN.size())
	pig._saw_cop(cop)
	assert_true(pig.running)
	watch_signals(pig)
	pig.global_position = pig.run_path.back()
	pig.run_path = [pig.run_path.back()]
	pig._run(1.0 / 60.0)
	assert_true(pig.in_van)
	assert_false(pig.visible)
	assert_signal_emitted(pig, "hid_in_van")


func test_a_cuffed_robber_is_walked_to_the_patrol_car() -> void:
	var duck := _robber("pato")
	await _cop_at(duck, -1.0)
	duck.cuffed(Handcuffs.SECONDS)
	assert_eq(duck.prompt_key(cop), "PROMPT_ESCORT_OWNER")
	duck.use(cop)
	var escort := OwnerEscort.of(duck)
	assert_eq(escort.escorted_by, cop)
	duck.global_position = bank.car.global_position + bank.car.global_basis.x * 2.0
	escort._physics_process(1.0 / 60.0)
	assert_true(escort.in_car)


func test_a_hostage_led_out_goes_free() -> void:
	var hostage := bank.hostages[0]
	assert_eq(hostage.prompt_key(cop), "PROMPT_LEAD_HOSTAGE")
	hostage.use(cop)
	assert_eq(hostage.led_by, cop)
	assert_eq(hostage.prompt_key(cop), "PROMPT_LET_GO_HOSTAGE")
	hostage.global_position = bank.global_transform * Vector3(0, 0.1, BankLevel.HALF_Z + 2.0)
	hostage._physics_process(1.0 / 60.0)
	assert_true(hostage.freed)
	assert_eq(hostage.said(), "HOSTAGE_FREE")
	assert_eq(bank.hostages_freed, 1)


func test_a_robber_seeing_a_hostage_led_out_hurries_the_drill() -> void:
	var duck := _robber("pato")
	var hostage := bank.hostages[0]
	watch_signals(duck)
	cop.global_position = duck.global_position - duck.facing() * 3.0
	hostage.use(cop)
	hostage.set_physics_process(false)
	duck.look = 0.0
	hostage.global_position = duck.global_position + duck.facing() * 1.0
	await wait_physics_frames(2)
	assert_signal_emitted(duck, "saw_hostage")
	assert_gt(bank.drill.nervous_left, 0.0)
