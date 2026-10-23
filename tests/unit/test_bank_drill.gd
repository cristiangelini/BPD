extends GutTest

## The robbers' drill (robo-banco.md, step 3, decision 102): DRILL_TIME seconds to get through the vault's door,
## faster while the gang is nervous (a robber spotted a cop, or El Oso was lied to), stopped while paused, and the
## vault's door swinging open when it's done.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel


func before_each() -> void:
	bank = LEVEL.instantiate()
	bank.get_node("Cop").input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)


func test_it_stands_at_the_vault_door_and_starts_running() -> void:
	var drill := bank.drill
	assert_lt(drill.position.distance_to(Vector3(BankLevel.VAULT_X, drill.position.y, BankLevel.VAULT_DOOR_Z)), 1.0)
	assert_eq(drill.rate(), 1.0)
	assert_gt(drill.drilled, 0.0, "already drilling")
	assert_almost_eq(drill.bar.max_value, BankDrill.DRILL_TIME, 0.01)


func test_a_robber_spotting_a_cop_makes_it_faster() -> void:
	var cop: Cop = bank.get_node("Cop")
	bank.robbers[0].spotted.emit(bank.robbers[0], cop)
	assert_eq(bank.drill.rate(), BankDrill.NERVOUS_RATE)
	bank.drill._physics_process(BankDrill.NERVOUS + 0.1)
	assert_eq(bank.drill.rate(), 1.0, "calm again")


func test_paused_it_stops() -> void:
	bank.drill.pause(30.0)
	var before := bank.drill.drilled
	bank.drill._physics_process(1.0)
	assert_eq(bank.drill.drilled, before)
	bank.drill._physics_process(30.0)
	assert_eq(bank.drill.rate(), 1.0)


func test_when_done_the_vault_opens() -> void:
	watch_signals(bank.drill)
	bank.drill.drilled = BankDrill.DRILL_TIME - 0.5
	bank.drill._physics_process(1.0)
	assert_true(bank.drill.is_open)
	assert_signal_emitted(bank.drill, "opened")
	assert_eq(bank.drill.rate(), 0.0)
	var door := bank.vault_door.position
	assert_gt(door.x, BankLevel.VAULT_X, "swung into the vault")
	assert_gt(absf(door.z - BankLevel.VAULT_DOOR_Z), BankLevel.VAULT_DOOR_RADIUS, "out of the doorway")
