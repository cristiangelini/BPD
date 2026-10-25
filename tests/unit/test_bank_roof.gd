extends GutTest

## The roof robbery (robo-banco-techo.md, step 1, decision 126): a seventh of the seeds the gang leaves by the roof:
## fire escape stairs up the east wall, the toy helicopter waiting on its helipad and El Oso's nephew on a bench across
## the street.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
var cop: Cop


func _bank(want := "roof") -> void:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != want:
		seed_ += 1
	bank = LEVEL.instantiate()
	bank.case_seed = seed_
	cop = bank.get_node("Cop")
	cop.input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)


func test_a_seventh_of_the_seeds_and_the_arg_forces_it() -> void:
	var roofs := 0
	for seed_ in range(1, 701):
		if BankLevel.variant(seed_, PackedStringArray()) == "roof":
			roofs += 1
	assert_between(roofs, 70, 140)
	for seed_ in range(1, 20):
		assert_eq(BankLevel.variant(seed_, PackedStringArray(["--bank=roof"])), "roof")
	for seed_ in [1, 2, 3, 4]:
		assert_ne(BankLevel.variant(seed_, PackedStringArray()), "roof", "the old test seeds stay the same")


func test_the_others_have_no_helicopter() -> void:
	await _bank("base")
	assert_false(bank.roof)
	assert_null(bank.helicopter)
	assert_null(bank.nephew)


func test_the_helicopter_waits_on_the_roof() -> void:
	await _bank()
	assert_true(bank.roof)
	assert_not_null(bank.helicopter)
	await wait_physics_frames(20)
	var on := bank.to_local(bank.helicopter.global_position)
	assert_almost_eq(on.y, BankLevel.ROOF, 0.15, "it stands on the roof, not through it")
	assert_almost_eq(Vector2(on.x, on.z), Vector2(BankLevel.HELIPAD_AT.x, BankLevel.HELIPAD_AT.z), Vector2.ONE * 0.2,
		"on its helipad")
	assert_eq(bank.helicopter.mass, ToyHelicopter.KG)
	assert_gt(ToyHelicopter.KG, GameScale.COP_CARRY_KG, "one cop alone only drags it")


func test_the_rotors_hum() -> void:
	await _bank()
	var rotor := bank.helicopter.find_child("rotor", true, false) as Node3D
	var before := rotor.rotation.y
	await wait_frames(5)
	assert_ne(rotor.rotation.y, before)


func test_the_fire_escape_takes_a_cop_up_to_the_roof() -> void:
	await _bank()
	var foot := BankLevel.ESCAPE_FOOT + Vector3(0, 0.3, 0.5)
	cop.global_position = bank.to_global(foot)
	await wait_physics_frames(5)
	# Walk up the flight toward -Z and onto the landing, then west onto the roof.
	for i in 140:
		cop.velocity = bank.global_basis * Vector3(0, cop.velocity.y, -GameScale.WALK_SPEED)
		cop.move_and_slide()
		await wait_physics_frames(1)
	var at := bank.to_local(cop.global_position)
	assert_gt(at.y, BankLevel.ROOF - 0.2, "up at the landing")
	for i in 90:
		cop.velocity = bank.global_basis * Vector3(-GameScale.WALK_SPEED, cop.velocity.y, 0)
		cop.move_and_slide()
		await wait_physics_frames(1)
	at = bank.to_local(cop.global_position)
	assert_lt(at.x, BankLevel.HALF_X - 2.0, "walked onto the roof")
	assert_gt(at.y, BankLevel.ROOF - 0.2, "standing on it")


func test_the_nephew_plays_across_the_street() -> void:
	await _bank()
	var at := bank.to_local(bank.nephew.global_position)
	assert_gt(at.z, BankLevel.HALF_Z + CityLayout.SIDEWALK + CityLayout.STREET, "on the sidewalk across")
	assert_eq(bank.nephew.prompt_key(cop), "PROMPT_TALK_NEPHEW")
	bank.nephew.use(cop)
	assert_eq(bank.nephew.said(), "NEPHEW_1")
	bank.nephew.use(cop)
	assert_eq(bank.nephew.said(), "NEPHEW_2")
