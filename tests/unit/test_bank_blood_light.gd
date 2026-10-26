extends GutTest

## The blood bank's light (robo-banco-sangre.md, step 2, decision 128): a vampire in a flashlight's beam hides behind
## his cape, blind and still, and only then can he be cuffed from the front; the fuse box brings the bank's light back
## for a while, every vampire hides once and puts his sunglasses on, and El Conde has it cut again.

const LEVEL := preload("res://scenes/levels/bank.tscn")

var bank: BankLevel
var cop: Cop


func before_each() -> void:
	var seed_ := 1
	while BankLevel.variant(seed_, PackedStringArray()) != "blood":
		seed_ += 1
	bank = LEVEL.instantiate()
	bank.case_seed = seed_
	bank.get_node("Cop").input_enabled = false
	add_child_autofree(bank)
	await wait_physics_frames(2)
	cop = bank.get_node("Cop")


func _robber(animal: String) -> BankRobber:
	for robber in bank.robbers:
		if robber.animal == animal:
			return robber
	return null


## The cop `away` meters in front of the robber, looking at his face.
func _face(robber: BankRobber, away: float) -> void:
	var front := robber.global_position + robber.facing() * away
	cop.global_position = front
	cop.look_at(Vector3(robber.global_position.x, cop.global_position.y, robber.global_position.z), Vector3.UP)
	await wait_physics_frames(2)


func test_the_flashlight_makes_him_hide_behind_his_cape() -> void:
	var oso := _robber("oso")
	await _face(oso, 4.0)
	assert_false(oso.is_hiding())
	cop.belt.flashlight.toggle()
	await wait_until(func() -> bool: return oso.is_hiding(), 2.0)
	assert_true(oso.is_hiding(), "he hides from the light")
	assert_true(oso.find_child("CapeUp", true, false).visible, "behind his cape")
	assert_string_starts_with(oso.said(), "ROBBER_VAMPIRE_LIGHT_")
	assert_false(oso.sees_cop(cop), "and sees nothing")


func test_from_the_front_only_the_hidden_one_is_cuffed() -> void:
	var oso := _robber("oso")
	await _face(oso, 1.5)
	oso.cuffed(Handcuffs.SECONDS)
	assert_false(oso.is_cuffed(), "he sees the cuffs coming")
	cop.belt.flashlight.toggle()
	await wait_until(func() -> bool: return oso.is_hiding(), 2.0)
	oso.cuffed(Handcuffs.SECONDS)
	assert_true(oso.is_cuffed(), "behind his cape he doesn't")


func test_the_beam_only_where_it_points() -> void:
	var oso := _robber("oso")
	await _face(oso, 4.0)
	cop.rotate_y(PI)
	cop.belt.flashlight.toggle()
	await wait_physics_frames(15)
	assert_false(oso.is_hiding(), "the light points away")


func test_hiding_he_doesnt_spot_anyone() -> void:
	var conejo := _robber("conejo")
	conejo.lit()
	await _face(conejo, 1.2)
	await wait_physics_frames(10)
	assert_false(conejo.surrendered, "the rabbit didn't see the cop")
	conejo.hiding_left = 0.0
	await wait_physics_frames(5)
	assert_true(conejo.surrendered, "now he does")


func test_the_fuse_box_brings_the_light_back_once() -> void:
	assert_eq(bank.blood_bank.fuse_box.prompt_key(cop), "PROMPT_BANK_LIGHTS")
	bank.blood_bank.fuse_box.use(cop)
	assert_true(bank.blood_bank.lights_on())
	for lamp in bank.lamps:
		assert_true(lamp.visible, "the lamps are on")
	assert_eq(bank.blood_bank.fuse_box.prompt_key(cop), "", "nothing to do while it's on")
	for robber in bank.robbers:
		assert_true(robber.is_hiding(), robber.animal + " hides once")
		assert_true(robber.shades)
		robber.hiding_left = 0.0
	await wait_process_frames(3)
	for robber in bank.robbers:
		robber.lit(true)
		assert_false(robber.is_hiding(), robber.animal + " has his sunglasses on now")
		assert_true(robber.find_child("Shades", true, false).visible)


func test_el_conde_has_the_light_cut_again() -> void:
	bank.blood_bank.turn_lights(true)
	bank.blood_bank.lights_left = 0.05
	await wait_physics_frames(10)
	assert_false(bank.blood_bank.lights_on())
	for lamp in bank.lamps:
		assert_false(lamp.visible, "dark again")
	assert_eq(bank.boss.said(), "ROBBER_CONDE_CUT")
