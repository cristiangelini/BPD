extends GutTest

## Bigotes steals (escena-acuario.md, step 6a): what a cop leaves on the floor near him, or holds standing still near
## him for 3 s, goes on his nose and nobody can take it off; a fish from the kitchen counter gets it back, and Don
## Anzuelo is moved (SeaLion, AquariumFish, AquariumKeeper).

const COP_SCENE := preload("res://scenes/player/cop.tscn")
const SPOT := Vector3(-6.5, Aquarium.FLOOR_TOP, 0.5)


## The aquarium with Bigotes sitting still at SPOT.
func _aquarium() -> Aquarium:
	var aquarium := Aquarium.new()
	add_child_autofree(aquarium)
	aquarium.sea_lion.waddling = false
	aquarium.sea_lion.position = SPOT
	return aquarium


## A crab a cop already held, lying on the floor at `local`.
func _dropped_crab(aquarium: Aquarium, local: Vector3) -> AquariumCrab:
	var crab := AquariumCrab.new()
	aquarium.add_child(crab)
	crab.position = local
	crab.was_held = true
	return crab


func test_he_takes_what_is_left_on_the_floor_near_him() -> void:
	var aquarium := _aquarium()
	var far := _dropped_crab(aquarium, SPOT + Vector3(0, 0.02, 4))
	var near := _dropped_crab(aquarium, SPOT + Vector3(1, 0.02, 0))
	await wait_physics_frames(20)
	var sea_lion := aquarium.sea_lion
	assert_eq(sea_lion.carried, near)
	assert_eq(sea_lion.said(), "SEA_LION_STOLE")
	assert_true(near.freeze)
	assert_eq(near.collision_layer, 0, "on his nose nobody can grab it")
	assert_gt(near.global_position.y, sea_lion.global_position.y + 0.8, "up on his nose")
	assert_false(far.freeze, "the far one stays")


func test_he_takes_it_from_a_cop_standing_still() -> void:
	var aquarium := _aquarium()
	var sea_lion := aquarium.sea_lion
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	cop.global_position = aquarium.to_global(SPOT + Vector3(1.2, 0, 0))
	var crab := AquariumCrab.new()
	add_child_autofree(crab)
	var grabber: Grabber = cop.get_node("Grabber")
	grabber.grab(crab)
	sea_lion._watch_hands(SeaLion.STILL_SECONDS - 0.5)
	assert_null(sea_lion.carried, "not yet")
	sea_lion._watch_hands(1.0)
	assert_eq(sea_lion.carried, crab)
	assert_null(grabber.held, "out of the cop's hands")


func test_a_fish_gets_it_back_and_he_rests() -> void:
	var aquarium := _aquarium()
	var sea_lion := aquarium.sea_lion
	var crab := _dropped_crab(aquarium, SPOT + Vector3(1, 0.02, 0))
	sea_lion.steal(crab)
	sea_lion.feed(null)
	assert_null(sea_lion.carried)
	assert_false(crab.freeze)
	assert_eq(crab.collision_layer, 4)
	assert_eq(sea_lion.said(), "SEA_LION_GIVES_BACK")
	await wait_physics_frames(40)
	assert_null(sea_lion.carried, "he rests before stealing again")
	assert_almost_eq(sea_lion.rest_left, SeaLion.REST, 1.0)


func test_a_fish_he_steals_he_eats() -> void:
	var aquarium := _aquarium()
	var fish := aquarium.get_node("Fish0") as AquariumFish
	aquarium.sea_lion.steal(fish)
	assert_null(aquarium.sea_lion.carried)
	assert_eq(aquarium.sea_lion.said(), "SEA_LION_YUM")
	assert_true(fish.is_queued_for_deletion())


func test_don_anzuelo_is_moved_when_he_sees_it() -> void:
	var aquarium := _aquarium()
	aquarium.sea_lion.feed(null)
	assert_ne(aquarium.keeper.said(), "KEEPER_FINALLY", "too far to see it")
	aquarium.sea_lion.position = Aquarium.KEEPER_AT + Vector3(2, Aquarium.FLOOR_TOP, 0)
	aquarium.sea_lion.feed(null)
	assert_eq(aquarium.keeper.said(), "KEEPER_FINALLY")


func test_the_kitchen_counter_has_fish_for_him() -> void:
	var aquarium := _aquarium()
	var fish := aquarium.find_children("Fish*", "AquariumFish", false, false)
	assert_eq(fish.size(), Aquarium.FISH)
	for one: AquariumFish in fish:
		assert_eq(aquarium.room(one.global_position), "kitchen")
	var cop: Cop = COP_SCENE.instantiate()
	add_child_autofree(cop)
	assert_eq((fish[0] as AquariumFish).held_prompt_key(cop), "PROMPT_HOLDING_FISH")
