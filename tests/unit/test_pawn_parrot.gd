extends GutTest

## Chicharra at the pawn shop (allanamiento-empenos.md, step 4): the cookie jar gives each cop one cookie, and the
## parrot repeats what he heard for it, once per cop; without a cookie he only asks for one, and now and then he
## squawks.

const SCENE := preload("res://scenes/levels/pawn_shop.tscn")


func _shop() -> PawnShop:
	var place: PawnShop = SCENE.instantiate()
	place.case_seed = 5
	place.get_node("Cop").input_enabled = false
	place.get_node("Cop/Grabber").input_enabled = false
	add_child_autofree(place)
	place._turn_left = 1000.0
	return place


func test_the_jar_gives_each_cop_one_cookie() -> void:
	var place := _shop()
	await wait_physics_frames(1)
	var cop: Cop = place.get_node("Cop")
	var jar := place.cookie_jar
	assert_eq(jar.prompt_key(cop), "PROMPT_PAWN_COOKIE")
	jar.use(cop)
	assert_true(jar.has_cookie(cop))
	assert_eq(jar.prompt_key(cop), "", "one per cop")
	jar.eat(cop)
	jar.use(cop)
	assert_false(jar.has_cookie(cop), "no second cookie")


func test_without_a_cookie_he_only_asks_for_one() -> void:
	var place := _shop()
	await wait_physics_frames(1)
	var cop: Cop = place.get_node("Cop")
	var parrot := place.parrot
	parrot.clue = "the clue"
	parrot.clue_speech = "the speech"
	watch_signals(parrot)
	assert_eq(parrot.prompt_key(cop), "PROMPT_PAWN_PARROT")
	parrot.use(cop)
	assert_eq(parrot.said(), "PARROT_WANTS_COOKIE")
	assert_signal_not_emitted(parrot, "told")


func test_for_a_cookie_he_tells_what_he_heard_once_per_cop() -> void:
	var place := _shop()
	await wait_physics_frames(1)
	var cop: Cop = place.get_node("Cop")
	var parrot := place.parrot
	parrot.clue = "the clue"
	parrot.clue_speech = "the speech"
	watch_signals(parrot)
	place.cookie_jar.use(cop)
	assert_eq(parrot.prompt_key(cop), "PROMPT_PAWN_PARROT_FEED")
	parrot.use(cop)
	assert_signal_emitted_with_parameters(parrot, "told", ["the clue"])
	assert_eq(parrot.said(), "the speech")
	assert_false(place.cookie_jar.has_cookie(cop), "he ate it")
	assert_eq(parrot.prompt_key(cop), "", "once per cop")
	parrot.use(cop)
	assert_signal_emit_count(parrot, "told", 1)


func test_with_no_story_he_says_nothing_useful() -> void:
	var place := _shop()
	await wait_physics_frames(1)
	var cop: Cop = place.get_node("Cop")
	place.cookie_jar.use(cop)
	place.parrot.use(cop)
	assert_eq(place.parrot.said(), "PARROT_NOTHING")


func test_he_squawks_now_and_then() -> void:
	var place := _shop()
	await wait_physics_frames(1)
	place.parrot._squawk_left = 0.05
	await wait_physics_frames(5)
	assert_eq(place.parrot.said(), "PARROT_SQUAWK_1")


func test_a_cop_by_the_counter_reaches_the_cage_and_the_jar() -> void:
	var place := _shop()
	await wait_physics_frames(2)
	var cop: Cop = place.get_node("Cop")
	cop.global_position = place.to_global(Vector3(9.2, PawnShop.FLOOR_TOP + 0.1, 3.4))
	await wait_physics_frames(10)
	var head: Node3D = cop.get_node("Head")
	head.look_at(place.parrot.global_position + Vector3.DOWN * 0.4)
	await wait_physics_frames(2)
	assert_eq(cop.aim_hit(GameScale.GRAB_REACH).get("collider"), place.parrot, "the cage is in reach")
