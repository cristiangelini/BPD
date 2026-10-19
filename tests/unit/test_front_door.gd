extends GutTest

## The grandpa's locked front door, the key pots and E to use things (docs/diseno/allanamiento.md).

const DOOR_SCENE := preload("res://scenes/props/front_door.tscn")
const POT_SCENE := preload("res://scenes/props/key_pot.tscn")
const COP_SCENE := preload("res://scenes/player/cop.tscn")
const HOUSE_SCENE := preload("res://scenes/levels/grandpa_house.tscn")


func _cop() -> Cop:
	var cop: Cop = COP_SCENE.instantiate()
	cop.input_enabled = false
	add_child_autofree(cop)
	return cop


func _door() -> FrontDoor:
	return add_child_autofree(DOOR_SCENE.instantiate())


func test_locked_door_needs_the_key() -> void:
	var door := _door()
	var cop := _cop()
	door.use(cop)
	assert_true(door.locked)
	assert_false(door.is_open)
	assert_eq(cop.get_node("Hud/Hint").text, "HINT_DOOR_LOCKED")


func test_only_the_drawn_pot_has_the_key() -> void:
	var cop := _cop()
	var empty: KeyPot = add_child_autofree(POT_SCENE.instantiate())
	var full: KeyPot = add_child_autofree(POT_SCENE.instantiate())
	full.has_key = true
	empty.use(cop)
	assert_false(cop.has_key)
	full.use(cop)
	assert_true(cop.has_key)
	assert_false(full.has_key, "the key is taken, not copied")


func test_key_unlocks_and_opens_the_door() -> void:
	var door := _door()
	var cop := _cop()
	cop.has_key = true
	watch_signals(door)
	door.use(cop)
	assert_false(door.locked)
	assert_true(door.is_open)
	assert_signal_emitted(door, "opened")
	await wait_seconds(FrontDoor.SWING_TIME + 0.1)
	assert_almost_eq(door.rotation.y, FrontDoor.SWING, 0.01)
	door.use(cop)
	assert_false(door.is_open, "using it again closes it")


func test_three_ram_hits_break_the_door() -> void:
	var door := _door()
	watch_signals(door)
	assert_false(door.ram_hit())
	assert_false(door.ram_hit())
	assert_true(door.ram_hit())
	assert_true(door.is_broken)
	assert_signal_emitted(door, "broken")
	assert_eq(door.get_node("Panel").collision_layer, 0, "the broken door no longer blocks the way")


func test_house_hides_the_key_in_one_pot() -> void:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.case_seed = 99
	house.get_node("Cop").input_enabled = false
	add_child_autofree(house)
	var with_key := house.pots.filter(func(p: KeyPot) -> bool: return p.has_key)
	assert_eq(with_key.size(), 1)
	assert_eq(with_key[0], house.pots[house.key_pot])


func test_cop_uses_the_door_in_front() -> void:
	var house: GrandpaHouse = HOUSE_SCENE.instantiate()
	house.case_seed = 99
	var cop: Cop = house.get_node("Cop")
	cop.input_enabled = false
	cop.position = Vector3(0, 0.1, 11.4)
	add_child_autofree(house)
	await wait_physics_frames(3)
	assert_true(cop.use(), "E reaches the door in front")
	assert_eq(cop.get_node("Hud/Hint").text, "HINT_DOOR_LOCKED")
