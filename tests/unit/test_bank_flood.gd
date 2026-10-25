extends GutTest

## The flooding vault (robo-banco-inundado.md, step 1, decision 125): a sixth of the seeds the duck's drill punctured
## the pipe and the bank fills with water that rises 0.2 m a minute up to 1 m and slows everyone wading in it.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
var cop: Cop


## The front door open with the pipe pouring: the level holds where the test puts it (and the pig running out
## doesn't let a wave out).
func _hold() -> void:
	bank.front_door.open_from_inside()


func _bank(want := "flood") -> void:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != want:
		seed_ += 1
	bank = LEVEL.instantiate()
	bank.case_seed = seed_
	cop = bank.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)


func test_a_sixth_of_the_seeds_flood_and_the_arg_forces_it() -> void:
	var floods := 0
	for seed_ in range(1, 401):
		if BankLevel.variant(seed_, PackedStringArray()) == "flood":
			floods += 1
	assert_between(floods, 40, 100)
	for seed_ in range(1, 20):
		assert_eq(BankLevel.variant(seed_, PackedStringArray(["--bank=flood"])), "flood")
	for seed_ in [1, 2, 3, 4]:
		assert_ne(BankLevel.variant(seed_, PackedStringArray()), "flood", "the old test seeds stay dry")


func test_the_others_have_no_water() -> void:
	await _bank("base")
	assert_null(bank.water)


func test_the_flood_has_its_water_pouring() -> void:
	await _bank()
	assert_not_null(bank.water)
	assert_true(bank.water.running, "the jet pours from the start")


func test_the_water_rises_up_to_a_meter() -> void:
	await _bank()
	var before := bank.water.level
	await wait_physics_frames(30)
	assert_gt(bank.water.level, before)
	assert_almost_eq(BankWater.RISE * 60.0, 0.2, 0.001, "0.2 m a minute")
	bank.water.level = BankWater.MAX_LEVEL - 0.0001
	await wait_physics_frames(10)
	assert_eq(bank.water.level, BankWater.MAX_LEVEL)


func test_the_deeper_the_slower() -> void:
	assert_eq(BankWater.factor(0.0), 1.0)
	assert_almost_eq(BankWater.factor(0.3), 0.8, 0.001)
	assert_almost_eq(BankWater.factor(0.45), 0.7, 0.001)
	assert_almost_eq(BankWater.factor(0.6), 0.6, 0.001)
	assert_almost_eq(BankWater.factor(1.0), 0.45, 0.001)
	assert_almost_eq(BankWater.factor(2.0), 0.45, 0.001)


func test_only_inside_the_bank() -> void:
	await _bank()
	_hold()
	bank.water.level = 0.6
	assert_eq(bank.water.depth_at(bank.to_global(Vector3(0, 0, 3))), 0.6)
	assert_eq(bank.water.depth_at(bank.to_global(Vector3(0, 0, BankLevel.HALF_Z + 3.0))), 0.0, "the sidewalk is dry")


func test_the_cop_wades_slower_inside() -> void:
	await _bank()
	_hold()
	bank.water.level = 0.6
	cop.global_position = bank.to_global(Vector3(0, 0.1, 3))
	var dry := GameScale.WALK_SPEED
	await wait_physics_frames(2)
	assert_almost_eq(cop.wade, 0.6, 0.001)
	assert_almost_eq(cop.current_speed(), dry * 0.6, 0.01)
	cop.global_position = bank.to_global(Vector3(0, 0.1, BankLevel.HALF_Z + 3.0))
	await wait_physics_frames(2)
	assert_eq(cop.wade, 1.0)


func test_the_robbers_and_the_hostages_wade_too() -> void:
	await _bank()
	_hold()
	bank.water.level = 1.0
	await wait_physics_frames(2)
	for robber in bank.robbers:
		assert_almost_eq(robber.wade, 0.45, 0.001, robber.animal)
	for hostage in bank.hostages:
		assert_almost_eq(hostage.wade, 0.45, 0.001)
	# Low enough to be down from the counter (step 3).
	bank.water.level = 0.45
	await wait_physics_frames(1)
	var hostage := bank.hostages[0]
	hostage.led_by = cop
	cop.global_position = hostage.global_position + Vector3(4, 0, 0)
	await wait_physics_frames(1)
	var horizontal := Vector2(hostage.velocity.x, hostage.velocity.z).length()
	assert_almost_eq(horizontal, hostage.speed() * BankWater.factor(0.45), 0.05, "led by the hand, the hostage wades")


func test_the_water_shows_and_the_jet_pours() -> void:
	await _bank()
	_hold()
	bank.water.level = 0.5
	await wait_physics_frames(1)
	var surface := bank.water.get_node("Surface") as MeshInstance3D
	assert_true(surface.visible)
	assert_almost_eq(surface.scale.y, 0.5, 0.01)
	assert_true((bank.water.get_node("Jet") as Node3D).visible)
