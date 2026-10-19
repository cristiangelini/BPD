extends GutTest

## Dropping the ram and the key prompts under the crosshair (playtest 19/10).

const COP_SCENE := preload("res://scenes/player/cop.tscn")
const POT_SCENE := preload("res://scenes/props/key_pot.tscn")
const CRATE_SCENE := preload("res://scenes/props/crate.tscn")


func _cop() -> Cop:
	var cop: Cop = COP_SCENE.instantiate()
	cop.input_enabled = false
	add_child_autofree(cop)
	return cop


func test_g_drops_the_ram_and_e_takes_it_again() -> void:
	var cop := _cop()
	cop.equip_ram()
	var pickup := cop.drop_ram()
	autofree(pickup)
	assert_null(cop.ram)
	assert_not_null(pickup)
	assert_almost_eq(pickup.global_position.distance_to(cop.global_position), Cop.DROP_AHEAD, 0.01, "lands in front")
	assert_eq(pickup.prompt_key(cop), "PROMPT_TAKE_RAM")
	pickup.use(cop)
	assert_not_null(cop.ram)
	assert_null(_cop().drop_ram(), "nothing to drop without a ram")


func test_prompt_follows_what_the_cop_looks_at() -> void:
	var cop := _cop()
	var pot: KeyPot = POT_SCENE.instantiate()
	add_child_autofree(pot)
	pot.global_position = cop.camera.global_position + Vector3(0, -0.4, -1.5)
	cop.look(Vector2(0, 0.25))
	await wait_physics_frames(2)
	assert_eq(cop.current_prompt(), "PROMPT_POT")
	cop.equip_ram()
	assert_eq(cop.current_prompt(), "PROMPT_RAM", "what's in hand comes first")


func test_prompt_for_grabbing_and_holding() -> void:
	var cop := _cop()
	var crate: Grabbable = CRATE_SCENE.instantiate()
	crate.gravity_scale = 0.0
	add_child_autofree(crate)
	crate.global_position = cop.camera.global_position + Vector3(0, 0, -1.5)
	await wait_physics_frames(2)
	assert_eq(cop.current_prompt(), "PROMPT_GRAB")
	assert_true(cop.get_node("Grabber").try_grab())
	assert_eq(cop.current_prompt(), "PROMPT_HOLDING")


func test_nothing_in_front_shows_no_prompt() -> void:
	var cop := _cop()
	await wait_physics_frames(1)
	assert_eq(cop.current_prompt(), "")
